//Questão das cancelas de um estacionamento 2

	logic[25:0] clock_atraso;
	always_ff @(posedge clk_2) begin
		clock_atraso <= clock_atraso + 1;
	end
	// No simulador não precisa disso
	parameter q0 = 0, q1 = 1, q2 = 2; 
	logic res, btnEntrada, btnSaida, cancelaEntradaAberta, cancelaSaidaAberta;
	logic [2:0] numCarros; 
	
	//Entradas
	always_comb begin
		res <= SWI[6];
		btnEntrada <= SWI[0];
		btnSaida <= SWI[1];
	end

	logic[3:0] state;

	//Loop-Máquina de estados
	always_ff @ (posedge clock_atraso[0]) begin
		if (res) begin
			state <= q0;
			numCarros <= 0;
			cancelaEntradaAberta <= 0;
			cancelaSaidaAberta <= 0;
		end
		else begin
			unique case (state)
				q0: begin
					if (btnEntrada && numCarros < 4) begin
						state <= q1;
						cancelaEntradaAberta <= 1;
					end
					else if (btnSaida && numCarros > 0) begin
						state <= q2;
						cancelaSaidaAberta <= 1;
					end
				end
				q1: if (!btnEntrada) begin
					state <= q0;
					numCarros <= numCarros + 1;
					cancelaEntradaAberta <= 0;
				end
				q2: if (!btnSaida) begin
					state <= q0;
					numCarros <= numCarros - 1;
					cancelaSaidaAberta <= 0;
				end
			endcase
		end
	end
	
	//Saídas
	always_comb begin
		LED[7] <= clock_atraso[0];
		LED[0] <= cancelaEntradaAberta;
		LED[1] <= cancelaSaidaAberta;
		
		unique case (numCarros)
			0: SEG[7:0] <= 'b00111111;
			1: SEG[7:0] <= 'b00000110;
			2: SEG[7:0] <= 'b01011011;
			3: SEG[7:0] <= 'b01001111;
			4: SEG[7:0] <= 'b01100110;
		endcase

	end