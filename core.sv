`include "define.vh"

module core(
	input logic clk,
	input logic rst,
	output uart_tx
	);

	logic [31:0] pc;
	logic [31:0] inst;

	logic reg_we;

	logic [31:0] rs1;
	logic [31:0] rs2;
	logic [31:0] rd;
	logic [4:0] rs1_src;
	logic [4:0] rs2_src;
	logic [4:0] rd_src;

	logic [31:0] imm;
	logic [5:0] alucode;
	logic [1:0] aluop1_type;
	logic [1:0] aluop2_type;
	logic is_load;
	logic is_store;
	logic is_halt;
	logic [31:0] pc_next;
	logic [31:0] alu_result;

	logic [31:0] data_r;
	logic [31:0] data_w;
	logic [31:0] addr_w, addr_r;

	wire [7:0] uart_IN_data;
	wire uart_we;
	wire uart_OUT_data;

	wire [31:0] hc_OUT_data;

	pipeline_t pipeline_status, pipeline_status_saved;

	logic fetch_pipeline_ctl_in, decode_pipeline_ctl_in, exec_pipeline_ctl_in, write_pipeline_ctl_in;
	logic fetch_pipeline_ctl_out, decode_pipeline_ctl_out, exec_pipeline_ctl_out, write_pipeline_ctl_out;

	assign fetch_pipeline_ctl_in = (pipeline_status == PIPELINE_RUN || pipeline_status == PIPELINE_WARMUP_1 || pipeline_status == PIPELINE_WARMUP_2 || pipeline_status == PIPELINE_WARMUP_3 ) ? 'b1 : 'b0;
	assign decode_pipeline_ctl_in = (pipeline_status == PIPELINE_RUN || pipeline_status == PIPELINE_WARMUP_2 || pipeline_status == PIPELINE_WARMUP_3 ) ? 'b1 : 'b0;
	assign exec_pipeline_ctl_in = (pipeline_status == PIPELINE_RUN || pipeline_status == PIPELINE_WARMUP_3 ) ? 'b1 : 'b0;
	assign write_pipeline_ctl_in = (pipeline_status == PIPELINE_RUN) ? 'b1 : 'b0;


	always @(posedge clk or negedge rst) begin
		if(!rst) begin
			pipeline_status <= PIPELINE_INIT;
			pipeline_status_prev <= PIPELINE_INIT;
			pipeline_status_saved <= PIPELINE_INIT;
		end
		if (!fetch_pipeline_ctl_out || !decode_pipeline_ctl_out || !exec_pipeline_ctl_out || !write_pipeline_ctl_out) begin
			pipeline_status <= PIPELINE_PAUSE;
			if (pipeline_status != PIPELINE_PAUSE) begin
				pipeline_status_saved <= pipeline_status;
			end
		end else begin
			if (pipeline_status == PIPELINE_PAUSE) begin
				pipeline_status <= pipeline_status_saved
			end
			else if(pipeline_status == PIPELINE_INIT) begin
				pipeline_status <= PIPELINE_WARMUP_1;
			end
			else if(pipeline_status == PIPELINE_WARMUP_1) begin
				pipeline_status <= PIPELINE_WARMUP_2;
			end
			else if(pipeline_status == PIPELINE_WARMUP_2) begin
				pipeline_status <= PIPELINE_WARMUP_3;
			end
			else if(pipeline_status == PIPELINE_WARMUP_3) begin
				pipeline_status <= PIPELINE_RUN;
			end
			else begin
				pipeline_status <= PIPELINE_RUN;
			end
		end
	end


	fetch fetch0(
		.*
	);

	regfile regfile0(
		.*
	);


	decoder decoder0(
		.*
	);

	execute execute0(
		.*
	);


	data_mem data_mem0(
		.*
	);

	write write0(
		.*
	);

	assign data_w = rs2;
	assign addr_w = alu_result;
	assign addr_r = alu_result;


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

	hardware_counter hardware_counter0(
		.CLK_IP(clk),
		.RSTN_IP(rst),
		.COUNTER_OP(hc_OUT_data)
	);

	assign rd = ((alucode == `ALU_LW) && (addr_w == `HARDWARE_COUNTER_ADDR)) ? hc_OUT_data : is_load == `ENABLE ? data_r : alu_result;

endmodule
