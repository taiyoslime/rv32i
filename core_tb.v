module core_tb;
    reg sysclk;
    reg cpu_resetn;
    wire uart_tx;

    parameter CYCLE = 100;

    always #(CYCLE/2) sysclk = ~sysclk;

    core core0(
       .clk(sysclk),
       .rst(cpu_resetn),
       .uart_tx(uart_tx)
    );

    initial begin
        #10     sysclk     = 1'd0;
                cpu_resetn    = 1'd0;
        #(CYCLE) cpu_resetn = 1'd1;
        #(100000000000000) $finish;
    end
endmodule
