`timescale 1ns / 1ps

`include "define.vh"

module write(
	input clk,
	input rst,
	input logic [31:0] pc_next,
	output logic [31:0] pc
    );
	always @(negedge rst or posedge clk) begin
		if (rst == '0) begin
			pc <= 'h08000;
		end else begin
			pc <= pc_next;
		end
	end
endmodule
