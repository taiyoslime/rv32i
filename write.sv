`include "define.vh"

module write(
	input logic clk,
	input logic rst,
	input logic [31:0] pc_next,
	input logic write_pipeline_ctl_in,
	output logic [31:0] pc,
	output logic write_pipeline_ctl_out
	);
	always_ff @(negedge rst or posedge clk) begin
		if (!rst) begin
			 write_pipeline_ctl_out <= 0;
		end
		if (write_pipeline_ctl_in) begin
			if (rst == '0) begin
				pc <= 'h08000;
			end else begin
				pc <= pc_next;
			end
			write_pipeline_ctl_out <= 1;
		end
	end
endmodule
