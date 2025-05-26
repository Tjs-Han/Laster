module motor_control_2
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input			i_cal_mode   		,//标定模式标志 1 = 标定模式 0 = 普通模式
	input	[3:0]	i_freq_mode  		,//0 = 30hz ,1 = 15hz
	input			i_measure_mode		,
	input			i_opto_switch		,//码盘信号输入
	input	[15:0]	i_pwm_value_0		,

	output			o_motor_state		,//1 = 调速完成 0 = 调速未完成
	output	[15:0]	o_pwm_value  		,
	output			o_motor_pwm  		 //电机PWM输出
);

	reg         r_motor_pwm    	= 1'b0;
	reg         r_motor_state 	= 1'b0;
	
	reg	[15:0]	r_pwm_value   	= 16'd1970;//电机PWM高电平占空比
	reg	[15:0]	r_pwm_cnt     	= 16'd1999;//电机PWM计数
	
	reg       	r_opto_switch1 	= 1'b1;
	reg        	r_opto_switch2	= 1'b1;//码盘信号同步
	
	wire       	w_opto_rise   ;//码盘信号上升沿
	
	reg	[7:0]	r_opto_cnt0		= 8'd0;//码盘信号齿计数
	reg	[29:0]	r_opto_cnt1		= 30'd0;//码盘信号上升沿计数
	
	reg	[31:0]	r_encoder_cnt;
	
	reg	[31:0]	r_delay_40s		= 32'd0;//延时计数
	reg			r_delay_en		= 1'b0;
	
	reg	[29:0]	r_cnt_max		= 30'd2_000_000;
	reg	[29:0]	r_cnt_higher	= 30'd1_800_000;
	reg	[29:0]	r_cnt_high		= 30'd1_683_000;
	reg	[29:0]	r_cnt_low		= 30'd1_666_666;
	reg	[29:0]	r_cnt_lower		= 30'd1_650_000;
	reg	[29:0]	r_cnt_state_high= 30'd1_750_000;
	reg	[29:0]	r_cnt_state_low	= 30'd1_500_000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
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
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin//对码盘信号做两次同步
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
	end
			
	assign w_opto_rise = ~r_opto_switch2 & r_opto_switch1;//判断码盘信号上升沿
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin//对码盘信号上升沿进行计数，以判断是否到达一圈
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
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin//码盘转一圈有多少个周期
		if(i_rst_n == 0)
			r_opto_cnt1 <= 30'd0;
		else if(i_cal_mode)
			r_opto_cnt1 <= 30'd0;
		else if(r_opto_cnt0 == 8'd38 && w_opto_rise)
			r_opto_cnt1 <= 30'd0;
		else if(r_opto_cnt1 >= 30'd49_999_999)
			r_opto_cnt1 <= 30'd0;
		else
			r_opto_cnt1 <= r_opto_cnt1 + 1'b1;
	end
		
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_delay_en 	<= 1'b0;
		else 
			r_delay_en 	<= 1'b1;
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin//计算电机起转时间
		if(i_rst_n == 0)
			r_delay_40s <= 32'd0;
		else if(i_cal_mode)
			r_delay_40s <= 32'd0;
		else if(r_delay_40s < 32'd2_000_000_000)
			r_delay_40s <= r_delay_40s + r_delay_en;
		else
			r_delay_40s <= r_delay_40s;
	end
	
//////////////////////////////////////////////////////////////////////以下修改			
	reg			frequency_state		= 1'b0;           //频率状态寄存
	reg	[3:0]	frequency_state_reg	= 4'd0;
	reg [15:0]	r_pwm_value_0		= 16'd0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)  	
			frequency_state <= 1'd1;
		else if(r_opto_cnt0 == 8'd38 && w_opto_rise && i_freq_mode == 2'd0)begin
			if(r_opto_cnt1 >= 30'd2500000)			 
				frequency_state <= 1'd1;
			else if(r_opto_cnt1 <= 30'd2000000)
				frequency_state <= 1'd0;
			else
				frequency_state <= frequency_state;
        end	 
		else if(r_opto_cnt0 == 8'd38 && w_opto_rise && i_freq_mode == 2'd1)begin
			if(r_opto_cnt1 >= 30'd5000000)			 
				frequency_state <= 1'd1;
			else if(r_opto_cnt1 <= 30'd4000000)
				frequency_state <= 1'd0;
			else
				frequency_state <= frequency_state;
		end
		else if(r_opto_cnt1 >= 30'd49_999_999)begin
			frequency_state <= 1'd1;
		end
		else
			frequency_state <= frequency_state;	
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			frequency_state_reg <= 4'd0;
		else if(frequency_state == 1'd0)begin
			if(frequency_state_reg == 4'd8)
				frequency_state_reg <= 4'd8;
			else
				frequency_state_reg <= frequency_state_reg+1'd1;	 
		end		   
		else 
			frequency_state_reg <= 4'd0;
	end
		 
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_pwm_value_0 <= i_pwm_value_0;
		else if(r_pwm_value_0 <= 16'd1880)begin
			if(r_opto_cnt1 >= 32'd2500000 && r_opto_cnt0 == 8'd38 && w_opto_rise && i_freq_mode == 2'd0)		   
				r_pwm_value_0 <= r_pwm_value_0 + 16'd100;
			else if(r_opto_cnt1 >= 32'd5000000 && r_opto_cnt0 == 8'd38 && w_opto_rise && i_freq_mode == 2'd1)		   
				r_pwm_value_0 <= r_pwm_value_0 + 16'd100;
			else if(r_opto_cnt1 >= 30'd49_999_999)
				r_pwm_value_0 <= r_pwm_value_0 + 16'd100;
			else
				r_pwm_value_0 <= r_pwm_value_0;
		end	
	end
		 
	always@(posedge i_clk_50m or negedge i_rst_n)begin//根据码盘一圈的时间调整PWM占空比
		if(i_rst_n == 0)
			r_pwm_value <= 16'd1980;
		else if(frequency_state == 1'd1)
			r_pwm_value <= 16'd1980;
		else if(frequency_state_reg == 4'd4)
			r_pwm_value <= r_pwm_value_0;
		else if(r_delay_40s < 32'd2_000_000_000 && r_opto_cnt0 == 8'd38 && w_opto_rise)begin
			if(r_opto_cnt1 > r_cnt_max && r_pwm_value < 16'd1980)
				r_pwm_value <= r_pwm_value + 4'd7;
			else if(r_opto_cnt1 > r_cnt_higher && r_pwm_value < 16'd1980)
				r_pwm_value <= r_pwm_value + 2'd3;
			else if(r_opto_cnt1 > r_cnt_state_high && r_pwm_value < 16'd1980)
				r_pwm_value <= r_pwm_value + 1'b1;		
			else if(r_opto_cnt1 < r_cnt_state_low && r_pwm_value > 16'd30)
				r_pwm_value <= r_pwm_value - 2'd3;
			else if(r_opto_cnt1 < r_cnt_lower && r_pwm_value > 16'd30)
				r_pwm_value <= r_pwm_value - 1'b1;
			else
				r_pwm_value <= r_pwm_value;
		end
		else if(r_delay_40s == 32'd2_000_000_000 && r_opto_cnt0 == 8'd38 && w_opto_rise)begin
			if(r_opto_cnt1 > r_cnt_state_low && r_opto_cnt1 < r_cnt_state_high && r_pwm_value < 16'd1980)
				r_pwm_value <= r_pwm_value;
			else if(r_opto_cnt1 >= r_cnt_high && r_pwm_value < 16'd1980)
				r_pwm_value <= r_pwm_value + 1'b1;
			else if(r_opto_cnt1 <= r_cnt_lower && r_pwm_value > 16'd30)
				r_pwm_value <= r_pwm_value - 1'b1;
			else 
				r_pwm_value <= r_pwm_value;
		end
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_pwm_cnt <= 16'd1999;
		else if(i_cal_mode)
			r_pwm_cnt <= 16'd1999;
		else if(r_pwm_cnt >= 16'd1999)//周期25kHz
			r_pwm_cnt <= 16'd0;
		else
			r_pwm_cnt <= r_pwm_cnt + 16'd1;
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin//电机PWM控制
		if(i_rst_n == 0)
			r_motor_pwm <= 1'b0;
		else if(i_cal_mode || i_measure_mode == 1'b0)
			r_motor_pwm <= 1'b0;
		else if(r_pwm_cnt < r_pwm_value)	
			r_motor_pwm <= 1'b1;
		else
			r_motor_pwm <= 1'b0;
	end

//////////////////////////////////////////////////////////////////////////////////////

	reg			r_motor_err_sig = 1'b0;
	reg	[7:0]	r_motor_err_cnt = 8'd0;
	reg	[3:0]	r_state_cnt = 4'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin//
		if(i_rst_n == 0)
			r_state_cnt <= 4'd0;
		else if(r_delay_40s >= 32'd0 && r_opto_cnt0 == 8'd38 && w_opto_rise)begin
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
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin//
		if(i_rst_n == 0)
			r_motor_err_cnt <= 8'd0;
		else if(r_delay_40s >= 32'd0 && r_opto_cnt0 == 8'd38 && w_opto_rise)begin
			if(r_opto_cnt1 > r_cnt_state_low && r_opto_cnt1 < r_cnt_state_high)
				r_motor_err_cnt <= 8'd0;
			else 
				r_motor_err_cnt <= r_motor_err_cnt + 1'b1;
		end
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin//
		if(i_rst_n == 0)
			r_motor_err_sig <= 1'b0;
		else if(r_motor_err_cnt >= 8'd200)
			r_motor_err_sig <= 1'b1;
		else if(r_state_cnt >= 4'd6)
			r_motor_err_sig <= 1'b0;
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin//
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
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin//
		if(i_rst_n == 0)
			r_encoder_cnt <= 32'd0;
		else if(w_opto_rise || i_cal_mode)
			r_encoder_cnt <= 32'd0;
		else if(r_encoder_cnt >= 32'd50_000_000)
			r_encoder_cnt <= 32'd50_000_000;
		else
			r_encoder_cnt <= r_encoder_cnt + 1'd1;
	end
			
		
	assign      o_motor_pwm   = r_motor_pwm;
	assign      o_motor_state = r_motor_state & i_measure_mode;
	assign      o_pwm_value   = r_pwm_value;

endmodule 