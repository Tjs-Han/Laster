// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: gpx2_lvds
// Date Created 	: 2024/09/06 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:gpx2_lvds
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
`timescale 1ns/1ps
module gpx2_lvds
(
	input				i_clk,
	input               i_lvds_clk,
	input               i_gpx2_ressig, 
	input  [2:0]        i_lvds_sdo,
	input  [2:0]        i_lvds_frame,

	output [31:0]       o_result_start,
	output [31:0]       o_result_sto11,
	output [31:0]       o_result_sto12,
	output [31:0]       o_result_sto21,
	output [31:0]       o_result_sto22
);
    //--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    reg  [31:0]         r_result_start;
	reg  [31:0]         r_result_stop1;
	reg  [31:0]         r_result_stop2;

	reg  [31:0]         r_valid_data1;
	reg  [31:0]         r_valid_data2;
	reg  [31:0]         r_valid_data3;

	reg  [31:0]         r_result_sto11;
	reg  [31:0]         r_result_sto12;
	
	reg  [31:0]         r_result_sto21;
	reg  [31:0]         r_result_sto22;
	
	
	
	reg  [2:0]          r1_lvds_sdo;
	reg  [2:0]          r2_lvds_sdo;
	
	reg  [2:0]          r1_lvds_frame;
	reg  [2:0]          r2_lvds_frame;
	
	reg  [5:0]          r_result_cnt1 = 6'd32;
	reg  [5:0]          r_result_cnt2 = 6'd32;
	reg  [5:0]          r_result_cnt3 = 6'd32;
	
	reg  [5:0]          r_result_cnt22 = 6'd32;
	reg  [5:0]          r_result_cnt32 = 6'd32;
	
	reg                 r1_gpx2_ressig;
	reg                 r2_gpx2_ressig;

    wire                w_gpx2_ressig;
	//--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------
	always@(posedge i_lvds_clk) begin
		    r1_gpx2_ressig  <= i_gpx2_ressig;
			r2_gpx2_ressig  <= r1_gpx2_ressig;
	end
			
	
	assign w_gpx2_ressig = ~r1_gpx2_ressig & r2_gpx2_ressig;
	
	
	always@(posedge i_lvds_clk) begin
		    r1_lvds_frame   <= i_lvds_frame;
			r2_lvds_frame   <= r1_lvds_frame;
			r1_lvds_sdo     <= i_lvds_sdo;
			r2_lvds_sdo     <= r1_lvds_sdo;
	end

	//r_result_cnt1
	always@(posedge i_lvds_clk) begin
	    if(r_result_cnt1 > 6'd0) begin
		    r_result_start	<= {r_result_start[30:0],i_lvds_frame[0]};
			r_result_cnt1	<= r_result_cnt1 - 1'b1;
		end else if(i_lvds_frame[0]) begin
		    r_result_cnt1	<= 6'd31;
			r_result_start	<= {r_result_start[30:0],i_lvds_frame[0]};
		end
    end

	always@(posedge i_lvds_clk) begin
		if(r_result_cnt1 == 6'd0)
			r_valid_data1	<= r_result_start;
		else
			r_valid_data1	<= r_valid_data1;
	end

	always@(posedge i_lvds_clk) begin
	    if(r_result_cnt2 > 6'd0) begin
		    r_result_stop1	<= {r_result_stop1[30:0],i_lvds_frame[1]};
			r_result_cnt2	<= r_result_cnt2 - 1'b1;
		end else if(i_lvds_frame[1]) begin
		    r_result_cnt2	<= 6'd31;
			r_result_stop1	<= {r_result_stop1[30:0],i_lvds_frame[1]};
		end
    end

	always@(posedge i_lvds_clk) begin
		if(r_result_cnt2 == 6'd0)
			r_valid_data2	<= r_result_stop1;
		else
			r_valid_data2	<= r_valid_data2;
	end

	always@(posedge i_lvds_clk) begin
	    if(r_result_cnt3 > 6'd0) begin
		    r_result_stop2	<= {r_result_stop2[30:0],i_lvds_frame[2]};
			r_result_cnt3	<= r_result_cnt2 - 1'b1;
		end else if(i_lvds_frame[2]) begin
		    r_result_cnt3	<= 6'd31;
			r_result_stop2	<= {r_result_stop2[30:0],i_lvds_frame[2]};
		end
    end

	always@(posedge i_lvds_clk) begin
		if(r_result_cnt3 == 6'd0)
			r_valid_data3	<= r_result_stop2;
		else
			r_valid_data3	<= r_valid_data3;
	end
			
	//----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------	
	assign o_result_start = r_result_start;
	assign o_result_sto11 = r_result_sto11;
	assign o_result_sto12 = r_result_sto12;
	assign o_result_sto21 = r_result_sto21;
	assign o_result_sto22 = r_result_sto22;
			

endmodule 