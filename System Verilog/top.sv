// DESCRIPTION: Verilator: Systemverilog example module
// with interface to switch buttons, LEDs, LCD and register display

parameter NINSTR_BITS = 32;
parameter NBITS_TOP = 8, NREGS_TOP = 32;
module top(input  logic clk_2,
           	input  logic [NBITS_TOP-1:0] SWI,
           	output logic [NBITS_TOP-1:0] LED,
           	output logic [NBITS_TOP-1:0] SEG,
           	output logic [NINSTR_BITS-1:0] lcd_instruction,
           	output logic [NBITS_TOP-1:0] lcd_registrador [0:NREGS_TOP-1],
           	output logic [NBITS_TOP-1:0] lcd_pc, lcd_SrcA, lcd_SrcB,
        	lcd_ALUResult, lcd_Result, lcd_WriteData, lcd_ReadData, 
          	output logic lcd_MemWrite, lcd_Branch, lcd_MemtoReg, lcd_RegWrite
		);

	always_comb begin
		// LED <= SWI;
		// SEG <= SWI;
		lcd_WriteData <= SWI;
		lcd_pc <= 'h12;
		lcd_instruction <= 'h34567890;
		lcd_SrcA <= 'hab;
		lcd_SrcB <= 'hcd;
		lcd_ALUResult <= 'hef;
		lcd_Result <= 'h11;
		lcd_ReadData <= 'h33;
		// lcd_MemWrite <= SWI[0];
		// lcd_Branch <= SWI[1];
		// lcd_MemtoReg <= SWI[2];
		// lcd_RegWrite <= SWI[3];
	end