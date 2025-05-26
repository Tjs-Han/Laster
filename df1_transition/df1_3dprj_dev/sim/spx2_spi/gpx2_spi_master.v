// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: gpx2_spi_master
// Date Created 	: 2024/09/05 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:
//				Convert serial data to Manchester code for sending
//				2024.8.20---two byte send
// Parameters:  SPI_MODE, can be 0, 1, 2, or 3.
//              Can be configured in one of 4 modes:
//              Mode | Clock Polarity (CPOL/CKP) | Clock Phase (CPHA)
//               0   |             0             |        0
//               1   |             0             |        1
//               2   |             1             |        0
//               3   |             1             |        1
// -------------------------------------------------------------------------------------------------
// Revision History :
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module gpx2_spi_master
#(
	parameter CLK_DIV_NUM			= 4,
	parameter SPICOM_INRV_CLKCNT	= 5
)
(
	input					i_clk,
	input					i_rst_n,

	output					o_spi_dclk,
	output					o_spi_mosi,
	input					i_spi_miso,

	input					i_spicom_req,
	input  [7:0]			i_spi_wdata,
	output					o_spicom_ready,
	output					o_spi_rdvalid,
	output [7:0]			o_spi_rdbyte
);
	//--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
	localparam 	ST_IDLE   	= 8'd0;
	localparam 	ST_SPI_INRV	= 8'd1;
	localparam 	ST_DCLK_L 	= 8'd2;
	localparam 	ST_DCLK_H 	= 8'd3;
	localparam 	ST_DONE   	= 8'd4;
	//--------------------------------------------------------------------------------------------------
	// reg and wire declarations
	//--------------------------------------------------------------------------------------------------
	reg [7:0]   r_curr_state	= ST_IDLE;
    reg [7:0]   r_next_state	= ST_IDLE;
	reg	[7:0]	r_cs_dlycnt		= 8'd0;
	reg	[7:0]	r_cmd_dlycnt	= 8'd0;
	reg 		r_spi_dclk		= 1'b0;
	reg			r_spi_mosi		= 1'b0;
	reg			r_spicom_ready	= 1'b1;
	reg   		r_spi_rdvalid	= 1'b0;
	reg	[7:0]	r_spi_rdbyte		= 8'd0;
	reg [7:0]	r_clk_cnt 		= 8'd0;
	reg [3:0]	r_bit_cnt 		= 4'd0;
	reg [15:0]	r_spi_wdata		= 16'h0;
	//--------------------------------------------------------------------------------------------------
	// Flops  always_ff domain
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	// Three-stage state machine
	//--------------------------------------------------------------------------------------------------
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_curr_state <= ST_IDLE;
		else 
            r_curr_state <= r_next_state;
    end

    always@(*) begin
        case(r_curr_state)
            ST_IDLE: begin
                if(i_spicom_req)
                    r_next_state = ST_SPI_INRV;
                else
                    r_next_state = ST_IDLE;  
            end
			ST_SPI_INRV: begin
                if(r_cs_dlycnt >= SPICOM_INRV_CLKCNT)
                    r_next_state = ST_DCLK_L;
                else
                    r_next_state = ST_SPI_INRV;  
            end
			ST_DCLK_L: begin
                if (r_clk_cnt == (CLK_DIV_NUM - 8'd1))
					r_next_state = ST_DCLK_H;
				else
					r_next_state = ST_DCLK_L;
            end
			ST_DCLK_H:
				if (r_clk_cnt == (CLK_DIV_NUM - 8'd1)) begin
					if (r_bit_cnt == 4'd7)
						r_next_state = ST_DONE;
					else
						r_next_state = ST_DCLK_L;
				end else
					r_next_state = ST_DCLK_H;
			ST_DONE:
				r_next_state = ST_IDLE;
            default: r_next_state = ST_IDLE;
        endcase
    end

	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			r_cs_dlycnt		<= 8'd0;
			r_cmd_dlycnt	<= 8'd0;
			r_clk_cnt		<= 8'd0;
			r_bit_cnt		<= 8'd0;
			r_spi_wdata		<= 8'h0;
			r_spi_rdvalid	<= 1'b0;
			r_spi_rdbyte		<= 8'h0;
			r_spi_dclk		<= 1'b0;
			r_spi_mosi		<= 1'b0;
			r_spicom_ready	<= 1'b1;
		end else begin
			case (r_curr_state)
				ST_IDLE: begin
					r_cs_dlycnt		<= 8'd0;
					r_cmd_dlycnt	<= 8'd0;
					r_clk_cnt		<= 8'd0;
					r_bit_cnt		<= 8'd0;
					r_spi_dclk		<= 1'b0;
					r_spi_mosi		<= 1'b0;
					r_spicom_ready	<= 1'b1;
					r_spi_rdvalid	<= 1'b0;
				end
				ST_SPI_INRV: begin
					r_spicom_ready	<= 1'b0;
					r_spi_wdata <= i_spi_wdata;
					if(r_cs_dlycnt >= SPICOM_INRV_CLKCNT)
						r_cs_dlycnt <= 8'd0;
					else
						r_cs_dlycnt <= r_cs_dlycnt + 1'b1;
				end
				ST_DCLK_L: begin
					r_spi_dclk	<= 1'b0;
					r_spi_mosi	<= r_spi_wdata[15];
					if (r_clk_cnt == (CLK_DIV_NUM - 8'd1))
						r_clk_cnt <= 16'd0;
					else
						r_clk_cnt	<= r_clk_cnt + 8'd1;
				end	
				ST_DCLK_H: begin
					r_spi_dclk	<= 1'b1;
					r_spi_rdbyte	<= {r_spi_rdbyte[6:0], i_spi_miso};
					r_spi_wdata	<= r_spi_wdata << 1'b1;
					if (r_clk_cnt == (CLK_DIV_NUM - 8'd1)) begin
						r_clk_cnt <= 16'd0;
						r_bit_cnt <= r_bit_cnt + 4'd1;
					end else begin
						r_clk_cnt	<= r_clk_cnt + 8'd1;
						r_bit_cnt <= r_bit_cnt;
					end
				end
				ST_DONE: begin
					r_spi_rdvalid	<= 1'b0;
				end
			endcase
		end
	end
	//----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_spicom_ready	= r_spicom_ready;
	assign o_spi_rdvalid	= r_spi_rdvalid;
	assign o_spi_rdbyte		= r_spi_rdbyte;
	assign o_spi_dclk		= r_spi_dclk;
	assign o_spi_mosi		= r_spi_mosi;
endmodule
