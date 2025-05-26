`timescale 1ns / 1ps

`define DIV_CLK			16'd100_0

module mcp4726a0_top
(
	input					clk,
	input					rst_n,

	output reg			o_scl = 1'b1,
	inout					io_sda,

	input					i_start,
	input			[11:0]i_dac_value,

	output reg			o_error = 1'b0
);

	localparam IDLE	= 0;
	localparam START	= 1;
	localparam DATA	= 2;
	localparam ACK		= 3;
	localparam STOP	= 4;
	localparam DONE	= 5;
	localparam RDSTART	= 6;
	localparam RDDATA	= 7;
	localparam RDSTOP	= 8;

	reg			[15:0]r_clk_cnt = 16'd0;
	reg 			[ 7:0]r_bit_cnt = 8'd0;
	reg					r_sda = 1'b1;
	reg					r_en = 1'b0;
	reg			[ 3:0]r_state = IDLE;

	assign io_sda = r_sda ? 1'bz: 1'b0;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_en <= 1'b0;
		else if (i_start == 1'b1)
			r_en <= 1'b1;
		else if (r_state == DONE)
			r_en <= 1'b0;
		else if (r_state == RDSTART)
			r_en <= 1'b1;
		else if (r_state == IDLE)
			r_en <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_bit_cnt <= 8'd0;
		else if (r_en == 1'b0)
			r_bit_cnt <= 8'd0;
		else if (r_en == 1'b1) begin
			if (r_clk_cnt >= (`DIV_CLK - 16'd1))// && r_bit_cnt < 5'd28)
				r_bit_cnt <= r_bit_cnt + 8'd1;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_clk_cnt<= 16'd0;
		else if (r_en == 1'b0)
			r_clk_cnt<= 16'd0;
		else if (r_en == 1'b1) begin
			if (r_clk_cnt >= (`DIV_CLK - 16'd1))
				r_clk_cnt <= 16'd0;
			else
				r_clk_cnt <= r_clk_cnt + 16'd1;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_scl <= 1'b1;
		else begin
			case(r_state)
				IDLE: begin
					o_scl <= 1'b1;
				end
				START, RDSTART: begin
					if (r_clk_cnt <= (`DIV_CLK >> 2) + (`DIV_CLK >> 1) - 16'd1)
						o_scl <= 1'b1;
					else
						o_scl <= 1'b0;
				end
				DATA, RDDATA, ACK: begin
					if (r_clk_cnt <= (`DIV_CLK >> 2) - 16'd1 || r_clk_cnt > (`DIV_CLK >> 2) + (`DIV_CLK >> 1) - 16'd1)
						o_scl <= 1'b0;
					else
						o_scl <= 1'b1;
				end
				STOP, RDSTOP: begin
					if (r_clk_cnt <= (`DIV_CLK >> 2) - 16'd1)
						o_scl <= 1'b0;
					else
						o_scl <= 1'b1;
				end
			endcase
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_sda <= 1'b1;
		else begin
			case(r_state)
				START, RDSTART: begin
					if (r_clk_cnt <= (`DIV_CLK >> 1) - 16'd1)
						r_sda <= 1'b1;
					else
						r_sda <= 1'b0;
				end
				DATA: begin
					case(r_bit_cnt)
						1: r_sda <= 1'b1;
						2: r_sda <= 1'b1;
						3: r_sda <= 1'b0;
						4: r_sda <= 1'b0;
						5: r_sda <= 1'b0;
						6: r_sda <= 1'b0;
						7: r_sda <= 1'b0;
						8: r_sda <= 1'b0;
						10: r_sda <= 1'b0;
						11: r_sda <= 1'b0;
						12: r_sda <= 1'b0;
						13: r_sda <= 1'b0;//1'b1;
						14: r_sda <= i_dac_value[11];
						15: r_sda <= i_dac_value[10];
						16: r_sda <= i_dac_value[9];
						17: r_sda <= i_dac_value[8];
						19: r_sda <= i_dac_value[7];
						20: r_sda <= i_dac_value[6];
						21: r_sda <= i_dac_value[5];
						22: r_sda <= i_dac_value[4];
						23: r_sda <= i_dac_value[3];
						24: r_sda <= i_dac_value[2];
						25: r_sda <= i_dac_value[1];
						26: r_sda <= i_dac_value[0];
					endcase
				end
				RDDATA: begin
					case(r_bit_cnt)
						1: r_sda <= 1'b1;
						2: r_sda <= 1'b1;
						3: r_sda <= 1'b0;
						4: r_sda <= 1'b0;
						5: r_sda <= 1'b0;
						6: r_sda <= 1'b0;
						7: r_sda <= 1'b0;
						8: r_sda <= 1'b1;
						18:r_sda <= 1'b0;
						19:r_sda <= 1'b1;
						27:r_sda <= 1'b0;
						28:r_sda <= 1'b1;
						36:r_sda <= 1'b0;
						37:r_sda <= 1'b1;
						45:r_sda <= 1'b0;
						46:r_sda <= 1'b1;
						54:r_sda <= 1'b0;
						55:r_sda <= 1'b1;
						63:r_sda <= 1'b0;
					endcase
				end
				ACK: begin
					if(r_clk_cnt > (`DIV_CLK >> 2) + (`DIV_CLK >> 1) - 16'd1)
						r_sda <= 1'b0;
					else
						r_sda <= 1'b1;
				end
				STOP, RDSTOP: begin
					if (r_clk_cnt <= (`DIV_CLK >> 1) - 16'd1)
						r_sda <= 1'b0;
					else
						r_sda <= 1'b1;
				end
				default: r_sda <= r_sda;
			endcase
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_error <= 1'b0;
		else if (i_start == 1'b1)
			o_error <= 1'b0;
		else if (r_state == ACK) begin
			if (r_clk_cnt == (`DIV_CLK >> 1) - 16'd1) begin
				if (io_sda == 1'b1)
					o_error <= 1'b1;
			end
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
					if (r_clk_cnt >= (`DIV_CLK - 16'd1) && r_bit_cnt == 8'd0)
						r_state <= DATA;
					else
						r_state <= START;
				end
				DATA: begin
					if (r_clk_cnt >= (`DIV_CLK - 16'd1) && (r_bit_cnt == 8'd8 || r_bit_cnt == 8'd17 || r_bit_cnt == 8'd26))
						r_state <= ACK;
					else
						r_state <= DATA;
				end
				ACK: begin
					if (r_clk_cnt == (`DIV_CLK >> 1) - 16'd1) begin
						if (io_sda == 1'b1)
							r_state <= DONE;
						else
							r_state <= ACK;
					end
					else if (r_clk_cnt >= (`DIV_CLK - 16'd1)) begin
						if (r_bit_cnt == 8'd27)
							r_state <= STOP;
						else
							r_state <= DATA;
					end
					else
						r_state <= ACK;
				end
				STOP: begin
					if (r_clk_cnt >= (`DIV_CLK - 16'd1)) begin
						r_state <= DONE;
					end
					else
						r_state <= STOP;
				end
				DONE: r_state <= RDSTART;//IDLE;
				RDSTART:begin
					if (r_clk_cnt >= (`DIV_CLK - 16'd1) && r_bit_cnt == 8'd0)
						r_state <= RDDATA;
					else
						r_state <= RDSTART;
				end
				RDDATA:begin
					if (r_clk_cnt >= (`DIV_CLK - 16'd1) && r_bit_cnt == 8'd63)
						r_state <= RDSTOP;
					else
						r_state <= RDDATA;
				end
				RDSTOP: begin
					if (r_clk_cnt >= (`DIV_CLK - 16'd1)) 
						r_state <= IDLE;
					else
						r_state <= RDSTOP;
				end
				default: r_state <= r_state;
			endcase
		end
	end

endmodule
