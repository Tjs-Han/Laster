// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: encoder generate
// Date Created 	: 2023/09/06 
// Version 			: V1.1
// -------------------------------------------------------------------------------------------------
// File description	:encoder generate
//				There are two modes based on user Settings
//				1:Calibration mode; 0:Normal mode
//				The frequency of the control signal is calculated according to 
//				the edge signal of the photoelectric pulse in normal mode
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module encoder_generate_6
(
	input				i_clk_50m,
	input				i_rst_n,

	input				i_opto_switch,
	input				i_motor_state,
	input				i_cal_mode,
	input	[3:0]		i_reso_mode,
	input				i_laser_mode,
	input	[15:0]		i_angle_offset,

	output	[15:0]		o_js_cal,
	output	[7:0]		o_code_wraddr,
	output	[31:0]		o_code_wrdata,
	output				o_code_wren,

	output	[15:0]		o_code_angle,
	output				o_zero_sign,
	output				o_angle_sync
);	
	//----------------------------------------------------------------------------------------------
	// reg and wire define
	//----------------------------------------------------------------------------------------------
	reg      	   	r_opto_switch1 			= 1'b1;
	reg      	   	r_opto_switch2 			= 1'b1;
	reg [23:0]		r_high_time_prior_cnt 	= 24'd0;			   
	reg [23:0]		r_high_time_current_cnt = 24'd0;
	
	reg				r_zero_sign_r;
	reg [15:0]		r_code_angle 			= 16'd0;
	reg				r_angle_sync_cal 		= 1'b0;
	reg				r_zero_sign_cal 		= 1'b0;
	reg [15:0]		r_angle_cal_value 		= 16'd439;
	reg [15:0]		r_angle_cal_cnt 		= 16'd0;

	reg [23:0]		r_js_cal 				= 24'd0;
	reg [23:0]		r_cyc_cnt 				= 24'd0;
	reg [7:0]		r_fs_cnt 				= 8'd20;
	reg [7:0]		r_fs_cnt2 				= 8'd40;
	reg [15:0]		r_fs_factor 			= 16'd3276;
	reg [23:0]		r_mult1_dataA 			= 24'd0;
    
	
	reg [7:0]		fs_state 				= 8'd0;
	reg        		r_angle_sync			= 1'd0;
	reg [7:0]		r_pss_cnt 				= 8'd0;
	reg [23:0]		r_delay_cnt 			= 8'd0;
	reg [7:0]		r_angle_cnt 			= 8'd0;
	reg [15:0]		r_inrv_cnt 				= 16'd0;
	reg				r_opto_rise 			= 1'd0;
	reg [15:0]		r_angle_zero 			= 16'd0;

	reg	[7:0] 		r_code_wraddr 			= 8'd0;
	reg	[31:0] 		r_code_wrdata 			= 32'd0;
	reg				r_code_wren	  			= 1'b0;
	reg	[31:0]		r_code_cnt    			= 32'd0;

	wire     	  	w_opto_rise;
	wire     	  	w_opto_fall;
	wire			w_zero_sign;
	wire [39:0]		w_mult1_result;	
	
	wire [31:0]		w_mult2_result;
	wire	   		w_angle_sync_pre;
	//----------------------------------------------------------------------------------------------
	// cali mode output data
	//----------------------------------------------------------------------------------------------
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_cal_value <= 16'd439;
		else
			r_angle_cal_value <= 16'd439;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
	   if(i_rst_n == 0)
		   r_angle_cal_cnt <= 16'd0;
		else if(r_angle_cal_cnt + 1'b1 >= r_angle_cal_value)
		   r_angle_cal_cnt <= 16'd0;
		else
		   r_angle_cal_cnt <= r_angle_cal_cnt + 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
	   if(i_rst_n == 0)
		   r_angle_sync_cal <= 1'b0;
		else if(r_angle_cal_cnt + 1'b1 >= r_angle_cal_value)
		   r_angle_sync_cal <= 1'b1;
		else
		   r_angle_sync_cal <= 1'b0;
			
	//r_zero_sign_cal
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_zero_sign_cal	<= 1'b0;
		else if(r_code_angle == 16'd3599 && o_angle_sync && i_reso_mode == 4'd0)
			r_zero_sign_cal	<= 1'b1;
		else if(r_code_angle == 16'd7199 && o_angle_sync && i_reso_mode == 4'd1)
			r_zero_sign_cal	<= 1'b1;		
		else
			r_zero_sign_cal	<= 1'b0;
		   
	//----------------------------------------------------------------------------------------------
	// motor mode output data：zero_sign, angle_sync
	//----------------------------------------------------------------------------------------------	
	always@(posedge i_clk_50m or negedge i_rst_n)
	    if(i_rst_n == 0)begin
			r_opto_switch1 <= 1'b1;
			r_opto_switch2 <= 1'b1;
		end
		else begin
			r_opto_switch1 <= i_opto_switch;
			r_opto_switch2 <= r_opto_switch1;
		end
			
	assign w_opto_rise = ~r_opto_switch2 & r_opto_switch1;
	assign w_opto_fall = ~r_opto_switch1 & r_opto_switch2;
	
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_high_time_current_cnt <= 24'd0;
		else if(w_opto_fall)
			r_high_time_current_cnt <= 24'd0;
		else if(r_high_time_current_cnt == 24'hfffff0)
			r_high_time_current_cnt <= 24'hfffff0;
		else
			r_high_time_current_cnt <= r_high_time_current_cnt + 1'b1;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_high_time_prior_cnt   <= 24'd0;
		else if(w_opto_rise)
			r_high_time_prior_cnt   <= r_high_time_current_cnt + (r_high_time_current_cnt >> 1'd1);
			
	assign w_zero_sign = (r_high_time_current_cnt >= r_high_time_prior_cnt) ? w_opto_rise : 1'b0;
	
/////////////////////////////////////////////////////////////////////////////////				   
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_fs_cnt 	<= 8'd20;
		else if(i_reso_mode == 4'd0)
			r_fs_cnt 	<= 8'd20;//0.1
		else if(i_reso_mode == 4'd1)
			r_fs_cnt 	<= 8'd40;//0.05
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_fs_cnt2 	<= 8'd40;
		else if(i_reso_mode == 4'd0)
			r_fs_cnt2 	<= 8'd40;//0.1
		else if(i_reso_mode == 4'd1)
			r_fs_cnt2 	<= 8'd80;//0.05
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_cyc_cnt <= 24'd0;
		else if(w_opto_rise)
			r_cyc_cnt <= 24'd0;
		else if(r_cyc_cnt >= 24'hffff00)
			r_cyc_cnt <= r_cyc_cnt;
		else
			r_cyc_cnt <= r_cyc_cnt + 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_mult1_dataA 	<= 24'd0;
		else if(w_zero_sign)
			r_mult1_dataA	<= r_cyc_cnt >> 1'b1;
		else if(w_opto_rise)
			r_mult1_dataA	<= r_cyc_cnt;

	//r_fs_factor
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_fs_factor <= 16'd3276;//0.1
		else if(i_reso_mode == 4'd0)
			r_fs_factor <= 16'd3276;//0.1
		else if(i_reso_mode == 4'd1)
			r_fs_factor <= 16'd1638;//0.05
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_js_cal  <= 24'd0;
		else 
			r_js_cal  <= w_mult1_result[39:16];
			
	parameter 	FS_IDLE  	= 8'b0000_0000,
				FS_WAIT  	= 8'b0000_0010,
				FS_JUDGE 	= 8'b0000_0100,
				FS_BEGIN 	= 8'b0000_1000,
				FS_DELAY 	= 8'b0001_0000,				
				FS_CYC   	= 8'b0010_0000,
				FS_INRV  	= 8'b0100_0000;
				 
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			fs_state     <= FS_IDLE;
			r_pss_cnt    <= 8'd0;
			r_delay_cnt  <= 16'd0;
			r_angle_sync <= 1'b0;
			r_angle_cnt  <= 8'd0;
			r_inrv_cnt   <= 16'd0;
		end
		else begin
			case(fs_state)
				FS_IDLE  :begin
					fs_state     <= FS_WAIT;
				end
				FS_WAIT	:begin
					if(i_motor_state)
						fs_state	<= FS_JUDGE;
					else
						fs_state	<= FS_WAIT;
				end
				FS_JUDGE :begin
					if(w_zero_sign || r_zero_sign_r)begin
						r_pss_cnt	<= 8'd0;
						fs_state	<= FS_DELAY;
					end
					else 
						fs_state	<= FS_JUDGE;
				end				
				FS_BEGIN :begin
					r_angle_sync	<= 1'b0;
					if(w_opto_rise || r_opto_rise)begin
						r_pss_cnt		<= r_pss_cnt + 1'b1;
						fs_state		<= FS_DELAY;
					end
					else 
						fs_state		<= FS_BEGIN;
				end
				FS_DELAY	:begin
					if(r_delay_cnt < 8'd5)begin
						r_delay_cnt		<= r_delay_cnt + 1'b1;
						fs_state		<= FS_DELAY;
					end
					else begin
						r_delay_cnt		<= 8'd0;
						r_angle_cnt		<= 8'd0;
						r_inrv_cnt		<= 16'd0;
						fs_state		<= FS_CYC;
					end
				end
				FS_CYC  :begin
					r_angle_sync 	<= 1'b1;
					r_angle_cnt  	<= r_angle_cnt + 1'b1;
					fs_state     	<= FS_INRV;
				end
				FS_INRV :begin
					r_angle_sync 	<= 1'b0;
					if(r_inrv_cnt + 2'd2 < r_js_cal)begin
						r_inrv_cnt		<= r_inrv_cnt + 1'b1;
						fs_state		<= FS_INRV;
					end
					else begin
						r_inrv_cnt		<= 16'd0;
						if(r_pss_cnt < 8'd178)begin
							if(r_angle_cnt < r_fs_cnt)
								fs_state		<= FS_CYC;
							else
								fs_state		<= FS_BEGIN;
						end
						else begin
							if(r_angle_cnt < r_fs_cnt2)
								fs_state		<= FS_CYC;
							else 
								fs_state		<= FS_JUDGE;
						end
					end
				end
				default:fs_state     <= FS_IDLE;
			endcase
		end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_rise <= 1'b0;
		else if(fs_state == FS_BEGIN || fs_state == FS_WAIT)
			r_opto_rise <= 1'b0;
		else if(w_opto_rise && w_zero_sign == 1'b0)
			r_opto_rise <= 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_zero_sign_r <= 1'd0;
		else if(w_zero_sign)
			r_zero_sign_r <= 1'd1;
		else if(fs_state == FS_JUDGE || fs_state == FS_WAIT || w_opto_rise)
			r_zero_sign_r <= 1'd0;
				
	//////////////////////////////////////////////////////////////////////////////////
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_zero <= 16'd0;
		else 
			r_angle_zero <= w_mult2_result[15:0] + i_angle_offset[3:0];
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_code_angle <= 16'd0;
		else if(fs_state == FS_JUDGE && (w_zero_sign || r_zero_sign_r))begin
			if(i_reso_mode == 4'd0)
				r_code_angle <= r_angle_zero;
			else
				r_code_angle <= {r_angle_zero[14:0],1'b0};
		end
		else if(o_angle_sync)begin
			if(r_code_angle >= 16'd3599 && i_reso_mode == 4'd0)
				r_code_angle <= 16'd0;
			else if(r_code_angle >= 16'd7199 && i_reso_mode == 4'd1)
				r_code_angle <= 16'd0;
			else
				r_code_angle <= r_code_angle + 1'b1;
		end
	//----------------------------------------------------------------------------------------------
	// motor mode output data：zero_sign, angle_sync
	//----------------------------------------------------------------------------------------------			
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_code_cnt <= 32'd0;
		else if(w_opto_rise || w_zero_sign)
			r_code_cnt <= 32'd0;
		else 
			r_code_cnt <= r_code_cnt + 1'd1;
	end

	// always@(posedge i_clk_50m or negedge i_rst_n) begin
	// 	if(i_rst_n == 0)
	// 		r_code_wrdata <= 32'd0;
	// 	else if(w_opto_rise || w_zero_sign) begin
	// 		r_code_wrdata[23:0]	 <= r_code_cnt[23:0];
	// 		r_code_wrdata[31:24] <= r_code_cnt[7:0] + r_code_cnt[15:8] + r_code_cnt[23:16];
	// 	end
	// end
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_code_wrdata <= 32'd0;
		else if(w_opto_rise || w_zero_sign)
			r_code_wrdata <= r_code_cnt;
	end

	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_code_wraddr <= 8'd0;
		else if(w_zero_sign)
			r_code_wraddr <= 8'd0;
		else if(w_opto_rise)
			r_code_wraddr <= r_code_wraddr + 1'b1;
	end

	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_code_wren <= 1'b0;
		else
			r_code_wren <= w_opto_rise | o_zero_sign;
	end
			
	assign o_code_wraddr 	= r_code_wraddr;
	assign o_code_wrdata 	= r_code_wrdata;
	assign o_code_wren 		= r_code_wren;
			
	assign w_angle_sync_pre	= (i_cal_mode) ? r_angle_sync_cal : r_angle_sync;
	assign o_zero_sign		= (i_cal_mode) ? r_zero_sign_cal : w_zero_sign;
	assign o_angle_sync 	= (i_laser_mode)? w_angle_sync_pre : 1'b0;
	assign o_code_angle 	= r_code_angle;
	assign o_js_cal			= r_js_cal[15:0];
	
	multiplier2 U1
	(
		.Clock				( i_clk_50m				), 
		.ClkEn				( 1'b1					), 
		
		.Aclr				( 1'b0					), 
		.DataA				( r_mult1_dataA			), 
		.DataB				( r_fs_factor			), 
		.Result				( w_mult1_result		)
	);
	
	multiplier U2
	(
		.Clock				( i_clk_50m				), 
		.ClkEn				( 1'b1					), 
		
		.Aclr				( 1'b0					), 
		.DataA				( {4'd0,i_angle_offset[15:4]}), 
		.DataB				( 16'd10				), 
		.Result				( w_mult2_result		)
	);

endmodule 