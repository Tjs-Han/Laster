`timescale 1ns / 1ps

`define CMD_IDLE			8'h00
`define CMD_WREN          	8'h06
`define CMD_WRDI          	8'h04
`define CMD_RDID          	8'h9f
`define CMD_RDSR          	8'h05
`define CMD_WRSR          	8'h01
`define CMD_READ          	8'h03
`define CMD_FAST_READ     	8'h0b
`define CMD_PP            	8'h02
`define CMD_SE            	8'hd8
`define CMD_BE            	8'hc7

module spi_flash_top
(
	input					clk,
	input					rst_n,

	output 					o_spi_cs,
	output  				o_spi_dclk,
	output					o_spi_mosi,
	input					i_spi_miso,

	input			[15:0]	i_clk_div,
	input			[ 7:0]	i_cmd,
	input					i_cmd_valid,
	output reg				o_cmd_ack = 1'b0,

	input			[23:0]	i_addr,
	input			[ 8:0]	i_byte_size,

	output					o_data_req,
	input			[ 7:0]	i_data_in,
	output			[ 7:0]	o_data_out,
	output					o_data_valid
);
    //----------------------------------------------------------------------------------------------
    // parameter adn localparam define 
    //----------------------------------------------------------------------------------------------
	localparam CMD_DLYNUM	= 4'd4;
	localparam IDLE   		= 4'd0;
	localparam WAIT_CMD		= 4'd1;
	localparam CMD			= 4'd2;
	localparam CMD_ACK		= 4'd3;
    //----------------------------------------------------------------------------------------------
    // reg and wire define 
    //----------------------------------------------------------------------------------------------
	reg  [7:0]			r_cmd			= 4'd0;
	reg  				r_cmd_valid		= 1'b0;
	reg  [7:0]			r_data_in 		= 8'h0;
	reg  [3:0]			r_state 		= IDLE;
	reg  [3:0]			r_cmd_dlycnt	= 4'd0;
	wire				w_cmd_ack;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_cmd <= `CMD_IDLE;
		else if (r_state == IDLE)
			r_cmd <= `CMD_IDLE;
		else if (r_state == CMD) begin
			if (i_cmd == `CMD_READ)
				r_cmd <= `CMD_READ;
			else if (i_cmd == `CMD_PP) begin
				if (r_cmd == `CMD_IDLE)
					r_cmd <= `CMD_WREN;
				else if (r_cmd == `CMD_WREN)
					r_cmd <= `CMD_PP;
				else if (r_cmd == `CMD_PP)
					r_cmd <= `CMD_RDSR;
			end
			else if (i_cmd == `CMD_SE) begin
				if (r_cmd == `CMD_IDLE)
					r_cmd <= `CMD_WREN;
				else if (r_cmd == `CMD_WREN)
					r_cmd <= `CMD_SE;
				else if (r_cmd == `CMD_SE)
					r_cmd <= `CMD_RDSR;
			end
			else if (i_cmd == `CMD_BE) begin
				if (r_cmd == `CMD_IDLE)
					r_cmd <= `CMD_WREN;
				else if (r_cmd == `CMD_WREN)
					r_cmd <= `CMD_BE;
				else if (r_cmd == `CMD_BE)
					r_cmd <= `CMD_RDSR;
			end
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_cmd_valid <= 1'b0;
		else if (r_state == CMD)
			r_cmd_valid <= 1'b1;
		else
			r_cmd_valid <= 1'b0;
	end

	//r_cmd_dlycnt
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_cmd_dlycnt <= 4'd0;
		else if (r_state == WAIT_CMD)
			r_cmd_dlycnt <= r_cmd_dlycnt + 1'b1;
		else
			r_cmd_dlycnt <= 4'd0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			r_state <= IDLE;
			o_cmd_ack <= 1'b0;
		end
		else begin
			case(r_state)
				IDLE: begin
					o_cmd_ack <= 1'b0;
					if (i_cmd_valid == 1'b1 && (i_cmd == `CMD_READ || i_cmd == `CMD_PP || i_cmd == `CMD_SE || i_cmd == `CMD_BE))
						r_state <= WAIT_CMD;
					else
						r_state <= IDLE;
				end
				WAIT_CMD: begin
					if(r_cmd_dlycnt >= CMD_DLYNUM)
						r_state <= CMD;
					else
						r_state <= WAIT_CMD;
				end
				CMD:
					r_state <= CMD_ACK;
				CMD_ACK:
					if (w_cmd_ack == 1'b1) begin
						if (i_cmd == `CMD_READ) begin
							r_state <= IDLE;
							o_cmd_ack <= 1'b1;
						end
						else if (i_cmd == `CMD_PP) begin
							if (r_cmd == `CMD_RDSR && o_data_out[0] == 1'b0) begin
								r_state <= IDLE;
								o_cmd_ack <= 1'b1;
							end
							else
								r_state <= WAIT_CMD;
						end
						else if (i_cmd == `CMD_SE) begin
							if (r_cmd == `CMD_RDSR && o_data_out[0] == 1'b0) begin
								r_state <= IDLE;
								o_cmd_ack <= 1'b1;
							end
							else
								r_state <= WAIT_CMD;
						end
						else if (i_cmd == `CMD_BE) begin
							if (r_cmd == `CMD_RDSR && o_data_out[0] == 1'b0) begin
								r_state <= IDLE;
								o_cmd_ack <= 1'b1;
							end
							else
								r_state <= WAIT_CMD;
						end
					end
					else
						r_state <= CMD_ACK;
			endcase
		end
	end

	spi_flash_cmd u_spi_cmd(
		.clk 			( clk 					),
		.rst_n			( rst_n 				),

		.o_spi_cs		( o_spi_cs 				),
		.o_spi_dclk		( o_spi_dclk 			),
		.o_spi_mosi		( o_spi_mosi 			),
		.i_spi_miso		( i_spi_miso 			),

		.i_clk_div		( i_clk_div 			),
		.i_cmd 			( r_cmd 				),
		.i_cmd_valid	( r_cmd_valid 			),
		.o_cmd_ack		( w_cmd_ack 			),

		.i_addr			( i_addr 				),
		.i_byte_size	( i_byte_size 			),

		.o_data_req		( o_data_req 			),
		.i_data_in		( i_data_in 			),
		.o_data_out		( o_data_out 			),
		.o_data_valid	( o_data_valid 			)
	);

endmodule
