`timescale 1ns / 1ps

`include "define.h"

module fetch(
    input clk,
    input rst,
    input [31:0] pc,
    output [31:0] inst
    );
    
    logic [31:0] mem[0:'h1000]; //TODO
    
    assign inst = mem[pc << 2];
    
    initial begin
        $readmemh("", mem);
    end
    
    always @(posedge clk) begin
        // pcを何らかの形で接続する必要はあるかも？
    end
    
endmodule
