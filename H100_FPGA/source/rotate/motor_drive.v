module motor_drive
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input	[2:0]	i_freq_mode  		,//0=15,1=20,2=25,3=30,4=33,5=40,6=50
	input			i_measure_mode		,
	input			i_cal_mode			,
	input			i_opto_switch		,//码盘信号输入
	input	[15:0]	i_pwm_value_0		,

	output			o_motor_state		,//1 = 调速完� = 调速未完成
	output	[15:0]	o_pwm_value  		,
    output	[23:0]	o_speed_value		,
	output			o_motor_pwm   				
);

    parameter	TOOTH_NUM = 8'd39;
    parameter	JUJIANG_MOTOR = 1'b1;

    reg        	r_opto_switch1 	= 1'b1;
	reg        	r_opto_switch2	= 1'b1;//码盘信号同步
	
	wire		w_opto_rise;//码盘信号上升�

    reg	[7:0]	r_opto_cnt0	    = 8'd0;//码盘信号齿计�
	reg	[23:0]	r_opto_cnt1	    = 24'd0;//码盘信号上升沿计�
    reg	[23:0]	r_opto_cnt2	    = 24'd0;//码盘信号上升沿计数寄�

	reg	[2:0]	r_freq_mode 	= 3'd0;
	reg	[23:0]	r_cnt_low		= 24'd3_300_000;
	reg	[23:0]	r_cnt_higher	= 24'd3_500_000;
	reg	[23:0]	r_cnt_high		= 24'd3_366_666;
	reg	[23:0]	r_cnt_lower		= 24'd3_166_666;
	reg	[23:0]	r_cnt_state_high= 24'd3_400_000;
	reg	[23:0]	r_cnt_state_low	= 24'd3_266_666;

	reg	[15:0]	r_pwm_value   	= 16'd1980;//电机PWM高电平占空比
	reg	[15:0]	r_pwm_cnt    	= 16'd1999;//电机PWM计数
	reg       	r_motor_pwm    	= 1'b0;
	reg       	r_motor_state 	= 1'b0;
	reg [31:0]	r_delay_20s	    = 32'd0;//延时计数

    always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_freq_mode	<= 3'd0;
		else
			r_freq_mode	<= i_freq_mode;
	end
	
    always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin   //  1000000000ns/15HZ/20ns
			r_cnt_higher		<= 24'd3_500_000;   //105%
			r_cnt_high			<= 24'd3_366_666;   //101%
			r_cnt_low   		<= 24'd3_300_000;
			r_cnt_lower 	 	<= 24'd3_166_666;   //95%
			r_cnt_state_high	<= 24'd3_400_000;   //102%
			r_cnt_state_low		<= 24'd3_266_666;   //98%
		end
		else begin
			case(r_freq_mode)
				3'd0:	begin			//  1000000000ns/15HZ/20ns
					r_cnt_higher		<= 24'd3_500_000;   //105%
					r_cnt_high			<= 24'd3_366_666;   //101%
					r_cnt_low   		<= 24'd3_300_000;	//99%
					r_cnt_lower 	 	<= 24'd3_166_666;   //95%
					r_cnt_state_high	<= 24'd3_400_000;   //102%
					r_cnt_state_low		<= 24'd3_266_666;   //98%
				end
				3'd1:	begin			//  1000000000ns/20HZ/20ns
					r_cnt_higher		<= 24'd2_625_000;   //105%
					r_cnt_high			<= 24'd2_525_000;   //101%
					r_cnt_low   		<= 24'd2_475_000;	//99%
					r_cnt_lower 	 	<= 24'd2_375_000;   //95%
					r_cnt_state_high	<= 24'd2_550_000;   //102%
					r_cnt_state_low		<= 24'd2_450_000;   //98%
				end		
				3'd2:	begin           //  1000000000ns/25HZ/20ns
					r_cnt_higher		<= 24'd2_100_000;   //105%
					r_cnt_high			<= 24'd2_020_000;   //101%
					r_cnt_low   		<= 24'd1_980_000;	//99%
					r_cnt_lower 	 	<= 24'd1_900_000;   //95%
					r_cnt_state_high	<= 24'd2_040_000;   //102%
					r_cnt_state_low		<= 24'd1_960_000;   //98%
				end
				3'd3:	begin           //  1000000000ns/30HZ/20ns
					r_cnt_higher		<= 24'd1_750_000;   //105%
					r_cnt_high			<= 24'd1_683_333;   //101%
					r_cnt_low   		<= 24'd1_650_000;	//99%
					r_cnt_lower 	 	<= 24'd1_583_333;   //95%
					r_cnt_state_high	<= 24'd1_700_000;   //102%
					r_cnt_state_low		<= 24'd1_633_333;   //98%
				end
				3'd4:	begin           //  1000000000ns/33HZ/20ns
					r_cnt_higher		<= 24'd1_575_000;   //105%
					r_cnt_high			<= 24'd1_515_000;   //101%
					r_cnt_low   		<= 24'd1_485_000;	//99%
					r_cnt_lower 	 	<= 24'd1_425_000;   //95%
					r_cnt_state_high	<= 24'd1_530_000;   //102%
					r_cnt_state_low		<= 24'd1_470_000;   //98%
				end
				3'd5:	begin           //  1000000000ns/40HZ/20ns
					r_cnt_higher		<= 24'd1_312_500;   //105%
					r_cnt_high			<= 24'd1_262_500;   //101%
					r_cnt_low   		<= 24'd1_247_500;	//99%
					r_cnt_lower 	 	<= 24'd1_187_500;   //95%
					r_cnt_state_high	<= 24'd1_275_000;   //102%
					r_cnt_state_low		<= 24'd1_225_000;   //98%
				end
				3'd6:	begin           //  1000000000ns/50HZ/20ns
					r_cnt_higher		<= 24'd1_050_000;   //105%
					r_cnt_high			<= 24'd1_010_000;   //101%
					r_cnt_low   		<= 24'd990_000;		//99%
					r_cnt_lower 	 	<= 24'd950_000;     //95%
					r_cnt_state_high	<= 24'd1_020_000;   //102%
					r_cnt_state_low		<= 24'd980_000;     //98%
				end
				default:	begin
					r_cnt_higher		<= 24'd3_500_000;   //105%
					r_cnt_high			<= 24'd3_366_666;   //101%
					r_cnt_low   		<= 24'd3_300_000;	//99%
					r_cnt_lower 	 	<= 24'd3_166_666;   //95%
					r_cnt_state_high	<= 24'd3_400_000;   //102%
					r_cnt_state_low		<= 24'd3_266_666;   //98%
				end
			endcase
		end
	end

    //对码盘信号做两次同步
    always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_opto_switch1 <= 1'b1;
			r_opto_switch2 <= 1'b1;
		end
		else if(i_measure_mode == 1'b0 || i_cal_mode)begin
			r_opto_switch1 <= 1'b1;
			r_opto_switch2 <= 1'b1;
		end
		else begin
			r_opto_switch1 <= i_opto_switch;
			r_opto_switch2 <= r_opto_switch1;
		end
    end
			
	assign w_opto_rise = ~r_opto_switch2 & r_opto_switch1;//判断码盘信号上升�

    //对码盘信号上升沿进行计数，以判断是否到达一�
    always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_opto_cnt0 <= 8'd0;
		else if(i_measure_mode == 1'b0 || i_cal_mode)
			r_opto_cnt0 <= 8'd0;
		else if(r_opto_cnt0 + 1'b1 >= TOOTH_NUM && w_opto_rise)
			r_opto_cnt0 <= 8'd0;
		else if(w_opto_rise)
			r_opto_cnt0 <= r_opto_cnt0 + 1'b1;
		else
			r_opto_cnt0 <= r_opto_cnt0;
    end

    //码盘转一圈有多少个周�
    always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_opto_cnt1 <= 24'd0;
		else if(i_measure_mode == 1'b0 || i_cal_mode)
			r_opto_cnt1 <= 24'd0;
		else if(r_opto_cnt0 + 1'b1 >= TOOTH_NUM && w_opto_rise)
			r_opto_cnt1 <= 24'd0;
		else if(r_opto_cnt1 <= 24'hFFFF00)
			r_opto_cnt1 <= r_opto_cnt1 + 1'b1;
    end

    //码盘转一圈有多少个周期寄�
    always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_opto_cnt2 <= 24'd0;
		else if(i_measure_mode == 1'b0 || i_cal_mode)
			r_opto_cnt2 <= 24'd0;
		else if(r_opto_cnt0 + 1'b1 >= TOOTH_NUM && w_opto_rise)
			r_opto_cnt2 <= r_opto_cnt1;
		else if(r_opto_cnt1 > 24'hFFFF00)
			r_opto_cnt2 <= r_opto_cnt1;
    end

    //计算电机起转时间
    always@(posedge i_clk_50m or negedge i_rst_n)begin
	    if(i_rst_n == 0)
		    r_delay_20s <= 32'd0;
		else if(i_measure_mode == 1'b0 || i_cal_mode)
		    r_delay_20s <= 32'd0;
		else if(r_delay_20s < 32'd1_000_000_000)
		    r_delay_20s <= r_delay_20s + 1'b1;
		else
		    r_delay_20s <= r_delay_20s;
    end

    //根据码盘一圈的时间调整PWM占空�
    always@(posedge i_clk_50m or negedge i_rst_n)begin
	    if(i_rst_n == 0)
		    r_pwm_value <= 16'd1980;
        else if(JUJIANG_MOTOR == 1'b0)begin
            if(r_delay_20s < 32'd200_000_000)
                r_pwm_value <= i_pwm_value_0;
            else if(r_delay_20s < 32'd1_000_000_000 && r_opto_cnt0 + 1'b1 >= TOOTH_NUM && w_opto_rise)begin
                if(r_opto_cnt1 > r_cnt_higher && r_pwm_value < 16'd1980)
                    r_pwm_value <= r_pwm_value + 3'd5;
                else if(r_opto_cnt1 > r_cnt_high && r_pwm_value < 16'd1980)
                    r_pwm_value <= r_pwm_value + 1'b1;		
                else if(r_opto_cnt1 < r_cnt_low && r_pwm_value > 16'd100)
                    r_pwm_value <= r_pwm_value - 1'b1;
                else if(r_opto_cnt1 < r_cnt_lower && r_pwm_value > 16'd100)
                    r_pwm_value <= r_pwm_value - 3'd5;
                else
                    r_pwm_value <= r_pwm_value;
            end
            else if(r_delay_20s == 32'd1_000_000_000 && r_opto_cnt0 + 1'b1 >= TOOTH_NUM && w_opto_rise)begin
                if(r_opto_cnt1 > r_cnt_high && r_pwm_value < 16'd1980)
                    r_pwm_value <= r_pwm_value + 1'b1;		
                else if(r_opto_cnt1 < r_cnt_low && r_pwm_value > 16'd100)
                    r_pwm_value <= r_pwm_value - 1'b1;
                else 
                    r_pwm_value <= r_pwm_value;
            end
        end
        else begin
            if(i_freq_mode == 3'd0)//15hz
                r_pwm_value <= 16'd400;
            else if(i_freq_mode == 3'd2)//25hz
                r_pwm_value <= 16'd600;
            else if(i_freq_mode == 3'd3)//30hz
                r_pwm_value <= 16'd900;
            else
                r_pwm_value <= 16'd400;
        end
    end

    always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_pwm_cnt <= 16'd1999;
		else if(i_measure_mode == 1'b0 || i_cal_mode)
			r_pwm_cnt <= 16'd1999;
		else if(r_pwm_cnt >= 16'd1999)//周期25kHz
			r_pwm_cnt <= 16'd0;
		else
			r_pwm_cnt <= r_pwm_cnt + 16'd1;
    end

	//电机PWM控制
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_motor_pwm <= 1'b0;
		else if(i_measure_mode == 1'b0 || i_cal_mode)
			r_motor_pwm <= 1'b0;
		else if(r_pwm_cnt < r_pwm_value)	
			r_motor_pwm <= 1'b1;
		else
			r_motor_pwm <= 1'b0;
    end

	reg			r_motor_err_sig = 1'b0;
	reg	[7:0]	r_motor_err_cnt = 8'd0;
	reg	[3:0]	r_state_cnt = 4'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_state_cnt <= 4'd0;
        else if(r_opto_cnt1 >= 24'hFFFF00)
			r_state_cnt <= 4'd0;
		else if(r_delay_20s >= 32'd0 && r_opto_cnt0 + 1'b1 >= TOOTH_NUM && w_opto_rise)begin
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
		else
			r_state_cnt <= r_state_cnt;
    end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_motor_err_cnt <= 8'd0;
		else if(r_delay_20s >= 32'd0 && r_opto_cnt0 + 1'b1 >= TOOTH_NUM && w_opto_rise)begin
			if(r_opto_cnt1 > r_cnt_state_low && r_opto_cnt1 < r_cnt_state_high)
				r_motor_err_cnt <= 8'd0;
			else 
				r_motor_err_cnt <= r_motor_err_cnt + 1'b1;
		end
    end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_motor_err_sig <= 1'b0;
        else if(r_opto_cnt1 >= 24'hFFFF00)
			r_motor_err_sig <= 1'b1;
		else if(r_motor_err_cnt >= 8'd200)
			r_motor_err_sig <= 1'b1;
		else if(r_state_cnt >= 4'd6)
			r_motor_err_sig <= 1'b0;
    end

    //1 = 调速完� = 调速未完成	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
	    if(i_rst_n == 0)
			r_motor_state <= 1'b0;
		else if(i_cal_mode)
			r_motor_state <= 1'b1;
		else if(i_measure_mode == 1'b0)
			r_motor_state <= 1'b0;
		else if(r_motor_err_sig && i_measure_mode == 1'b1)
			r_motor_state <= 1'b0;	
		else if(r_state_cnt >= 4'd6)
			r_motor_state <= 1'b1;
		else
			r_motor_state <= r_motor_state;
    end

    assign  o_motor_state = r_motor_state;
	assign  o_pwm_value = r_pwm_value;
    assign  o_speed_value = r_opto_cnt2;
	assign  o_motor_pwm = r_motor_pwm;

endmodule