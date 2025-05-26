module motor_control
(
	input			i_clk_50m    	,
	input			i_rst_n      	,
	
	input			i_cal_mode   	,
	input	[3:0]	i_freq_mode  		,
	input			i_measure_mode	,
	input			i_opto_switch	,
	input	[15:0]	i_pwm_value_0		,

	output			o_motor_state	,
	output	[15:0]	o_pwm_value  		,
	output			o_motor_pwm  	
				
);

	reg         r_motor_pwm    	= 1'b0;
	reg         r_motor_state 	= 1'b0;
	
	reg  [15:0]r_pwm_value   = 16'd970;//电机PWM高电平占空比
	reg  [15:0]r_pwm_cnt     = 16'd999;//电机PWM计数
	
	reg        	r_opto_switch1 	= 1'b1;
	reg        	r_opto_switch2	= 1'b1;//码盘信号同步
	
	wire       	w_opto_rise   ;//码盘信号上升沿
	
	reg   [7:0]r_opto_cnt0	= 8'd0;//码盘信号齿计数
	reg  [23:0]r_opto_cnt1	= 24'd0;//码盘信号上升沿计数
	
	reg		[31:0]r_encoder_cnt;	
	
	reg  [23:0]r_cnt_max		= 24'd2_000_000;
	reg  [23:0]r_cnt_higher		= 24'd1_800_000;
	reg  [23:0]r_cnt_high		= 24'd1_683_333;
	reg  [23:0]r_cnt_low		= 24'd1_666_666;
	reg  [23:0]r_cnt_lower		= 24'd1_650_000;
	reg  [23:0]r_cnt_state_high= 24'd1_750_000;
	reg  [23:0]r_cnt_state_low	= 24'd1_583_333;

	
	reg			r_motor_err_sig = 1'b0;
	reg	[7:0]	r_motor_err_cnt = 8'd0;
	reg	[3:0]	r_state_cnt = 4'd0;
	reg	[3:0]	r_slow_cnt = 4'd8;
	reg	[3:0]	r_fast_cnt = 4'd0;
	
	reg	[15:0]	r_pwm_value_0 = 16'd0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_cnt_max 			<= 24'd2_000_000;
			r_cnt_higher		<= 24'd1_800_000;
			r_cnt_high			<= 24'd1_683_333;
			r_cnt_low   		<= 24'd1_666_666;
			r_cnt_lower 		<= 24'd1_650_000;
			r_cnt_state_high	<= 24'd1_750_000;
			r_cnt_state_low		<= 24'd1_583_333;
			end
		else if(i_freq_mode == 4'd0)begin
			r_cnt_max 			<= 24'd2_000_000;
			r_cnt_higher		<= 24'd1_800_000;
			r_cnt_high			<= 24'd1_683_333;
			r_cnt_low   		<= 24'd1_666_666;
			r_cnt_lower 		<= 24'd1_650_000;
			r_cnt_state_high	<= 24'd1_750_000;
			r_cnt_state_low		<= 24'd1_583_333;
			end
		else if(i_freq_mode == 4'd1)begin
			r_cnt_max 			<= 24'd4_000_000;
			r_cnt_higher		<= 24'd3_600_000;
			r_cnt_high			<= 24'd3_366_666;
			r_cnt_low   		<= 24'd3_333_333;
			r_cnt_lower 		<= 24'd3_300_000;
			r_cnt_state_high	<= 24'd3_500_000;
			r_cnt_state_low		<= 24'd3_166_666;
			end
	
	always@(posedge i_clk_50m or negedge i_rst_n)//对码盘信号做两次同步
	   if(i_rst_n == 0)begin
		   r_opto_switch1 <= 1'b1;
		   r_opto_switch2 <= 1'b1;
		   end
		else if(i_cal_mode)begin
		   r_opto_switch1 <= 1'b1;
		   r_opto_switch2 <= 1'b1;
		   end
		else begin
		   r_opto_switch1 <= i_opto_switch;
		   r_opto_switch2 <= r_opto_switch1;
		   end
			
	assign w_opto_rise = ~r_opto_switch2 & r_opto_switch1;//判断码盘信号上升沿
	
	always@(posedge i_clk_50m or negedge i_rst_n)//对码盘信号上升沿进行计数，以判断是否到达一圈
		if(i_rst_n == 0)
			r_opto_cnt0 <= 8'd0;
		else if(i_cal_mode)
			r_opto_cnt0 <= 8'd0;
		else if(r_opto_cnt0 == 8'd38 && w_opto_rise)
			r_opto_cnt0 <= 8'd0;
		else if(w_opto_rise)
			r_opto_cnt0 <= r_opto_cnt0 + 1'b1;
		else
			r_opto_cnt0 <= r_opto_cnt0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//码盘转一圈有多少个周期
		if(i_rst_n == 0)
			r_opto_cnt1 <= 24'd0;
		else if(i_cal_mode)
			r_opto_cnt1 <= 24'd0;
		else if(r_opto_cnt0 == 8'd38 && w_opto_rise)
			r_opto_cnt1 <= 24'd0;
		else
			r_opto_cnt1 <= r_opto_cnt1 + 1'b1;
	
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pwm_value <= 16'd210;
		else if(i_freq_mode)
			r_pwm_value <= 16'd210; // 占空比，高电平时间
		else
			r_pwm_value <= 16'd410;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pwm_cnt <= 16'd999;
		else if(i_cal_mode)
			r_pwm_cnt <= 16'd999;
		else if(r_pwm_cnt >= 16'd999)//周期50kHz
			r_pwm_cnt <= 16'd0;
		else
			r_pwm_cnt <= r_pwm_cnt + 16'd1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//电机PWM控制
		if(i_rst_n == 0)
			r_motor_pwm <= 1'b0;
		else if(i_cal_mode || i_measure_mode == 1'b0)
			r_motor_pwm <= 1'b0;
		else if(r_pwm_cnt < r_pwm_value)	
			r_motor_pwm <= 1'b1;
		else
			r_motor_pwm <= 1'b0;

always@(posedge i_clk_50m or negedge i_rst_n)//
		if(i_rst_n == 0)
			r_state_cnt <= 4'd0;
		else if( r_opto_cnt0 == 8'd38 && w_opto_rise)begin
			if(r_state_cnt >= 4'd6)begin
				if(r_motor_err_sig)
					r_state_cnt <= 4'd0;
				else
					r_state_cnt <= r_state_cnt;
				end
			else if(r_opto_cnt1 > r_cnt_state_low && r_opto_cnt1 < r_cnt_state_high)
				r_state_cnt <= r_state_cnt + 1'b1;
			else
				r_state_cnt <= 4'd0;
			end
		else if(r_encoder_cnt >= 32'd50_000_000)
			r_state_cnt <= 4'd0;
		else
			r_state_cnt <= r_state_cnt;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//
		if(i_rst_n == 0)
			r_motor_err_cnt <= 8'd0;
		else if(r_opto_cnt0 == 8'd38 && w_opto_rise)begin
			if(r_opto_cnt1 > r_cnt_state_low && r_opto_cnt1 < r_cnt_state_high)
				r_motor_err_cnt <= 8'd0;
			else 
				r_motor_err_cnt <= r_motor_err_cnt + 1'b1;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)//
		if(i_rst_n == 0)
			r_motor_err_sig <= 1'b0;
		else if(r_motor_err_cnt >= 8'd200)
			r_motor_err_sig <= 1'b1;
		else if(r_state_cnt >= 4'd6)
			r_motor_err_sig <= 1'b0;
					
			
	always@(posedge i_clk_50m or negedge i_rst_n)//
	   if(i_rst_n == 0)
			r_motor_state <= 1'b0;
		else if(i_cal_mode)
			r_motor_state <= i_cal_mode;
		else if(r_motor_err_sig && i_cal_mode == 0)
			r_motor_state <= 1'b0;	
		else if(r_encoder_cnt >= 32'd50_000_000)
			r_motor_state <= 1'b0;
		else if(r_state_cnt >= 4'd6)
			r_motor_state <= 1'b1;
		else
			r_motor_state <= r_motor_state;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//
	   if(i_rst_n == 0)
			r_encoder_cnt <= 32'd0;
		else if(w_opto_rise | i_cal_mode)
			r_encoder_cnt <= 32'd0;
		else if(r_encoder_cnt >= 32'd50_000_000)//1s
			r_encoder_cnt <= 32'd50_000_000;
		else
			r_encoder_cnt <= r_encoder_cnt + 1'd1;
			
		
	assign      o_motor_pwm   = r_motor_pwm;
	assign      o_motor_state = r_motor_state & i_measure_mode;
	assign      o_pwm_value   = r_pwm_value;
	
	

	

	
	
	

endmodule 