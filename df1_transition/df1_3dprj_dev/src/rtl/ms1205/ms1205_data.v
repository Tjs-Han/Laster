// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: ms1205_data
// Date Created 	: 2023/08/15 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:ms1205_data
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module ms1205_data
(
	input				i_clk_50m,
	input				i_rst_n,

	input				i_angle_sync,
	input				i_motor_state,
	input  [15:0]		i_code_angle,
	input				i_rise_err_sig,
	input				i_fall_err_sig,
	input				i_rise_new_sig,
	input				i_fall_new_sig,

	input	[15:0]		i_rise_data,
	input	[15:0]		i_fall_data,

	output	[15:0]		o_rise_data,
	output	[15:0]		o_fall_data,
	output				o_tdc_err_sig,
	output				o_tdc_new_sig,
	output [15:0]		o_code_angle_tdc
);
	//--------------------------------------------------------------------------------------------------
	// reg define
	//--------------------------------------------------------------------------------------------------
	reg		[2:0]	r_data_state 	= 3'd0;
	reg		[15:0]	r_rise_data 	= 16'd0;
	reg		[15:0]	r_fall_data 	= 16'd0;
	reg				r_tdc_new_sig 	= 1'b0;
	reg		[15:0]	r_code_angle_tdc= 16'd0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_data_state	<= 3'd0;
			r_rise_data		<= 16'd0;
			r_fall_data		<= 16'd0;
		end
		else begin
			case(r_data_state)
				3'd0	:begin
					if(i_motor_state)
						r_data_state	<= 3'd1;
				end
				3'd1:	begin
					if(i_angle_sync)
						r_data_state	<= 3'd2;
				end
				3'd2:	begin
					if(i_angle_sync)begin
						r_rise_data		<= 16'd0;
						r_fall_data		<= 16'd0;
						r_data_state	<= 3'd6;
					end
					else if(i_rise_new_sig && i_fall_new_sig)begin
						r_rise_data		<= i_rise_data;
						r_fall_data		<= i_fall_data;
						r_data_state	<= 3'd5;
					end
					else if(i_rise_new_sig)begin
						r_rise_data		<= i_rise_data;
						r_data_state	<= 3'd3;
					end
					else if(i_fall_new_sig)begin
						r_fall_data		<= i_fall_data;
						r_data_state	<= 3'd4;
					end
				end
				3'd3:	begin
					if(i_angle_sync)begin
						r_fall_data		<= 16'd0;
						r_data_state	<= 3'd6;
					end
					else if(i_fall_new_sig)begin
						r_fall_data		<= i_fall_data;
						r_data_state	<= 3'd5;
					end
				end
				3'd4:	begin
					if(i_angle_sync)begin
						r_rise_data		<= 16'd0;
						r_data_state	<= 3'd6;
					end
					else if(i_rise_new_sig)begin
						r_rise_data		<= i_rise_data;
						r_data_state	<= 3'd5;
					end
				end
				3'd5:	begin
					r_data_state	<= 3'd0;
				end
				3'd6:	begin
					r_data_state	<= 3'd2;
				end
				default:
					r_data_state	<= 3'd0;
				endcase
			end
	
	//r_tdc_new_sig
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_tdc_new_sig	<= 1'b0;
		else if(r_data_state == 3'd5 || r_data_state == 3'd6)
			r_tdc_new_sig	<= 1'b1;
		else
			r_tdc_new_sig	<= 1'b0;
	end
	
	//r_code_angle_tdc
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_code_angle_tdc	<= 16'd0;
		else if(i_angle_sync)
			r_code_angle_tdc	<= i_code_angle;
	end
			
	assign	o_rise_data	  	= r_rise_data;
	assign	o_fall_data	  	= r_fall_data;
	assign	o_tdc_err_sig 	= i_rise_err_sig | i_fall_err_sig;
	assign	o_tdc_new_sig 	= r_tdc_new_sig;
	assign  o_code_angle_tdc= r_code_angle_tdc;
endmodule 