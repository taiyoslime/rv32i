`include "define.vh"

module alu(
	input logic [5:0] alucode,
	input logic [31:0] op1,
	input logic [31:0] op2,
	output logic [31:0] alu_result,
	output logic br_taken
	);

	logic [31:0] multipiler_result;
	logic [31:0] divider_result;

	multipiler multipiler(
		.alucode,
		.op1,
		.op2,
		.multipiler_result
	);

	divider divider(
		.alucode,
		.op1,
		.op2,
		.divider_result
	);

	always_latch begin
		case (alucode)
		`ALU_ADD, `ALU_LB, `ALU_LH, `ALU_LW, `ALU_LBU, `ALU_LHU, `ALU_SB, `ALU_SH, `ALU_SW: begin
			alu_result = op1 + op2;
			br_taken = `DISABLE;
		end
		`ALU_SUB: begin
			alu_result = op1 - op2;
			br_taken = `DISABLE;
		end
		`ALU_SLL: begin
			alu_result = op1 <<  op2[4:0]; // op2[4:0]
			br_taken = `DISABLE;
		end
		`ALU_SLT: begin
			alu_result = {31'b0, $signed(op1) < $signed(op2)};
			br_taken = `DISABLE;
		end
		`ALU_SLTU: begin
			alu_result = {31'b0, op1 < op2};
			br_taken = `DISABLE;
		end
		`ALU_XOR: begin
			alu_result = op1 ^ op2;
			br_taken = `DISABLE;
		end
		`ALU_SRL: begin
			alu_result = op1 >> op2[4:0]; // op2[4:0]
			br_taken = `DISABLE;
		end

		`ALU_SRA: begin
			alu_result = $signed(op1) >>> $signed(op2[4:0]); // op2[4:0]
			br_taken = `DISABLE;
		end

		`ALU_OR: begin
			alu_result = op1 | op2;
			br_taken = `DISABLE;
		end
		`ALU_AND: begin
			alu_result = op1 & op2;
			br_taken = `DISABLE;
		end
		`ALU_LUI: begin
			alu_result = op2;
			br_taken = `DISABLE;
		end
		`ALU_JAL: begin
			alu_result = op2 + 32'h4;
			br_taken = `ENABLE;
		end
		`ALU_JALR: begin
			alu_result = op2 + 32'h4;
			br_taken = `ENABLE;
		end
		`ALU_BEQ, `ALU_BNE, `ALU_BLT, `ALU_BGE, `ALU_BLTU, `ALU_BGEU: begin
			alu_result = 32'b0;
			case (alucode)
				`ALU_BEQ: br_taken = op1 == op2 ? `ENABLE : `DISABLE;
				`ALU_BNE: br_taken = op1 == op2 ? `DISABLE : `ENABLE;
				`ALU_BLT: br_taken = $signed(op1) < $signed(op2) ?  `ENABLE : `DISABLE;
				`ALU_BGE: br_taken = $signed(op1) < $signed(op2) ? `DISABLE : `ENABLE;
				`ALU_BLTU: br_taken = op1 < op2 ? `ENABLE : `DISABLE;
				`ALU_BGEU: br_taken = op1 < op2 ?  `DISABLE : `ENABLE;
				default: ;
			endcase
		end
	
		`ALU_MUL, `ALU_MULH, `ALU_MULSU, `ALU_MULU: begin
			alu_result = multipiler_result;
			br_taken = `DISABLE;
		end

		`ALU_DIV, `ALU_DIVU, `ALU_REM, `ALU_REMU: begin
			alu_result = divider_result;
			br_taken = `DISABLE;
		end

		default: ;
		endcase
	end

endmodule
