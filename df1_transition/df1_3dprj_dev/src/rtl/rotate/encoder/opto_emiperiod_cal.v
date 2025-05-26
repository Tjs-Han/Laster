// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: opto_emiperiod_cal
// Date Created 	: 2025/05/14 
// Version 			: V1.1
// -------------------------------------------------------------------------------------------------
// File description	:opto_emiperiod_cal module
//				The light time interval is calculated according to the light frequency
//				Based on Clock counting 
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module opto_emiperiod_cal
#(	
	parameter SEC2NS_REFVAL		= 32'd1000_000_000,
	parameter CLK_PERIOD_NS		= 'd10,
	parameter OPTO_FREQ			= 32'd800_000
)
(
	input       		i_clk,
	input       		i_rst_n,

	input				i_sync_ready,
	output				o_angle_sync,
	output				o_tdc_strdy
);
	//----------------------------------------------------------------------------------------------
	/* 	
		localparam and localparam define
	*/
	//----------------------------------------------------------------------------------------------
	localparam LASER_CLK_CNT	= SEC2NS_REFVAL/OPTO_FREQ/CLK_PERIOD_NS;
	//----------------------------------------------------------------------------------------------
	//	reg define
	//----------------------------------------------------------------------------------------------
	reg				r_angle_sync		= 1'b0;
	reg	[15:0]		r_clk_cnt 			= 16'd0;
	reg             r_tdc_strdy			= 1'b0;
	reg	[15:0]		r_initclk_cnt		= 16'd0;
    //----------------------------------------------------------------------------------------------
	// Flip-flop interface
	//----------------------------------------------------------------------------------------------
	//r_clk_cnt
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_clk_cnt	<= 16'd0;
		end else if(i_sync_ready) begin
			if(r_clk_cnt <= LASER_CLK_CNT-1)
				r_clk_cnt	<= r_clk_cnt + 1'b1;
			else 
				r_clk_cnt	<= 16'd0;
		end else begin
			r_clk_cnt		<= 16'd0;
		end
	end	

	//r_angle_sync
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_angle_sync	<= 1'b0;
		end else if(i_sync_ready) begin
			if(r_clk_cnt + 1'b1 <= LASER_CLK_CNT)
				r_angle_sync	<= 1'b0;
			else
				r_angle_sync	<= 1'b1;
		end else begin
			r_angle_sync	<= 1'b0;
		end
	end	

	//r_tdc_strdy
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_tdc_strdy	<= 1'b0;
		end else if(i_sync_ready) begin
			if(r_clk_cnt + 16'd10 == LASER_CLK_CNT)
				r_tdc_strdy	<= 1'b1;
			else
				r_tdc_strdy	<= 1'b0;
		end else begin
			r_tdc_strdy	<= 1'b0;
		end
	end	
	//----------------------------------------------------------------------------------------------
	// output assign
	//----------------------------------------------------------------------------------------------		
	assign o_angle_sync	= r_angle_sync;
	assign o_tdc_strdy	= r_tdc_strdy;	
endmodule 