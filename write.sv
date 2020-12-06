`include "define.vh"

module write(
	input logic clk,
	input logic rst,
	input logic [31:0] pc_next,
	output logic [31:0] pc
	);
	always_ff @(negedge rst or posedge clk) begin
		if (rst == '0) begin
			pc <= 'h08000;
		end else begin
			pc <= pc_next;
		end
	end
endmodule
