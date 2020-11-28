`include "define.vh"

module alu(
    input [5:0] alucode,      
    input [31:0] op1,
    input [31:0] op2,
    output logic [31:0] alu_result, 
    output logic br_taken 
    );
    
    always @(*) begin
    case (alucode)
    `ALU_ADD, `ALU_LB, `ALU_LH, `ALU_LW, `ALU_LBU, `ALU_LHU, `ALU_SB, `ALU_SH, `ALU_SW: begin
        alu_result <= op1 + op2;
        br_taken <= `DISABLE;
    end
    `ALU_SUB: begin
        alu_result <= op1 - op2;
        br_taken <= `DISABLE;
    end
    `ALU_SLL: begin
        alu_result <= op1 <<  op2[4:0]; // op2[4:0]
        br_taken <= `DISABLE;
    end
    `ALU_SLT: begin
        alu_result <= $signed(op1) < $signed(op2);
        br_taken <= `DISABLE;
    end
    `ALU_SLTU: begin
        alu_result <= $signed(op1) < $signed(op2);
        br_taken <= `DISABLE;
    end
    `ALU_XOR: begin
        alu_result <= op1 ^ op2;
        br_taken <= `DISABLE;
    end
    `ALU_SRL: begin
        alu_result <= op1 >> op2[4:0]; // op2[4:0]
        br_taken <= `DISABLE;
    end
    
    `ALU_SRA: begin
        alu_result <= $signed(op1) >>> $signed(op2[4:0]); // op2[4:0]
        br_taken <= `DISABLE;
    end
    
    `ALU_OR: begin
        alu_result <= op1 | op2;
        br_taken <= `DISABLE;
    end
    `ALU_AND: begin
        alu_result <= op1 & op2;
        br_taken <= `DISABLE;
    end
    `ALU_LUI: begin
        alu_result <= op2;
        br_taken <= `DISABLE;
    end
    `ALU_JAL: begin
        alu_result <= op2 + 32'h4;
        br_taken <= `ENABLE;
    end
    `ALU_JALR: begin
        alu_result <= op2 + 32'h4;
        br_taken <= `ENABLE;
    end
    `ALU_BEQ, `ALU_BNE, `ALU_BLT, `ALU_BGE, `ALU_BLTU, `ALU_BGEU: begin
        alu_result <= 32'b0;
        case (alucode)
            `ALU_BEQ: br_taken <= op1 == op2 ? `ENABLE : `DISABLE;
            `ALU_BNE: br_taken <= op1 == op2 ? `DISABLE : `ENABLE;
            `ALU_BLT: br_taken <= $signed(op1) < $signed(op2) ?  `ENABLE : `DISABLE;
            `ALU_BGE: br_taken <= $signed(op1) < $signed(op2) ? `DISABLE : `ENABLE;
            `ALU_BLTU: br_taken <= op1 < op2 ? `ENABLE : `DISABLE;
            `ALU_BGEU: br_taken <= op1 < op2 ?  `DISABLE : `ENABLE;
        endcase
    end
    endcase
    end

endmodule
