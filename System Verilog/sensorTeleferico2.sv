logic[25:0] clock_atraso;
always_ff @(posedge clk_2) begin
    clock_atraso <= clock_atraso + 1;
end


parameter q0 = 0, q1 = 1, q2 = 2, q3 = 3, q4 = 4;
logic res, a_pronta, b_pronta, perto_base, perto_topo, chegou_base, chegou_topo, lento, subir_A, subir_B, alarme, a_topo, b_topo;
logic perto_de_parar;
logic [2:0] tempo_de_falha;
//Entradas
always_comb begin
    res <= SWI[7];
    a_pronta <= SWI[0];
    b_pronta <= SWI[1];
    perto_base <= SWI[2];
    perto_topo <= SWI[3];
    chegou_base <= SWI[4];
    chegou_topo <= SWI[5];
end

logic[4:0] state;

//Loop-Máquina de estados
always_ff @ (posedge clock_atraso[1]) begin
    if (res) begin
        state <= q0;
        lento <= 1;
        alarme <= 0;
        subir_A <= 0;
        subir_B <= 0;
        a_topo <= 1;
        b_topo <= 0;
        tempo_de_falha <= 1;
        perto_de_parar <= 0;
    end
    else begin
        unique case (state)
            q0: begin // Cabinas paradas nas estações
                subir_A <= 0;
                subir_B <= 0;
                if (!chegou_base || !chegou_topo) begin 
                    alarme <= 1;
                    state <= q0;
                end
                else if (chegou_base && chegou_topo && a_pronta && b_pronta && a_topo) begin 
                    subir_B <= 1;
                    subir_A <= 0;
                    state <= q1;
                end
                else if (chegou_base && chegou_topo && a_pronta && b_pronta && b_topo) begin 
                    subir_B <= 0;
                    subir_A <= 1;
                    state <= q1;
                end
            end
            q1: begin // Cabines movendo com motor lento
                subir_A <= b_topo;
                subir_B <= a_topo;
                lento <= 1;
                if (perto_base || perto_topo) begin 
                    if (tempo_de_falha == 3) begin 
                        alarme <= 1;
                        tempo_de_falha <= 1;
                        state <= q2;
                    end
                    tempo_de_falha <= tempo_de_falha + 1;
                end
                else if (!perto_base && !perto_topo) begin 
                    state <= q3;
                end
            end
            q2: begin // Cabines parada devido ao alarme
                subir_A <= 0;
                subir_B <= 0;
                if (!perto_base && !perto_topo) begin 
                    lento <= 0;
                    state <= q3;
                    alarme <= 0;
                end
                else if (perto_base && perto_topo) begin 
                    lento <= 1;
                    if (perto_de_parar) begin 
                        alarme <= 0;
                        state <= q4;
                    end
                    else begin
                        alarme <= 0;
                        state <= q1;
                    end
                    
                end
            end
            q3: begin //cabines movendo com motor normal
                subir_A <= b_topo;
                subir_B <= a_topo;
                lento <= 0;
                if (!perto_base || !perto_topo) begin 
                    if (tempo_de_falha == 5) begin
                        tempo_de_falha <= 1;
                        alarme <= 1;
                        state <= q2;
                    end
                    tempo_de_falha <= tempo_de_falha + 1;
                end
                else begin 
                    state <= q4;
                end
            end
            q4: begin // Perto das estações com motor lento e prestes a parar
                subir_A <= b_topo;
                subir_B <= a_topo;
                lento <= 1;
                if (!chegou_base || !chegou_topo) begin 
                    if (tempo_de_falha == 3) begin 
                        tempo_de_falha <= 1;
                        alarme <= 1;
                        state <= q2;
                    end
                    tempo_de_falha <= tempo_de_falha + 1;
                end
                else begin
                    b_topo <= !b_topo;
                    a_topo <= !a_topo;
                    state <= q0;
                end
            end
        endcase
    end
end

//Saídas
always_comb begin
    SEG[0] <= subir_A;
    SEG[3] <= subir_B;
    LED[0] <= lento;
    LED[7] <= alarme;
    SEG[7] <= clock_atraso[1];
end