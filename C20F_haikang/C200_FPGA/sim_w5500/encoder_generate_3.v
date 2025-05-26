module encoder_generate_3
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input			i_opto_switch		,//�����ź�����
	input			i_motor_state		,//1 = ������� 0 = ����δ���
	input			i_cal_mode   		,//�궨ģʽ��־ 1 = �궨ģʽ 0 = ��ͨģʽ
	input	[1:0]	i_reso_mode  		,//4:3:�ֱ���ģʽ��־ 3 = 0.5 2 = 0.33 1 = 0.25 0 = 0.2 
	input	[1:0]	i_freq_mode  		,//1 = 25Hz 0 = 15Hz
	input			i_laser_mode 		,
	input	[15:0]	i_angle_offset		,
	
	output			o_zero_sign			,
	output	[15:0]	o_code_angle 		,//�Ƕ�ֵ
	output			o_angle_sync 		 //�����źű�־�����Ա�־��������
);

	reg [15:0]r_code_angle = 16'd0;//�Ƕ�ֵ
	
//////////////////////////////////////////////////////////////////////	
	reg         r_angle_sync_cal = 1'b0;//�궨ģʽ��α��������ź�
	reg			r_zero_sign = 1'b0;
	reg	[15:0]	r_angle_cal_value = 16'd1543;//�궨ģʽ��α��������źŵļ�ʱ��
	reg	[15:0]	r_angle_cal_cnt = 16'd0;//�궨ģʽ��α��������źŵļ�ʱ��
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_cal_value <= 16'd1543;
		else
			r_angle_cal_value <= 16'd1543;
	
	always@(posedge i_clk_50m or negedge i_rst_n)//�궨ģʽ��α��������źŵļ�ʱ��
	   if(i_rst_n == 0)
		   r_angle_cal_cnt <= 16'd0;
		else if(r_angle_cal_cnt + 1'b1 >= r_angle_cal_value)
		   r_angle_cal_cnt <= 16'd0;
		else
		   r_angle_cal_cnt <= r_angle_cal_cnt + 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//�궨ģʽ��α��������ź�,Ϊ27K
	   if(i_rst_n == 0)
		   r_angle_sync_cal <= 1'b0;
		else if(r_angle_cal_cnt + 1'b1 >= r_angle_cal_value)
		   r_angle_sync_cal <= 1'b1;
		else
		   r_angle_sync_cal <= 1'b0;
		   
	//r_zero_sign
	always@(posedge i_clk_50m or negedge i_rst_n)//�궨ģʽ��α�������ź�
		if(i_rst_n == 0)
			r_zero_sign	<= 1'b0;
		else if(r_code_angle == 16'd1026 && r_angle_cal_cnt + 1'b1 >= r_angle_cal_value)
			r_zero_sign	<= 1'b1;
		else
			r_zero_sign	<= 1'b0;
		   
//////////////////////////////////////////////////////////////////////
	
	reg         r_opto_switch1 = 1'b1;
	reg         r_opto_switch2 = 1'b1;//�����ź�ͬ��
	wire        w_opto_rise   ;//�����ź�������	
	
	always@(posedge i_clk_50m or negedge i_rst_n)//�������ź�������ͬ��
	    if(i_rst_n == 0)begin
			r_opto_switch1 <= 1'b1;
			r_opto_switch2 <= 1'b1;
			end
		else begin
			r_opto_switch1 <= i_opto_switch;
			r_opto_switch2 <= r_opto_switch1;
			end
			
	assign w_opto_rise = ~r_opto_switch2 & r_opto_switch1;//�ж������ź�������
	
//////////////////////////////////////////////////////////////////////////
	
	reg   [23:0]r_low_time_prior_cnt = 24'd0;							   //��һ���ڵ͵�ƽʱ�����
	reg   [23:0]r_low_time_current_cnt = 24'd0;						   //��ǰ���ڵ͵�ƽʱ�����
	
	wire        w_zero_sign;
	
	always@(posedge i_clk_50m or negedge i_rst_n)//һ�����ڵ͵�ƽʱ�����
		if(i_rst_n == 0)
			r_low_time_current_cnt <= 24'd0;
		else if(w_opto_rise)
			r_low_time_current_cnt <= 24'd0;
		else if(r_low_time_current_cnt == 24'hfffff0)
			r_low_time_current_cnt <= 24'hfffff0;
		else if(r_opto_switch1 == 0)
			r_low_time_current_cnt <= r_low_time_current_cnt + 1'b1;

	always@(posedge i_clk_50m or negedge i_rst_n)//��һ���ڵ���ʱ��ǰ�������뵱ǰ�͵�ƽ����������һ���ڵص�ƽ����������һ���ڼ�����
		if(i_rst_n == 0)
			r_low_time_prior_cnt   <= 24'd0;
		else if(w_opto_rise)
			r_low_time_prior_cnt   <= r_low_time_current_cnt << 1'b1;
			
	assign w_zero_sign = (r_low_time_current_cnt >= r_low_time_prior_cnt) ? w_opto_rise : 1'b0;
	
/////////////////////////////////////////////////////////////////////////////////				   
	reg [31:0]	r_js_cal = 32'd0;
	reg [23:0]	r_cyc_cnt = 24'd0;
	reg	[7:0]	r_fs_cnt = 8'd27;//ÿ����Ӧ����������
	reg	[15:0]	r_fs_factor = 16'd2427;//����
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_js_cal  <= 32'd0;
			r_cyc_cnt <= 24'd0;
			end
		else if(w_zero_sign)begin
			r_js_cal  <= (r_cyc_cnt * r_fs_factor) >> 8'd17;//(r_cyc_cnt >> 1'b1)/r_fs_cnt;//
			r_cyc_cnt <= 24'd0;
			end
		else if(w_opto_rise)begin
			r_js_cal  <= (r_cyc_cnt * r_fs_factor) >> 8'd16;//r_cyc_cnt/r_fs_cnt;
			r_cyc_cnt <= 24'd0;
			end
		else if(r_cyc_cnt >= 24'hffff00)
			r_cyc_cnt <= r_cyc_cnt;
		else
			r_cyc_cnt <= r_cyc_cnt + 1'b1;

////////////////////////////////////////////////////////////////////////////	
	
	reg	[7:0]	fs_state = 8'd0;//״̬��
	reg        	r_angle_sync = 1'd0;//���⼰����ź�
	reg	[7:0]	r_pss_cnt = 8'd0;//���̳�������
	reg	[7:0]	r_delay_cnt = 8'd0;//��ʱ����
	reg	[7:0]	r_angle_cnt = 8'd0;//�Ƕȸ�������
	reg	[15:0]	r_inrv_cnt = 16'd0;//����ʱ��������
	
	reg			r_opto_rise = 1'd0;//��������������
	//�ֱ���ģʽ��־ 3 = 0.5 2 = 0.33 1 = 0.25 0 = 0.2 
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_fs_cnt <= 8'd27;//0.33
		else if(i_reso_mode == 2'd0)
			r_fs_cnt <= 8'd45;//0.20
		else if(i_reso_mode == 2'd1)
			r_fs_cnt <= 8'd36;//0.25
		else if(i_reso_mode == 2'd2)
			r_fs_cnt <= 8'd27;//0.33
		else if(i_reso_mode == 2'd3)
			r_fs_cnt <= 8'd18;//0.50
			
	//r_fs_factor
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_fs_factor <= 16'd2427;//0.33
		else if(i_reso_mode == 2'd0)
			r_fs_factor <= 16'd1456;//0.20
		else if(i_reso_mode == 2'd1)
			r_fs_factor <= 16'd1820;//0.25
		else if(i_reso_mode == 2'd2)
			r_fs_factor <= 16'd2427;//0.33
		else if(i_reso_mode == 2'd3)
			r_fs_factor <= 16'd3641;//0.50
	
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
			r_delay_cnt  <= 8'd0;
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
					   fs_state     <= FS_JUDGE;
					else
					   fs_state     <= FS_WAIT;
					end
				FS_JUDGE :begin
					if(w_zero_sign)begin
						r_pss_cnt    <= 8'd0;
						fs_state     <= FS_BEGIN;
						end
					else 
					   fs_state     <= FS_JUDGE;
					end
				FS_BEGIN :begin
					r_angle_sync <= 1'b0;
					if(r_pss_cnt <= 8'd38)begin
						if(w_opto_rise || r_opto_rise)begin
							r_pss_cnt    <= r_pss_cnt + 1'b1;
							fs_state     <= FS_DELAY;
							end
						else 
							fs_state     <= FS_BEGIN;
						end
					else 
					   fs_state     <= FS_JUDGE;
					end
				FS_DELAY	:begin
					if(r_delay_cnt < 8'd5)begin
						r_delay_cnt  <= r_delay_cnt + 1'b1;
						fs_state     <= FS_DELAY;
						end
					else begin
						r_delay_cnt  <= 8'd0;
						r_angle_cnt  <= 8'd0;
						r_inrv_cnt   <= 16'd0;
						fs_state     <= FS_CYC;
						end
					end
				FS_CYC  :begin
					r_angle_sync <= 1'b1;
					r_angle_cnt  <= r_angle_cnt + 1'b1;
					fs_state     <= FS_INRV;
					end
				FS_INRV :begin
					r_angle_sync <= 1'b0;
					if(r_inrv_cnt + 2'd3 < r_js_cal)begin
						r_inrv_cnt   <= r_inrv_cnt + 1'b1;
						fs_state     <= FS_INRV;
						end
					else begin
						r_inrv_cnt   <= 16'd0;
						if(r_angle_cnt < r_fs_cnt)
							fs_state     <= FS_CYC;
						else
							fs_state     <= FS_BEGIN;
						end
					end
				default:fs_state     <= FS_IDLE;
				endcase
			end
			
		always@(posedge i_clk_50m or negedge i_rst_n)//��������������
			if(i_rst_n == 0)
				r_opto_rise <= 1'b0;
			else if(fs_state == FS_BEGIN)
				r_opto_rise <= 1'b0;
			else if(w_opto_rise)
				r_opto_rise <= 1'b1;
				
	//////////////////////////////////////////////////////////////////////////////////
	
	reg	[15:0]	r_angle_zero = 16'd0;
	
	wire   		w_angle_sync_pre , w_angle_sync;
	reg			r_angle_sync_out = 1'b0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_zero <= 16'd0;
		else begin
			case(i_reso_mode)
				2'd0:r_angle_zero <= (i_angle_offset[15:8] * 3'd5) + i_angle_offset[7:0];
				2'd1:r_angle_zero <= i_angle_offset[15:10] + i_angle_offset[7:0];
				2'd2:r_angle_zero <= (i_angle_offset[15:8] * 2'd3) + i_angle_offset[7:0];
				2'd3:r_angle_zero <= i_angle_offset[15:9] + i_angle_offset[7:0];
				endcase
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_code_angle <= 16'd0;
		else if(w_zero_sign)
			r_code_angle <= r_angle_zero;
		else if(w_angle_sync)begin
			if(r_code_angle >= 16'd1755 && i_reso_mode == 2'd0)
				r_code_angle <= 16'd0;
			else if(r_code_angle >= 16'd1404 && i_reso_mode == 2'd1)
				r_code_angle <= 16'd0;
			else if(r_code_angle >= 16'd1053 && i_reso_mode == 2'd2)
				r_code_angle <= 16'd0;
			else if(r_code_angle >= 16'd702 && i_reso_mode == 2'd3)
				r_code_angle <= 16'd0;
			else
				r_code_angle <= r_code_angle + 1'b1;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_sync_out	<= 1'b0;
		else
			r_angle_sync_out	<= w_angle_sync;
			
	assign w_angle_sync_pre = (i_cal_mode) ? r_angle_sync_cal : r_angle_sync;
	assign o_zero_sign		= (i_cal_mode) ? r_zero_sign : w_zero_sign;
	assign w_angle_sync 	= (i_laser_mode)? w_angle_sync_pre : 1'b0;
	assign o_angle_sync		= r_angle_sync_out;
	assign o_code_angle 	= r_code_angle;

endmodule 