`timescale 1ns / 1ps

module regfile(
    input clk,
    input rst,
    input [4:0] rd_src,
    input [31:0] rd,
    input [4:0] rs1_src,
    input [4:0] rs2_src,
    
    output [31:0] rs1,
    output [31:0] rs2
    );
    
    logic [31:0] register [0:31];
    
    assign rs1 = register[rs1_src];
    assign rs2 = register[rs2_src];
    
    initial begin
        register[5'b0] = 32'b0;
    end
    
endmodule
