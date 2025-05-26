// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: opto_switch
// Date Created 	: 2024/09/07 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------
// File description	:opto_switch
//                  receive optp signal or Creating a fake coded signal  
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module opto_switch
#(
	parameter SEC2NS_REFVAL	= 1000_000_000,
	parameter CLK_PERIOD_NS	= 10,
	parameter MOTOR_FREQ	= 100,
	parameter TOOTH_NUM		= 100
)
(
	input       i_clk,
	input       i_rst_n,

	input		i_cal_mode,
	input		i_code_sigin,

	output		o_opto_switch
);
	//----------------------------------------------------------------------------------------------
	/* 	parameter and localparam define
		two code per tooth
		CLK_PERIOD_NS: i_clk period,the units are ns,use to calculate clk cnt
		TOTAL_CODE_NUM: df1 the code disk is designed for 100 teeth, 98 normal tooth and 1 zero tooth
						which is 196 normal code and 2 zero code.
	*/ 
	//----------------------------------------------------------------------------------------------
	parameter TOTAL_CODE_NUM	= TOOTH_NUM << 1;
	parameter NORMAL_CODE_NUM	= (TOOTH_NUM-2) << 1;
	parameter NORMCODE_CLKCNT	= SEC2NS_REFVAL/CLK_PERIOD_NS/MOTOR_FREQ/TOTAL_CODE_NUM;
	parameter ZEROCODE_CLKCNT	= NORMCODE_CLKCNT << 1;
	//--------------------------------------------------------------------------------------------------
	// reg define
	//--------------------------------------------------------------------------------------------------
	reg			r_opto_switch_cal	= 1'b1;
	reg	[31:0]	r_clk_cnt 			= 32'd0;
	reg	[15:0]	r_code_cnt 			= 16'd0;
	//--------------------------------------------------------------------------------------------------
	/*
		Creating a fake coded signal according to lasring freq and code tooth
	*/
	//--------------------------------------------------------------------------------------------------
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_clk_cnt	<= 32'd0;
		else if(r_code_cnt <= (NORMAL_CODE_NUM - 1))begin
			if(r_clk_cnt >= NORMCODE_CLKCNT)
				r_clk_cnt	<= 32'd0;
			else
				r_clk_cnt	<= r_clk_cnt + 1'b1;
		end else begin
			if(r_clk_cnt >= ZEROCODE_CLKCNT)
				r_clk_cnt	<= 32'd0;
			else
				r_clk_cnt	<= r_clk_cnt + 1'b1;
		end
	end
	
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_code_cnt	<= 16'd0;
		else if(r_code_cnt <= (NORMAL_CODE_NUM - 1))begin
			if(r_clk_cnt >= NORMCODE_CLKCNT)
				r_code_cnt	<= r_code_cnt + 1'b1;
			else
				r_code_cnt	<= r_code_cnt;
		end else begin
			if(r_clk_cnt >= ZEROCODE_CLKCNT)begin
				if(r_code_cnt >= (NORMAL_CODE_NUM + 1))
					r_code_cnt	<= 16'd0;
				else
					r_code_cnt	<= r_code_cnt + 1'b1;
			end else
				r_code_cnt	<= r_code_cnt;
		end
	end
	
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_opto_switch_cal	<= 1'b1;
		else if(r_code_cnt <= (NORMAL_CODE_NUM - 1))begin
			if(r_clk_cnt >= NORMCODE_CLKCNT)
				r_opto_switch_cal	<= ~r_opto_switch_cal;
			else
				r_opto_switch_cal	<= r_opto_switch_cal;
		end else begin
			if(r_clk_cnt >= ZEROCODE_CLKCNT)
				r_opto_switch_cal	<= ~r_opto_switch_cal;
			else
				r_opto_switch_cal	<= r_opto_switch_cal;
		end
	end
			
			
	assign o_opto_switch = (i_cal_mode) ? r_opto_switch_cal : i_code_sigin;
			
endmodule 