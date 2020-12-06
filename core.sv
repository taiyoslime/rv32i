`include "define.vh"

module core(
	input logic clk,
	input logic rst,
	output uart_tx
	);

	logic [4:0] pipeline_clk;

	initial begin
		pipeline_clk = 5'b10000;
	end

	logic [31:0] pc;
	logic [31:0] inst;

	always @(posedge clk or negedge rst) begin
		if(!rst) begin
			pipeline_clk <= 5'b10000;
		end else begin
			pipeline_clk <= pipeline_clk != 5'b10000 ? (pipeline_clk << 1) : 5'b00001;
		end
	end


	fetch fetch(
		.clk(pipeline_clk[0]),
		.*
	);

	logic reg_we;

	logic [31:0] rs1;
	logic [31:0] rs2;
	logic [31:0] rd;
	logic [4:0] rs1_src;
	logic [4:0] rs2_src;
	logic [4:0] rd_src;


	regfile regfile(
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
		.clk(pipeline_clk[1]),
		.*
	);


	logic [31:0] pc_next;
	logic [31:0] alu_result;

	execute execute(
		.clk(pipeline_clk[2]),
		.*
	);

	logic [31:0] data_r;
	logic [31:0] data_w;
	assign data_w = rs2;
	logic [31:0] addr_w, addr_r;
	assign addr_w = alu_result;
	assign addr_r = alu_result;

	data_mem data_mem(
		.clk(pipeline_clk[3]),
		.*
	);

	write write(
		.clk(pipeline_clk[4]),
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
		.sys_rstn_i(rst)
	);

	assign uart_IN_data = data_w[7:0];
	assign uart_we = ((addr_w == `UART_ADDR) && (is_store == `ENABLE)) ? 1'b1 : 1'b0;
	assign uart_tx = uart_OUT_data;


	wire [31:0] hc_OUT_data;

	hardware_counter hardware_counter0(
		.CLK_IP(clk),
		.RSTN_IP(rst),
		.COUNTER_OP(hc_OUT_data)
	);

	assign rd = ((alucode == `ALU_LW) && (addr_w == `HARDWARE_COUNTER_ADDR)) ? hc_OUT_data : is_load == `ENABLE ? data_r : alu_result;

endmodule
