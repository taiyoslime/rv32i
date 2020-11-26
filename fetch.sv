`timescale 1ns / 1ps

`include "define.h"

module fetch(
    input clk,
    input rst,
    input logic [31:0] pc,
    output logic [31:0] inst
    );

    inst_mem inst_mem(
            .clk,
            .addr,
            .data(inst)
        );

    logic addr [31:0];
    assign addr = pc << 2;

endmodule
