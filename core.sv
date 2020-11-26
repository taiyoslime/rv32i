`timescale 1ns / 1ps

`include "define.vh"

module core(

    );


    wire [7:0] uart_IN_data;
    wire uart_we;
    wire uart_OUT_data;

    uart uart0(
        .uart_tx(uart_OUT_data),
        .uart_wr_i(uart_we),
        .uart_dat_i(uart_IN_data),
        .sys_clk_i(clk),
        .sys_rstn_i(rst_n)
    );
    
    wire [31:0] hc_OUT_data;

    hardware_counter hardware_counter0(
        .CLK_IP(clk),
        .RSTN_IP(rst_n),
        .COUNTER_OP(hc_OUT_data)
    );


endmodule
