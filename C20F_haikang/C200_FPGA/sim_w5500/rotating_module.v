module rotating_module
(
	input			i_clk_50m		,
	input			i_rst_n			,
	
	input			i_opto_switch	,//�����ź�����
	input	[7:0]	i_config_mode 	,//0:�궨ģʽ��־ 1 = �궨ģʽ 0 = ��ͨģʽ	2:1:ת��ģʽ��־ 1 = 25Hz 0 = 15hz 4:3:�ֱ���ģʽ��־ 3 = 0.5 2 = 0.33 1 = 0.25 0 = 0.2  5:����ģʽ��־λ 1 = ����ģʽ 0 = ������ģʽ 6:���ģʽ 1�����ģʽ 0������ģʽ
	input	[15:0]	i_pwm_value_0	,//���ת�ٳ�ʼֵ
	input	[15:0]	i_angle_offset	,
	
	
	output			o_encoder_right,
	output			o_motor_state	,//1 = ������� 0 = ����δ���
	output	[15:0]	o_pwm_value  	,//��ǰ���PWMֵ
	output			o_motor_pwm  	,//���PWM���
	output	[15:0]	o_code_angle 	,//�Ƕ�ֵ
	output	[15:0]	o_zero_angle	,
	output			o_zero_sign		,
	output			o_angle_sync 	 //�����źű�־�����Ա�־��������
);

	wire			w_cal_mode;
	wire	[1:0]	w_freq_mode;
	wire	[1:0]	w_reso_mode;
	wire			w_laser_mode;
	wire			w_measure_mode;
	
	assign	w_cal_mode		= i_config_mode[0];
	assign	w_freq_mode		= i_config_mode[2:1];
	assign	w_reso_mode		= i_config_mode[4:3];
	assign	w_laser_mode	= i_config_mode[5];
	assign	w_measure_mode	= i_config_mode[6];

	wire			w_opto_switch;
	opto_switch_filter U1
	(
		.i_clk_50m    		(i_clk_50m)		,
		.i_rst_n      		(i_rst_n)		,
		
		.i_opto_switch		(i_opto_switch)	,//�����ź�����
		
		.o_opto_switch		(w_opto_switch)	 //�����ź����
	);
	
	motor_control U2
	(
		.i_clk_50m    		(i_clk_50m)		,
		.i_rst_n      		(i_rst_n)		,
		
		.i_cal_mode   		(w_cal_mode)	,//�궨ģʽ��־ 1 = �궨ģʽ 0 = ��ͨģʽ
		.i_freq_mode  		(w_freq_mode)	,//1 = 25Hz    0 = 15Hz
		.i_measure_mode		(w_measure_mode),
		.i_opto_switch		(i_opto_switch)	,//�����ź�����
		.i_pwm_value_0		(i_pwm_value_0)	,
	
		.o_motor_state		(o_motor_state)	,//1 = ������� 0 = ����δ���
		.o_pwm_value  		(o_pwm_value)	,
		.o_motor_pwm  		(o_motor_pwm)	 //���PWM���
	);
	
	encoder_generate U3
	(
		.i_clk_50m    		(i_clk_50m)		,
		.i_rst_n      		(i_rst_n)		,
		
		.i_opto_switch		(w_opto_switch)	,//�����ź�����
		.i_motor_state		(o_motor_state)	,//1 = ������� 0 = ����δ���
		.i_cal_mode   		(w_cal_mode)	,//�궨ģʽ��־ 1 = �궨ģʽ 0 = ��ͨģʽ
		.i_reso_mode  		(w_reso_mode)	,//1 = 0.33��  0 = 0.2��
		.i_freq_mode  		(w_freq_mode)	,//1 = 25Hz    0 = 15Hz
		.i_laser_mode 		(w_laser_mode)	,
		.i_angle_offset		(i_angle_offset),
		
		.o_encoder_right	(o_encoder_right),
		.o_zero_sign		(o_zero_sign)	,
		.o_code_angle 		(o_code_angle)	,//�Ƕ�ֵ
		.o_zero_angle		(o_zero_angle)	,
		.o_angle_sync 		(o_angle_sync) 	 //�����źű�־�����Ա�־��������
	);

endmodule 