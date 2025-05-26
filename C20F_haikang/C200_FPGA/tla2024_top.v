`timescale 1ns / 1ps

`include "tla2024_cmd_defines.v"

module tla2024_top
(
	input					clk,
	input					rst_n,

	output				o_scl,
	inout					io_sda,

	output reg	[11:0]o_adc0 = 12'h0,
	output reg	[11:0]o_adc1 = 12'h0,
	output reg	[11:0]o_adc2 = 12'h0,
	output reg	[11:0]o_adc3 = 12'h0,

	output				o_valid,
	output				o_error
);

	localparam IDLE 			= 0;
	localparam SET_CH			= 1;
	localparam SET_CH_ACK	= 2;
	localparam WAIT_CH		= 3;
	localparam WAIT_CH_ACK	= 4;
	localparam SET_RP			= 5;
	localparam SET_RP_ACK	= 6;
	localparam GET_CH			= 7;
	localparam GET_CH_ACK	= 8;

	reg			[ 3:0]r_state = IDLE;
	reg			[ 4:0]r_adc_time = 5'd0;
	reg			[ 1:0]r_adc_channel = 2'd0;
	reg					r_start = 1'b0;
	reg			[15:0]r_data_in = 16'd0;
	reg			[ 3:0]r_cmd = 4'h0;

	reg			[16:0]r_adc0_value = 17'd0;
	reg			[16:0]r_adc1_value = 17'd0;
	reg			[16:0]r_adc2_value = 17'd0;
	reg			[16:0]r_adc3_value = 17'd0;

	wire					w_end;
	wire			[15:0]w_data_out;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			r_state <= IDLE;
			r_adc_time <= 5'd0;
			r_adc_channel <= 2'd0;
			r_cmd <= 4'h0;
			r_data_in <= 16'd0;
			r_start <= 1'b0;
		end
		else begin
			case(r_state)
				IDLE: begin
					r_state <= SET_CH;
				end
				SET_CH: begin
					r_state <= SET_CH_ACK;
					r_cmd <= `SET_CFG_DATA;
					r_data_in <= {1'b1, 1'b1, r_adc_channel, 4'h3, 8'hc0};
					r_start <= 1'b1;
				end
				SET_CH_ACK: begin
					r_start <= 1'b0;
					if (w_end == 1'b1) begin
						if (o_error == 1'b1)
							r_state <= IDLE;
						else
							r_state <= WAIT_CH;
					end
					else
						r_state <= SET_CH_ACK;
				end
				WAIT_CH: begin
					r_state <= WAIT_CH_ACK;
					r_cmd <= `GET_CFG_DATA;
					r_start <= 1'b1;
				end
				WAIT_CH_ACK: begin
					r_start <= 1'b0;
					if (w_end == 1'b1) begin
						if (o_error == 1'b1)
							r_state <= IDLE;
						else begin
							if (w_data_out[15] == 1'b1)
								r_state <= SET_RP;
							else
								r_state <= WAIT_CH;
						end
					end
					else
						r_state <= WAIT_CH_ACK;
				end
				SET_RP: begin
					r_state <= SET_RP_ACK;
					r_cmd <= `SET_CONV_RP;
					r_start <= 1'b1;
				end
				SET_RP_ACK: begin
					r_start <= 1'b0;
					if (w_end == 1'b1) begin
						if (o_error == 1'b1)
							r_state <= IDLE;
						else
							r_state <= GET_CH;
					end
					else
						r_state <= SET_RP_ACK;
				end
				GET_CH: begin
					r_state <= GET_CH_ACK;
					r_cmd <= `GET_CONV_DATA;
					r_start <= 1'b1;
				end
				GET_CH_ACK: begin
					r_start <= 1'b0;
					if (w_end == 1'b1) begin
						if (o_error == 1'b1)
							r_state <= IDLE;
						else begin
							r_adc_time <= r_adc_time + 5'd1;
							r_state <= SET_CH;
							if (r_adc_time == 5'b11111) begin
								r_adc_channel <= r_adc_channel + 2'd1;
							end
						end
					end
					else
						r_state <= GET_CH_ACK;
				end
			endcase
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			r_adc0_value <= 17'd0;
			r_adc1_value <= 17'd0;
			r_adc2_value <= 17'd0;
			r_adc3_value <= 17'd0;
			o_adc0 <= 12'h0;
			o_adc1 <= 12'h0;
			o_adc2 <= 12'h0;
			o_adc3 <= 12'h0;
		end
		else begin
			if (r_state == SET_CH && r_adc_time == 5'd0) begin
				case(r_adc_channel)
					0: begin
						o_adc3 <= r_adc3_value[15:4];
						r_adc3_value <= 17'd0;
					end
					1: begin
						o_adc0 <= r_adc0_value[15:4];
						r_adc0_value <= 17'd0;
					end
					2: begin
						o_adc1 <= r_adc1_value[15:4];
						r_adc1_value <= 17'd0;
					end
					3: begin
						o_adc2 <= r_adc2_value[15:4];
						r_adc2_value <= 17'd0;
					end
				endcase
			end
			else if (r_state == GET_CH_ACK && w_end == 1'b1)begin// && r_adc_time == 5'b11111) begin
				case(r_adc_channel)
					0: r_adc0_value <= r_adc0_value + w_data_out[15:4];
					1: r_adc1_value <= r_adc1_value + w_data_out[15:4];
					2: r_adc2_value <= r_adc2_value + w_data_out[15:4];
					3: r_adc3_value <= r_adc3_value + w_data_out[15:4];
				endcase
			end
		end
	end

	i2c_master u1(
		.clk				( clk ),
		.rst_n			( rst_n ),

		.o_scl			( o_scl ),
		.io_sda			( io_sda ),

		.i_cmd			( r_cmd ),
		.i_data_in		( r_data_in ),
		.o_data_out		( w_data_out ),

		.i_start			( r_start ),
		.o_end			( w_end ),
		.o_error			( o_error )
	);

endmodule
