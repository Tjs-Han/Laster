module encoder_generate
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input			i_opto_switch		,//码盘信号输入
	input			i_motor_state		,//1 = 调速完成 0 = 调速未完成
	input			i_cal_mode   		,//标定模式标志 1 = 标定模式 0 = 普通模式
	input	[3:0]	i_reso_mode  		,//0 = 0.1 1 = 0.05 2 = 0.2 3 = 0.3333
	input	[3:0]	i_freq_mode  		,//0 = 30hz ,1 = 15hz
	input			i_laser_mode 		,
	input	[5:0]	i_random_seed		,
	
	output			o_zero_sign			,
	output			o_opto_fall			,
	output	[7:0]	o_fall_cnt 			,//角度值
	output	[15:0]	o_zero_angle		,
	output			o_angle_sync 		 //码盘信号标志，用以标志充电与出光
);
	reg [15:0]	r_zero_angle 	= 16'd0;
	
//////////////////////////////////////////////////////////////////////		
	reg			r_angle_sync	= 1'b0;//标定模式下伪造的码盘信号
	reg			r_zero_sign_cal	= 1'b0;
	reg			r_opto_fall_cal	= 1'b0;
	reg [15:0]	r_fall_angle 	= 16'd0;//角度值
	reg	[15:0]	r_angle_cal_cnt	= 16'd0;//标定模式下伪造的码盘信号的计时器
	reg	[15:0]	r_angle_cal_value = 16'd439;
	reg [3:0]	reso_mode;
	reg [3:0]	freq_mode;	
	wire[5:0]	w_random_number;
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			reso_mode <= 4'd0;
		else
			reso_mode <= i_reso_mode;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			freq_mode <= 4'd0;
		else
			freq_mode <= i_freq_mode;			


	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_cal_value <= 16'd439;
		else if((freq_mode==4'd0) && (reso_mode==4'd0))			//30hz  0.1°  	108K
			r_angle_cal_value <= 16'd407  + w_random_number;    //  50M/440 = 113,636
		else if((freq_mode==4'd1) && (reso_mode==4'd1))			//15hz  0.05° 	108K
			r_angle_cal_value <= 16'd407  + w_random_number;  	//  50M/440 = 113,636
		else if((freq_mode==4'd1) && (reso_mode==4'd2))			//15hz  0.2°  	27K
			r_angle_cal_value <= 16'd1727 + w_random_number;  	//  50M/1760 = 28.409K
		else if((freq_mode==4'd1) && (reso_mode==4'd3))			//15hz  0.3333° 16.2K
			r_angle_cal_value <= 16'd2900 + w_random_number;  	//  50M/2933 = 17.047K									
	
	always@(posedge i_clk_50m or negedge i_rst_n)//标定模式下伪造的码盘信号的计时器
		if(i_rst_n == 0)
		   r_angle_cal_cnt <= 16'd0;
		else if(r_angle_cal_cnt + 1'b1 >= r_angle_cal_value)
		   r_angle_cal_cnt <= 16'd0;
		else
		   r_angle_cal_cnt <= r_angle_cal_cnt + 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//标定模式下伪造的码盘信号,为27K
		if(i_rst_n == 0)
		   r_angle_sync 	<= 1'b0;
		else if(r_angle_cal_cnt + 1'b1 >= r_angle_cal_value)
		   r_angle_sync 	<= i_motor_state | i_cal_mode;//1'b1;
		else
		   r_angle_sync 	<= 1'b0;
		   
	//r_zero_sign_cal
	always@(posedge i_clk_50m or negedge i_rst_n)//标定模式下伪造的零点信号
		if(i_rst_n == 0)
			r_zero_sign_cal	<= 1'b0;
		else if((r_zero_angle == 16'd1079) && ((r_angle_cal_cnt + 1'b1) >= r_angle_cal_value) && (reso_mode == 4'd3)) //0.3333  360/0.3333
			r_zero_sign_cal	<= 1'b1;			
		else if((r_zero_angle == 16'd1799) && ((r_angle_cal_cnt + 1'b1) >= r_angle_cal_value) && (reso_mode == 4'd2)) //0.2     360/0.2
			r_zero_sign_cal	<= 1'b1;			
		else if((r_zero_angle == 16'd3599) && ((r_angle_cal_cnt + 1'b1) >= r_angle_cal_value) && (reso_mode == 4'd0)) //0.1     360/0.1
			r_zero_sign_cal	<= 1'b1;
		else if((r_zero_angle == 16'd7199) && ((r_angle_cal_cnt + 1'b1) >= r_angle_cal_value) && (reso_mode == 4'd1)) //0.05    360/0.05
			r_zero_sign_cal	<= 1'b1;
		else
			r_zero_sign_cal	<= 1'b0;
			
	//r_opto_fall_cal
	always@(posedge i_clk_50m or negedge i_rst_n)//标定模式下伪造的零点信号
		if(i_rst_n == 0)
			r_opto_fall_cal	<= 1'b0;
		else if((r_fall_angle == 16'd26)  && ((r_angle_cal_cnt + 1'b1) >= r_angle_cal_value) && (reso_mode == 4'd3)) //0.3333   360°/40/0.3333°           40 code teeth
			r_opto_fall_cal	<= 1'b1;			
		else if((r_fall_angle == 16'd44)  && ((r_angle_cal_cnt + 1'b1) >= r_angle_cal_value) && (reso_mode == 4'd2)) //0.2		360°/40/0.2°
			r_opto_fall_cal	<= 1'b1;			
		else if((r_fall_angle == 16'd89)  && ((r_angle_cal_cnt + 1'b1) >= r_angle_cal_value) && (reso_mode == 4'd0)) //0.1		360°/40/0.1°
			r_opto_fall_cal	<= 1'b1;
		else if((r_fall_angle == 16'd179) && ((r_angle_cal_cnt + 1'b1) >= r_angle_cal_value) && (reso_mode == 4'd1)) //0.05		360°/40/0.05°
			r_opto_fall_cal	<= 1'b1;
		else
			r_opto_fall_cal	<= 1'b0;
		
		   
//////////////////////////////////////////////////////////////////////
	
	reg         r_opto_switch1 = 1'b1;
	reg         r_opto_switch2 = 1'b1;////码盘信号同步
	wire        w_opto_fall   ;//判断码盘信号下降沿
	wire        w_opto_rise   ;//判断码盘信号上升沿	
	
	always@(posedge i_clk_50m or negedge i_rst_n)//对码盘信号做两次同步
	    if(i_rst_n == 0)begin
			r_opto_switch1 <= 1'b1;
			r_opto_switch2 <= 1'b1;
			end
		else begin
			r_opto_switch1 <= i_opto_switch;
			r_opto_switch2 <= r_opto_switch1;
			end
			
	assign w_opto_fall = ~r_opto_switch1 & r_opto_switch2;//判断码盘信号下降沿
	assign w_opto_rise = ~r_opto_switch2 & r_opto_switch1;//判断码盘信号上升沿	
	
//////////////////////////////////////////////////////////////////////////
	
	reg	[23:0]	r_low_time_prior_cnt = 24'd0;							   //上一周期低电平时间计数
	reg	[23:0]	r_low_time_current_cnt = 24'd0;						   //当前周期低电平时间计数
	
	reg			r_zero_sign	= 1'b0;
	wire		w_zero_sign;
	wire		w_zero_rise;
	
	always@(posedge i_clk_50m or negedge i_rst_n)//一个周期低电平时间计数
		if(i_rst_n == 0)
			r_low_time_current_cnt <= 24'd0;
		else if(w_opto_rise)
			r_low_time_current_cnt <= 24'd0;
		else if(r_low_time_current_cnt == 24'hfffff0)
			r_low_time_current_cnt <= 24'hfffff0;
		else if(r_opto_switch1 == 0)
			r_low_time_current_cnt <= r_low_time_current_cnt + 1'b1;

	always@(posedge i_clk_50m or negedge i_rst_n)//下一周期到来时当前计数存入当前低电平计数器，上一周期地电平计数存入上一周期计数器
		if(i_rst_n == 0)
			r_low_time_prior_cnt   <= 24'd0;
		else if(w_opto_rise)
			r_low_time_prior_cnt   <= r_low_time_current_cnt << 1'b1;
			
	assign w_zero_sign = (r_low_time_current_cnt >= r_low_time_prior_cnt) ? 1'b1 : 1'b0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_zero_sign		<= 1'b0;
		else
			r_zero_sign		<= w_zero_sign;
			
	assign	w_zero_rise = ~r_zero_sign & w_zero_sign;
				
	//////////////////////////////////////////////////////////////////////////////////
	
	reg	[7:0]	r_fall_cnt		= 8'd0;
	reg	[7:0]	r_angle_reso 	= 8'd90;
	reg			r_angle_sync_out = 1'b0;
	wire[15:0]	w_mult1_result;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_reso	<= 8'd90;
		else begin
			case(reso_mode)
				4'd0	:r_angle_reso <= 8'd90;		//0.1°
				4'd1	:r_angle_reso <= 8'd180;	//0.05°
				4'd2	:r_angle_reso <= 8'd45;	    //0.2°
				4'd3	:r_angle_reso <= 8'd27;	    //0.3333°								
				default	:r_angle_reso <= 8'd90;
				endcase
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)		
			r_fall_cnt		<= 8'd0;
		else if(o_zero_sign)
			r_fall_cnt		<= 8'd0;
		else if(o_opto_fall)
			r_fall_cnt		<= r_fall_cnt + 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)		
			r_fall_angle	<= 16'd0;
		else if(o_opto_fall || o_zero_sign)
			r_fall_angle	<= 16'd0;
		else if(o_angle_sync)
			r_fall_angle	<= r_fall_angle	+ 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_zero_angle	<= 16'd0;
		else if(o_zero_sign)
			r_zero_angle	<= 16'd0;
		else if(o_opto_fall)
			r_zero_angle	<= w_mult1_result;
		else if(o_angle_sync)
			r_zero_angle	<= r_zero_angle	+ 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_sync_out	<= 1'b0;
		else
			r_angle_sync_out	<= w_angle_sync;
			
	assign o_zero_sign		= (i_cal_mode) 		? r_zero_sign_cal : w_zero_rise;
	assign o_opto_fall		= (i_cal_mode)		? r_opto_fall_cal : w_opto_fall;
	assign w_angle_sync 	= (i_laser_mode)	? r_angle_sync : 1'b0;
	assign o_angle_sync		= r_angle_sync_out;
	assign o_fall_cnt		= r_fall_cnt;
	assign o_zero_angle		= r_zero_angle;
	
	multiplier3 U1
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(1'b1), 
		
		.Aclr				(1'b0), 
		.DataA				(r_fall_cnt + 1'b1), 
		.DataB				(r_angle_reso), 
		.Result				(w_mult1_result)
	);
	random_number_generator U2
	(
		.clk				(i_clk_50m),
		.reset_n			(i_rst_n),
		
		.random_seed		(i_random_seed),
		.generator_en		(r_angle_sync),
	
		.random_number		(w_random_number)
	);

endmodule 