`timescale 1ns / 1ps

`include "define.vh"

module fetch(
    input clk,
    input rst,
    input logic [31:0] pc,
    output logic [31:0] inst
    );
    
    logic [31:0] addr;
    assign addr = {pc[31:2], 2'b0};
    
    inst_mem inst_mem(
            .clk,
            .addr,
            .data(inst)
     );
endmodule
