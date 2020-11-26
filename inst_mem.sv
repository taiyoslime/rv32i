`timescale 1ns / 1ps

`include "define.vh"

module inst_mem(
	input clk,
	input logic [4:0] addr
	output logic [31:0] data
	);

	reg [4:0] addr_reg;
	reg logic [31:0] mem [0:'h1000];

	initial $readmemh(`INST_MEM_FILE, mem);

	always @(posedge clk) begin
		addr_reg <= addr;
	end
	assign data = mem[addr_reg]; //TODO

endmodule;