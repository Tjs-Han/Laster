// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: udp_broadcast
// Date Created 	: 2025/02/25 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:angle2index
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module udp_broadcast
(
	input					i_clk,
	input					i_rst_n,

	input                   i_userlink_state,
	output                  o_broadcast_en
);
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
	localparam BROADCAST_DELAY_SEC	= 8'd2;
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
    reg  [9:0]              r_delay_clkcnt  = 10'd0;
	reg  [9:0]				r_1us_clkcnt 	= 10'd0;
	reg  [9:0]				r_1ms_uscnt 	= 10'd0;	
	reg  [9:0]				r_sec_mscnt     = 10'd0;
    reg  [7:0]				r_1sec_dlycnt   = 8'd10;
	reg                     r_broadcast_en 	= 1'b0;
    //--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    //r_1us_clkcnt
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_1us_clkcnt    <= 10'd0;
		else if(r_1us_clkcnt >= 10'd99)
			r_1us_clkcnt    <= 10'd0;
        else
            r_1us_clkcnt    <= r_1us_clkcnt + 1'b1;
	end

    //r_1ms_uscnt
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_1ms_uscnt <= 10'd0;
		else if(r_1ms_uscnt >= 10'd999)
			r_1ms_uscnt <= 10'd0;
        else if(r_1us_clkcnt >= 10'd99)
            r_1ms_uscnt <= r_1ms_uscnt + 1'b1;
        else
            r_1ms_uscnt <= r_1ms_uscnt;
	end

    //r_sec_mscnt
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_sec_mscnt <= 10'd0;
		else if(r_sec_mscnt >= 10'd999)
			r_sec_mscnt <= 10'd0;
        else if(r_1ms_uscnt >= 10'd999)
            r_sec_mscnt <= r_sec_mscnt + 1'b1;
        else
            r_sec_mscnt <= r_sec_mscnt;
	end

    //r_1sec_dlycnt
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_1sec_dlycnt <= 8'd0;
		else if(r_1sec_dlycnt >= BROADCAST_DELAY_SEC)
			r_1sec_dlycnt <= 8'd0;
        else if(r_sec_mscnt >= 10'd999)
            r_1sec_dlycnt <= r_1sec_dlycnt + 1'b1;
        else
            r_1sec_dlycnt <= r_1sec_dlycnt;
	end

    //r_broadcast_en
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_broadcast_en <= 1'b0;
        else if(i_userlink_state)
            r_broadcast_en <= 1'b0;
		else if(r_1sec_dlycnt >= BROADCAST_DELAY_SEC)
			r_broadcast_en <= 1'b1;
		else
			r_broadcast_en <= 1'b0;
	end

    assign o_broadcast_en   = r_broadcast_en;

endmodule