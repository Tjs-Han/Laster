// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: mpt2042_spi_master
// Date Created 	: 2025/03/27
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:
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
module mpt2042_spi_master
#(	
	parameter SPI_CPOL				= 1'b0,
	parameter SPI_CPHA				= 1'b1,
	parameter BIT_NUM				= 4'd8,
	parameter CLK_DIV_NUM			= 8'd4,
	parameter SPICOM_INRV_CLKCNT	= 8'd4
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
	output					o_spicom_done,
	output [7:0]			o_spi_rdbyte
);
	//--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
	localparam	CLK_DIV_HALFCNT	= CLK_DIV_NUM >> 1;
	localparam 	ST_IDLE   		= 8'd0;
	localparam 	ST_SPI_INRV		= 8'd1;
	localparam 	ST_DCLK_L 		= 8'd2;
	localparam 	ST_DCLK_H 		= 8'd3;
	localparam	ST_SPI_OVER		= 8'd4;
	localparam 	ST_SPI_DONE		= 8'd5;
	//--------------------------------------------------------------------------------------------------
	// reg and wire declarations
	//--------------------------------------------------------------------------------------------------
	reg [7:0]   r_curr_state	= ST_IDLE;
    reg [7:0]   r_next_state	= ST_IDLE;
	reg	[7:0]	r_cs_dlycnt		= 8'd0;
	reg 		r_spi_dclk		= 1'b0;
	reg			r_spi_mosi		= 1'b0;
	reg			r_spicom_ready	= 1'b1;
	reg   		r_spicom_done	= 1'b0;
	reg	[7:0]	r_spi_rdbyte	= 8'd0;
	reg [7:0]	r_clk_cnt 		= 8'd0;
	reg [3:0]	r_bit_cnt 		= 4'd0;
	reg [7:0]	r_spi_wdata		= 8'h0;
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
                if(r_cs_dlycnt >= SPICOM_INRV_CLKCNT) begin
					if(SPI_CPHA)
                    	r_next_state = ST_DCLK_H;
					else
						r_next_state = ST_DCLK_L;
				end else
                    r_next_state = ST_SPI_INRV;  
            end
			ST_DCLK_L: begin
				if (r_clk_cnt == (CLK_DIV_HALFCNT - 8'd1)) begin
					if (r_bit_cnt == BIT_NUM - 1'b1)
						r_next_state = ST_SPI_OVER;
					else
						r_next_state = ST_DCLK_H;
				end else
					r_next_state = ST_DCLK_L;
            end
			ST_DCLK_H:
				if (r_clk_cnt == (CLK_DIV_HALFCNT - 8'd1))
					r_next_state = ST_DCLK_L;
				else
					r_next_state = ST_DCLK_H;
			ST_SPI_OVER: begin
                if(r_cs_dlycnt >= SPICOM_INRV_CLKCNT)
                    r_next_state = ST_SPI_DONE;
                else
                    r_next_state = ST_SPI_OVER;  
            end
			ST_SPI_DONE:
				r_next_state = ST_IDLE;
            default: r_next_state = ST_IDLE;
        endcase
    end

	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			r_cs_dlycnt		<= 8'd0;
			r_clk_cnt		<= 8'd0;
			r_bit_cnt		<= 4'd0;
			r_spi_wdata		<= 8'h0;
			r_spicom_done	<= 1'b0;
			r_spi_rdbyte	<= 8'h0;
			r_spi_dclk		<= SPI_CPOL;
			r_spi_mosi		<= 1'b0;
			r_spicom_ready	<= 1'b1;
		end else begin
			case (r_curr_state)
				ST_IDLE: begin
					r_cs_dlycnt		<= 8'd0;
					r_clk_cnt		<= 8'd0;
					r_bit_cnt		<= 4'd0;
					r_spi_dclk		<= SPI_CPOL;
					r_spi_mosi		<= 1'b0;
					r_spicom_ready	<= 1'b1;
					r_spicom_done	<= 1'b0;
					if(i_spicom_req)
						r_spi_wdata <= i_spi_wdata;
					else
						r_spi_wdata	<= 8'h0;
				end
				ST_SPI_INRV: begin
					r_spicom_ready	<= 1'b0;
					if(r_cs_dlycnt >= SPICOM_INRV_CLKCNT) begin
						r_cs_dlycnt <= 8'd0;
						r_spi_dclk	<= ~SPI_CPOL;
						r_spi_mosi	<= r_spi_wdata[BIT_NUM-1];
					end else
						r_cs_dlycnt	<= r_cs_dlycnt + 1'b1;
				end
				ST_DCLK_L: begin
					r_cs_dlycnt 	<= 8'd0; 
					if (r_clk_cnt == (CLK_DIV_HALFCNT - 8'd1)) begin
						r_spi_mosi	<= r_spi_wdata[BIT_NUM-1];
						r_clk_cnt 	<= 8'd0;
						r_bit_cnt	<= r_bit_cnt + 4'd1;
						if(r_bit_cnt < (BIT_NUM -1))
							r_spi_dclk	<= ~SPI_CPOL;
					end else begin
						r_clk_cnt	<= r_clk_cnt + 8'd1;
						r_bit_cnt	<= r_bit_cnt;
					end
					if(r_clk_cnt == 8'd0)
						r_spi_rdbyte	<= {r_spi_rdbyte[6:0], i_spi_miso};
				end	
				ST_DCLK_H: begin
					r_cs_dlycnt <= 8'd0;
					if (r_clk_cnt == (CLK_DIV_HALFCNT - 8'd1)) begin
						r_spi_dclk		<= SPI_CPOL;
						r_clk_cnt		<= 8'd0;
						r_spi_wdata		<= r_spi_wdata << 1'b1;
					end else begin
						r_clk_cnt	<= r_clk_cnt + 8'd1;
					end
				end
				ST_SPI_OVER: begin
					r_spi_dclk		<= SPI_CPOL;
					r_spicom_ready	<= 1'b0;
					if(r_cs_dlycnt >= SPICOM_INRV_CLKCNT)
						r_cs_dlycnt	<= 8'd0;
					else
						r_cs_dlycnt <= r_cs_dlycnt + 1'b1;
				end
				ST_SPI_DONE: begin
					r_spicom_ready	<= 1'b0;
					r_spicom_done	<= 1'b1;
				end
			endcase
		end
	end
	//----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_spicom_ready	= r_spicom_ready;
	assign o_spicom_done	= r_spicom_done;
	assign o_spi_rdbyte		= r_spi_rdbyte;
	assign o_spi_dclk		= r_spi_dclk;
	assign o_spi_mosi		= r_spi_mosi;
endmodule
