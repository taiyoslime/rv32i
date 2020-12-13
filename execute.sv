`include "define.vh"

module execute(
	input clk,
	input rst,
	input [31:0] pc,
	input [5:0] alucode,
	input [1:0] aluop1_type,
	input [1:0] aluop2_type,
	input [31:0] rs1,
	input  [31:0] rs2,
	input [31:0] imm,
	input [4:0] rd_src_de, //for fwd
	input exec_pipeline_ctl_in,
	input is_fwd_rs1,
	input is_fwd_rs2,
	input [31:0] fwd_val,
	input is_load,
	input is_store,
	input reg_we,
	output logic [31:0] pc_next,
	output logic [31:0] alu_result,
	output logic exec_pipeline_ctl_out,
	output logic [4:0] rd_src_out,
	output logic is_load_out,
	output logic is_store_out,
	output logic reg_we_out,
	output logic br_taken_out,
	output logic [31:0] rs2_out,
	output logic [31:0] op1,
	output logic [31:0] op2,
	output logic [31:0] alu_result_rg,
	output logic [5:0] alucode_out
	
	);

	//logic [31:0] op1;
	//logic [31:0] op2;
	
	

	logic br_taken;

	//logic [31:0] alu_result_rg;

	alu alu(
		.alucode,
		.op1,
		.op2,
		.alu_result(alu_result_rg),
		.br_taken
	);


	always_latch begin
	   		    if (pc == 'h80b8) begin
		      $display(is_fwd_rs2, is_load, is_store, fwd_val, rs2);
		    end
		case(aluop1_type)

			`OP_TYPE_REG: op1 = (is_fwd_rs1 && !is_load && !is_store) ? fwd_val : rs1;
			`OP_TYPE_IMM: op1 = imm;
			`OP_TYPE_PC: op1 = pc;
			default: ;
		endcase
		case(aluop2_type)
			`OP_TYPE_REG: op2 = (is_fwd_rs2 && !is_load && !is_store) ? fwd_val :rs2;
			`OP_TYPE_IMM: op2 = imm;
			`OP_TYPE_PC: op2 = pc;
			default: ;
		endcase
	end

	always_ff @(negedge rst or posedge clk) begin
		if (!rst) begin
			exec_pipeline_ctl_out <= 0;
		end else begin
            if (exec_pipeline_ctl_in) begin
                is_load_out <= is_load;
                is_store_out <= is_store;
                reg_we_out <= reg_we;
                rs2_out <= rs2;
                rd_src_out <= rd_src_de;
                br_taken_out <= br_taken;
                alu_result <= alu_result_rg;
                alucode_out <= alucode;
                if (br_taken == `ENABLE) begin
                    pc_next <= alucode != `ALU_JALR ? pc + imm : rs1 + imm;
                    exec_pipeline_ctl_out <= 1;
                end 
            end
            if (exec_pipeline_ctl_out) begin
                exec_pipeline_ctl_out <= 0;
            end           
        end
	end

endmodule

