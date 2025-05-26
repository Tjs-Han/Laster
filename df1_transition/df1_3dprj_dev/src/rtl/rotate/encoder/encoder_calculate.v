// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: encoder_calculate
// Date Created 	: 2025/05/14 
// Version 			: V1.1
// -------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------
// File description	:encoder_calculate
//                  calculate the code disk
// -------------------------------------------------------------------------------------------------
// Revision History :V1.1
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module encoder_calculate
(
	input			    i_clk,
	input			    i_rst_n, 
	input			    i_opto_switch,
    
	output			    o_zero_sign,
	output			    o_opto_rise
);
    //----------------------------------------------------------------------------------------------
	// reg signal define
	//----------------------------------------------------------------------------------------------
    reg      	        r_opto_switch1          = 1'b1;
	reg      	        r_opto_switch2          = 1'b1;
    reg  [7:0]          r_codedge_cnt           = 8'd0;
    reg  [31:0]	        r_pulse_time_avecnt     = 32'd9259;
    reg  [31:0]	        r_pulse_time_prior_cnt  = 32'd0;
	reg  [31:0]	        r_time_sumcnt           = 32'd0;
    reg  [31:0]         r_pulsetime_actcnt      = 32'd0;
    //----------------------------------------------------------------------------------------------
	// motor mode output data：zero_sign
	//----------------------------------------------------------------------------------------------
    //r_opto_switch1， r_opto_switch2
	always@(posedge i_clk or negedge i_rst_n)begin
	    if(!i_rst_n)begin
			r_opto_switch1 <= 1'b1;
			r_opto_switch2 <= 1'b1;
		end else begin
			r_opto_switch1 <= i_opto_switch;
			r_opto_switch2 <= r_opto_switch1;
		end
    end
			
	assign o_opto_rise = ~r_opto_switch2 & r_opto_switch1;

    // r_time_sumcnt
    always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n)
			r_time_sumcnt <= 32'd0;
		else if(r_codedge_cnt == 8'd16)
			r_time_sumcnt <= 32'd0;
		else
			r_time_sumcnt <= r_time_sumcnt + 1'b1;
    end

    always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n) begin
            r_codedge_cnt       <= 8'd0;
            r_pulse_time_avecnt <= 32'd9259;
        end else if(r_codedge_cnt == 8'd16) begin
            r_codedge_cnt       <= 8'd0;
            r_pulse_time_avecnt <= (r_time_sumcnt >> 4'd4);
        end else if(o_opto_rise) begin
            r_codedge_cnt       <= r_codedge_cnt + 1'b1;
            r_pulse_time_avecnt <= r_pulse_time_avecnt;
        end 
    end

    always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n)
			r_pulsetime_actcnt <= 32'd0;
		else if(o_opto_rise)
			r_pulsetime_actcnt <= 32'd0;
		else
			r_pulsetime_actcnt <= r_pulsetime_actcnt + 1'b1;
    end

    always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n)
			r_pulse_time_prior_cnt   <= 32'd0;
		else 
            r_pulse_time_prior_cnt   <= r_pulse_time_avecnt + (r_pulse_time_avecnt >> 2'd1);//1.5
    end
			
	assign o_zero_sign = (r_pulsetime_actcnt >= r_pulse_time_prior_cnt) ? o_opto_rise : 1'b0;
endmodule