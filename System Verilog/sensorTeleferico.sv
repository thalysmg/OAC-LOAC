//Questão das cabines do teleférico
logic[25:0] clock_atraso;
	always_ff @(posedge clk_2) begin
		clock_atraso <= clock_atraso + 1;
	end


	parameter q0 = 0, q1 = 1, q2 = 2, q3 = 3, q4 = 4, q5 = 5, q6 = 6, q7 = 7, q8 = 8, q9 = 9, q10 = 10, q11 = 11, q12 = 12;
	logic res, a_pronta, b_pronta, perto_base, perto_topo, chegou_base, chegou_topo, lento, subir_A, subir_B, alarme, a_topo, b_topo;
	
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
		end
		else begin
			unique case (state)
			q0: begin
			    if (!chegou_base || !chegou_topo) begin  // se logo no início as 2 cabines não estiverem nas estações (base e topo), alarme ativado
					alarme <= 1;
					state <= q0;
				end
				else begin                               // caso contrário, alarme não é ativado, e vai pro próximo estado
					state <= q1;                       	
					alarme <= 0;
				end
				subir_A <= 0;
				subir_B <= 0;
			end
			q1: begin 
				if (chegou_base && chegou_topo && a_pronta && b_pronta && a_topo) begin          
					subir_B <= 1;                                                                   
					subir_A <= 0;
					state <= q2;
					alarme <= 0;
					lento <= 1;                                                                      // q1: Se ambos estiverem prontos nas estações,
				end																				     // a cabine B sobe se A estiver no topo e vice-versa  
				else if (chegou_base && chegou_topo && a_pronta && b_pronta &&  b_topo) begin  
					subir_B <= 0;
					subir_A <= 1;
					state <= q2;
					alarme <= 0;
					lento <= 1;
				end
				
			end
			q2: state <= q3;             // q2 e q3: contagem dos 3 segundos
			q3: state <= q4;
			q4: begin
				if (perto_base || perto_topo) begin       // se um dos sensores estiver ligado, alarme é ativado e motor morre
					alarme <= 1;
					subir_A <= 0;
					subir_B <= 0;
					state <= q4;
				end
				else begin                                // senão, motor roda na velocidade normal (lento = 0)
					subir_A <= b_topo;
					subir_B <= a_topo;
					lento <= 0;
					alarme <= 0;
					state <= q5;
				end
			end
			q5: state <= q6;
			q6: state <= q7;                      // q5 - q8: contagem dos 5 segundos
			q7: state <= q8;
			q8: state <= q9;
			q9: begin
			    if (!perto_base || !perto_topo) begin    // se após 5 segundos, não estiverem perto da base, alarme é ativado e motor morre
					alarme <= 1;
					subir_A <= 0;
					subir_B <= 0;
				end
				else begin                              
					subir_A <= b_topo;                  // caso estejam perto da base, motor voltar a funcionar no modo lento e vai para o próximo estado
					subir_B <= a_topo;
					alarme <= 0;
					lento <= 1;
					state <= q10;
				end
			end
			q10: state <= q11;              //contagem de mais 3 segundos
			q11: state <= q12;                  
			q12: begin
				if (!chegou_base || !chegou_topo) begin     // se em 3 segundos, as cabines não tiverem chegado nas estações,
					alarme <= 1; 							// alarme é ativado e motores morrem
					subir_A <= 0;
					subir_B <= 0;
					state <= q12;
				end
				else begin
					subir_A <= b_topo;                      // caso contrário volta pro estado inicial,
					subir_B <= a_topo;					    // com as cabines começando em posições invertidas
					alarme <= 0; 
					state <= q0;
					if (a_topo) begin 
						a_topo <= 0;
						b_topo <= 1;
					end
					else begin 
						a_topo <= 1;
						b_topo <= 0;
					end
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