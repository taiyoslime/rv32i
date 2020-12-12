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
	logic [4:0] rd_src, rd_src_de;

	logic [31:0] imm;
	logic [5:0] alucode;
	logic [1:0] aluop1_type;
	logic [1:0] aluop2_type;
	logic is_load;
	logic is_store;
	logic is_halt;
	logic [31:0] pc_next;
	logic [31:0] alu_result;

	logic [4:0] fwd_rd_src; //from exec
	logic [31:0] fwd_rd;  //from exec
	logic [4:0] fwd_rs1_src; //from decode
	logic [4:0] fwd_rs2_src; //from decode
	logic is_fwd_rs1;
	logic is_fwd_rs2;
	logic [31:0] fwd_val;

	logic [31:0] data_r;
	logic [31:0] data_w;
	logic [31:0] addr_w, addr_r;
	
	logic br_taken;

	wire [7:0] uart_IN_data;
	wire uart_we;
	wire uart_OUT_data;

	wire [31:0] hc_OUT_data;
	
	typedef enum logic[3:0] {PIPELINE_INIT, PIPELINE_RUN, PIPELINE_PAUSE, PIPELINE_WARMUP_1, PIPELINE_WARMUP_2, PIPELINE_WARMUP_3, PIPELINE_STALL_LOAD, PIPELINE_STALL_LOAD_2, PIPELINE_STALL_EXEC} pipeline_t;

	pipeline_t pipeline_status, pipeline_status_saved;

	logic fetch_pipeline_ctl_in, decode_pipeline_ctl_in, exec_pipeline_ctl_in, write_pipeline_ctl_in;
	logic fetch_pipeline_ctl_out, decode_pipeline_ctl_out, exec_pipeline_ctl_out, write_pipeline_ctl_out;

	assign fetch_pipeline_ctl_in = decode_pipeline_ctl_out ? 0 : (pipeline_status == PIPELINE_RUN || pipeline_status == PIPELINE_WARMUP_1 || pipeline_status == PIPELINE_WARMUP_2 || pipeline_status == PIPELINE_WARMUP_3 ) ? 'b1 : 'b0;
	assign decode_pipeline_ctl_in = decode_pipeline_ctl_out ? 0 : (pipeline_status == PIPELINE_RUN || pipeline_status == PIPELINE_WARMUP_2 || pipeline_status == PIPELINE_WARMUP_3 ) ? 'b1 : 'b0;
	assign exec_pipeline_ctl_in = decode_pipeline_ctl_out ? 1 : (pipeline_status == PIPELINE_RUN || pipeline_status == PIPELINE_WARMUP_3 /*|| pipeline_status == PIPELINE_STALL_LOAD*/) ? 'b1 : 'b0;
	assign write_pipeline_ctl_in =  decode_pipeline_ctl_out ? 1 :(pipeline_status == PIPELINE_RUN || pipeline_status == PIPELINE_STALL_LOAD || pipeline_status == PIPELINE_STALL_LOAD_2  /*|| pipeline_status == PIPELINE_STALL_EXEC*/) ? 'b1 : 'b0;


	always @(posedge clk or negedge rst) begin
		if(!rst) begin
			pipeline_status <= PIPELINE_WARMUP_1;
			pipeline_status_saved <= PIPELINE_WARMUP_1;
		end else begin
            if (exec_pipeline_ctl_out) begin
                pipeline_status <= PIPELINE_STALL_EXEC; // stall due to jump
            end else if (decode_pipeline_ctl_out) begin
                pipeline_status <= PIPELINE_STALL_LOAD; // stall due to load
            end else begin
                if (pipeline_status == PIPELINE_PAUSE) begin
                    pipeline_status <= pipeline_status_saved;
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
                else if(pipeline_status == PIPELINE_STALL_LOAD) begin
                    pipeline_status <= PIPELINE_STALL_LOAD_2;
                end
                else if(pipeline_status == PIPELINE_STALL_LOAD_2) begin
                    pipeline_status <= PIPELINE_RUN;
                end
                else if(pipeline_status == PIPELINE_STALL_EXEC) begin
                    pipeline_status <= PIPELINE_WARMUP_1;
                end
                else begin
                    pipeline_status <= PIPELINE_RUN;
                end
            end
        end
	end
	
	// seq
	always @(posedge clk or negedge rst) begin
		if(!rst) begin
			pc <= 'h8000;
		end else begin
			if (br_taken == `ENABLE) begin
				pc <= pc_next;
			end else if (decode_pipeline_ctl_out || pipeline_status == PIPELINE_STALL_LOAD || pipeline_status == PIPELINE_STALL_LOAD_2) begin
				pc <= pc;
			end else begin
				pc <= pc + 'h4;
			end
		end
	end
	

	logic [31:0] pc_fd;
	fetch fetch0(
		.pc_out(pc_fd),
		.*
	);

	regfile regfile0(
		.*
	);
	
	logic is_load_de;
	logic is_store_de;
	logic [31:0] pc_de;
	logic reg_we_de;
	logic [5:0] alucode_de;

	decoder decoder0(
		.pc(pc_fd),
		.rd_src(rd_src_de),
		.is_load(is_load_de),
		.is_store(is_store_de),
		.pc_out(pc_de),
		.reg_we(reg_we_de),
		.alucode(alucode_de),
		.*
	);
	
	logic is_load_ew, is_store_ew, reg_we_ew;
	logic [31:0] rs2_ew, alu_result_e, alu_result_ew, alu_result_ef, pc_next_ew;
	logic br_taken_ew;
	logic [4:0] rd_src_ew, rd_src_ef;
	logic [5:0] alucode_ew;
	
	logic [31:0] op1;
	logic [31:0] op2;
	logic [31:0] alu_result_rg;
	
	logic [4:0] rd_src_e_out;
	assign rd_src_ew = rd_src_e_out;
	assign rd_src_ef = rd_src_e_out;

	assign alu_result_ew = alu_result_e;
	assign alu_result_ef = alu_result_e;

	execute execute0(
		.pc(pc_de),
		.is_load(is_load_de),
		.is_store(is_store_de),
		.is_load_out(is_load_ew),
		.is_store_out(is_store_ew),
		.reg_we_out(reg_we_ew),
		.alu_result(alu_result_e),
		.rs2_out(rs2_ew),
		.reg_we(reg_we_de),
		.br_taken_out(br_taken_ew),
		.pc_next(pc_next_ew),
		.rd_src_out(rd_src_e_out),
		.alucode(alucode_de),
		.alucode_out(alucode_ew),
		.*
	);

	forwarding forwarding0(
		.fwd_rd_src(rd_src_ef),
		.fwd_rd(alu_result_ef),
		.fwd_rs1_src(rs1_src),
		.fwd_rs2_src(rs2_src),
		.*
	);
	
	data_mem data_mem0(
		.*
	);
	
	logic [31:0] rs2_w_out;

	write write0(
		.is_load(is_load_ew),
		.is_store(is_store_ew),
		.reg_we(reg_we_ew),
		.alu_result(alu_result_ew),
		.rs2(rs2_ew),
		.br_taken(br_taken_ew),
		.pc_next(pc_next_ew),
		.rd_src(rd_src_ew),
		.alucode(alucode_ew),
		
		.is_load_out(is_load),
		.is_store_out(is_store),
		.reg_we_out(reg_we),
		.alu_result_out(alu_result),
		.rs2_out(rs2_w_out),
		.br_taken_out(br_taken),
		.pc_next_out(pc_next),
		.rd_src_out(rd_src),
		.alucode_out(alucode),
		
		.*
	);

	uart uart0(
		.uart_tx(uart_OUT_data),
		.uart_wr_i(uart_we),
		.uart_dat_i(uart_IN_data),
		.sys_clk_i(clk),
		.sys_rstn_i(rst)
	);


	hardware_counter hardware_counter0(
		.CLK_IP(clk),
		.RSTN_IP(rst),
		.COUNTER_OP(hc_OUT_data)
	);

	assign data_w = rs2_w_out;
	assign addr_w = alu_result;
	assign addr_r = alu_result;
	
	
	assign uart_IN_data = data_w[7:0];
	assign uart_we = ((addr_w == `UART_ADDR) && (is_store == `ENABLE)) ? 1'b1 : 1'b0;
	assign uart_tx = uart_OUT_data;

	assign rd = ((alucode == `ALU_LW) && (addr_w == `HARDWARE_COUNTER_ADDR)) ? hc_OUT_data : is_load == `ENABLE ? data_r : alu_result;

endmodule
