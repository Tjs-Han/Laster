`timescale 1ns / 1ps

`include "tla2024_cmd_defines.v"

`define I2C_DIV_CLK 16'd1000

module i2c_master
(
	input					clk,
	input					rst_n,

	output reg			o_scl = 1'b1,
	inout					io_sda,

	input			[ 3:0]i_cmd,
	input			[15:0]i_data_in,
	output reg	[15:0]o_data_out,

	input					i_start,
	output reg			o_end = 1'b0,
	output reg			o_error = 1'b0
);

	localparam IDLE 			= 0;
	localparam START			= 1;
	localparam ADDR			= 2;
	localparam ACK				= 3;
	localparam DATA 			= 4;
	localparam STOP			= 5;
	localparam DONE			= 6;

	reg			[ 3:0]r_state = IDLE;
	reg					r_sda = 1'b1;
	reg 			[15:0]r_clk_cnt = 16'd0;
	reg			[ 5:0]r_bit_cnt = 6'd0;
	reg			[ 5:0]r_bit_size = 6'd0;
	reg					r_rw = 1'b0;
	reg					r_en = 1'b0;
	reg			[ 7:0]r_reg_ptr = 8'h00;

	assign io_sda = r_sda ? 1'bz : 1'b0;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			r_bit_size <= 6'd0;
			r_rw <= 1'b0;
			r_reg_ptr <= 8'h00;
		end
		else if (i_start == 1'b1) begin
			case(i_cmd)
				`SET_CFG_RP: begin
					r_bit_size <= 6'd20;
					r_rw <= 1'b0;
					r_reg_ptr <= 8'h01;
				end
				`SET_CONV_RP: begin
					r_bit_size <= 6'd20;
					r_rw <= 1'b0;
					r_reg_ptr <= 8'h00;
				end
				`SET_CFG_DATA: begin
					r_bit_size <= 6'd38;
					r_rw <= 1'b0;
					r_reg_ptr <= 8'h01;
				end
				`GET_CFG_DATA, `GET_CONV_DATA: begin
					r_bit_size <= 6'd29;
					r_rw <= 1'b1;
				end
				default: begin
					r_bit_size <= 6'd0;
					r_rw <= 1'b0;
					r_reg_ptr <= 8'h00;
				end
			endcase
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_en <= 1'b0;
		else if (r_state == IDLE || r_state == DONE)
			r_en <= 1'b0;
		else
			r_en <= 1'b1;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_clk_cnt <= 16'd0;
		else if (r_en == 1'b0)
			r_clk_cnt <= 16'd0;
		else if (r_en == 1'b1) begin
			if (r_clk_cnt >= `I2C_DIV_CLK - 16'd1)
				r_clk_cnt <= 16'd0;
			else
				r_clk_cnt <= r_clk_cnt + 16'd1;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_bit_cnt <= 6'd0;
		else if (r_en == 1'b0)
			r_bit_cnt <= 6'd0;
		else if (r_en == 1'b1) begin
			if (r_clk_cnt >= `I2C_DIV_CLK - 16'd1)
				r_bit_cnt <= r_bit_cnt + 6'd1;
		end
	end
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_end <= 1'b0;
		else if (r_state == DONE)
			o_end <= 1'b1;
		else
			o_end <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_scl <= 1'b1;
		else begin
			case(r_state)
				IDLE, DONE: begin
					o_scl <= 1'b1;
				end
				START: begin
					if (r_clk_cnt < (`I2C_DIV_CLK >> 1) - 16'd1)
						o_scl <= 1'b1;
					else
						o_scl <= 1'b0;
				end
				ADDR, ACK, DATA: begin
					if ((r_clk_cnt > (`I2C_DIV_CLK >> 2) - 16'd1) && (r_clk_cnt <= (`I2C_DIV_CLK >> 1) + (`I2C_DIV_CLK >> 2) - 16'd1))
						o_scl <= 1'b1;
					else
						o_scl <= 1'b0;
				end
				STOP: begin
					if (r_clk_cnt < (`I2C_DIV_CLK >> 1) - 16'd1)
						o_scl <= 1'b0;
					else
						o_scl <= 1'b1;
				end
			endcase
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_data_out <= 16'h0;
		else if (r_state == DATA && r_rw == 1'b1 && r_clk_cnt == (`I2C_DIV_CLK >> 1) - 16'd1) begin
			case(r_bit_cnt)
				10: o_data_out[15] <= io_sda;
				11: o_data_out[14] <= io_sda;
				12: o_data_out[13] <= io_sda;
				13: o_data_out[12] <= io_sda;
				14: o_data_out[11] <= io_sda;
				15: o_data_out[10] <= io_sda;
				16: o_data_out[9] <= io_sda;
				17: o_data_out[8] <= io_sda;

				19: o_data_out[7] <= io_sda;
				20: o_data_out[6] <= io_sda;
				21: o_data_out[5] <= io_sda;
				22: o_data_out[4] <= io_sda;
				23: o_data_out[3] <= io_sda;
				24: o_data_out[2] <= io_sda;
				25: o_data_out[1] <= io_sda;
				26: o_data_out[0] <= io_sda;
			endcase
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_sda <= 1'b1;
		else begin
			case(r_state)
				IDLE, DONE: r_sda <= 1'b1;
				START: begin
					if (r_clk_cnt > (`I2C_DIV_CLK >> 2) - 16'd1)
						r_sda <= 1'b0;
					else
						r_sda <= 1'b1;
				end
				ADDR: begin
					case(r_bit_cnt)
						1: r_sda <= 1'b1;
						2: r_sda <= 1'b0;
						3: r_sda <= 1'b0;
						4: r_sda <= 1'b1;
						5: r_sda <= 1'b0;
						6: r_sda <= 1'b0;
						7: r_sda <= 1'b0;
						8: r_sda <= r_rw;
						default: r_sda <= 1'b1;
					endcase
				end
				DATA: begin
					case(i_cmd)
						`SET_CONV_RP, `SET_CFG_RP, `SET_CFG_DATA: begin
							case(r_bit_cnt)
								10: r_sda <= 1'b0;
								11: r_sda <= 1'b0;
								12: r_sda <= 1'b0;
								13: r_sda <= 1'b0;
								14: r_sda <= 1'b0;
								15: r_sda <= 1'b0;
								16: r_sda <= 1'b0;
								17: r_sda <= i_cmd[0];

								19: r_sda <= i_data_in[15];
								20: r_sda <= i_data_in[14];
								21: r_sda <= i_data_in[13];
								22: r_sda <= i_data_in[12];
								23: r_sda <= i_data_in[11];
								24: r_sda <= i_data_in[10];
								25: r_sda <= i_data_in[9];
								26: r_sda <= i_data_in[8];

								28: r_sda <= i_data_in[7];
								29: r_sda <= i_data_in[6];
								30: r_sda <= i_data_in[5];
								31: r_sda <= i_data_in[4];
								32: r_sda <= i_data_in[3];
								33: r_sda <= i_data_in[2];
								34: r_sda <= i_data_in[1];
								35: r_sda <= i_data_in[0];
							endcase
						end
						`GET_CFG_DATA, `GET_CONV_DATA: begin
							r_sda <= 1'b1;
						end
					endcase
				end
				ACK: begin
					if ((i_cmd == `GET_CFG_DATA || i_cmd == `GET_CONV_DATA) && (r_bit_cnt == 18 || r_bit_cnt == 27))
						r_sda <= 1'b0;
					else
						r_sda <= 1'b1;
				end
				STOP: begin
					if (r_clk_cnt > (`I2C_DIV_CLK >> 1) + (`I2C_DIV_CLK >> 2) - 16'd1)
						r_sda <= 1'b1;
					else
						r_sda <= 1'b0;
				end
				default: r_sda <= 1'b1;
			endcase
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_error <= 1'b0;
		else if (r_state == START)
			o_error <= 1'b0;
		else if (r_state == ACK && r_clk_cnt == (`I2C_DIV_CLK >> 1) - 16'd1) begin
			if (io_sda != 1'b0)
				o_error <= 1'b1;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_state <= IDLE;
		else begin
			case(r_state)
				IDLE: begin
					if (i_start == 1'b1)
						r_state <= START;
					else
						r_state <= IDLE;
				end
				START: begin
					if (r_clk_cnt >= `I2C_DIV_CLK - 16'd1)
						r_state <= ADDR;
					else
						r_state <= START;
				end
				ADDR: begin
					if (r_clk_cnt >= `I2C_DIV_CLK - 16'd1 && r_bit_cnt == 6'd8)
						r_state <= ACK;
					else
						r_state <= ADDR;
				end
				ACK: begin
					if (r_clk_cnt >= `I2C_DIV_CLK - 16'd1) begin
						if (o_error == 1'b1)
							r_state <= DONE;
						else if (r_bit_cnt + 6'd8 < r_bit_size)
							r_state <= DATA;
						else
							r_state <= STOP;
					end
					else
						r_state <= ACK;
				end
				DATA: begin
					if (r_clk_cnt >= `I2C_DIV_CLK - 16'd1 && (r_bit_cnt == 6'd17 || r_bit_cnt == 6'd26 || r_bit_cnt == 6'd35))
						r_state <= ACK;
					else
						r_state <= DATA;
				end
				STOP: begin
					if (r_clk_cnt >= `I2C_DIV_CLK - 16'd1)
						r_state <= DONE;
					else
						r_state <= STOP;
				end
				DONE: r_state <= IDLE;
			endcase
		end
	end

endmodule
