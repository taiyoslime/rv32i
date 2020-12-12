`include "define.vh"

module write(
	input clk,
	input rst,
	input[31:0] pc_next,
	input write_pipeline_ctl_in,
	input is_load,
	input is_store,
	input reg_we,
	input [31:0] rs2,
	input [31:0] alu_result,
	input br_taken,
	input [4:0] rd_src,
	input [5:0] alucode,
	output logic [31:0] pc_next_out,
	output logic write_pipeline_ctl_out,
	output logic is_load_out,
	output logic is_store_out,
	output logic reg_we_out,
	output logic [31:0] rs2_out,
	output logic [31:0] alu_result_out,
	output logic br_taken_out,
	output logic [4:0] rd_src_out,
	output logic [5:0] alucode_out
	);
	
	
	
	assign is_load_out =  is_load;
	assign is_store_out = is_store;
	assign reg_we_out =  write_pipeline_ctl_in == '1 ? reg_we : 0;
	assign rs2_out = rs2;
	assign alu_result_out = alu_result;
	assign alucode_out = alucode;
	assign rd_src_out = write_pipeline_ctl_in == '1 ? rd_src : 0;
	
	always_ff @(negedge rst or posedge clk) begin
		if (!rst) begin
			 write_pipeline_ctl_out <= 0;
		end else begin
            if (write_pipeline_ctl_in) begin
            /*
            	is_load_out <= is_load;
                is_store_out <= is_store;
                reg_we_out <= reg_we;
                rs2_out <= rs2;
                alu_result_out <= alu_result;
                rd_src_out <= rd_src;
          */
               
                
                pc_next_out <= pc_next;
                br_taken_out <= br_taken;

            end
            if (br_taken_out) begin
            	 br_taken_out <= 0;
            end
        end
	end
endmodule
