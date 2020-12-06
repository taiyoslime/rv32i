`include "define.vh"

module regfile(
    input logic clk,
    input logic reg_we,
    input logic [4:0] rd_src,
    input logic [31:0] rd,
    input logic [4:0] rs1_src,
    input logic [4:0] rs2_src,
    //input pe,
    
    output logic [31:0] rs1,
    output logic [31:0] rs2
    );
    integer i;

    logic [31:0] register [0:31];

    assign rs1 = register[rs1_src];
    assign rs2 = register[rs2_src];

    initial begin
        register[5'b0] = 32'b0;
    end

    always @(posedge clk) begin
        if (reg_we == `ENABLE && rd_src != 5'b0) begin
            register[rd_src] <= rd;
        end
        //if (pe) begin

        //   for (i = 0; i < 32; i++) begin
         //       $display("%h",  register[i]);
         //   end
         //    $display("----------");
        // end
    end


endmodule
