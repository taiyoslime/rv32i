`include "define.vh"

module forwarding(
	input logic clk,
	input logic rst,
	input logic [4:0] fwd_rd_src, //from exec
	input logic [31:0] fwd_rd,  //from exec
	input logic [4:0] fwd_rs1_src, //from decode
	input logic [4:0] fwd_rs2_src, //from decode
	output logic is_fwd_rs1,
	output logic is_fwd_rs2,
	output logic [31:0] fwd_val
	);

	logic [4:0] fwd_rd_src_rg, fwd_rs1_src_rg, fwd_rs2_src_rg;
	logic [31:0] fwd_rd_rg;

	assign fwd_val = fwd_rd;
	assign is_fwd_rs1 = (fwd_rd_src == fwd_rs1_src && fwd_rs1_src != '0 ) ? 'b1 : 'b0;
	assign is_fwd_rs2 = (fwd_rd_src == fwd_rs2_src && fwd_rs1_src != '0) ? 'b1 : 'b0;

	//always_ff @(posedge clk) begin
		//fwd_rd_src_rg <= fwd_rd_src;
		//fwd_rd_rg <= fwd_rd;
		//fwd_rs1_src_rg <= fwd_rs1_src;
		//fwd_rs2_src_rg <= fwd_rs2_src;
	//end

endmodule
