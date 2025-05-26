`timescale 1ns / 1ps
module spi_flash_cmd_tb;

	reg					clk = 1'b0;
	reg					rst_n = 1'b0;

	wire					w_spi_cs;
	wire					w_spi_dclk;
	wire					w_spi_mosi;
	reg					r_spi_miso = 1'b1;
	reg			[ 3:0]r_cmd = 4'd0;
	reg					r_cmd_valid = 1'b0;
	wire					w_cmd_ack;
	reg			[23:0]r_addr = 24'h0;
	reg			[ 8:0]r_byte_size = 9'd0;
	wire					w_data_req;
	reg			[ 7:0]r_data_in = 8'h0;
	wire			[ 7:0]w_data_out;
	wire					w_data_valid;

	always #5 clk <= ~clk;

	initial begin
		#1000 rst_n = 1;
		#100 r_cmd = 4'd9; r_cmd_valid = 1'b1; 
			  r_addr = 24'h112233; r_byte_size = 9'd4;
			  r_data_in = 8'h35;
	end

	always @(posedge clk) begin
		if (w_data_req) begin
			r_data_in <= r_data_in + 8'd1;
		end
	end


	spi_flash_cmd u1(
		.clk 				( clk ),
		.rst_n			( rst_n ),

		.o_spi_cs		( w_spi_cs ),
		.o_spi_dclk		( w_spi_dclk ),
		.o_spi_mosi		( w_spi_mosi ),
		.i_spi_miso		( r_spi_miso ),

		.i_clk_div		( 16'd4 ),
		.i_cmd 			( r_cmd ),
		.i_cmd_valid	( r_cmd_valid ),
		.o_cmd_ack		( w_cmd_ack ),

		.i_addr			( r_addr ),
		.i_byte_size	( r_byte_size ),

		.o_data_req		( w_data_req ),
		.i_data_in		( r_data_in ),
		.o_data_out		( w_data_out ),
		.o_data_valid	( w_data_valid )
	);

endmodule
