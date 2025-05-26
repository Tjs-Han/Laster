module motor_control
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input			i_cal_mode   		,//�궨ģʽ��־ 1 = �궨ģʽ 0 = ��ͨģʽ
	input	[1:0]	i_freq_mode  		,//2 = 30Hz	   1 = 25Hz    0 = 15Hz
	input			i_measure_mode		,
	input			i_opto_switch		,//�����ź�����
	input	[15:0]	i_pwm_value_0		,

	output			o_motor_state		,//1 = ������� 0 = ����δ���
	output	[15:0]	o_pwm_value  		,
	output			o_motor_pwm  		 //���PWM���
);

	reg         r_motor_pwm    	= 1'b0;
	reg         r_motor_state 	= 1'b0;
	
	reg  [15:0]r_pwm_value   = 16'd970;//���PWM�ߵ�ƽռ�ձ�
	reg  [15:0]r_pwm_cnt     = 16'd999;//���PWM����
	
	reg        	r_opto_switch1 	= 1'b1;
	reg        	r_opto_switch2	= 1'b1;//�����ź�ͬ��
	
	wire       	w_opto_rise   ;//�����ź�������
	
	reg   [7:0]r_opto_cnt0	= 8'd0;//�����źųݼ���
	reg  [29:0]r_opto_cnt1	= 30'd0;//�����ź������ؼ���
	
	reg		[31:0]r_encoder_cnt;
	
	reg  [31:0]r_delay_40s	= 32'd0;//��ʱ����
	reg			r_delay_en	= 1'b0;
	
	reg  [29:0]r_cnt_max		= 30'd2_000_000;
	reg  [29:0]r_cnt_higher	= 30'd1_800_000;
	reg  [29:0]r_cnt_high		= 30'd1_683_000;
	reg  [29:0]r_cnt_low		= 30'd1_666_666;
	reg  [29:0]r_cnt_lower		= 30'd1_650_000;
	reg  [29:0]r_cnt_state_high= 30'd1_750_000;
	reg  [29:0]r_cnt_state_low	= 30'd1_500_000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_cnt_max 		<= 30'd2_000_000;
			r_cnt_higher	<= 30'd1_800_000;
			r_cnt_high		<= 30'd1_683_000;
			r_cnt_low   	<= 30'd1_666_666;
			r_cnt_lower 	<= 30'd1_650_000;
			r_cnt_state_high<= 30'd1_700_000;
			r_cnt_state_low	<= 30'd1_633_333;
			end
		else if(i_freq_mode == 2'd0)begin
			r_cnt_max 		<= 30'd2_000_000;
			r_cnt_higher	<= 30'd1_800_000;
			r_cnt_high		<= 30'd1_683_000;
			r_cnt_low   	<= 30'd1_666_666;
			r_cnt_lower 	<= 30'd1_650_000;
			r_cnt_state_high<= 30'd1_700_000;
			r_cnt_state_low	<= 30'd1_633_333;
			end
		else if(i_freq_mode == 2'd1)begin
			r_cnt_max 		<= 30'd1_200_000;
			r_cnt_higher	<= 30'd1_080_000;
			r_cnt_high		<= 30'd1_009_800;
			r_cnt_low   	<= 30'd1_000_000;
			r_cnt_lower 	<= 30'd990_000;
			r_cnt_state_high<= 30'd1_020_000;
			r_cnt_state_low	<= 30'd980_000;
			end
		else if(i_freq_mode == 2'd2)begin
			r_cnt_max 		<= 30'd1_000_000;
			r_cnt_higher	<= 30'd900_000;
			r_cnt_high		<= 30'd844_000;
			r_cnt_low   	<= 30'd833_333;
			r_cnt_lower 	<= 30'd825_000;
			r_cnt_state_high<= 30'd850_000;
			r_cnt_state_low	<= 30'd791_666;
			end
	
	always@(posedge i_clk_50m or negedge i_rst_n)//�������ź�������ͬ��
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
			
	assign w_opto_rise = ~r_opto_switch2 & r_opto_switch1;//�ж������ź�������
	
	always@(posedge i_clk_50m or negedge i_rst_n)//�������ź������ؽ��м��������ж��Ƿ񵽴�һȦ
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
			
	always@(posedge i_clk_50m or negedge i_rst_n)//����תһȦ�ж��ٸ�����
		if(i_rst_n == 0)
			r_opto_cnt1 <= 30'd0;
		else if(i_cal_mode)
			r_opto_cnt1 <= 30'd0;
		else if(r_opto_cnt0 == 8'd38 && w_opto_rise)
			r_opto_cnt1 <= 30'd0;
		else
			r_opto_cnt1 <= r_opto_cnt1 + 1'b1;
		
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_delay_en 	<= 1'b0;
		else 
			r_delay_en 	<= 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//��������תʱ��
	   if(i_rst_n == 0)
		   r_delay_40s <= 32'd0;
		else if(i_cal_mode)
		   r_delay_40s <= 32'd0;
		else if(r_delay_40s < 32'd1_000_000_000)
		   r_delay_40s <= r_delay_40s + r_delay_en;
		else
		   r_delay_40s <= r_delay_40s;
//////////////////////////////////////////////////////////////////////�����޸�			
	 reg   frequency_state;           //Ƶ��״̬�Ĵ�
    always@(posedge i_clk_50m or negedge i_rst_n)
	   if(i_rst_n == 0)  	
		 frequency_state <= 1'd1;
       else if(r_opto_cnt0 == 8'd38 && w_opto_rise&&i_freq_mode==2'd0)
         begin
           if(r_opto_cnt1>=32'd2500000)			 
		     frequency_state <= 1'd1;
		   else if(r_opto_cnt1<=32'd1666667)
		     frequency_state <= 1'd0;
		   else
			 frequency_state <= frequency_state;
           end	 
		else if(r_opto_cnt0 == 8'd38 && w_opto_rise&&i_freq_mode==2'd1)
         begin
           if(r_opto_cnt1>=32'd1250000)			 
		     frequency_state <= 1'd1;
		   else if(r_opto_cnt1<=32'd1000000)
		     frequency_state <= 1'd0;
		   else
			 frequency_state <= frequency_state;
           end
         else if(r_opto_cnt0 == 8'd38 && w_opto_rise&&i_freq_mode==2'd2)
         begin
           if(r_opto_cnt1>=32'd1000000)			 
		     frequency_state <= 1'd1;
		   else if(r_opto_cnt1<=32'd833333)
		     frequency_state <= 1'd0;
		   else
			 frequency_state <= frequency_state;
           end
         else
           frequency_state <= frequency_state;	

    reg   [3:0]frequency_state_reg;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
	   if(i_rst_n == 0)
	     frequency_state_reg <= 4'd0;
	   else if(frequency_state==1'd0)
		 begin
		 if(frequency_state_reg==4'd8)
		   frequency_state_reg <= 4'd8;
		 else
		   frequency_state_reg <= frequency_state_reg+1'd1;	 
         end		   
	   else if(frequency_state==1'd1)
		 frequency_state_reg <= 4'd0;
		 
	reg [15:0] 	 r_pwm_value_0;
	always@(posedge i_clk_50m or negedge i_rst_n)
	  if(i_rst_n == 0)
		 r_pwm_value_0 <= i_pwm_value_0;
      else if(r_pwm_value!=16'd980)
		 begin
      if(r_opto_cnt1>=32'd2500000&&r_opto_cnt0 == 8'd38 && w_opto_rise&&i_freq_mode==2'd0)		   
		 r_pwm_value_0 <= r_pwm_value_0 +16'd50;
	  else if(r_opto_cnt1>=32'd1250000&&r_opto_cnt0 == 8'd38 && w_opto_rise&&i_freq_mode==2'd1)		   
		 r_pwm_value_0 <= r_pwm_value_0 +16'd50;
	  else if(r_opto_cnt1>=32'd1000000&&r_opto_cnt0 == 8'd38 && w_opto_rise&&i_freq_mode==2'd2)		   
		 r_pwm_value_0 <= r_pwm_value_0 +16'd50;
      else
         r_pwm_value_0 <= r_pwm_value_0;
         end		  
		 
		 
		 
	always@(posedge i_clk_50m or negedge i_rst_n)//��������һȦ��ʱ�����PWMռ�ձ�
	   if(i_rst_n == 0)
		   r_pwm_value <= 16'd980;
	   else if(frequency_state==1'd1)
		   r_pwm_value <= 16'd980;
	   else if(frequency_state_reg == 4'd4)
		   r_pwm_value <= r_pwm_value_0;//i_pwm_value_0;//
	   else if(r_delay_40s < 32'd1_000_000_000 && r_opto_cnt0 == 8'd38 && w_opto_rise)begin
		   if(r_opto_cnt1 > r_cnt_max && r_pwm_value < 16'd980)
			   r_pwm_value <= r_pwm_value + 4'd5;
			else if(r_opto_cnt1 > r_cnt_higher && r_pwm_value < 16'd980)
			   r_pwm_value <= r_pwm_value + 2'd3;
			else if(r_opto_cnt1 > r_cnt_state_high && r_pwm_value < 16'd980)
			   r_pwm_value <= r_pwm_value + 1'b1;		
			else if(r_opto_cnt1 < r_cnt_state_low && r_pwm_value > 16'd30)
				r_pwm_value <= r_pwm_value - 1'b1;
			else
			   r_pwm_value <= r_pwm_value;
			end
		else if(r_delay_40s == 32'd1_000_000_000 && r_opto_cnt0 == 8'd38 && w_opto_rise)begin
		   if(r_opto_cnt1 > r_cnt_state_low && r_opto_cnt1 < r_cnt_state_high && r_pwm_value < 16'd980)
			   r_pwm_value <= r_pwm_value;
			else if(r_opto_cnt1 >= r_cnt_high && r_pwm_value < 16'd980)
			   r_pwm_value <= r_pwm_value + 1'b1;
			else if(r_opto_cnt1 <= r_cnt_lower && r_pwm_value > 16'd30)
			   r_pwm_value <= r_pwm_value - 1'b1;
			else 
			   r_pwm_value <= r_pwm_value;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pwm_cnt <= 16'd999;
		else if(i_cal_mode)
			r_pwm_cnt <= 16'd999;
		else if(r_pwm_cnt >= 16'd999)//����25kHz
			r_pwm_cnt <= 16'd0;
		else
			r_pwm_cnt <= r_pwm_cnt + 16'd1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//���PWM����
		if(i_rst_n == 0)
			r_motor_pwm <= 1'b0;
		else if(i_cal_mode || i_measure_mode == 1'b0)
			r_motor_pwm <= 1'b0;
		else if(r_pwm_cnt < r_pwm_value)	
			r_motor_pwm <= 1'b1;
		else
			r_motor_pwm <= 1'b0;

//////////////////////////////////////////////////////////////////////////////////////

	reg			r_motor_err_sig = 1'b0;
	reg	[7:0]	r_motor_err_cnt = 8'd0;
	reg	[3:0]	r_state_cnt = 4'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//
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
			
	always@(posedge i_clk_50m or negedge i_rst_n)//
		if(i_rst_n == 0)
			r_motor_err_cnt <= 8'd0;
		else if(r_delay_40s >= 32'd0 && r_opto_cnt0 == 8'd38 && w_opto_rise)begin
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
		else if(r_encoder_cnt >= 32'd50_000_000)
			r_encoder_cnt <= 32'd50_000_000;
		else
			r_encoder_cnt <= r_encoder_cnt + 1'd1;
			
		
	assign      o_motor_pwm   = r_motor_pwm;
	assign      o_motor_state = r_motor_state & i_measure_mode;
	assign      o_pwm_value   = r_pwm_value;

endmodule 