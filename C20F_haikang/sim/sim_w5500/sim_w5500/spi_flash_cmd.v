`timescale 1ns / 1ps

`define CMD_IDLE			  8'h00
`define CMD_WREN          8'h06
`define CMD_WRDI          8'h04
`define CMD_RDID          8'h9f
`define CMD_RDSR          8'h05
`define CMD_WRSR          8'h01
`define CMD_READ          8'h03
`define CMD_FAST_READ     8'h0b
`define CMD_PP            8'h02
`define CMD_SE            8'hd8
`define CMD_BE            8'hc7

module spi_flash_cmd
(
	input					clk,
	input					rst_n,

	output 				o_spi_cs,
	output  				o_spi_dclk,
	output				o_spi_mosi,
	input					i_spi_miso,

	input			[15:0]i_clk_div,
	input			[ 7:0]i_cmd,
	input					i_cmd_valid,
	output reg			o_cmd_ack = 1'b0,

	input			[23:0]i_addr,
	input			[ 8:0]i_byte_size,

	output reg			o_data_req = 1'b0,
	input			[ 7:0]i_data_in,
	output		[ 7:0]o_data_out,
	output reg			o_data_valid
);

	localparam IDLE   		= 0;
	localparam CS_LOW 		= 1;
	localparam CS_HIGH 		= 2;
	localparam CMD   			= 3;
	localparam CMD_ACK		= 4;
	localparam ADDR			= 5;
	localparam ADDR_ACK		= 6;
	localparam BYTE 			= 7;
	localparam BYTE_ACK		= 8;

	wire					w_wr_ack;

	reg					r_cs_ctrl = 1'b1;
	reg					r_wr_req = 1'b0;
	reg			[ 3:0]r_state = IDLE;
	reg			[ 8:0]r_byte_size = 9'd0;
	reg			[ 8:0]r_byte_cnt = 9'd0;
	reg			[ 7:0]r_data_in = 8'h0;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_byte_size <= 9'd0;
		else if (r_state == CS_LOW) begin
			case(i_cmd)
				`CMD_RDID       : r_byte_size <= i_byte_size;
            `CMD_RDSR       : r_byte_size <= 9'd1;
            `CMD_WRSR       : r_byte_size <= 9'd1;
            `CMD_READ       : r_byte_size <= 9'd3 + i_byte_size;
            `CMD_FAST_READ  : r_byte_size <= 9'd3 + i_byte_size;
            `CMD_PP         : r_byte_size <= 9'd3 + i_byte_size;
            `CMD_SE         : r_byte_size <= 9'd3;
            default         : r_byte_size <= 9'd0;
			endcase
		end
		else
			r_byte_size <= r_byte_size;
	end

	// always @(posedge clk or negedge rst_n) begin
	// 	if (!rst_n)
	// 		r_cmd_code <= 8'h0;
	// 	else if (r_state == CS_LOW) begin
	// 		case(i_cmd)
	// 			`CMD_WREN       : r_cmd_code <= 8'h06;
 //            `CMD_WRDI       : r_cmd_code <= 8'h04;
 //            `CMD_RDID       : r_cmd_code <= 8'h9f;
 //            `CMD_RDSR       : r_cmd_code <= 8'h05;
 //            `CMD_WRSR       : r_cmd_code <= 8'h01;
 //            `CMD_READ       : r_cmd_code <= 8'h03;
 //            `CMD_FAST_READ  : r_cmd_code <= 8'h0b;
 //            `CMD_PP         : r_cmd_code <= 8'h02;
 //            `CMD_SE         : r_cmd_code <= 8'hd8;
 //            `CMD_BE         : r_cmd_code <= 8'hc7;
 //            default         : r_cmd_code <= 8'h00;
	// 		endcase
	// 	end
	// 	else
	// 		r_cmd_code <= r_cmd_code;
	// end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_cs_ctrl <= 1'b1;
		else if (r_state == CS_LOW)
			r_cs_ctrl <= 1'b0;
		else if (r_state == CS_HIGH)
			r_cs_ctrl <= 1'b1;
		else
			r_cs_ctrl <= r_cs_ctrl;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_wr_req <= 1'b0;
		else if (r_state == CMD || r_state == ADDR || r_state == BYTE)
			r_wr_req <= 1'b1;
		else
			r_wr_req <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_data_in <= 8'h0;
		else if (r_state == CMD)
			r_data_in <= i_cmd;
		else if (r_state == ADDR) begin
			if (r_byte_cnt == 9'd1)
				r_data_in <= i_addr[23:16];
			else if (r_byte_cnt == 9'd2)
				r_data_in <= i_addr[15:8];
			else if (r_byte_cnt == 9'd3)
				r_data_in <= i_addr[7:0];
		end
		else if (r_state == BYTE_ACK) begin
			if (i_cmd == `CMD_WRSR || i_cmd == `CMD_PP || i_cmd == `CMD_SE)
				r_data_in <= i_data_in;
			else
				r_data_in <= 8'd0;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_byte_cnt <= 9'd0;
		else if (r_state == IDLE)
			r_byte_cnt <= 9'd0;
		else if (w_wr_ack == 1'b1)
			r_byte_cnt <= r_byte_cnt + 9'd1;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_data_valid <= 1'b0;
		else if (r_state == BYTE_ACK && w_wr_ack == 1'b1 && (i_cmd == `CMD_READ || i_cmd == `CMD_RDID || i_cmd == `CMD_RDSR))
			o_data_valid <= 1'b1;
		else
			o_data_valid <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_cmd_ack <= 1'b0;
		else if (r_state == CS_HIGH)
			o_cmd_ack <= 1'b1;
		else
			o_cmd_ack <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_data_req <= 1'b0;
		else if (r_state == BYTE_ACK && w_wr_ack == 1'b1 && r_byte_cnt < r_byte_size && i_cmd == `CMD_PP) begin
			o_data_req <= 1'b1;
		end
		else
			o_data_req <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_state <= IDLE;
		else begin
			case(r_state)
				IDLE:
					if (i_cmd_valid)
						r_state <= CS_LOW;
					else
						r_state <= IDLE;
				CS_LOW:
					r_state <= CMD;
				CS_HIGH:
					r_state <= IDLE;
				CMD:
					r_state <= CMD_ACK;
				CMD_ACK:
					if (w_wr_ack == 1'b1) begin
						if (i_cmd == `CMD_WREN || i_cmd == `CMD_WRDI || i_cmd == `CMD_BE)
							r_state <= CS_HIGH;
						else if (i_cmd == `CMD_RDID || i_cmd == `CMD_RDSR || i_cmd == `CMD_WRSR)
							r_state <= BYTE;
						else if (i_cmd == `CMD_READ || i_cmd == `CMD_PP || i_cmd == `CMD_SE)
							r_state <= ADDR;
					end
					else
						r_state <= CMD_ACK;
				ADDR:
					r_state <= ADDR_ACK;
				ADDR_ACK:
					if (w_wr_ack == 1'b1) begin
						if (r_byte_cnt < 9'd3)
							r_state <= ADDR;
						else if (i_cmd == `CMD_READ || i_cmd == `CMD_PP)
							r_state <= BYTE;
						else if (i_cmd == `CMD_SE)
							r_state <= CS_HIGH;
					end
					else
						r_state <= ADDR_ACK;
				BYTE:
					r_state <= BYTE_ACK;
				BYTE_ACK:
					if (w_wr_ack == 1'b1) begin
						if (r_byte_cnt < r_byte_size)
							r_state <= BYTE;
						else
							r_state <= CS_HIGH;
					end
					else
						r_state <= BYTE_ACK;
			endcase
		end
	end


	spi_master u1(
		.clk 				( clk ),
		.rst_n			( rst_n ),

		.o_spi_cs		( o_spi_cs ),
		.o_spi_dclk		( o_spi_dclk ),
		.o_spi_mosi		( o_spi_mosi ),
		.i_spi_miso		( i_spi_miso ),

		.i_cs_ctrl		( r_cs_ctrl ),
		.i_clk_div		( i_clk_div ),
		.i_wr_req		( r_wr_req ),
		.o_wr_ack		( w_wr_ack ),
		.i_data_in		( r_data_in ),
		.o_data_out		( o_data_out )
	);

endmodule
