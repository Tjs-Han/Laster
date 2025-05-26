module rotate_control
(
	input			i_clk_50m		,
	input			i_rst_n			,

	input			i_motor_switch	,	
	input			i_opto_switch	,//码盘信号输入
	input	[15:0]	i_config_mode 	,
	input	[15:0]	i_pwm_value_0	,//电机转速初始�
	input	[5:0]	i_random_seed	,	
	
	output	reg		    o_motor_state	, //1 = 调速完�0 = 调速未完成
	output	reg [15:0]	o_pwm_value  	, //当前电机PWM�
	output	reg			o_motor_pwm  	, //电机PWM输出
	output		[7:0]	o_fall_cnt 		, //角度�
	output		[15:0]	o_zero_angle	,
	output				o_opto_fall		,
	output				o_zero_sign		,
	output				o_angle_sync 	  //码盘信号标志，用以标志充电与出光
	

);

	wire			w_cal_mode;
	wire	[3:0]	w_freq_mode;
	wire	[3:0]	w_reso_mode;
	wire			w_laser_mode;
	wire			w_measure_mode;
	
	//15:12	转速挡位：0�0Hz	1:25hz
	//11:8	分辨率挡位：0�.1° 1:0.05
	//7:脉宽模式 1：脉宽模�0：温补模�
	//6:测距模式 1：测距模�0：休眠模�
	//5:出光模式标志�1 = 出光模式 0 = 不出光模�
	//4:平滑滤波模式 1 = 平滑模式 0 = 普通模�
	//3:拖尾滤波模式 1 = 滤波模式 0 = 普通模�
	//2:
	//1:
	//0:标定模式标志 1 = 标定模式 0 = 普通模�
	
	//assign	w_cal_mode		= 1'b1;//tjs
	assign	w_cal_mode		= i_config_mode[0];

	assign	w_freq_mode		= i_config_mode[15:12];
	assign	w_reso_mode		= i_config_mode[11:8];
	assign	w_laser_mode	= i_config_mode[5];
	assign	w_measure_mode	= i_config_mode[6];

	wire		w_opto_switch;
	wire		w_motor_state_1;
	wire[15:0]	w_pwm_value_1;
	wire		w_motor_pwm_1;
	
	wire		w_motor_state_2;
	wire[15:0]	w_pwm_value_2;
	wire		w_motor_pwm_2;
	
	// assign		o_motor_state 	= (i_motor_switch)?w_motor_state_1:w_motor_state_2;
	// assign		o_pwm_value 	= (i_motor_switch)?w_pwm_value_1:w_pwm_value_2;
	// assign		o_motor_pwm 	= (i_motor_switch)?w_motor_pwm_1:w_motor_pwm_2;

	always@(posedge i_clk_50m)
		if(~i_rst_n)
			o_motor_state <= 1'b0;
		else if(i_motor_switch)
			o_motor_state <= w_motor_state_1;
		else
			o_motor_state <= w_motor_state_2;

	always@(posedge i_clk_50m)
		if(~i_rst_n)
			o_pwm_value <= 16'd0;
		else if(i_motor_switch)
			o_pwm_value <= w_pwm_value_1;
		else
			o_pwm_value <= w_pwm_value_2;

	always@(posedge i_clk_50m)
		if(~i_rst_n)
			o_motor_pwm <= 1'd0;
		else if(i_motor_switch)
			o_motor_pwm <= w_motor_pwm_1;
		else
			o_motor_pwm <= w_motor_pwm_2;

	opto_switch_filter U1
	(
		.i_clk_50m    		(i_clk_50m)		,
		.i_rst_n      		(i_rst_n)		,
		
		.i_opto_switch		(i_opto_switch)	,//码盘信号输入
		
		.o_opto_switch		(w_opto_switch)	 //码盘信号输出
	);
	
	motor_control U2
	(
		.i_clk_50m    		(i_clk_50m)		,
		.i_rst_n      		(i_rst_n)		,
		
		.i_cal_mode   		(w_cal_mode)	,//标定模式标志 1 = 标定模式 0 = 普通模�
		.i_freq_mode  		(w_freq_mode)	,
		.i_measure_mode		(w_measure_mode),
		.i_opto_switch		(i_opto_switch)	,//码盘信号输入
		.i_pwm_value_0		(i_pwm_value_0)	,
		

	
		.o_motor_state		(w_motor_state_1), //1 = 调速完�0 = 调速未完成
		.o_pwm_value  		(w_pwm_value_1)	,
		.o_motor_pwm  		(w_motor_pwm_1)	   //电机PWM输出		
		
	);

	motor_control_2 U3
	(
		.i_clk_50m    	(i_clk_50m)			,
		.i_rst_n      	(i_rst_n)			,
		
		.i_cal_mode   	(w_cal_mode)		,//±ê¶¨Ä£Ê½±êÖ¾ 1 = ±ê¶¨Ä£Ê½ 0 = ÆÕÍ¨Ä£Ê½
		.i_freq_mode  	(w_freq_mode)		,
		.i_measure_mode	(w_measure_mode)	,
		.i_opto_switch	(i_opto_switch)		,//ÂëÅÌÐÅºÅÊäÈë
		.i_pwm_value_0	(i_pwm_value_0)		,
	
		.o_motor_state	(w_motor_state_2)	,//1 = µ÷ËÙÍê³É 0 = µ÷ËÙÎ´Íê³É
		.o_pwm_value  	(w_pwm_value_2)		,
		.o_motor_pwm  	(w_motor_pwm_2)	 	//µç»úPWMÊä³ö	
	);
		
	encoder_generate U4
	(
		.i_clk_50m    		(i_clk_50m)		,
		.i_rst_n      		(i_rst_n)		,
		
		.i_opto_switch		(w_opto_switch)	,//码盘信号输入
		.i_motor_state		(o_motor_state)	,//1 = 调速完�0 = 调速未完成
		.i_cal_mode   		(w_cal_mode)	,//标定模式标志 1 = 标定模式 0 = 普通模�
		.i_freq_mode  		(w_freq_mode)	,
		.i_reso_mode  		(w_reso_mode)	,
		.i_laser_mode 		(w_laser_mode)	,
		
		.i_random_seed	(i_random_seed)		,
		
		.o_zero_sign		(o_zero_sign)	,
		.o_opto_fall		(o_opto_fall)	,
		.o_fall_cnt 		(o_fall_cnt)	,//角度�
		.o_zero_angle		(o_zero_angle)	,
		.o_angle_sync 		(o_angle_sync) 	 //码盘信号标志，用以标志充电与出光
	);

endmodule 