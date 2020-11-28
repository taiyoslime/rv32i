`include "define.vh"

module core(
    input clk,
    input rst,
    output uart_tx
    );
    
    logic [31:0] pc;
    logic [31:0] inst;
    
    fetch fetch(
        .*
    );
    
    logic reg_we;
    
    logic [31:0] rs1;
    logic [31:0] rs2;
    logic [31:0] rd;
    logic [4:0] rs1_src;
    logic [4:0] rs2_src;
    logic [4:0] rd_src;

    regfile regrile(
        .*
    );
    
    logic [31:0] imm;
    logic [5:0] alucode;
    logic [1:0] aluop1_type;
    logic [1:0] aluop2_type;
    logic is_load;
    logic is_store;
    logic is_halt;
    
    decoder decoder(
        .*
    );
    
    
    logic [31:0] pc_next;
    logic [31:0] alu_result;
    
    execute execute(
        .*
    );
    
    logic [31:0] data_r;
    logic [31:0] data_w;
    assign data_w = rs2;
    logic [31:0] addr_w, addr_r;
    assign addr_w = alu_result;
    assign addr_r = alu_result;
    
    data_mem data_memt(
        .*
    );
    
    write write(
        .*
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
    
    assign uart_IN_data = data_w[7:0];  // ストアするデータをモジュールへ入力
    assign uart_we = ((addr_w == `UART_ADDR) && (is_store == `ENABLE)) ? 1'b1 : 1'b0;  // シリアル通信用アドレスへのストア命令実行時に送信開始信号をアサート
    assign uart_tx = uart_OUT_data;  // シリアル通信モジュールの出力はFPGA外部へと出力

    
    wire [31:0] hc_OUT_data;

    hardware_counter hardware_counter0(
        .CLK_IP(clk),
        .RSTN_IP(rst_n),
        .COUNTER_OP(hc_OUT_data)
    );
    
    assign rd = ((alucode == `ALU_LW) && (addr_w == `HARDWARE_COUNTER_ADDR)) ? hc_OUT_data : is_load == `ENABLE ? data_r : alu_result;

endmodule
