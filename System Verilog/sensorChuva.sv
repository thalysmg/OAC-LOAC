logic[25:0] clock_atraso;
	always_ff @(posedge clk_2) begin
		if (!SWI[7]) begin
			clock_atraso <= clock_atraso + 1;
		end
	end

	parameter q0 = 0, q1 = 1, q2 = 2; 
	logic res, gota1, gota2, gota3, gota4, gota5, gota6;
	logic [1:0] limpador;
	logic [1:0] sem_chuva;
	logic [1:0] chuva_fraca;
	logic [1:0] chuva_forte;
	logic[1:0] state;
	//Entradas
	always_comb begin
		gota1 <= SWI[0];
		gota2 <= SWI[1];
		gota3 <= SWI[2];
		gota4 <= SWI[3];
		gota5 <= SWI[4];
		gota6 <= SWI[5];
		res <= SWI[6];
	end

	//Loop-Máquina de estados
	always_ff @ (posedge clock_atraso[1]) begin
		if (res) begin
			sem_chuva <= 0;
			chuva_fraca <= 0;
			chuva_forte <= 0;
			limpador <= 0;
			state <= q0;
		end
		else begin
			unique case (state)
				q0: begin 
					if ((gota1 + gota2 + gota3 + gota4 + gota5 + gota6) >= 5) begin
						if (chuva_forte >= 2) begin 
							chuva_forte <= 0;
							limpador <= 2;
							state <= q2;
						end
						chuva_forte <= chuva_forte + 1;
						chuva_fraca <= 0;
						sem_chuva <= 0;
					end
					else if ((gota1 + gota2 + gota3 + gota4 + gota5 + gota6) >= 3) begin
						if (chuva_fraca >= 3) begin 
							chuva_fraca <= 0;
							limpador <= 1;
							state <= q1;
						end
						chuva_fraca <= chuva_fraca + 1;
						chuva_forte <= 0;
						sem_chuva <= 0;
					end
				end
				q1: begin 
					if ((gota1 + gota2 + gota3 + gota4 + gota5 + gota6) < 2) begin
						if (sem_chuva == 1) begin 
							limpador <= 0;
							sem_chuva <= 0;
							state <= q0;
						end
						sem_chuva <= sem_chuva + 1;
						chuva_forte <= 0;
						chuva_fraca <= 0;
					end
					else if ((gota1 + gota2 + gota3 + gota4 + gota5 + gota6) > 5) begin
						if (chuva_forte >= 2) begin 
							chuva_forte <= 0;
							limpador <= 2;
							state <= q2;
						end
						chuva_forte <= chuva_forte + 1;
						chuva_fraca <= 0;
						sem_chuva <= 0;
					end
				end
				q2: begin 
					if ((gota1 + gota2 + gota3 + gota4 + gota5 + gota6) < 4) begin 
						if (chuva_fraca == 1) begin
							chuva_fraca <= 0;
							limpador <= 1;
							state <= q1;
						end
						chuva_fraca <= chuva_fraca + 1;
						sem_chuva <= 0;
						chuva_forte <= 0;
					end
				end
			endcase
		end
	end
	
	//Saídas
	always_comb begin
		SEG[7] <= clock_atraso[1];
		LED[1:0] <= limpador;
	end