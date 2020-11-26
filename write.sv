`timescale 1ns / 1ps

`include "define.vh"

module write(
	input clk,
	input rst,
	input logic [31:0] pc_next,
	output logic [31:0] pc
    );
	always @(negedge rest or posedge clk) begin
		if (rst == '0) begin
			pc <= 'h7ffc;
		end else begin
			pc <= npc;
		end
	end
endmodule
