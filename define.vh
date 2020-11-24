
`define ENABLE 1'b1
`define DISABLE 1'b0

//opcode
`define OP_OPIMM    7'b0010011
`define OP_OP   7'b0110011
`define OP_LUI  7'b0110111
`define OP_AUIPC    7'b0010111
`define OP_JAL  7'b1101111
`define OP_JALR 7'b1100111
`define OP_BRANCH   7'b1100011
`define OP_STORE    7'b0100011
`define OP_LOAD 7'b0000011

// ALUコード
`define ALU_LUI   6'd0
`define ALU_JAL   6'd1
`define ALU_JALR  6'd2
`define ALU_BEQ   6'd3
`define ALU_BNE   6'd4
`define ALU_BLT   6'd5
`define ALU_BGE   6'd6
`define ALU_BLTU  6'd7
`define ALU_BGEU  6'd8
`define ALU_LB    6'd9
`define ALU_LH    6'd10
`define ALU_LW    6'd11
`define ALU_LBU   6'd12
`define ALU_LHU   6'd13
`define ALU_SB    6'd14
`define ALU_SH    6'd15
`define ALU_SW    6'd16
`define ALU_ADD   6'd17
`define ALU_SUB   6'd18
`define ALU_SLT   6'd19
`define ALU_SLTU  6'd20
`define ALU_XOR   6'd21
`define ALU_OR    6'd22
`define ALU_AND   6'd23
`define ALU_SLL   6'd24
`define ALU_SRL   6'd25
`define ALU_SRA   6'd26
`define ALU_NOP   6'd63


`define OP_TYPE_NONE 2'd0
`define OP_TYPE_REG  2'd1
`define OP_TYPE_IMM  2'd2
`define OP_TYPE_PC   2'd3

// パイプラインステージ
`define IF_STAGE 3'd0
`define RR_STAGE 3'd1
`define EX_STAGE 3'd2
`define MA_STAGE 3'd3
`define RW_STAGE 3'd4

// address for hardware counter
`define HARDWARE_COUNTER_ADDR 32'hffffff00

// address for UART
`define UART_ADDR 32'hf6fff070