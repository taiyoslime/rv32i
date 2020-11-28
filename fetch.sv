`include "define.vh"

module fetch(
    input clk,
    input rst,
    input logic [31:0] pc,
    output logic [31:0] inst
    );
    
    //logic [31:0] addr;
    
    /*
    inst_mem inst_mem(
            .clk,
            .addr,
            .data(inst)
     );
     */
     
     logic [31:0] mem [0:'h10000];

	 initial $readmemh(`INST_MEM_FILE, mem);
	 logic [31:0] pc_r;
	 assign inst = mem[pc_r[31:2]];
     
     always @(negedge rst or posedge clk) begin
        if (rst == '0) begin
            // TODO
        end else begin
            pc_r <= pc;
        end
     end
endmodule
