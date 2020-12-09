`include "define.vh"

module fetch(
	input logic clk,
	input logic [31:0] pc,
	input logic fetch_pipeline_ctl_in,
	output logic [31:0] inst,
	output logic fetch_pipeline_ctl_out
	);

	//logic [31:0] addr;

	/*
	inst_mem inst_mem(
			.clk,
			.addr,
			.data(inst)
	);
	*/

	// instruction memory
	logic [31:0] mem [0:'h5fff];

	initial $readmemh(`INST_MEM_FILE, mem);
	logic [31:0] pc_r;
	assign inst = mem[pc_r[31:2]];

	always_ff @(posedge clk) begin
		if (fetch_pipeline_ctl_in) begin
			pc_r <= pc;
			pipeline_ctl <= 1;
		end
	end
endmodule
