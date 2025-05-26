`timescale 1ns / 1ps

module spi_master_tb;
	reg					clk = 1'b0;
	reg					rst_n = 1'b0;

	reg					r_spi_miso = 1'b1;
	reg					r_cs_ctrl = 1'b0;
	reg					r_wr_req = 1'b1;

	wire					w_spi_cs;
	wire					w_spi_dclk;
	wire					w_spi_mosi;
	wire					w_wr_ack;
	wire					w_data_out;

	always #5 clk <= ~clk;

	initial begin
		#1000 rst_n = 1;
	end

	spi_master u1(
		.clk 			( clk ),
		.rst_n		( rst_n ),

		.o_spi_cs	( w_spi_cs ),
		.o_spi_dclk	( w_spi_dclk ),
		.o_spi_mosi	( w_spi_mosi ),
		.i_spi_miso	( r_spi_miso ),

		.i_cs_ctrl	( r_cs_ctrl ),
		.i_clk_div	( 16'd4 ),
		.i_wr_req	( r_wr_req ),
		.o_wr_ack	( w_wr_ack ),
		.i_data_in	( 8'h12 ),
		.o_data_out	( w_data_out )
	);

endmodule
