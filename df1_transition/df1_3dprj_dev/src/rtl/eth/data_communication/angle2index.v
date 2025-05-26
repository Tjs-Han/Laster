// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: angle2index
// Date Created 	: 2024/11/14 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:angle2index
//		The input values are the set start and stop angles
//		Converts Angle values to index values based on angular resolution
//		All values are expressed in complement form after 10,000 times magnification. 
//		For example: set angle is -45°~225°,this file receive vaule is 32‘hFFF92230 ~ 32'h00225510
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module angle2index
(
	input					i_clk,
	input					i_rst_n,

	input  [15:0]			i_angle_reso,
	input  [31:0]			i_start_angle,
	input  [31:0]			i_stop_angle,
	
	output [15:0]			o_start_index,
	output [15:0]			o_stop_index,
	output [15:0]			o_index_num	
);
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
	reg  [15:0]				r_start_index 	= 16'd0;
	reg  [15:0]				r_stop_index 	= 16'd3600;	
	reg  [15:0]				r_index_num_pre = 16'd3600;
	reg  [15:0]				r_index_num 	= 16'd3600;
	
	reg  					r_cal_sig 		= 1'b0;
	reg  [31:0] 			r_dividend 		= 32'd0;
	reg  [15:0] 			r_divisor 		= 16'd0;
	wire [15:0]				w_quotient;
	wire					w_cal_done;
	
	reg  [15:0]				r_angle_reso 	= 16'd1000;
	reg  [31:0]				r_start_angle 	= 32'hFFF24460;
	reg  [31:0]				r_stop_angle 	= 32'h002932E0;
	reg  [15:0]				r_index_max 	= 16'd3600;
	
	reg  [31:0]				r_start_angle_c = 32'h0;
	reg  [31:0]				r_stop_angle_c 	= 32'h002932E0;
	
	reg	 [15:0]				r_start_index1 	= 16'd0;
	reg	 [15:0]				r_stop_index1 	= 16'd3600;	
	
	reg	 [15:0]				r_start_index2 	= 16'd0;
	reg	 [15:0]				r_stop_index2 	= 16'd3600;
	reg  [7:0]				r_index_state 	= 8'd0;
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
	localparam FIXED_ADDVAULE	= 32'h000DBBA0; //90° vaule is 900000

	localparam ST_IDLE			= 8'b0000_0000;
	localparam ST_ASSIGN		= 8'b0000_0010;
	localparam ST_START			= 8'b0000_0100;
	localparam ST_STOP			= 8'b0000_1000;
	localparam ST_END			= 8'b0001_0000;
	localparam ST_OUTPUT		= 8'b0010_0000; 
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
	// r_index_max
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_index_max	<= 16'd3600;
		else if(r_angle_reso == 16'd1200)
			r_index_max	<= 16'd3000;
		else if(r_angle_reso == 16'd1000)
			r_index_max	<= 16'd3600;
		else if(r_angle_reso == 16'd500)
			r_index_max	<= 16'd7200;
		else
			r_index_max	<= 16'd3600;
	end

	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)begin
			r_angle_reso 	<= 16'd1000;
			r_start_angle 	<= 32'hFFF24460;
			r_stop_angle 	<= 32'h002932E0;
		end else begin
			r_angle_reso 	<= i_angle_reso;
			r_start_angle 	<= i_start_angle;
			r_stop_angle 	<= i_stop_angle;
		end
	end

	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 1'b0) begin
			r_start_index 	<= 16'd0;
			r_stop_index	<= 16'd3600;	
			r_index_num 	<= 16'd3600;
			r_index_num_pre	<= 16'd3600;
			r_cal_sig 		<= 1'b0;
			r_dividend 		<= 32'd0;
			r_divisor 		<= 16'd0;
			r_start_angle_c <= 32'h0;
			r_stop_angle_c 	<= 32'h002932E0;
			r_index_state	<= ST_IDLE;
		end else begin
			case(r_index_state)
				ST_IDLE: begin
					r_cal_sig 		<= 1'b0;
					r_dividend 		<= 32'd0;
					r_divisor 		<= 16'd0;
					r_index_state	<= ST_ASSIGN;
				end
				ST_ASSIGN: begin
					r_start_angle_c <= r_start_angle + FIXED_ADDVAULE;
					r_stop_angle_c 	<= r_stop_angle + FIXED_ADDVAULE;
					r_index_state	<= ST_START;
				end
				ST_START: begin
					r_cal_sig 		<= 1'b1;
					r_dividend	 	<= r_start_angle_c;
					r_divisor 		<= r_angle_reso;
					if(w_cal_done)begin
						r_cal_sig 		<= 1'b0;
						r_start_index	<= w_quotient;
						r_index_state	<= ST_STOP;
					end
				end
				ST_STOP: begin
					r_cal_sig 		<= 1'b1;
					r_dividend	 	<= r_stop_angle_c;
					r_divisor 		<= r_angle_reso;
					if(w_cal_done)begin
						r_cal_sig 		<= 1'b0;
						r_stop_index	<= w_quotient;
						r_index_state	<= ST_END;
					end
				end
				ST_END: begin
					if(r_stop_index >= r_start_index)
						r_index_num_pre	<= r_stop_index - r_start_index + 1'b1;
					else
						r_index_num_pre	<= r_start_index - r_stop_index + 1'b1;
					r_index_state	<= ST_OUTPUT;
				end
				ST_OUTPUT: begin
					if(r_index_num_pre >= r_index_max)
						r_index_num		<= r_index_max;
					else
						r_index_num		<= r_index_num_pre;
					r_index_state	<= ST_IDLE;
				end
				default:r_index_state	<= ST_IDLE;
			endcase
		end
	end

	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)begin
			r_start_index1 	<= 16'd0;
			r_stop_index1 	<= 16'd3600;
			r_start_index2 	<= 16'd0;
			r_stop_index2 	<= 16'd3600;
		end else begin
			r_start_index1 	<= r_start_index;
			r_stop_index1 	<= r_stop_index;
			r_start_index2 	<= r_start_index1;
			r_stop_index2 	<= r_stop_index1;
		end
	end
		
	//--------------------------------------------------------------------------------------------------
	// inst domain
	//--------------------------------------------------------------------------------------------------
	division u_calindex_division
	(
		.i_clk				( i_clk					),
		.i_rst_n			( i_rst_n				),
		 
		.i_cal_sig			( r_cal_sig				),
		.i_dividend			( r_dividend			),
		.i_divisor			( r_divisor				),
		.o_quotient			( w_quotient			),
		.o_cal_done			( w_cal_done			)
	);
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign	o_start_index 	= r_start_index2;
	assign	o_stop_index 	= r_stop_index2;
	assign	o_index_num 	= r_index_num;
endmodule 