`include "define.vh"

module execute(
    input logic clk,
    //input rst,
    input logic [31:0] pc,
    input logic [5:0] alucode,
    input logic [1:0] aluop1_type,
    input logic [1:0] aluop2_type,
    input logic [31:0] rs1,
    input logic [31:0] rs2,
    input logic [31:0] imm,
    output logic [31:0] pc_next,
    output logic [31:0] alu_result
    );

    logic [31:0] op1;
    logic [31:0] op2;

    logic br_taken;
    //assign op1 = aluop1_type == `OP_TYPE_REG ? rs1 : aluop1_type == `OP_TYPE_IMM ? imm : aluop1_type == `OP_TYPE_PC ? pc : '0;
    //assign op2 = aluop2_type == `OP_TYPE_REG ? rs2 : aluop2_type == `OP_TYPE_IMM ? imm : aluop2_type == `OP_TYPE_PC ? pc : '0;
    
    logic [31:0] alu_result_rg;
    
    alu alu(
        .alucode,
        .op1,
        .op2,
        .alu_result(alu_result_rg),
        .br_taken
    );
   

    always @(*) begin
        case(aluop1_type)
            `OP_TYPE_REG: op1 = rs1;
            `OP_TYPE_IMM: op1 = imm;
            `OP_TYPE_PC: op1 = pc;
            default: ;
        endcase
        case(aluop2_type)
            `OP_TYPE_REG: op2 = rs2;
            `OP_TYPE_IMM: op2 = imm;
            `OP_TYPE_PC: op2 = pc;
            default: ;
        endcase
    end
    
   always @(posedge clk) begin
        alu_result <= alu_result_rg;
        if (br_taken == `ENABLE) begin
            pc_next <= alucode != `ALU_JALR ? pc + imm : rs1 + imm;
        end else begin
            pc_next <= pc + 32'b100;
        end
   end

endmodule

