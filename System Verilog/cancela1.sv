	logic[25:0] clock_atraso;
	always_ff @(posedge clk_2) begin
		clock_atraso <= clock_atraso + 1;
	end
	

	//questão das cancelas do estacionamento 1

	parameter q0 = 0, q1 = 1, q2 = 2, q3 = 3;
	logic cancelaEntrada, cancelaSaida, cancelaEntradaAberta, cancelaSaidaAberta, res;
	logic [6:3] numCarros;
	//Entradas
	always_comb begin
		cancelaEntrada <= SWI[0];
		cancelaSaida <= SWI[7];
		res <= SWI[1];
	end

	logic[3:0] state;

	//Máquina de Estados
	always_ff @ (posedge clk_2) begin
		if (res) begin
			state <= q0;
			numCarros <= 0;
			cancelaEntradaAberta <= 0;
			cancelaSaidaAberta <= 0;
		end
		else begin
			unique case (state)
				q0: begin
					if (cancelaEntrada && numCarros < 10) begin
						state <= q1;
						cancelaEntradaAberta <= 1;
					end
					else if (cancelaSaida && numCarros > 0) begin
						state <= q2;
						cancelaSaidaAberta <= 1;
					end
				end
				q1: if (!cancelaEntrada) begin
					numCarros <= numCarros + 1;
					state <= q0;
					cancelaEntradaAberta <= 0;
				end
				q2:	if (!cancelaSaida) begin
					numCarros <= numCarros - 1;
					state <= q0;
					cancelaSaidaAberta <= 0;
				end			
			endcase
		end
	end
	//Saídas
	always_comb begin
		LED[6:3] <= numCarros;
		LED[0] <= cancelaEntradaAberta;
		LED[1] <= cancelaSaidaAberta;
		LED[7] <= clk_2;
	end