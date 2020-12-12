`include "define.vh"

module fetch(
	input clk,
	input rst, 
	input  [31:0] pc,
	input fetch_pipeline_ctl_in,
	output logic [31:0] inst,
	output logic fetch_pipeline_ctl_out,
	output logic [31:0] pc_out
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
	assign inst = mem[pc_out[31:2]];

	always_ff @(negedge rst or posedge clk) begin
		if(!rst) begin
			fetch_pipeline_ctl_out <= 0;
		end else begin
            if (fetch_pipeline_ctl_in) begin
                pc_out <= pc;
            end
        end
	end
endmodule
