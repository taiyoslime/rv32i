`include "define.vh"

module execute(
	input logic clk,
	input logic rst,
	input logic [31:0] pc,
	input logic [5:0] alucode,
	input logic [1:0] aluop1_type,
	input logic [1:0] aluop2_type,
	input logic [31:0] rs1,
	input logic [31:0] rs2,
	input logic [31:0] imm,
	input logic [4:0] rd_src_de, //for fwd
	input logic exec_pipeline_ctl_in,
	input logic is_fwd_rs1,
	input logic is_fwd_rs2,
	input logic [31:0] fwd_val,
	output logic [31:0] pc_next,
	output logic [31:0] alu_result,
	output logic exec_pipeline_ctl_out,
	output logic [4:0] rd_src
	);

	logic [31:0] op1;
	logic [31:0] op2;

	logic br_taken;

	logic [31:0] alu_result_rg;

	alu alu(
		.alucode,
		.op1,
		.op2,
		.alu_result(alu_result_rg),
		.br_taken
	);


	always_latch begin
		case(aluop1_type)
			`OP_TYPE_REG: op1 = is_fwd_rs1 ? fwd_val : rs1;
			`OP_TYPE_IMM: op1 = imm;
			`OP_TYPE_PC: op1 = pc;
			default: ;
		endcase
		case(aluop2_type)
			`OP_TYPE_REG: op2 = is_fwd_rs2 ? fwd_val :rs2;
			`OP_TYPE_IMM: op2 = imm;
			`OP_TYPE_PC: op2 = pc;
			default: ;
		endcase
	end

	always_ff @(negedge rst or posedge clk) begin
		if (!rst) begin
			exec_pipeline_ctl_out <= 0;
		end
		if (exec_pipeline_ctl_in) begin
			alu_result <= alu_result_rg;
			if (br_taken == `ENABLE) begin
				pc_next <= alucode != `ALU_JALR ? pc + imm : rs1 + imm;
				exec_pipeline_ctl_out <= 1;
			end else begin
				pc_next <= pc + 32'b100;
			end
		end
		if (exec_pipeline_ctl_out) begin
			exec_pipeline_ctl_out <= 0;
		end
		rd_src <= rd_src_de;
	end

endmodule

