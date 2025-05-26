// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: loop_packet
// Date Created 	: 2024/11/27 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:loop_packet
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module loop_packet
#(
	parameter PACKET_DOT_NUM	= 16'd100
)
(
	input					i_clk,
	input					i_rst_n,

	input					i_measure_en,
	input					i_newsig_sync,
	input  [15:0]			i_code_angle1,
	input  [15:0]			i_code_angle2,
	input  [3:0]			i_tdc_lasernum,
	input  [15:0]			i_rise_data,
	input  [15:0]			i_fall_data,
	input  [31:0]			i_dist_data,
	input  [15:0]			i_rssi_data,

	input  [15:0]			i_start_index,
	input  [15:0]			i_stop_index,
	input  [3:0]			i_reso_mode,
	input					i_loopdata_flag,
	input					i_busy,

	output					o_loop_wren,
	output					o_loop_pingpang,
	output [7:0]			o_loop_wrdata,
	output [9:0]			o_loop_wraddr,

	output [15:0]			o_loop_points,
	output					o_loop_make,
    output                  o_loop_cycle_done
);
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
	reg						r_loop_wren 		= 1'b0;
	reg	 [7:0]				r_loop_wrdata 		= 8'd0;
	reg	 [9:0]				r_loop_wraddr 		= 10'd0;
	reg	 [15:0]				r_loop_points 		= 16'd0;
	reg						r_loop_pingpang 	= 1'b0;
	reg						r_loop_make 		= 1'b0;
	reg						r_loop_cycle_done	= 1'b0;
	
	reg	 [11:0]				r_loop_state 		= 12'h0;
	reg	 [15:0]				r_packet_num 		= 16'd0;
	reg	 [2:0]				r_shift_num 		= 3'd0;
	reg	 [63:0]				r_packet_data 		= 64'd0;
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
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------	
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0) begin
			r_loop_state	<= ST_IDLE;
		end else begin
			case(r_loop_state)
				ST_IDLE: begin
					if(i_loopdata_flag)
						r_loop_state	<= ST_WAIT;
					else
						r_loop_state	<= ST_IDLE;
				end
				ST_WAIT: begin
					if(i_newsig_sync)
						r_loop_state	<= ST_WRITE;
					else
						r_loop_state	<= ST_WAIT;
				end
				ST_WAIT2: begin
					if(i_newsig_sync)
						r_loop_state	<= ST_WRITE;
					else
						r_loop_state	<= ST_WAIT2;
				end
				ST_WRITE:
					r_loop_state	<= ST_SHIFT;
				ST_SHIFT: begin
					if(i_loopdata_flag && r_shift_num >= 3'd7)
						r_loop_state	<= ST_SHIFT2;
					else if(~i_loopdata_flag)
						r_loop_state	<= ST_END;
					else
						r_loop_state	<= ST_WRITE;
				end
				ST_SHIFT2: begin
					if(r_packet_num >= PACKET_DOT_NUM)
						r_loop_state	<= ST_SHIFT3;
					else
						r_loop_state	<= ST_WAIT2;
				end
				ST_SHIFT3:	r_loop_state	<= ST_WAIT;
				ST_END	:	r_loop_state	<= ST_IDLE;
				default		:	r_loop_state	<= ST_IDLE;
			endcase
		end
	end

	//r_shift_num
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_shift_num	<= 3'd0;
		else if(r_loop_state == ST_SHIFT)
			r_shift_num	<= r_shift_num + 1'b1;
		else if(r_loop_state == ST_SHIFT2 || r_loop_state == ST_WAIT)
			r_shift_num	<= 3'd0;
	end

	//r_packet_data
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_packet_data	<= 64'd0;
		else if(i_newsig_sync)
			r_packet_data	<= {i_rise_data, i_code_angle1, i_code_angle2, 12'h0, i_tdc_lasernum};
		else if(r_loop_state == ST_SHIFT)
			r_packet_data	<= {r_packet_data[55:0],8'd0};
	end

	//r_loop_wren
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_loop_wren	<= 1'b0;
		else if(r_loop_state == ST_WRITE)
			r_loop_wren	<= 1'b1;
		else
			r_loop_wren	<= 1'b0;
	end

	//r_loop_wrdata
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_loop_wrdata	<= 32'd0;
		else if(r_loop_state == ST_WRITE)
			r_loop_wrdata	<= r_packet_data[63:56];
	end

	//r_loop_wraddr
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_loop_wraddr <= 10'd0;
		else if(r_loop_state	== ST_WAIT || r_loop_state == ST_IDLE)
			r_loop_wraddr <= 10'd0;
		else if(r_loop_state == ST_SHIFT)
			r_loop_wraddr <= r_loop_wraddr + 1'b1;
	end

	//r_packet_num
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0) begin
			r_packet_num	<= 16'd0;
		end else if(r_loop_state == ST_IDLE) begin
			r_packet_num	<= 16'd0;
		end else if(r_loop_state == ST_WAIT || r_loop_state == ST_WAIT2) begin
			if(i_newsig_sync)
				r_packet_num	<= r_packet_num + 1'b1;
			else
				r_packet_num	<= r_packet_num;
		end else if(r_loop_state == ST_SHIFT3)
			r_packet_num	<= 16'd0;
	end

	//r_loop_pingpang
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_loop_pingpang	<= 1'b0;
		else if(r_loop_state == ST_END || r_loop_state	== ST_SHIFT3)
			r_loop_pingpang	<= ~r_loop_pingpang;
	end

	//r_loop_points
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_loop_points	<= PACKET_DOT_NUM;
		else if(r_loop_state	== ST_END || r_loop_state	== ST_SHIFT3)
			r_loop_points	<= r_packet_num;
	end

	//r_loop_make
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_loop_make	<= 1'b0;
		else if(r_loop_state	== ST_END || r_loop_state	== ST_SHIFT3)
			r_loop_make	<= 1'b1;
		else
			r_loop_make	<= 1'b0;
	end

	// //r_loop_cycle_done
	// always@(posedge i_clk or negedge i_rst_n) begin
	// 	if(i_rst_n == 0)
	// 		r_loop_cycle_done	<= 1'b0;
	// 	else if(r_loop_state	== ST_CYCLE_DONE)
	// 		r_loop_cycle_done	<= 1'b1;
	// 	else
	// 		r_loop_cycle_done	<= 1'b0;
	// end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_loop_wren 		    = r_loop_wren;
	assign o_loop_wrdata 		= r_loop_wrdata;
	assign o_loop_wraddr 		= r_loop_wraddr;
	assign o_loop_pingpang 	    = r_loop_pingpang;
	assign o_loop_points		= r_loop_points;
	assign o_loop_make 		    = r_loop_make;
    assign o_loop_cycle_done    = r_loop_cycle_done;
endmodule 