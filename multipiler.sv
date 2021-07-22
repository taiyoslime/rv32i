`include "define.vh"

module multipiler (
	input logic [5:0] alucode,
	input logic [31:0] op1,
	input logic [31:0] op2,
	output logic [31:0] multipiler_result
	);

    logic [63:0] mul_u;
    logic [63:0] mul_su;
    logic [63:0] mul_s;

    assign mul_u = op1 * op2;
    assign mul_su = $signed(op1) * $signed({1'b0, op2} );
    assign mul_s = $signed(op1) * $signed(op2);

	always_latch begin
		case (alucode)

		`ALU_MUL: begin
			multipiler_result = mul_u[31:0];
		end

		`ALU_MULH: begin
			multipiler_result = mul_s[63:32];
		end
		
		`ALU_MULSU: begin
			multipiler_result = mul_su[63:32];
		end

		`ALU_MULU: begin
			multipiler_result = mul_u[63:32];
		end

        default: begin
            multipiler_result = 32'b0;
        end

		endcase

	end

endmodule
