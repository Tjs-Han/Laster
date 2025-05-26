`timescale 1ns / 1ps

module spi_master_eth
(
	input					clk,
	input					rst_n,

	output 				o_spi_cs,
	output reg			o_spi_dclk = 1'b0,
	output reg			o_spi_mosi = 1'b0,
	input					i_spi_miso,

	input					i_cs_ctrl,
	input			[15:0]i_clk_div,
	input					i_wr_req,
	output reg			o_wr_ack = 1'b0,
	input			[ 7:0]i_data_in,
	output reg	[ 7:0]o_data_out = 8'd0
);

	localparam IDLE   = 0;
	localparam READY  = 1;
	localparam DCLK_L = 2;
	localparam DCLK_H = 3;
	localparam DONE   = 4;

	reg		[15:0]	r_clk_cnt = 16'd0;
	reg		[ 3:0]	r_bit_cnt = 4'd0;
	reg		[ 2:0]	r_state = 3'd0;
	reg		[ 7:0]	r_data_in = 8'd0;
	reg             i_spi_miso_reg;

	assign o_spi_cs = i_cs_ctrl;

	//clock count
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_clk_cnt <= 16'd0;
		else if (r_clk_cnt == (i_clk_div - 16'd1))
			r_clk_cnt <= 16'd0;
		else if (r_state == DCLK_L || r_state == DCLK_H)
			r_clk_cnt <= r_clk_cnt + 16'd1;
	end

	//spi clock
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_spi_dclk <= 1'b0;
		else if (r_state == DCLK_L && r_clk_cnt == (i_clk_div - 16'd1)) begin
			o_spi_dclk <= 1'b1;
		end
		else if (r_state == DCLK_H && r_clk_cnt == (i_clk_div - 16'd1)) begin
			o_spi_dclk <= 1'b0;
		end
	end

	//bit count
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_bit_cnt <= 4'd0;
		else if (r_state == IDLE)
			r_bit_cnt <= 4'd0;
		else if (r_state == DCLK_H && r_clk_cnt == (i_clk_div - 16'd1)) begin
			r_bit_cnt <= r_bit_cnt + 4'd1;
		end
	end

	//write ack
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_wr_ack <= 1'b0;
		else if (r_state == DONE)
			o_wr_ack <= 1'b1;
		else
			o_wr_ack <= 1'b0;
	end

	//spi mosi
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_data_in <= 8'd0;
		else if (r_state == READY)
			r_data_in <= {i_data_in[6:0],1'b0};
		else if (r_state == DCLK_H && r_clk_cnt == (i_clk_div - 16'd1))
			r_data_in <= r_data_in << 1;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_spi_mosi <= 1'b0;
		else if (r_state == READY)
			o_spi_mosi <= i_data_in[7];
		else if (r_state == DCLK_H && r_bit_cnt < 4'd7)
			o_spi_mosi <= r_data_in[7];
		else if (r_state == DONE)
			o_spi_mosi <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			i_spi_miso_reg <= 1'b0;
		else 
			i_spi_miso_reg <= i_spi_miso;
	end
	//spi miso
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_data_out <= 8'h0;
		else if ((r_state == DCLK_H) && (r_clk_cnt == (i_clk_div - 16'd1)))
			o_data_out[0] <= i_spi_miso_reg;
		else if ((r_bit_cnt >= 4'd1) && (r_bit_cnt <= 4'd7) && (r_state == DCLK_L) && (r_clk_cnt == (i_clk_div - 16'd1)))
			o_data_out <= o_data_out << 1;
	end

	//spi one byte state machine
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_state <= IDLE;
		else begin
			case (r_state)
				IDLE:
					if (i_wr_req == 1'b1)
						r_state <= READY;
					else
						r_state <= IDLE;
				READY:
					r_state <= DCLK_L;
				DCLK_L:
					if (r_clk_cnt == (i_clk_div - 16'd1))
						r_state <= DCLK_H;
					else
						r_state <= DCLK_L;
				DCLK_H:
					if (r_clk_cnt == (i_clk_div - 16'd1))
						if (r_bit_cnt == 4'd7)
							r_state <= DONE;
						else
							r_state <= DCLK_L;
					else
						r_state <= DCLK_H;
				DONE:
					r_state <= IDLE;
			endcase
		end
	end

endmodule
