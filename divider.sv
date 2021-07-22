`include "define.vh"

module divider (
	input logic [5:0] alucode,
	input logic [31:0] op1,
	input logic [31:0] op2,
	output logic [31:0] divider_result
	);
	
    // TODO マルチサイクル命令にする

	always_latch begin
		case (alucode)

		`ALU_DIV: begin
            if (op2 == 32'b0) divider_result = 32'hffffffff;
            else if (op1 == 32'h80000000 && op2 == 32'hffffffff) divider_result = op1;
            else divider_result = $signed(op1) / $signed(op2);
		end
		
		`ALU_DIVU: begin
            if (op2 == 32'b0) divider_result = 32'hffffffff;
            else divider_result = op1 / op2;
		end

		`ALU_REM: begin
            if (op2 == 32'b0) divider_result = op1;
            else if (op1 == 32'h80000000 && op2 == 32'hffffffff) divider_result = 32'b0;
            else divider_result = $signed(op1) % $signed(op2);
		end

		`ALU_REMU: begin
            if (op2 == 32'b0) divider_result = op1;
            else divider_result = op1 % op2;
		end

		endcase

	end

endmodule
