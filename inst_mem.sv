`include "define.vh"

module inst_mem(
	input clk,
	input logic [31:0] addr,
	output logic [31:0] data
	);

	logic [31:0] addr_reg;
	logic [31:0] mem [0:'h10000];

	initial $readmemh(`INST_MEM_FILE, mem);

	always_ff @(posedge clk) begin
		addr_reg = addr;
	end
	assign data = mem[addr_reg]; //TODO

endmodule