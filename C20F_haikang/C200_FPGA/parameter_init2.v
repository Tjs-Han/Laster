
`include "datagram_cmd_defines.v"
`include "parameter_ident_define.v"

module parameter_init2
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	output	[31:0]	o_set_para0 		,
	output	[31:0]	o_set_para1			,
	output	[31:0]	o_set_para2			,
	output	[31:0]	o_set_para3			,
	output	[31:0]	o_set_para4			,
	output	[31:0]	o_set_para5			,
	output	[31:0]	o_set_para6			,
	output	[31:0]	o_set_para7			,
	output	[31:0]	o_set_para8			,

	input	[31:0]	i_get_para0			,
	input	[31:0]	i_get_para1			,
	input	[31:0]	i_get_para2			,
	input	[31:0]	i_get_para3			,
	input	[31:0]	i_get_para4			,
	input	[31:0]	i_get_para5			,
	input	[31:0]	i_get_para6			,
	input	[31:0]	i_get_para7			,
	input	[31:0]	i_get_para8			,

	output	[7:0]	o_set_cmd_code		,
	input	[7:0]	i_get_cmd_code		,

	input			i_cmd_ack			,
	output			o_cmd_make			,
	
	input			i_packet_make		,
	
	input	[15:0]	i_scan_counter		,
	input	[7:0]	i_telegram_no		,
	input	[15:0]	i_first_angle		,
	input	[15:0]	i_packet_points		,
	input	[31:0]	i_time_stamp		,
	input	[15:0]	i_code_angle		,
	input	[15:0]	i_pulse_get			,
	input	[7:0]	i_status_code		,
	input	[15:0]	i_apd_hv_value		,
	input	[15:0]	i_device_temp		,
	
	output	[7:0]	o_config_mode		,
	output	[15:0]	o_pwm_value_0		,
	output	[15:0]	o_tdc_window		,
	output	[15:0]	o_rise_start		,
	output	[15:0]	o_rise_step			,
	output	[15:0]	o_pulse_start		,
	output	[15:0]	o_pulse_step		,
	output	[15:0]	o_apd_hv_base		,
	output	[15:0]	o_apd_hv_coe		,
	output	[15:0]	o_pulse_stand		,
	
	input			i_read_complete_sig ,
	output			o_sram_csen_eth		,
	output			o_sram_wren_eth		,
	output			o_sram_rden_eth		,
	output	[17:0]	o_sram_addr_eth		,
	output	[15:0]	o_sram_data_eth		,
	input	[15:0]	i_sram_data_eth		,
	
	output			o_eth_data_rq		,
	input	 [7:0]	i_eth_data			,
	
	output	[1:0]	o_telegram_flag		,
	output	[2:0]	o_sram_store_flag	,	
	output			o_rst_n				
);

	reg		[9:0]	r_para_state = 10'd0;
	reg				r_sram_csen_eth = 1'b0;
	reg				r_sram_wren_eth = 1'b1;
	reg				r_sram_rden_eth = 1'b1;
	reg		[17:0]	r_sram_addr_eth = 18'd0;
	reg		[15:0]	r_sram_data_eth = 16'd0;
	reg		[17:0]	r_sram_addr_base = 18'd0; 
	reg		[9:0]	r_write_cnt	= 10'd0;
	
	reg				r_para_write_flag = 1'b0;
	reg		[7:0]	r_sram_addr_para = 8'd0;
	reg				r_coe_set_flag = 1'b0;
	reg				r_coe_write_flag = 1'b0;
	reg				r_alarm_set_flag = 1'b0;
	reg				r_alarm_write_flag = 1'b0;
	
	reg				r_login_state_02 = 1'b0;
	reg				r_login_state_03 = 1'b0;
	reg				r_check_pass_state = 1'b0;
	reg				r_eth_data_rq = 1'b0;
	
	wire			w_main_level,w_auth_level;
	
	reg				r_init_flag = 1'b0;//初始化标志位
	reg		[31:0]	r_password_user = 32'hF4724744;//用户密码
	reg		[31:0]	r_device_name	= 32'h0;
	reg		[31:0]	r_ip_addr	= 32'hC0A8016F;
	reg		[31:0]	r_gate_way	= 32'hC0A80101;
	reg		[31:0]	r_sub_mask	= 32'hFFFFFF00;
	reg		[47:0]	r_mac_addr	= 48'h112233445566;
	reg		[31:0]	r_serial_number = 32'h21050001;
	reg		[15:0]	r_scan_freqence	= 16'd1500;
	reg		[15:0]	r_angle_reso	= 16'd3333;
	reg		[31:0]	r_start_angle	= 32'hFFF92230;
	reg		[31:0]	r_stop_angle	= 32'h00225510;
	reg		[7:0]	r_data_layout	= 8'd0;//0：时间戳开关，1：反射率开关，2：滤波开关
	
	
	reg		[7:0]	r_device_mode	= 8'd0;//0：标定模式，1：出光模式，2：平滑开关，3：脉宽模式，4：0模式
	reg		[15:0]	r_pulse_stand	= 16'd0;
	reg		[15:0]	r_tdc_window	= 16'd0;
	reg		[15:0]	r_apd_hv_base	= 16'd0;
	reg		[15:0]	r_apd_hv_coe	= 16'd0;
	reg		[15:0]	r_pwm_value_0	= 16'd0;
	reg		[15:0]	r_rise_start	= 16'd0;
	reg		[15:0]	r_rise_step		= 16'd0;
	reg		[15:0]	r_pulse_start	= 16'd0;
	reg		[15:0]	r_pulse_step	= 16'd0;
	
	reg		[1:0]	r_telegram_flag = 2'd0;
	reg		[1:0]	r_telegram_flag_pre = 2'd0;
	reg				r_loop_telegram_flag = 1'b0;
	reg				r_rst_n		  = 1'b0;
	reg				r_parameter_sig = 1'b0;
	reg				r_measurn_switch = 1'b1;
	
	reg		[31:0]	r_set_para0 	= 32'd0;
	reg		[31:0]	r_set_para1		= 32'd0;
	reg		[31:0]	r_set_para2		= 32'd0;
	reg		[31:0]	r_set_para3		= 32'd0;
	reg		[31:0]	r_set_para4		= 32'd0;
	reg		[31:0]	r_set_para5		= 32'd0;
	reg		[31:0]	r_set_para6		= 32'd0;
	reg		[31:0]	r_set_para7		= 32'd0;
	reg		[31:0]	r_set_para8		= 32'd0;

	reg		[7:0]	r_set_cmd_code	= 8'd0;

	reg				r_cmd_make		= 1'b0;
	
	reg				r_cmd_ack		= 1'b0;
	reg				r_cmd_ack1		= 1'b0;
	wire			w_cmd_ack_rise	;
	
	parameter		PARA_IDLE		= 10'b00_0000_0000,
					PARA_WAIT		= 10'b00_0000_0010,
					PARA_READ		= 10'b00_0000_0100,
					PARA_WRITE		= 10'b00_0000_1000,
					PARA_STORE		= 10'b00_0001_0000,
					PARA_SHIF2		= 10'b00_0010_0000,
					PARA_WRIT2		= 10'b00_0100_0000,
					PARA_SHIF3		= 10'b00_1000_0000,
					PARA_WRIT3		= 10'b01_0000_0000,
					PARA_END		= 10'b10_0000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_para_state	<= PARA_IDLE;
		else begin
			case(r_para_state)
				PARA_IDLE	:begin
					r_para_state	<= PARA_WAIT;
					end
				PARA_WAIT	:begin
					if(i_read_complete_sig)
						r_para_state	<= PARA_READ;
					else if(r_para_write_flag)
						r_para_state	<= PARA_WRITE;
					else if(r_coe_set_flag)
						r_para_state	<= PARA_SHIF2;
					else if(r_alarm_set_flag)
						r_para_state	<= PARA_SHIF3;
					end
				PARA_READ	:begin
					if(r_sram_addr_eth >= `PARAMETER_NUM - 1'b1)
						r_para_state	<= PARA_END;
					end
				PARA_WRITE	:begin
					if(r_sram_addr_eth >= `PARAMETER_NUM - 1'b1)
						r_para_state	<= PARA_STORE;
					end
				PARA_STORE	:begin
					r_para_state	<= PARA_END;
					end
				PARA_SHIF2	:begin
					r_para_state	<= PARA_WRIT2;
					end
				PARA_WRIT2	:begin
					if(r_write_cnt >= 10'd512)
						r_para_state	<= PARA_END;
					else
						r_para_state	<= PARA_SHIF2;
					end
				PARA_SHIF3	:begin
					r_para_state	<= PARA_WRIT3;
					end
				PARA_WRIT3	:begin
					if(r_write_cnt >= 10'd811)
						r_para_state	<= PARA_END;
					else
						r_para_state	<= PARA_SHIF3;
					end
				PARA_END	:begin
					r_para_state	<= PARA_WAIT;
					end
				default:r_para_state	<= PARA_IDLE;
				endcase
			end
			
	//r_sram_addr_base
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_addr_base	<= 18'd0;
		else if(r_para_state == PARA_IDLE)
			r_sram_addr_base	<= 18'd0;
		else if(r_para_state == PARA_WAIT)begin
			if(r_coe_set_flag)
				r_sram_addr_base	<= 18'h10000 + (r_sram_addr_para << 4'd9);
			else if(r_alarm_set_flag)
				r_sram_addr_base	<= 18'h10000 + (r_sram_addr_para << 4'd10);
			end
		else if(r_para_state == PARA_END)
			r_sram_addr_base	<= 18'd0;
				
	//r_eth_data_rq
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_eth_data_rq	<= 1'b0;
		else if(r_para_state == PARA_IDLE)
			r_eth_data_rq	<= 1'b0;
		else if(r_para_state == PARA_WAIT && (r_coe_set_flag || r_alarm_set_flag))
			r_eth_data_rq	<= 1'b1;
		else if(r_para_state == PARA_WRIT2 && r_write_cnt >= 10'd511)
			r_eth_data_rq	<= 1'b0;
		else if(r_para_state == PARA_WRIT2 && r_write_cnt >= 10'd810)
			r_eth_data_rq	<= 1'b0;		
			
	//r_write_cnt
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_write_cnt		<= 10'd0;
		else if(r_para_state == PARA_IDLE)
			r_write_cnt		<= 10'd0;
		else if(r_para_state == PARA_SHIF2 || r_para_state == PARA_SHIF3)
			r_write_cnt		<= r_write_cnt + 1'b1;
		else if(r_para_state == PARA_END)
			r_write_cnt		<= 10'd0;
			
	//r_sram_csen_eth
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_csen_eth	<= 1'b0;
		else if(r_para_state == PARA_IDLE)
			r_sram_csen_eth	<= 1'b0;
		else if(r_para_state == PARA_WAIT && (i_read_complete_sig || r_para_write_flag))
			r_sram_csen_eth	<= 1'b1;
		else if(r_para_state == PARA_WRITE && r_sram_addr_eth >= 18'd31)
			r_sram_csen_eth	<= 1'b0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth >= 18'd31)
			r_sram_csen_eth	<= 1'b0;
		else if(r_para_state == PARA_WRIT2 || r_para_state == PARA_WRIT3)
			r_sram_csen_eth	<= 1'b1;
			
	//r_sram_wren_eth
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_wren_eth	<= 1'b1;
		else if(r_para_state == PARA_IDLE)
			r_sram_wren_eth	<= 1'b1;
		else if(r_para_state == PARA_WAIT && r_para_write_flag)
			r_sram_wren_eth	<= 1'b0;
		else if(r_para_state == PARA_WRIT2 || r_para_state == PARA_WRIT3)
			r_sram_wren_eth	<= 1'b0;
		else if(r_para_state == PARA_WRITE && r_sram_addr_eth >= 18'd31)
			r_sram_wren_eth	<= 1'b1;
			
	//r_sram_rden_eth
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_rden_eth	<= 1'b1;
		else if(r_para_state == PARA_IDLE)
			r_sram_rden_eth	<= 1'b1;
		else if(r_para_state == PARA_WAIT && i_read_complete_sig)
			r_sram_rden_eth	<= 1'b0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth >= 18'd31)
			r_sram_rden_eth	<= 1'b1;
			
	//r_sram_data_eth
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_data_eth	<= 16'd0;
		else if(r_para_state == PARA_WAIT && r_para_write_flag)
			r_sram_data_eth	<= 16'hAAAA;
		else if(r_para_state == PARA_SHIF2 || r_para_state == PARA_SHIF3)
			r_sram_data_eth[15:8] <= i_eth_data;
		else if(r_para_state == PARA_WRIT2 || r_para_state == PARA_WRIT3)
			r_sram_data_eth[7:0] <= i_eth_data;
		else if(r_para_state == PARA_WRITE)begin
			case(r_sram_addr_eth[5:0] + 1'b1)
				//`INITIAL_FLAG		: r_sram_data_eth	<= 16'hAAAA;
				`PASSWORD_USER_H	: r_sram_data_eth	<= r_password_user[31:16];
				`PASSWORD_USER_L	: r_sram_data_eth	<= r_password_user[15:0];
				`DEVIDE_NAME_H		: r_sram_data_eth	<= r_device_name[31:16];
				`DEVIDE_NAME_L		: r_sram_data_eth	<= r_device_name[15:0];
				`ETH_IP_ADDR_H		: r_sram_data_eth	<= r_ip_addr[31:16];
				`ETH_IP_ADDR_L		: r_sram_data_eth	<= r_ip_addr[15:0];
				`ETH_GATE_WAY_H		: r_sram_data_eth	<= r_gate_way[31:16];
				`ETH_GATE_WAY_L		: r_sram_data_eth	<= r_gate_way[15:0];
				`ETH_SUB_MASK_H		: r_sram_data_eth	<= r_sub_mask[31:16];
				`ETH_SUB_MASK_L		: r_sram_data_eth	<= r_sub_mask[15:0];
				`ETH_MAC_ADDR_H		: r_sram_data_eth	<= r_mac_addr[47:32];
				`ETH_MAC_ADDR_M		: r_sram_data_eth	<= r_mac_addr[31:16];
				`ETH_MAC_ADDR_L		: r_sram_data_eth	<= r_mac_addr[15:0];
				`SERIAL_NUMBER_H	: r_sram_data_eth	<= r_serial_number[31:16];
				`SERIAL_NUMBER_L	: r_sram_data_eth	<= r_serial_number[15:0];
				`SCAN_FREQUENCY		: r_sram_data_eth	<= r_scan_freqence;
				`ANGLE_RESOLUTION	: r_sram_data_eth	<= r_angle_reso;
				`START_ANGLE_H		: r_sram_data_eth	<= r_start_angle[31:16];
				`START_ANGLE_L		: r_sram_data_eth	<= r_start_angle[15:0];
				`STOP_ANGLE_H		: r_sram_data_eth	<= r_stop_angle[31:16];
				`STOP_ANGLE_L		: r_sram_data_eth	<= r_stop_angle[15:0];
				`DATA_LAYOUT_FLAG	: r_sram_data_eth	<= {8'd0,r_data_layout};

				`DEVICE_STATUS		: r_sram_data_eth	<= {8'd0,r_device_mode};
				`PULSE_STANDARD		: r_sram_data_eth	<= r_pulse_stand;
				`TDC_WINDOW			: r_sram_data_eth	<= r_tdc_window;
				`APD_HV_BASE		: r_sram_data_eth	<= r_apd_hv_base;
				`APD_HV_COE			: r_sram_data_eth	<= r_apd_hv_coe;
				`MOTOR_PWM_INIT		: r_sram_data_eth	<= r_pwm_value_0;
				`RISE_START			: r_sram_data_eth	<= r_rise_start;
				`RISE_STEP			: r_sram_data_eth	<= r_rise_step;
				`PULSE_START		: r_sram_data_eth	<= r_pulse_start;
				`PULSE_STEP			: r_sram_data_eth	<= r_pulse_step;
				default				: r_sram_data_eth	<= 16'd0;
				endcase
			end
						
	//r_sram_addr_eth
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_addr_eth	<= 18'd0;
		else if(r_para_state == PARA_IDLE)
			r_sram_addr_eth	<= 18'd0;
		else if(r_para_state == PARA_WAIT && (i_read_complete_sig || r_para_write_flag))
			r_sram_addr_eth	<= 18'd0;
		else if(r_para_state == PARA_READ)
			r_sram_addr_eth	<= r_sram_addr_eth + 1'b1;
		else if(r_para_state == PARA_WRITE)
			r_sram_addr_eth	<= r_sram_addr_eth + 1'b1;
		else if(r_para_state == PARA_WRIT2 || r_para_state == PARA_WRIT3)
			r_sram_addr_eth	<= r_sram_addr_base + r_write_cnt - 1'b1;
		else if(r_para_state == PARA_END)
			r_sram_addr_eth	<= 18'd0;
			
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//标志位设置
	//r_parameter_sig 参数保存标志位对外
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_parameter_sig	<= 1'b0;
		else if(r_para_state == PARA_STORE)
			r_parameter_sig	<= 1'b1;
		else
			r_parameter_sig	<= 1'b0;
			
	//r_para_write_flag = 1'b0; 参数保存标志位对内
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_para_write_flag	<= 1'b0;
		else if(r_set_cmd_code == `SAVE_U_PARA && r_cmd_ack)
			r_para_write_flag	<= 1'b1;
		else
			r_para_write_flag	<= 1'b0;
			
	//r_coe_set_flag 系数设置标志位
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_coe_set_flag		<= 1'b0;
		else if(r_set_cmd_code == `SET_COE && r_cmd_ack)
			r_coe_set_flag		<= 1'b1;
		else
			r_coe_set_flag		<= 1'b0;
			
	//r_coe_write_flag 系数保存标志位
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_coe_write_flag	<= 1'b0;
		else if(r_set_cmd_code == `SAVE_COE && r_cmd_ack)
			r_coe_write_flag	<= 1'b1;
		else
			r_coe_write_flag	<= 1'b0;
			
	//r_alarm_set_flag 区域报警设置标志位
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_alarm_set_flag	<= 1'b0;
		else if(r_set_cmd_code == `SET_ALARM && r_cmd_ack)
			r_alarm_set_flag	<= 1'b1;
		else
			r_alarm_set_flag	<= 1'b0;

	//r_alarm_write_flag 区域报警保存标志位
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_alarm_write_flag	<= 1'b0;
		else if(r_set_cmd_code == `SAVE_ALARM && r_cmd_ack)
			r_alarm_write_flag	<= 1'b1;
		else
			r_alarm_write_flag	<= 1'b0;
			
	//r_sram_addr_para SRAM地址参数设置
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_sram_addr_para	<= 8'd0;
		else if(r_set_cmd_code == `SET_COE && r_cmd_ack)
			r_sram_addr_para	<= i_get_para0[7:0];
		else if(r_set_cmd_code == `SET_ALARM && r_cmd_ack)
			r_sram_addr_para	<= i_get_para0[7:0];
			
	//r_telegram_flag_pre 单次标定取数标志位
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_telegram_flag_pre	<= 2'd0;
		else if(r_set_cmd_code == `CALI_DATA && r_cmd_ack)
			r_telegram_flag_pre	<= 2'b10;
		else if(r_set_cmd_code == `ONCE_DATA && r_cmd_ack)
			r_telegram_flag_pre	<= 2'b01;
		else if(i_packet_make)
			r_telegram_flag_pre	<= 2'd0;
			
	//r_loop_telegram_flag 连续取数标志位
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_loop_telegram_flag <= 1'b0;
		else if(r_set_cmd_code == `LOOP_DATA_SWITCH && r_cmd_ack)
			r_loop_telegram_flag <= i_get_para0[0];
			
	//r_telegram_flag
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_telegram_flag	<= 2'd0;
		else if(i_code_angle == 16'd0)begin
			if(r_loop_telegram_flag)
				r_telegram_flag	<= 2'b01;
			else
				r_telegram_flag	<= r_telegram_flag_pre;
			end
				
	//r_rst_n
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rst_n		<= 1'b0;
		else if(r_para_state == PARA_END)
			r_rst_n		<= 1'b1;
			
	//r_login_state_02
	//r_login_state_03
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_login_state_02	<= 1'b0;
			r_login_state_03	<= 1'b0;
			end
		else if(r_set_cmd_code == `LOGIN && r_cmd_ack)begin
			if(i_get_para0 == 32'h00000002 && i_get_para1 == 32'h20210518)
				r_login_state_02	<= 1'b1;
			else if(i_get_para0 == 32'h00000003 && i_get_para1 == r_password_user)
				r_login_state_03	<= 1'b1;
			end
			
	assign w_main_level = r_login_state_02;
	assign w_auth_level = r_login_state_02 | r_login_state_03;
			
	//r_check_pass_state = 1'b0;
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_check_pass_state <= 1'b0;
		else if(r_set_cmd_code == `CHECK_PASSWORD && r_cmd_ack)begin
			if(i_get_para0 == 32'h00000003 && i_get_para1 == r_password_user && r_login_state_03)
				r_check_pass_state <= 1'b1;
			else if(r_login_state_02)begin
				if(i_get_para0 == 32'h00000002 && i_get_para1 == 32'h20210518)
					r_check_pass_state	<= 1'b1;
				else if(i_get_para0 == 32'h00000003 && i_get_para1 == r_password_user)
					r_check_pass_state	<= 1'b1;
				end
			end
			
	//r_measurn_switch
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_measurn_switch	<= 1'b1;
		else if(r_set_cmd_code == `MEAS_SWITCH && r_cmd_ack && w_auth_level)
			r_measurn_switch 	<= i_get_para0[0];
			
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//r_init_flag
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_init_flag		<= 1'b0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `INITIAL_FLAG)begin
			if(i_sram_data_eth == 16'hAAAA)
				r_init_flag		<= 1'b1;
			else
				r_init_flag		<= 1'b0;
			end
			
	//r_password_user
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_password_user			<= 32'hF4724744;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `PASSWORD_USER_H && r_init_flag)
			r_password_user[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `PASSWORD_USER_L && r_init_flag)
			r_password_user[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_PASSWORD && r_cmd_ack && w_auth_level)
			r_password_user			<= i_get_para0;
			
	//r_device_name
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_device_name		<= 32'h0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `DEVIDE_NAME_H && r_init_flag)
			r_device_name[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `DEVIDE_NAME_L && r_init_flag)
			r_device_name[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_DEV_NAME && r_cmd_ack && w_auth_level)
			r_device_name			<= i_get_para0;

	//r_ip_addr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_ip_addr			<= 32'hC0A8016F;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `ETH_IP_ADDR_H && r_init_flag)
			r_ip_addr[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `ETH_IP_ADDR_L && r_init_flag)
			r_ip_addr[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_IP && r_cmd_ack && w_auth_level)
			r_ip_addr <= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0]};
			
	//r_gate_way
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_gate_way			<= 32'hC0A80101;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `ETH_GATE_WAY_H && r_init_flag)
			r_gate_way[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `ETH_GATE_WAY_L && r_init_flag)
			r_gate_way[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_GATEWAY && r_cmd_ack && w_auth_level)
			r_gate_way <= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0]};	
	
	//r_sub_mask
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sub_mask			<= 32'hFFFFFF00;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `ETH_SUB_MASK_H && r_init_flag)
			r_sub_mask[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `ETH_SUB_MASK_L && r_init_flag)
			r_sub_mask[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_SUBNET && r_cmd_ack && w_auth_level)
			r_sub_mask <= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0]};

	//r_mac_addr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_mac_addr			<= 48'h112233445566;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `ETH_MAC_ADDR_H && r_init_flag)
			r_mac_addr[47:32]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `ETH_MAC_ADDR_M && r_init_flag)
			r_mac_addr[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `ETH_MAC_ADDR_L && r_init_flag)
			r_mac_addr[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_MAC && r_cmd_ack && w_auth_level)
			r_mac_addr <= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0], i_get_para4[7:0], i_get_para5[7:0]};

	//r_serial_number
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_serial_number			<= 32'h21050001;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `SERIAL_NUMBER_H && r_init_flag)
			r_serial_number[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `SERIAL_NUMBER_L && r_init_flag)
			r_serial_number[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_SN && r_cmd_ack && w_main_level)
			r_serial_number			<= i_get_para0;

	//r_scan_freqence
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_scan_freqence			<= 16'd1500;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `SCAN_FREQUENCY && r_init_flag)
			r_scan_freqence			<= i_sram_data_eth;
			
	//r_angle_reso
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_reso			<= 16'd3333;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `ANGLE_RESOLUTION && r_init_flag)
			r_angle_reso			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_RESOLUTION && r_cmd_ack && w_auth_level)
			r_angle_reso			<= i_get_para0[15:0];
			
	//r_start_angle
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_start_angle			<= 32'hFFF92230;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `START_ANGLE_H && r_init_flag)
			r_start_angle[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `START_ANGLE_L && r_init_flag)
			r_start_angle[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_ANGLE && r_cmd_ack && w_auth_level)
			r_start_angle			<= i_get_para0;
			
	//r_stop_angle
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_stop_angle			<= 32'h00225510;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `STOP_ANGLE_H && r_init_flag)
			r_stop_angle[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `STOP_ANGLE_L && r_init_flag)
			r_stop_angle[15:0]		<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_ANGLE && r_cmd_ack && w_auth_level)
			r_stop_angle			<= i_get_para1;
			
	//r_data_layout
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_data_layout			<= 8'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `DATA_LAYOUT_FLAG && r_init_flag)
			r_data_layout			<= i_sram_data_eth[7:0];

	//r_device_mode
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_device_mode			<= 8'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `DEVICE_STATUS && r_init_flag)
			r_device_mode			<= i_sram_data_eth[7:0];
		else if(r_set_cmd_code == `SET_CALI_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[7]		<= i_get_para0[0];
		else if(r_set_cmd_code == `SET_LASING_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[6]		<= i_get_para0[0];
		else if(r_set_cmd_code == `SET_FILTER_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[5]		<= i_get_para0[0];
		else if(r_set_cmd_code == `SET_COMP_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[4]		<= i_get_para0[0];
		else if(r_set_cmd_code == `SET_0_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[3]		<= i_get_para0[0];
			
	//r_pulse_stand
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_stand			<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `PULSE_STANDARD && r_init_flag)
			r_pulse_stand			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_UP_PARA && r_cmd_ack && w_auth_level)
			r_pulse_stand			<= i_get_para0[15:0];
			
	//r_tdc_window
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_window			<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `TDC_WINDOW && r_init_flag)
			r_tdc_window			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_TDC_WIN && r_cmd_ack && w_auth_level)
			r_tdc_window			<= {i_get_para0[7:0],i_get_para1[7:0]};

	//r_apd_hv_base
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_apd_hv_base			<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `APD_HV_BASE && r_init_flag)
			r_apd_hv_base			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_HV_REF && r_cmd_ack && w_auth_level)
			r_apd_hv_base	<= i_get_para0[15:0];
			
	//r_apd_hv_coe
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_apd_hv_coe			<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `APD_HV_COE && r_init_flag)
			r_apd_hv_coe			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_HV_COE && r_cmd_ack && w_auth_level)
			r_apd_hv_coe	<= i_get_para0[15:0];
			
	//r_pwm_value_0
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pwm_value_0			<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `MOTOR_PWM_INIT && r_init_flag)
			r_pwm_value_0			<= i_sram_data_eth;
			
	//r_rise_start
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rise_start			<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `RISE_START && r_init_flag)
			r_rise_start			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_auth_level)
			r_rise_start	<= i_get_para0[15:0];
			
	//r_rise_step
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rise_step			<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `RISE_STEP && r_init_flag)
			r_rise_step			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_auth_level)
			r_rise_step	<= i_get_para1[15:0];
			
	//r_pulse_start
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_start			<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `PULSE_START && r_init_flag)
			r_pulse_start			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_auth_level)
			r_rise_step	<= i_get_para2[15:0];
			
	//r_pulse_step
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_step			<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth == `PULSE_STEP && r_init_flag)
			r_pulse_step			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_auth_level)
			r_rise_step	<= i_get_para3[15:0];
			
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
	//r_set_cmd_code
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_set_cmd_code	<= 8'd0;
		else if(i_cmd_ack)
			r_set_cmd_code	<= i_get_cmd_code;
		else if(i_packet_make)begin
			if(r_telegram_flag[1])
				r_set_cmd_code	<= `CALI_DATA;
			else
				r_set_cmd_code	<= `LOOP_DATA;
			end
			
	//r_cmd_ack
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)begin
			r_cmd_ack	<= 1'b0;
			r_cmd_ack1	<= 1'b0;
			end
		else begin
			r_cmd_ack	<= i_cmd_ack;
			r_cmd_ack1	<= r_cmd_ack;
			end
			
	assign	w_cmd_ack_rise = ~r_cmd_ack & r_cmd_ack1;
			
	//r_set_para
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)begin
			r_set_para0		<= 32'd0;
			r_set_para1		<= 32'd0;
			r_set_para2		<= 32'd0;
			r_set_para3		<= 32'd0;
			r_set_para4		<= 32'd0;
			r_set_para5		<= 32'd0;
			r_set_para6		<= 32'd0;
			r_set_para7		<= 32'd0;
			r_set_para8		<= 32'd0;
			end
		else if(r_cmd_ack)begin
			case(r_set_cmd_code)
				`LOGIN:
					r_set_para0 <= {31'd0,	r_login_state_02|r_login_state_03};
				`SET_PASSWORD:
					r_set_para0 <= r_password_user;
				`CHECK_PASSWORD:
					r_set_para0 <= {31'd0,	r_check_pass_state};
				`MEAS_SWITCH:
					r_set_para0 <= {31'd0,	r_measurn_switch};
				`GET_FW_VER:
					r_set_para0 <= 32'h20210521;
				`SET_DEV_NAME,`GET_DEV_NAME: 
					r_set_para0 <= r_device_name;
				`SET_SN,`GET_SN:
					r_set_para0 <= r_serial_number;
				`SET_IP,`GET_IP: begin
					r_set_para0 <= {24'h0, r_ip_addr[31:24]};
					r_set_para1 <= {24'h0, r_ip_addr[23:16]};
					r_set_para2 <= {24'h0, r_ip_addr[15:8]};
					r_set_para3 <= {24'h0, r_ip_addr[7:0]};
					end
				`SET_GATEWAY,`GET_GATEWAY: begin
					r_set_para0 <= {24'h0, r_gate_way[31:24]};
					r_set_para1 <= {24'h0, r_gate_way[23:16]};
					r_set_para2 <= {24'h0, r_gate_way[15:8]};
					r_set_para3 <= {24'h0, r_gate_way[7:0]};
				end
				`SET_SUBNET,`GET_SUBNET: begin
					r_set_para0 <= {24'h0, r_sub_mask[31:24]};
					r_set_para1 <= {24'h0, r_sub_mask[23:16]};
					r_set_para2 <= {24'h0, r_sub_mask[15:8]};
					r_set_para3 <= {24'h0, r_sub_mask[7:0]};
				end	
				`SET_MAC,`GET_MAC: begin
					r_set_para0 <= {24'h0, r_mac_addr[47:40]};
					r_set_para1 <= {24'h0, r_mac_addr[39:32]};
					r_set_para2 <= {24'h0, r_mac_addr[31:24]};
					r_set_para3 <= {24'h0, r_mac_addr[23:16]};
					r_set_para4 <= {24'h0, r_mac_addr[15:8]};
					r_set_para5 <= {24'h0, r_mac_addr[7:0]};
				end
				`SET_ANGLE,`GET_ANGLE:begin
					r_set_para0 <= r_start_angle;
					r_set_para0 <= r_stop_angle;
					end
				`SET_RESOLUTION,`GET_RESOLUTION:
					r_set_para0 <= {16'd0,	r_angle_reso};
				`SET_CALI_SWITCH,`SET_CALI_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[7]};
				`SET_LASING_SWITCH,`GET_LASING_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[6]};
				`SET_FILTER_SWITCH, `GET_FILTER_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[5]};
				`SET_COMP_SWITCH,`GET_COMP_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[4]};
				`SET_0_SWITCH,`GET_0_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[3]};
				`SET_HV_REF,`GET_HV_REF:
					r_set_para0 <= {16'h0,	r_apd_hv_base};
				`SET_HV_COE,`GET_HV_COE:
					r_set_para0 <= {31'h0,	r_apd_hv_coe};
				`SET_COMP_SWITCH,`GET_COMP_SWITCH:
					r_set_para0 <= {16'h0,	r_pulse_stand};
				`SET_UP_PARA,`GET_UP_PARA:
					r_set_para0 <= {16'h0,	r_device_mode[3]};
				`SET_TDC_WIN,`GET_TDC_WIN:begin
					r_set_para0 <= {24'h0,	r_tdc_window[15:8]};
					r_set_para1 <= {24'h0,	r_tdc_window[7:0]};
				end
				`SET_COE_PARA,`GET_COE_PARA:begin
					r_set_para0 <= {16'h0,	r_rise_start};
					r_set_para1 <= {16'h0,	r_rise_step};
					r_set_para2 <= {16'h0,	r_pulse_start};
					r_set_para3 <= {16'h0,	r_pulse_step};
				end
				`LOOP_DATA_SWITCH: 
					r_set_para0 <= {31'd0,	r_loop_telegram_flag};
				`LOOP_DATA,`ONCE_DATA:begin
					r_set_para0	<= {24'h0,	i_status_code};
					r_set_para1	<= i_scan_counter;
					r_set_para2	<= i_telegram_no;
					r_set_para3	<= {16'h0,	r_scan_freqence};
					r_set_para4	<= {16'h0,	r_angle_reso};
					r_set_para5	<= i_first_angle;
					r_set_para6	<= i_packet_points;
					r_set_para7	<= 32'h00010001;
					r_set_para8	<= i_time_stamp;
					end
				default:r_set_para0 <= 32'h00000000;
				endcase
			end

	//r_cmd_make
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_cmd_make	<= 1'b0;
		else if(r_set_cmd_code != `ONCE_DATA && r_set_cmd_code != `CALI_DATA)
			r_cmd_make	<= w_cmd_ack_rise;
		else 
			r_cmd_make	<= i_packet_make;
			
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	reg		[7:0]	r_config_mode = 8'd0;
	//0:标定模式标志 1 = 标定模式 0 = 普通模式	2:1:转速模式标志 1 = 25Hz 0 = 15hz 
	//4:3:分辨率模式标志 3 = 0.5 2 = 0.33 1 = 0.25 0 = 0.2 
	//5:出光模式标志位 1 = 出光模式 0 = 不出光模式
	//6:测距模式 1：测距模式 0：休眠模式
	//7:脉宽模式 1：脉宽模式 0：温补模式
	
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_config_mode <= 8'd0;
		else begin
			if(r_angle_reso == 16'd5000)
				r_config_mode[4:3] <= 2'b11;
			else if(r_angle_reso == 16'd3333)
				r_config_mode[4:3] <= 2'b10;
			else if(r_angle_reso == 16'd2500)
				r_config_mode[4:3] <= 2'b01;
			else 
				r_config_mode[4:3] <= 2'b00;
			if(r_scan_freqence == 16'd2500)
				r_config_mode[2:1] <= 2'b01;
			else 
				r_config_mode[2:1] <= 2'b00;
			r_config_mode[0] <= r_device_mode[7];
			r_config_mode[5] <= r_device_mode[6];
			r_config_mode[7] <= r_device_mode[5];
			r_config_mode[6] <= r_measure_switch;
			end
			
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
	assign		o_set_para0 = r_set_para0;
	assign		o_set_para1 = r_set_para1;
	assign		o_set_para2 = r_set_para2;
	assign		o_set_para3 = r_set_para3;
	assign		o_set_para4 = r_set_para4;
	assign		o_set_para5 = r_set_para5;
	assign		o_set_para6 = r_set_para6;
	assign		o_set_para7 = r_set_para7;
	assign		o_set_para8 = r_set_para8;

	assign		o_set_cmd_code = r_set_cmd_code;
	assign		o_cmd_make = r_cmd_make;
	assign		o_sram_csen_eth = r_sram_csen_eth;
	assign		o_sram_wren_eth = r_sram_wren_eth;
	assign		o_sram_rden_eth = r_sram_rden_eth;
	assign		o_sram_addr_eth = r_sram_addr_eth;
	assign		o_sram_data_eth = r_sram_data_eth;
	
	assign		o_eth_data_rq = r_eth_data_rq;
	
	assign		o_config_mode = r_config_mode;
	assign		o_pwm_value_0 = r_pwm_value_0;
	assign		o_tdc_window = r_tdc_window;
	assign		o_rise_start = r_rise_start;
	assign		o_rise_step	= r_rise_step;
	assign		o_pulse_start =	r_pulse_start;
	assign		o_pulse_step = r_pulse_step;
	assign		o_apd_hv_base = r_apd_hv_base;
	assign		o_apd_hv_coe = r_apd_hv_coe;
	assign		o_pulse_stand = r_pulse_stand;
	
	assign		o_telegram_flag = r_telegram_flag;
	assign		o_rst_n	 = r_rst_n;			
	assign		o_sram_store_flag = {r_parameter_sig,r_coe_write_flag,r_alarm_write_flag};

endmodule 

endmodule 