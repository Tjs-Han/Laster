// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: opto_signal_dejitter
// Date Created 	: 2023/06/29
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:opto_signal_dejitter module
//				Photoelectric conversion signal stabilization module
//				Filter out the jitter signal
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module opto_signal_dejitter
#(
	parameter DEJTER_CLK_CNT	= 100
)
(
	input       i_clk,
	input       i_rst_n,
	input		i_opto_signal,

	output		o_opto_signal
);
	//----------------------------------------------------------------------------------------------
	// Register define
	//----------------------------------------------------------------------------------------------	
	reg 		r_opto_signal;
	reg [3:0]	r_opto_sample;
	reg [15:0]	r_opto_cnt;
	
	always@(posedge i_clk or negedge i_rst_n) begin
	    if(i_rst_n == 0)
	   		r_opto_sample <= 4'h0;
		else
			r_opto_sample <= {r_opto_sample[2:0], i_opto_signal};
	end

	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0) begin
			r_opto_signal  <= 1'b0;
			r_opto_cnt 	   <= 16'd0;
		end else if(r_opto_sample[2] != r_opto_sample[1]) begin
			r_opto_signal  <= r_opto_signal;
			r_opto_cnt 	   <= 16'd0;	
		end else if(r_opto_cnt >= DEJTER_CLK_CNT) begin
			r_opto_signal  <= r_opto_sample[2];
			r_opto_cnt 	   <= 16'd0;
		end else begin
			r_opto_signal  <= r_opto_signal;
			r_opto_cnt     <= r_opto_cnt + 1'b1;
		end
	end
    //----------------------------------------------------------------------------------------------
	// output assign
	//----------------------------------------------------------------------------------------------		
	assign o_opto_signal = r_opto_signal;
			
endmodule 