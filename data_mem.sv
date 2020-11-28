`include "define.vh"

module data_mem(
	input clk,
	input [5:0] alucode,
	input is_load,
	input is_store,
	input [31:0] addr_w, addr_r,
	input [31:0] data_w,
	output logic [31:0] data_r
	);

	logic [31:0] mem [0:'h80000];

	initial $readmemh(`DATA_MEM_FILE, mem);

	always @(posedge clk) begin
		if (is_load == `ENABLE) begin
			case(alucode)
				`ALU_SB: begin
					case(addr_w[1:0])
						2'b00: mem[addr_w >> 2][7:0] <= data_w[7:0];
						2'b01: mem[addr_w >> 2][15:8] <= data_w[7:0];
						2'b10: mem[addr_w >> 2][23:16] <= data_w[7:0];
						2'b11: mem[addr_w >> 2][31:24] <= data_w[7:0];
					endcase
				end
				`ALU_SH: begin
					case(addr_w[1:0])
						2'b00: mem[addr_w >> 2][15:0] <= data_w[15:0];
						2'b01: mem[addr_w >> 2][23:8] <= data_w[15:0];
						2'b10: mem[addr_w >> 2][31:16] <= data_w[15:0];
					endcase
				end
				`ALU_SW: begin
					mem[addr_w >> 2] <= data_w;
				end
			endcase
		end
		if (is_store == `ENABLE) begin
			case(alucode)
				`ALU_LB: begin
					case (addr_w[1:0])
						2'b00: data_r <= $signed(mem[addr_r >> 2][7:0]);
						2'b01: data_r <= $signed(mem[addr_r >> 2][15:8]);
						2'b10: data_r <= $signed(mem[addr_r >> 2][23:16]);
						2'b11: data_r <= $signed(mem[addr_r >> 2][31:24]);
					endcase

				end
				`ALU_LBU: begin
					case (addr_w[1:0])
					2'b00: data_r <= $unsigned(mem[addr_r >> 2][7:0]);
					2'b01: data_r <= $unsigned(mem[addr_r >> 2][15:8]);
					2'b10: data_r <= $unsigned(mem[addr_r >> 2][23:16]);
					2'b11: data_r <= $unsigned(mem[addr_r >> 2][31:24]);
					endcase
				end
				`ALU_LH: begin
					case (addr_w[1:0])
						2'b00: data_r <= $signed(mem[addr_r >> 2][15:0]);
						2'b01: data_r <= $signed(mem[addr_r >> 2][23:8]);
						2'b10: data_r <= $signed(mem[addr_r >> 2][31:16]);
					endcase

				end

				`ALU_LHU: begin
					case (addr_w[1:0])
					2'b00: data_r <= $unsigned(mem[addr_r >> 2][15:0]);
					2'b01: data_r <= $unsigned(mem[addr_r >> 2][23:8]);
					2'b10: data_r <= $unsigned(mem[addr_r >> 2][31:16]);
					endcase
				end
				`ALU_LW: begin
					data_r <= mem[addr_r >> 2];
				end
			endcase
		end

	end
endmodule
