`include "define.vh"

module decoder(
	input logic clk,
	input logic rst,
	input logic [31:0] inst,
	input logic decode_pipeline_ctl_in,
	output logic [4:0] rs1_src,
	output logic [4:0] rs2_src,
	output logic [4:0] rd_src,
	output logic [31:0] imm,
	output logic [5:0] alucode,
	output logic [1:0] aluop1_type,
	output logic [1:0] aluop2_type,
	output logic reg_we,
	output logic is_load,
	output logic is_store,
	output logic is_halt,
	output logic decode_pipeline_ctl_out
	);

	always_ff @(negedge rst or posedge clk) begin
		if (!rst) begin
			decode_pipeline_ctl_out <= 0;
		end
		if (decode_pipeline_ctl_in) begin
			case(inst[6:0])
				`OP_OP: begin
					rs1_src <= inst[19:15];
					rs2_src <= inst[24:20];
					rd_src <= inst[11:7];
					imm <= 32'b0;
					case ({inst[31:25], inst[14:12]})
						10'b0000000000:  alucode <= `ALU_ADD;
						10'b0100000000: alucode <= `ALU_SUB;
						10'b0000000010: alucode <= `ALU_SLT;
						10'b0000000011: alucode <= `ALU_SLTU;
						10'b0000000100: alucode <= `ALU_XOR;
						10'b0000000110: alucode <= `ALU_OR;
						10'b0000000111: alucode <= `ALU_AND;
						10'b0000000001: alucode <= `ALU_SLL;
						10'b0000000101: alucode <= `ALU_SRL;
						10'b0100000101: alucode <= `ALU_SRA;
						default: alucode <= `ALU_NOP;
					endcase
					aluop1_type <= `OP_TYPE_REG;
					aluop2_type <= `OP_TYPE_REG;
					reg_we <= `ENABLE;
					is_load <= `DISABLE;
					is_store <= `DISABLE;
					is_halt <= `DISABLE;
				end
				`OP_OPIMM: begin
					rs1_src <= inst[19:15];
					rs2_src <= 5'b0;
					rd_src <= inst[11:7];

					case ({inst[31:25], inst[14:12]})
						10'b0000000001, 10'b0000000101, 10'b0100000101: begin
							imm <=  {{27'b0}, inst[24:20]};
							case ({inst[31:25], inst[14:12]})
								10'b0000000001: alucode <= `ALU_SLL;
								10'b0000000101: alucode <= `ALU_SRL;
								10'b0100000101: alucode <= `ALU_SRA;
								default: alucode <= `ALU_NOP;
							endcase
						 end
						 default: begin
							imm <= {{20{inst[31]}}, inst[31:20]};
							case (inst[14:12])
								3'b000: alucode <= `ALU_ADD;
								3'b010: alucode <= `ALU_SLT;
								3'b011: alucode <= `ALU_SLTU;
								3'b100: alucode <= `ALU_XOR;
								3'b110: alucode <= `ALU_OR;
								3'b111: alucode <= `ALU_AND;
								default: alucode <= `ALU_NOP;
							endcase
						 end
					endcase
					aluop1_type <= `OP_TYPE_REG;
					aluop2_type <= `OP_TYPE_IMM;
					reg_we <= `ENABLE;
					is_load <= `DISABLE;
					is_store <= `DISABLE;
					is_halt <= `DISABLE;
				end
				`OP_LUI: begin
					rs1_src <= 5'b0;
					rs2_src <= 5'b0;
					rd_src <= inst[11:7];
					imm <= {inst[31:12], 12'b0};
					alucode <= `ALU_LUI;
					aluop1_type <= `OP_TYPE_NONE;
					aluop2_type <= `OP_TYPE_IMM;
					reg_we <= `ENABLE;
					is_load <= `DISABLE;
					is_store <= `DISABLE;
					is_halt <= `DISABLE;
				end
				`OP_AUIPC: begin
					rs1_src <= 5'b0;
					rs2_src <= 5'b0;
					rd_src <= inst[11:7];
					imm <= {inst[31:12], 12'b0};
					alucode <= `ALU_ADD;
					aluop1_type <= `OP_TYPE_IMM;
					aluop2_type <= `OP_TYPE_PC;
					reg_we <= `ENABLE;
					is_load <= `DISABLE;
					is_store <= `DISABLE;
					is_halt <= `DISABLE;
				end
				`OP_JAL: begin
					rs1_src <= 5'b0;
					rs2_src <= 5'b0;
					rd_src <= inst[11:7];
					imm <= {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
					alucode <= `ALU_JAL;
					aluop1_type <= `OP_TYPE_NONE;
					aluop2_type <= `OP_TYPE_PC;
					reg_we <= inst[11:7] != 5'b0 ? `ENABLE : `DISABLE; // J
					is_load <= `DISABLE;
					is_store <= `DISABLE;
					is_halt <= `DISABLE;
				end
				`OP_JALR: begin
					rs1_src <= inst[19:15];
					rs2_src <= 5'b0;
					rd_src <= inst[11:7];
					imm <= {{20{inst[31]}}, inst[31:20]};
					alucode <= `ALU_JALR;
					aluop1_type <= `OP_TYPE_REG;
					aluop2_type <= `OP_TYPE_PC;
					reg_we <= inst[11:7] != 5'b0 ? `ENABLE : `DISABLE; // JR
					is_load <= `DISABLE;
					is_store <= `DISABLE;
					is_halt <= `DISABLE;
				end
				`OP_BRANCH: begin
					rs1_src <= inst[19:15];
					rs2_src <= inst[24:20];
					rd_src <= 5'b0;
					imm <= {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
					case (inst[14:12])
						3'b000: alucode <= `ALU_BEQ;
						3'b001: alucode <= `ALU_BNE;
						3'b100: alucode <= `ALU_BLT;
						3'b101: alucode <= `ALU_BGE;
						3'b110: alucode <= `ALU_BLTU;
						3'b111: alucode <= `ALU_BGEU;
						default: alucode <= `ALU_NOP;
					endcase
					aluop1_type <= `OP_TYPE_REG;
					aluop2_type <= `OP_TYPE_REG;
					reg_we <= `DISABLE;
					is_load <= `DISABLE;
					is_store <= `DISABLE;
					is_halt <= `DISABLE;
				end
				`OP_STORE: begin
					rs1_src <= inst[19:15];
					rs2_src <= inst[24:20];
					rd_src <= 5'b0;
					imm <= {{20{inst[31]}}, inst[31:25], inst[11:7]};
					case (inst[14:12])
						3'b000: alucode <= `ALU_SB;
						3'b001: alucode <= `ALU_SH;
						3'b010: alucode <= `ALU_SW;
						default: alucode <= `ALU_NOP;
					endcase
					aluop1_type <= `OP_TYPE_REG;
					aluop2_type <= `OP_TYPE_IMM;
					reg_we <= `DISABLE;
					is_load <= `DISABLE;
					is_store <= `ENABLE;
					is_halt <= `DISABLE;
				 end
				`OP_LOAD: begin
					rs1_src <= inst[19:15];
					rs2_src <= 5'b0;
					rd_src <= inst[11:7];
					imm <= {{20{inst[31]}}, inst[31:20]};
					case (inst[14:12])
						3'b000: alucode <= `ALU_LB;
						3'b001: alucode <= `ALU_LH;
						3'b010: alucode <= `ALU_LW;
						3'b100: alucode <= `ALU_LBU;
						3'b101: alucode <= `ALU_LHU;
						default: alucode <= `ALU_NOP;
					endcase
					aluop1_type <= `OP_TYPE_REG;
					aluop2_type <= `OP_TYPE_IMM;
					reg_we <= `ENABLE;
					is_load <= `ENABLE;
					is_store <= `DISABLE;
					is_halt <= `DISABLE;
					decode_pipeline_ctl_out <= 1;
				end
				default: ;

			endcase
		end
		if (decode_pipeline_ctl_out) begin
			decode_pipeline_ctl_out <= 0;
		end
	end
endmodule
