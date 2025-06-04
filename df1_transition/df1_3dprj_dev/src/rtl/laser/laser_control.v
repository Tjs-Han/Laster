// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: laser_control
// Date Created 	: 2023/08/15 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:laser control module
//				Output radar laser signal and TDC signal
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration		
//--------------------------------------------------------------------------------------------------
module laser_control
(
	input				i_clk_100m,
	input				i_rst_n,

	input				i_angle_sync,
	input				i_cdctdc_ready,
	input				i_laser_switch,
	input  [7:0]		i_laser_setnum,
	output [7:0]		o_laser_str,
	output				o_laser_sync,
	output [3:0]		o_tdc1_chnlmask,
	output [3:0]		o_tdc2_chnlmask,
	output [3:0]		o_laser_sernum
);  
	//--------------------------------------------------------------------------------------------------
	// reg define
	//-------------------------------------------------------------------------------------------------- 
	reg 				r_laser_switch 		= 1'b0;
	reg 				r_rstidx_tdc 		= 1'b0;
	reg  [7:0]			r_laser_state 		= 8'd0;
	reg  [3:0]			r_emit_cnt 			= 4'd0;
	reg  [7:0]			r_window_cnt 		= 8'd0;
	reg  [3:0]			r_laser_cnt			= 4'd0;

	reg  [7:0]			r_laser_str 		= 8'h00;
	reg					r_laser_sync		= 1'b0;
	reg  [7:0]			r_laser_sernum		= 8'h0C;
	//--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
	localparam		TDC_STOP1_WINDOW	= 8'd48;
	localparam		TDC_STOP2_WINDOW 	= 8'd54;	

	parameter   	ST_IDLE				= 8'b0000_0000,
					ST_READY   			= 8'b0000_0001,
					ST_LASER  			= 8'b0000_0010,
					ST_DONE				= 8'b0000_0100;
	//--------------------------------------------------------------------------------------------------
	// machine state
	//--------------------------------------------------------------------------------------------------				
	always@(posedge i_clk_100m or negedge i_rst_n) begin
	    if(i_rst_n == 0)
		   r_laser_state <= ST_IDLE;
		else begin
			case(r_laser_state)
				ST_IDLE: begin
					if(i_cdctdc_ready)
						r_laser_state <= ST_READY;
					else
						r_laser_state <= ST_IDLE;
				end
				ST_READY: begin
					if(i_angle_sync)
						r_laser_state <= ST_LASER;
					else
						r_laser_state <= ST_READY;
				end
				ST_LASER: begin
					r_laser_state <= ST_DONE;
				end
				ST_DONE: begin
					r_laser_state <= ST_IDLE;
				end
				default: r_laser_state <= ST_IDLE;
			endcase
		end
	end
	//--------------------------------------------------------------------------------------------------
	// sequence logic define
	//--------------------------------------------------------------------------------------------------
	//r_laser_cnt
	always@(posedge i_clk_100m or negedge i_rst_n) begin
		if(i_rst_n == 0) begin
			r_laser_cnt <= 4'd0;
		end else if(r_laser_state == ST_LASER) begin
			if(r_laser_cnt >= 4'd7)
				r_laser_cnt <= 4'd0;
			else
				r_laser_cnt	<= r_laser_cnt + 1'b1;
		end
	end

	//r_laser_str		
	always@(posedge i_clk_100m or negedge i_rst_n) begin
		if(i_rst_n == 0) begin
			r_laser_str <= 8'h00;
		end else if(r_laser_state == ST_LASER) begin
			if(i_laser_switch) begin
				r_laser_str <= (8'h01 << i_laser_setnum);
			end else begin
				r_laser_str <= (8'h01 << r_laser_cnt);
			end
		end else begin
			r_laser_str <= 8'h00;
		end
	end

	//r_laser_sync
	always@(posedge i_clk_100m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_laser_sync	<= 1'b0;
		else if(r_laser_state == ST_LASER)
			r_laser_sync	<= 1'b1;
		else 
			r_laser_sync	<= 1'b0;
	end

	// //r_laser_sernum
	// always@(posedge i_clk_100m or negedge i_rst_n) begin
	// 	if(i_rst_n == 0)
	// 		r_laser_sernum	<= 8'h0C;
	// 	else begin
	// 		case(r_laser_str)
	// 			8'h01: r_laser_sernum	<= 8'h0C;
	// 			8'h02: r_laser_sernum	<= 8'h0D;
	// 			8'h04: r_laser_sernum	<= 8'h0E;
	// 			8'h08: r_laser_sernum	<= 8'h0F;
	// 			8'h10: r_laser_sernum	<= 8'hC0;
	// 			8'h20: r_laser_sernum	<= 8'hD0;
	// 			8'h40: r_laser_sernum	<= 8'hE0;
	// 			8'h80: r_laser_sernum	<= 8'hF0;
	// 			default:;
	// 		endcase
	// 	end
	// end

	//r_laser_sernum
	always@(posedge i_clk_100m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_laser_sernum	<= 8'h0C;
		else begin
			case(r_laser_str)
				8'h01: r_laser_sernum	<= 8'h0C;
				8'h02: r_laser_sernum	<= 8'hF0;
				8'h04: r_laser_sernum	<= 8'hE0;
				8'h08: r_laser_sernum	<= 8'hD0;
				8'h10: r_laser_sernum	<= 8'hC0;
				8'h20: r_laser_sernum	<= 8'h0F;
				8'h40: r_laser_sernum	<= 8'h0E;
				8'h80: r_laser_sernum	<= 8'h0D;
				default:;
			endcase
		end
	end
	//--------------------------------------------------------------------------------------------------
	// assign define
	//--------------------------------------------------------------------------------------------------
	assign      o_laser_str 	= r_laser_str;
	assign      o_laser_sync 	= r_laser_sync;
	assign      o_tdc1_chnlmask	= r_laser_sernum[3:0];
	assign		o_tdc2_chnlmask	= r_laser_sernum[7:4];
	assign		o_laser_sernum	= r_laser_cnt;
endmodule 