// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: signal_dejitter
// Date Created 	: 2023/11/13
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:signal_dejitter module
//				Filter out the jitter signal
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module signal_dejitter
#(
	parameter DEJTER_CLK_CNT	= 10
)
(
	input       i_clk_50m,
	input       i_rst_n,
	input		i_signal,

	output		o_signal
);
	//----------------------------------------------------------------------------------------------
	// Register define
	//----------------------------------------------------------------------------------------------	
	reg 		r_signal_out;
	reg [3:0]	r_signal_sample;
	reg [15:0]	r_opto_cnt;
	
	always@(posedge i_clk_50m or negedge i_rst_n) begin
	    if(i_rst_n == 0)
	   		r_signal_sample <= 4'h0;
		else
			r_signal_sample <= {r_signal_sample[2:0], i_signal};
	end

	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0) begin
			r_signal_out  	<= 1'b0;
			r_opto_cnt 	   	<= 16'd0;
		end else if(r_signal_sample[2] != r_signal_sample[1]) begin
			r_signal_out  	<= r_signal_out;
			r_opto_cnt 	   	<= 16'd0;	
		end else if(r_opto_cnt >= DEJTER_CLK_CNT) begin
			r_signal_out  	<= r_signal_sample[2];
			r_opto_cnt 	   	<= 16'd0;
		end else begin
			r_signal_out	<= r_signal_out;
			r_opto_cnt		<= r_opto_cnt + 1'b1;
		end
	end
			
	assign o_signal = r_signal_out;
			
endmodule 