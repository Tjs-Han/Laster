// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: data_pre
// Date Created 	: 2024/12/4 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	: The pulse width is calculated according to the leading 
//				and trailing edge values and the signal synchronization is performed
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module data_pre
(
	input						i_clk,
	input						i_rst_n,
	input						i_discal_en,

	input						i_tdc_newsig,
	input  [15:0]				i_code_angle1,
	input  [15:0]				i_code_angle2,
	input  [31:0]				i_rise_data,
	input  [31:0]				i_fall_data,

	output [31:0]				o_rise_data,
	output [31:0]				o_pulse_data,
	output						o_dist_precal_sig,
	output [15:0]				o_dist_precal_angle1,
	output [15:0]				o_dist_precal_angle2
);
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
	localparam	ST_IDLE			=	4'b0000,
				ST_READY		=	4'b0001,
				ST_CAL_PULSE	=	4'b0010,
				ST_END			=	4'b0100;
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
	reg	 [3:0]		r_data_state 			= 4'd0;
	reg	 [31:0]		r_rise_data				= 32'd0;
	reg	 [31:0]		r_pulse_data			= 32'd0;
	reg				r_dist_precal_sig		= 1'b0;
	wire [31:0]		w_result_pulse;
	reg  [15:0]		r_dist_precal_angle1	= 16'd0;
	reg  [15:0]		r_dist_precal_angle2	= 16'd0;
	reg				r_tdc_newsig			= 1'b0;
	reg  [3:0]		r_subcal_dlycnt			= 4'd0;
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------	
	always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n)
			r_tdc_newsig	<= 1'b0;
		else
			r_tdc_newsig	<= i_tdc_newsig;
	end

	always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n)begin
			r_rise_data				<= 32'd0;
			r_pulse_data			<= 32'd0;
			r_dist_precal_sig		<= 1'b0;
			r_dist_precal_angle1	<= 16'd0;
			r_dist_precal_angle2	<= 16'd0;
			r_data_state			<= ST_IDLE;
		end else begin
			case(r_data_state)
				ST_IDLE: begin
					r_rise_data			<= 32'd0;
					r_pulse_data		<= 32'd0;
					r_dist_precal_sig	<= 1'b0;
					r_data_state		<= ST_READY;
					// if(i_discal_en)
					// 	r_data_state		<= ST_READY;
					// else
					// 	r_data_state		<= ST_IDLE;
				end
				ST_READY: begin
					r_dist_precal_sig	<= 1'b0;
					if(r_tdc_newsig) begin
						r_dist_precal_angle1	<= i_code_angle1;
						r_dist_precal_angle2	<= i_code_angle2;
						r_rise_data				<= i_rise_data;
						r_data_state			<= ST_CAL_PULSE;
					end else begin
						r_dist_precal_angle1	<= r_dist_precal_angle1;
						r_dist_precal_angle2	<= r_dist_precal_angle2;
						r_data_state			<= ST_READY;
					end
				end
				ST_CAL_PULSE: begin
					if(r_subcal_dlycnt >= 4'd3)begin
						r_pulse_data	<= w_result_pulse;
						r_data_state	<= ST_END;
					end else begin
						r_pulse_data	<= r_pulse_data;
						r_data_state	<= ST_CAL_PULSE;
					end	
				end
				ST_END: begin	
					r_dist_precal_sig	<= 1'b1;
					r_data_state		<= ST_READY;
				end
				default:
					r_data_state	<= ST_IDLE;
			endcase
		end
	end

	//r_subcal_dlycnt
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_subcal_dlycnt	<= 4'd0;
		else if(r_data_state == ST_CAL_PULSE)
			r_subcal_dlycnt	<= r_subcal_dlycnt + 1'b1;
		else
			r_subcal_dlycnt	<= 4'd0;
	end
    //----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
	sub_ip u_sub_ip
	(
		.DataA						( i_fall_data				),
		.DataB						( i_rise_data				),
		.Result						( w_result_pulse			)
	);
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_rise_data			= r_rise_data;
	assign o_pulse_data			= r_pulse_data;
	assign o_dist_precal_sig	= r_dist_precal_sig;
	assign o_dist_precal_angle1	= r_dist_precal_angle1;
	assign o_dist_precal_angle2	= r_dist_precal_angle2;
endmodule
