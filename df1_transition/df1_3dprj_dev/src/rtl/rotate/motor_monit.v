// -------------------------------------------------------------------------------------------------
// File description	:motor control module
//				Only output o_motor_state siganl and set to 1
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//				no use so far
//				Do not understand the meaning of this module, But reserved
//				It may be deleted later
//--------------------------------------------------------------------------------------------------
module motor_monit
(
	input				i_clk,
	input				i_rst_n,

	input				i_cal_mode,
	input [1:0]			i_freq_mode,//0 = 30hz ,1 = 15hz 2 = 50HZ
	input				i_measure_mode,
	input				i_opto_switch,
	
	output				o_motor_state,
	output				o_motor_monit		
);

	reg        	 		r_motor_pwm    	= 1'b0;
	reg         		r_motor_state 	= 1'b0;

	reg [15:0]			r_pwm_value   	= 16'd970;
	reg [15:0]			r_pwm_cnt     	= 16'd999;

	reg        			r_opto_switch1 	= 1'b1;
	reg        			r_opto_switch2	= 1'b1;

	wire       			w_opto_rise;
	
	reg [7:0]			r_opto_cnt0		= 8'd0;
	reg [23:0]			r_opto_cnt1		= 24'd0;
	reg [23:0]			r_motor_speed; 
	
	reg [31:0]			r_delay_40s		= 32'd0;
	reg					r_delay_en		= 1'b0;
	
	reg [23:0]			r_cnt_state_high= 24'd1_750_000;
	reg [23:0]			r_cnt_state_low	= 24'd1_583_333;
	
	reg					r_motor_err_sig = 1'b0;
	reg	[7:0]			r_motor_err_cnt = 8'd0;
	reg	[3:0]			r_state_cnt 	= 4'd0;
	reg	[3:0]			r_slow_cnt 		= 4'd8;
	reg	[3:0]			r_fast_cnt 		= 4'd0;

	reg	[15:0]			r_pwm_value_0 	= 16'd0;
	reg					r_opto_err;
	
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)begin
			r_cnt_state_high	<= 24'd1_833_333;
			r_cnt_state_low		<= 24'd1_500_000;
		end else if(i_freq_mode == 2'd0)begin
			r_cnt_state_high	<= 24'd1_833_333;
			r_cnt_state_low		<= 24'd1_500_000;
		end else if(i_freq_mode == 2'd1)begin
			r_cnt_state_high	<= 24'd3_666_666;
			r_cnt_state_low		<= 24'd3_000_000;
		end else if(i_freq_mode == 2'd2)begin
			r_cnt_state_high	<= 24'd1_100_000;
			r_cnt_state_low		<= 24'd900_000;
		end
	end

	always@(posedge i_clk or negedge i_rst_n) begin
	    if(i_rst_n == 0)begin
		   r_opto_switch1 <= 1'b1;
		   r_opto_switch2 <= 1'b1;
		end else if(i_cal_mode)begin
		   r_opto_switch1 <= 1'b1;
		   r_opto_switch2 <= 1'b1;
		end else begin
		   r_opto_switch1 <= i_opto_switch;
		   r_opto_switch2 <= r_opto_switch1;
		end
	end	
	assign w_opto_rise = ~r_opto_switch2 & r_opto_switch1;
	
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)begin
			r_opto_cnt0   <= 8'd0;
			r_motor_speed <= 24'd0;
		end else if(i_cal_mode)
			r_opto_cnt0 <= 8'd0;
		else if(r_opto_cnt0 == 8'd178 && w_opto_rise) begin
			r_motor_speed <= r_opto_cnt1;
			r_opto_cnt0   <= 8'd0;
		end else if(w_opto_rise)
			r_opto_cnt0 <= r_opto_cnt0 + 1'b1;
		else
			r_opto_cnt0 <= r_opto_cnt0;
	end

	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_opto_cnt1 <= 24'd0;
		else if(i_cal_mode)
			r_opto_cnt1 <= 24'd0;
		else if(r_opto_cnt0 == 8'd178 && w_opto_rise)
			r_opto_cnt1 <= 24'd0;
		else
			r_opto_cnt1 <= r_opto_cnt1 + 1'b1;
	end
//////////////////////////////////////////////////////////////////////////////////////
			
	always@(posedge i_clk or negedge i_rst_n)
		if(i_rst_n == 0)
			r_state_cnt <= 4'd0;
		else if(r_delay_40s >= 32'd0 && r_opto_cnt0 == 8'd178 && w_opto_rise)begin
			if(r_state_cnt >= 4'd6)begin
				if(r_motor_err_sig)
					r_state_cnt <= 4'd0;
				else
					r_state_cnt <= r_state_cnt;
			end else if(r_opto_cnt1 > r_cnt_state_low && r_opto_cnt1 < r_cnt_state_high)
				r_state_cnt <= r_state_cnt + 1'b1;
			else
				r_state_cnt <= 4'd0;
		end else
			r_state_cnt <= r_state_cnt;
			
	always@(posedge i_clk or negedge i_rst_n)//
		if(i_rst_n == 0)
			r_motor_err_cnt <= 8'd0;
		else if(r_delay_40s >= 32'd0 && r_opto_cnt0 == 8'd178 && w_opto_rise)begin
			if(r_opto_cnt1 > r_cnt_state_low && r_opto_cnt1 < r_cnt_state_high)
				r_motor_err_cnt <= 8'd0;
			else 
				r_motor_err_cnt <= r_motor_err_cnt + 1'b1;
			end
			
	always@(posedge i_clk or negedge i_rst_n)//
		if(i_rst_n == 0)
			r_motor_err_sig <= 1'b0;
		else if(r_motor_err_cnt >= 8'd200)
			r_motor_err_sig <= 1'b1;
		else if(r_opto_cnt1 >= 32'd100_000_000)
			r_motor_err_sig <= 1'b1;
		else if(r_state_cnt >= 4'd6)
			r_motor_err_sig <= 1'b0;
			
	always@(posedge i_clk or negedge i_rst_n)//
	   if(i_rst_n == 0)
			r_motor_state <= 1'b0;
		else if(i_cal_mode)
			r_motor_state <= i_cal_mode;
		else if(r_motor_err_sig && i_cal_mode == 0)
			r_motor_state <= 1'b0;
		else if(r_state_cnt >= 4'd6)
			r_motor_state <= 1'b1;
		else
			r_motor_state <= r_motor_state;
			
	always@(posedge i_clk or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_err <= 1'd0;
		else if(r_opto_cnt1 >= 32'd100_000_000)
			r_opto_err <= 1'd1;
		else
			r_opto_err <= 1'd0;
			
			
	assign		o_opto_err 	  = r_opto_err;
	// assign      o_motor_state = r_motor_state & i_measure_mode;
	assign      o_motor_state = 1'b1;
	assign		o_motor_monit = r_motor_err_sig;

endmodule 