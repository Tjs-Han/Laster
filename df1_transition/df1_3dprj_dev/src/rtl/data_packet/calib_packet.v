// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: calib_packet
// Date Created 	: 2024/11/7 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:calib_packet
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module calib_packet
#(
	parameter PACKET_DOT_NUM	= 16'd100
)
(
	input					i_clk,
	input					i_rst_n,

	input					i_measure_en,
	input					i_newsig_sync,
	input  [15:0]			i_code_angle1,
	input  [3:0]			i_tdc_lasernum,
	input  [15:0]			i_rise_data,
	input  [15:0]			i_fall_data,

	input  [15:0]			i_start_index,
	input  [15:0]			i_stop_index,
	input  [3:0]			i_reso_mode,
	input					i_calibrate_flag,
	input  [15:0]			i_cali_pointnum,
	input					i_busy,

	output					o_calib_wren,
	output					o_calib_pingpang,
	output [7:0]			o_calib_wrdata,
	output [9:0]			o_calib_wraddr,

	output [15:0]			o_calib_points,
	output					o_calib_make,
	output					o_calib_cycle_done		
);
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
	reg						r_calib_wren 		= 1'b0;
	reg	 [7:0]				r_calib_wrdata 		= 8'd0;
	reg	 [9:0]				r_calib_wraddr 		= 10'd0;
	reg	 [15:0]				r_calib_points 		= 16'd0;
	reg						r_calib_pingpang 	= 1'b0;
	reg						r_calib_make 		= 1'b0;
	reg						r_calib_cycle_done	= 1'b0;
	
	reg	 [11:0]				r_calib_state 		= 12'h0;
	reg	 [15:0]				r_packet_num 		= 16'd0;
	reg  [15:0]				r_cali_pointnum		= 16'd0;
	reg	 [2:0]				r_shift_num 		= 3'd0;
	reg	 [63:0]				r_packet_data 		= 64'd0;
	
	reg  [15:0]				r_max_index 		= 16'd2999;
	reg  [3:0]				r_dlycnt			= 4'd0;
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------		
	localparam ST_IDLE			= 12'b0000_0000_0000;
	localparam ST_WAIT			= 12'b0000_0000_0001;
	localparam ST_WAIT2			= 12'b0000_0000_0010;
	localparam ST_WRITE			= 12'b0000_0000_0100;
	localparam ST_SHIFT			= 12'b0000_0000_1000;
	localparam ST_SHIFT2		= 12'b0000_0001_0000;
	localparam ST_SHIFT3		= 12'b0000_0010_0000;
	localparam ST_END			= 12'b0000_0100_0000;
	localparam ST_DONE			= 12'b0000_1000_0000;
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------	
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_max_index	<= 16'd2999;
		else if(i_reso_mode == 4'd0)
			r_max_index	<= 16'd2999;
		else if(i_reso_mode == 4'd1)
			r_max_index	<= 16'd2999;
	end

	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_calib_state	<= ST_IDLE;
		else begin
			case(r_calib_state)
				ST_IDLE: begin
					if(i_calibrate_flag)
						r_calib_state	<= ST_WAIT;
					else
						r_calib_state	<= ST_IDLE;
				end
				ST_WAIT: begin
					if(i_newsig_sync)
						r_calib_state	<= ST_WRITE;
					else
						r_calib_state	<= ST_WAIT;
				end
				ST_WAIT2: begin
					if(i_newsig_sync)
						r_calib_state	<= ST_WRITE;
					else
						r_calib_state	<= ST_WAIT2;
				end
				ST_WRITE:
					r_calib_state	<= ST_SHIFT;
				ST_SHIFT: begin
					if(i_calibrate_flag && r_shift_num >= 3'd7)
						r_calib_state	<= ST_SHIFT2;
					else if(~i_calibrate_flag)
						r_calib_state	<= ST_IDLE;
					else
						r_calib_state	<= ST_WRITE;
				end
				ST_SHIFT2: begin
					if(r_cali_pointnum >= i_cali_pointnum)
						r_calib_state	<= ST_END;
					else if(r_packet_num >= PACKET_DOT_NUM)
						r_calib_state	<= ST_SHIFT3;
					else
						r_calib_state	<= ST_WAIT2;
				end
				ST_SHIFT3:	r_calib_state	<= ST_WAIT;
				ST_END: begin
					r_calib_state	<= ST_DONE;
				end
				ST_DONE: begin
					if(r_dlycnt >= 4'd3)
						r_calib_state	<= ST_IDLE;
					else
						r_calib_state	<= ST_DONE;
				end
				default: r_calib_state	<= ST_IDLE;
			endcase
		end
	end

	//r_dlycnt
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_dlycnt	<= 4'd0;
		else if(r_calib_state	== ST_DONE)
			r_dlycnt	<= r_dlycnt + 1'b1;
		else
			r_dlycnt	<= 4'd0;
	end	

	//r_shift_num
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_shift_num		<= 3'd0;
		else if(r_calib_state	== ST_SHIFT)
			r_shift_num		<= r_shift_num + 1'b1;
		else if(r_calib_state	== ST_SHIFT2 || r_calib_state	== ST_WAIT)
			r_shift_num		<= 3'd0;
	end

	//r_packet_data
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_packet_data	<= 64'd0;
		else if(i_newsig_sync)
			r_packet_data	<= {i_rise_data, i_fall_data, i_code_angle1, 12'h0, i_tdc_lasernum};
		else if(r_calib_state == ST_SHIFT)
			r_packet_data	<= {r_packet_data[55:0],8'd0};
	end

	//r_calib_wren
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_calib_wren	<= 1'b0;
		else if(r_calib_state == ST_WRITE)
			r_calib_wren	<= 1'b1;
		else
			r_calib_wren	<= 1'b0;
	end

	//r_calib_wrdata
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_calib_wrdata	<= 32'd0;
		else if(r_calib_state == ST_WRITE)
			r_calib_wrdata	<= r_packet_data[63:56];
	end

	//r_calib_wraddr
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_calib_wraddr <= 10'd0;
		else if(r_calib_state	== ST_WAIT || r_calib_state == ST_IDLE)
			r_calib_wraddr <= 10'd0;
		else if(r_calib_state == ST_SHIFT)
			r_calib_wraddr <= r_calib_wraddr + 1'b1;
	end

	//r_packet_num
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_packet_num	<= 16'd0;
		else if(r_calib_state == ST_IDLE)
			r_packet_num	<= 16'd0;
		else if(r_calib_state == ST_WAIT || r_calib_state == ST_WAIT2)
			r_packet_num	<= r_packet_num + i_newsig_sync;
		else if(r_calib_state == ST_END || r_calib_state	== ST_SHIFT3)
			r_packet_num	<= 16'd0;
	end

	//r_cali_pointnum
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_cali_pointnum	<= 16'd0;
		else if(r_calib_state == ST_IDLE)
			r_cali_pointnum	<= 16'd0;
		else if(r_calib_state == ST_WAIT || r_calib_state == ST_WAIT2) begin
			if(i_newsig_sync)
				r_cali_pointnum	<= r_cali_pointnum + 1'b1;
			else
				r_cali_pointnum	<= r_cali_pointnum;
		end
	end

	//r_calib_pingpang
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_calib_pingpang	<= 1'b0;
		else if(r_calib_state == ST_END || r_calib_state	== ST_SHIFT3)
			r_calib_pingpang	<= ~r_calib_pingpang;
	end

	//r_calib_points
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_calib_points	<= PACKET_DOT_NUM;
		else if(r_calib_state	== ST_END || r_calib_state	== ST_SHIFT3)
			r_calib_points	<= r_packet_num;
	end

	//r_calib_make
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_calib_make	<= 1'b0;
		else if(r_calib_state	== ST_END || r_calib_state	== ST_SHIFT3)
			r_calib_make	<= 1'b1;
		else
			r_calib_make	<= 1'b0;
	end

	//r_calib_cycle_done
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_calib_cycle_done	<= 1'b0;
		else if(r_calib_state	== ST_END)
			r_calib_cycle_done	<= 1'b1;
		else
			r_calib_cycle_done	<= 1'b0;
	end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_calib_wren 		= r_calib_wren;
	assign o_calib_wrdata 		= r_calib_wrdata;
	assign o_calib_wraddr 		= r_calib_wraddr;
	assign o_calib_pingpang 	= r_calib_pingpang;
	assign o_calib_points		= r_calib_points;
	assign o_calib_make 		= r_calib_make;
	assign o_calib_cycle_done	= r_calib_cycle_done;
endmodule 