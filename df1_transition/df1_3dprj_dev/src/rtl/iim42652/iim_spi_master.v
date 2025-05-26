// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: iim_spi_master
// Date Created 	: 2024/8/21 
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
module iim_spi_master
#(
	parameter IIM_CLK_DIV_NUM	= 4,
	parameter SPI_CPOL			= 1
)
(
	input					i_clk,
	input					i_rst_n,

	output 					o_spi_cs,
	output					o_spi_dclk,
	output					o_spi_mosi,
	input					i_spi_miso,

	input					i_wr_req,
	output					o_spicom_ready,
	output					o_wr_ack,
	input  [15:0]			i_spi_wdata,
	output					o_rdata_valid,
	output [7:0]			o_data_out
);
	//--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
	localparam 	ST_IDLE   	= 8'd0;
	localparam 	ST_CS_EN  	= 8'd1;
	localparam 	ST_DCLK_L 	= 8'd2;
	localparam 	ST_DCLK_H 	= 8'd3;
	localparam 	ST_CS_DIS 	= 8'd4;
	localparam	ST_SPI_INRV	= 8'd5;
	localparam 	ST_DONE   	= 8'd6;
	//--------------------------------------------------------------------------------------------------
	// reg and wire declarations
	//--------------------------------------------------------------------------------------------------
	reg [7:0]   r_curr_state	= ST_IDLE;
    reg [7:0]   r_next_state	= ST_IDLE;
	reg	[7:0]	r_cs_dlycnt		= 8'd0;
	reg	[7:0]	r_cmd_dlycnt	= 8'd0;
	reg			r_spi_cs		= 1'b1;
	reg 		r_spi_dclk		= SPI_CPOL;
	reg			r_spi_mosi		= 1'b0;
	reg			r_spicom_ready	= 1'b1;
	reg			r_wr_ack 		= 1'b0;
	reg   		r_rdata_valid	= 1'b0;
	reg	[7:0]	r_spi_rdata		= 8'h0;
	reg [7:0]	r_clk_cnt 		= 8'd0;
	reg [7:0]	r_bit_cnt 		= 8'd0;
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
                if(i_wr_req)
                    r_next_state = ST_CS_EN;
                else
                    r_next_state = ST_IDLE;  
            end
			ST_CS_EN: begin
                if(r_cs_dlycnt >= 8'd10)
                    r_next_state = ST_DCLK_L;
                else
                    r_next_state = ST_CS_EN;  
            end
			ST_DCLK_L: begin
                if (r_clk_cnt == (IIM_CLK_DIV_NUM - 8'd1))
					r_next_state = ST_DCLK_H;
				else
					r_next_state = ST_DCLK_L;
            end
			ST_DCLK_H:
				if (r_clk_cnt == (IIM_CLK_DIV_NUM - 8'd1)) begin
					if (r_bit_cnt == 8'd15)
						r_next_state = ST_CS_DIS;
					else
						r_next_state = ST_DCLK_L;
				end else
					r_next_state = ST_DCLK_H;
			ST_CS_DIS: begin
				if(r_cs_dlycnt >= 8'd10)
					r_next_state = ST_SPI_INRV;
				else 
					r_next_state = ST_CS_DIS;
			end
			ST_SPI_INRV: begin
				if(r_cmd_dlycnt >= 8'd50)
					r_next_state = ST_DONE;
				else 
					r_next_state = ST_SPI_INRV;
			end
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
			r_rdata_valid	<= 1'b0;
			r_spi_rdata		<= 8'h0;
			r_spi_cs		<= 1'b1;
			r_spi_dclk		<= SPI_CPOL;
			r_spi_mosi		<= 1'b0;
			r_spicom_ready	<= 1'b1;
			r_wr_ack		<= 1'b0;
		end else begin
			case (r_curr_state)
				ST_IDLE: begin
					r_cs_dlycnt		<= 8'd0;
					r_cmd_dlycnt	<= 8'd0;
					r_clk_cnt		<= 8'd0;
					r_bit_cnt		<= 8'd0;
					r_spi_cs		<= 1'b1;
					r_spi_dclk		<= SPI_CPOL;
					r_spi_mosi		<= 1'b0;
					r_spicom_ready	<= 1'b1;
					r_rdata_valid	<= 1'b0;
					r_wr_ack		<= 1'b0;
				end
				ST_CS_EN: begin
					r_spicom_ready	<= 1'b0;
					r_spi_wdata 	<= i_spi_wdata;
					r_spi_cs		<= 1'b0;
					if(r_cs_dlycnt >= 8'd10)
						r_cs_dlycnt <= 8'd0;
					else
						r_cs_dlycnt <= r_cs_dlycnt + 1'b1;
				end
				ST_DCLK_L: begin
					r_spi_dclk	<= 1'b0;
					r_spi_mosi	<= r_spi_wdata[15];
					if (r_clk_cnt == (IIM_CLK_DIV_NUM - 8'd1)) begin
						r_clk_cnt <= 16'd0;
						r_spi_rdata	<= {r_spi_rdata[6:0], i_spi_miso};
					end else
						r_clk_cnt	<= r_clk_cnt + 16'd1;
				end	
				ST_DCLK_H: begin
					r_spi_dclk	<= 1'b1;
					if (r_clk_cnt == (IIM_CLK_DIV_NUM - 8'd1)) begin
						r_clk_cnt <= 16'd0;
						r_bit_cnt <= r_bit_cnt + 4'd1;
						r_spi_wdata	<= r_spi_wdata << 1'b1;
					end else begin
						r_clk_cnt	<= r_clk_cnt + 16'd1;
						r_bit_cnt <= r_bit_cnt;
					end
				end	
				ST_CS_DIS: begin
					r_spi_dclk		<= SPI_CPOL;
					if(r_cs_dlycnt >= 8'd10) begin
						r_rdata_valid	<= 1'b1;
						r_cs_dlycnt 	<= 8'd0;
					end else begin
						r_rdata_valid	<= 1'b0;
						r_cs_dlycnt <= r_cs_dlycnt + 1'b1;
					end
				end
				ST_SPI_INRV: begin
					r_rdata_valid	<= 1'b0;
					r_spi_cs		<= 1'b1;
					if(r_cmd_dlycnt >= 8'd50)
						r_cmd_dlycnt <= 8'd0;
					else
						r_cmd_dlycnt <= r_cmd_dlycnt + 1'b1;
				end
				ST_DONE: begin
					r_spicom_ready	<= 1'b0;
					r_wr_ack		<= 1'b1;
				end
			endcase
		end
	end
	//----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_spicom_ready	= r_spicom_ready;
	assign o_wr_ack			= r_wr_ack;
	assign o_data_out		= r_spi_rdata;
	assign o_spi_cs 		= r_spi_cs;
	assign o_spi_dclk		= r_spi_dclk;
	assign o_spi_mosi		= r_spi_mosi;
	assign o_rdata_valid	= r_rdata_valid;
endmodule
