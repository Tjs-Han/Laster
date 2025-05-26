`timescale 1ns / 1ps

`include "datagram_cmd_defines.v"
`include "parameter_ident_define.v"

module parameter_init
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

	output	[7:0]	o_set_cmd_code		,
	input	[7:0]	i_get_cmd_code		,

	input			i_cmd_ack			,
	output			o_cmd_make			,
	
	input			i_packet_make		,
	input			i_calib_make		,
	input			i_connect_state		,
	
	input 	[1:0]   dist_report_error  ,
	input 	[1:0]	tdc_process_error  ,
	input   [31:0]	state_tsatic_value ,



	input			i_send_sig			,
	
	input	[15:0]	i_scan_counter		,
	input	[7:0]	i_telegram_no		,
	input	[15:0]	i_first_angle		,
	input	[15:0]	i_packet_points		,
	input	[15:0]	i_calib_points		,
	input	[15:0]	i_code_angle		,
	input	[15:0]	i_pulse_get			,
	input	[15:0]	i_pulse_rise		,
	input	[15:0]	i_pulse_fall		,
	input	[7:0]	i_status_code		,
	input	[15:0]	i_apd_hv_value		,
	input	[15:0]	i_apd_temp_value	,
	input	[7:0]	i_device_temp		,
	input	[9:0]	i_dac_value			,
	input	[15:0]	i_pwm_value			,
	
	input			i_code_right		,
	
	input			i_flash_busy		,
	
	output	[31:0]	o_ip_addr			,
	output	[31:0]	o_gate_way			,
	output	[31:0]	o_sub_mask			,
	output	[47:0]	o_mac_addr			,
	
	output	[7:0]	o_config_mode		,
	output	[1:0]	o_filter_mode		,
	output	[15:0]	o_pwm_value_0		,
	output	[15:0]	o_tdc_window		,
	output	[15:0]	o_rise_start		,
	output	[15:0]	o_pulse_start		,
	output	[15:0]	o_angle_offset		,
	output	[15:0]	o_zero_offset		,
	output	[15:0]	o_apd_hv_base		,
	output	[15:0]	o_pulse_stand		,
	output	[15:0]	o_temp_apdhv_base	,
	output	[15:0]	o_temp_temp_base	,
	output	[15:0]	o_temp_temp_coe		,
	
	output	[15:0]	o_distance_min		,
	output	[15:0]	o_distance_max		,
	output	[15:0]	o_start_index		,
	output	[15:0]	o_stop_index		,
	output	[15:0]	o_index_num			,
	
	input			i_read_complete_sig ,
	output			o_sram_csen_eth		,
	output			o_sram_wren_eth		,
	output			o_sram_rden_eth		,
	output	[17:0]	o_sram_addr_eth		,
	output	[15:0]	o_sram_data_eth		,
	input	[15:0]	i_sram_data_eth		,
	
	output	[9:0]	o_eth_rdaddr		,
	input	[7:0]	i_eth_data			,
	
	output	[1:0]	o_telegram_flag		,
	output	[7:0]	o_sram_store_flag	,	
	output			o_program_n			,
	output			o_rst_n				,
	output   reg    o_motor_rst_n       ,


	output   reg    save_user_sram_to_factory_flash_valid,
	output   reg    save_factory_sram_to_user_flash_valid,
	
	output [31:0]  o_temp_dist         ,
	output [7:0]   o_tdc_switch        ,
	output [15:0]  o_fixed_value        ,
	output 			o_dirt_mode			,
	output [7:0]   o_dirt_points		,
	
	output  [15:0]	 o_regaddr_opto	   ,//tjs
    input   [31:0]  i_data_opto_period 
);
    reg 	[15:0]	r_regaddr_opto;
	
	//reg             o_motor_rst_n;
	reg		[15:0]	r_para_state = 16'd0;
	reg				r_sram_csen_eth = 1'b0;
	reg				r_sram_wren_eth = 1'b1;
	reg				r_sram_rden_eth = 1'b1;
	reg		[17:0]	r_sram_addr_eth = 18'd0;
	reg		[15:0]	r_sram_data_eth = 16'd0;
	reg		[17:0]	r_sram_addr_base = 18'd0; 
	reg		[9:0]	r_write_cnt	= 10'd0;
	
	reg				r_para_write_flag = 1'b0;
	reg				r_fact_write_flag = 1'b0;
	reg				r_parameter_sig = 1'b0;
	reg				r_factory_sig = 1'b0;
	reg				r_load_factory_flag = 1'b0;
	reg				r_load_factory_sig = 1'b0;
	reg		[7:0]	r_sram_addr_para = 8'd0;
	reg				r_coe_set_flag = 1'b0;
	reg				r_coe_write_flag = 1'b0;
	reg				r_rssi_set_flag = 1'b0;
	reg				r_code_set_flag = 1'b0;
	reg				r_code_write_flag = 1'b0;
	reg		[2:0]	r_code_packet_num = 3'd0;
	
	reg				r_login_state_02 = 1'b0;
	reg				r_login_state_03 = 1'b0;
	reg				r_check_pass_state = 1'b0;
	reg		[9:0]	r_eth_rdaddr = 10'd0;
	
	wire			w_main_level,w_auth_level;
	
	reg				r_init_flag = 1'b0;
	reg		[15:0]	r_check_sum_set = 16'd0;
	reg		[15:0]	r_check_sum_get = 16'd0;
	reg				r_check_sum_flag = 1'b0;
	reg				r_parameter_read = 1'b0;
	reg		[31:0]	r_password_user = 32'hF4724744;//用户密码
	reg		[31:0]	r_device_name	= "C200";
	reg		[31:0]	r_ip_addr	= 32'hC0A8016F;
	reg		[31:0]	r_gate_way	= 32'hC0A80101;
	reg		[31:0]	r_sub_mask	= 32'hFFFFFF00;
	reg		[47:0]	r_mac_addr	= 48'h112233445566;
	reg		[31:0]	r_serial_number = 32'h21050001;
	reg		[15:0]	r_scan_freqence	= 16'd1500;
	reg		[15:0]	r_angle_reso	= 16'd3333;
	reg		[31:0]	r_start_angle	= 32'hFFF92230;
	reg		[31:0]	r_stop_angle	= 32'h00225510;
	reg		[7:0]	r_data_layout	= 8'd0;//0：时间戳开关，1：反射率开关，2：滤波开�
	
	reg		[7:0]	r_device_mode	= 8'b0110_0000;//8'd0;//7：标定模式，6：出光模式，5：平滑开关，4：脉宽模式，3�模式
	reg		[15:0]	r_pulse_stand	= 16'd0;
	reg		[15:0]	r_tdc_window	= 16'h3036;
	reg		[15:0]	r_apd_hv_base	= 16'h5B4;
	reg		[15:0]	r_pwm_value_0	= 16'd500;
	reg		[15:0]	r_rise_start	= 16'd0;
	reg		[15:0]	r_pulse_start	= 16'd0;
	reg		[15:0]	r_angle_offset	= 16'h0E00;//16'd0;
	reg		[15:0]	r_zero_offset	= 16'h15A0;//16'd0;
	reg		[15:0]	r_distance_min	= 16'd50;
	reg		[15:0]	r_distance_max	= 16'd25000;
	reg		[15:0]	r_temp_apdhv_base	= 16'h5B4;
	reg		[15:0]	r_temp_temp_base	= 16'd35;
	reg		[15:0]	r_temp_temp_coe		= 16'd15;
	
	reg		[31:0]	r_coe_timep		= 32'd0;
	reg		[31:0]	r_coe_version	= 32'd0;
	reg				r_coe_com_flag	= 1'b0;
	
	reg		[79:0]	r_time_stamp_set	= 80'h07D00101_000000_000000;
	reg				r_time_stamp_sig	= 1'b0;
	wire	[79:0]	w_time_stamp_get;
	
	reg		[1:0]	r_telegram_flag = 2'd0;
	reg		[1:0]	r_telegram_flag_pre = 2'd0;
	reg				r_loop_telegram_flag = 1'b0;
	reg				r_rst_n		  = 1'b0;
	reg             startup_flag  = 1'b0;
	reg				r_measure_switch = 1'b1;
	reg		[7:0]	r_status_code = 8'd0;
	
	reg		[7:0]	r_dirt_points = 8'd30;
	reg		[15:0]	r_dirt_rise	  = 16'd1000;	
	
	reg				r_program_sig = 1'b0;
	reg		[31:0]	r_program_cnt = 32'd0;
	reg				r_program_n	  = 1'b1;
	
	reg		[31:0]	r_set_para0 	= 32'd0;
	reg		[31:0]	r_set_para1		= 32'd0;
	reg		[31:0]	r_set_para2		= 32'd0;
	reg		[31:0]	r_set_para3		= 32'd0;
	reg		[31:0]	r_set_para4		= 32'd0;
	reg		[31:0]	r_set_para5		= 32'd0;
	reg		[31:0]	r_set_para6		= 32'd0;
	reg		[31:0]	r_set_para7		= 32'd0;
	reg		[31:0]	r_set_para8		= 32'd0;
	
	reg				r_code_conti_flag = 1'b1;//连续�
	reg				r_code_integ_flag = 1'b0;//完整�
	reg		[15:0]	r_code_seque_reg = 16'd0;
	reg				r_code_right	 = 1'd1;//正确�

	reg				r_packet_make	= 1'b0;
	reg		[7:0]	r_set_cmd_code	= 8'd0;

	reg				r_cmd_make		= 1'b0;
	reg				r_cmd_make2		= 1'b0;
	
	reg				r_cmd_ack		= 1'b0;
	reg				r_cmd_ack1		= 1'b0;
	wire			w_cmd_ack_rise	;
	
	
	reg    [31:0] r_temp_dist       = 32'h01230258;   //温补距离参数 
	
	reg    [7:0]  r_tdc_switch      = 8'd0;//8'd1;//TDC分割开�
	
	reg    [15:0] r_fixed_value;//定值补�
	
	reg		[7:0]	r_config_mode = 8'd0;
	//0:标定模式标志 1 = 标定模式 0 = 普通模�2:1:转速模式标�1 = 25Hz 0 = 15hz 
	//4:3:分辨率模式标�3 = 0.5 2 = 0.33 1 = 0.25 0 = 0.2 
	//5:出光模式标志�1 = 出光模式 0 = 不出光模�
	//6:测距模式 1：测距模�0：休眠模�
	//7:脉宽模式 1：脉宽模�0：温补模�
	

	reg                      load_para_end;
	reg                      f0_load_para_end;	
	reg                      temp_check_result;	
	reg                      temp_check_result_other;
	reg         [1:0]        check_result;
	reg                      load_para_first_flag;
	reg                      f0_load_para_first_flag;	
	reg                      load_para_lock_flag;
    reg                      load_factor_para_after_load_user_para_vld;		
	reg                      f0_load_factor_para_after_load_user_para_vld;
	reg                      f1_load_factor_para_after_load_user_para_vld;
	reg                      f2_load_factor_para_after_load_user_para_vld;
	reg                      f3_load_factor_para_after_load_user_para_vld;	

	//reg                 	 save_user_sram_to_factory_flash_valid;
	//reg                 	 save_factory_sram_to_user_flash_valid;

	reg			[15:0]		 f0_r_check_sum_get = 16'd0;
	reg			[15:0]		 check_sum_get_reg1 = 16'd0;
	reg			[15:0]		 check_sum_get_reg2 = 16'd0;

	parameter		PARA_IDLE		= 16'b0000_0000_0000_0000,
					PARA_WAIT		= 16'b0000_0000_0000_0010,
					PARA_READ		= 16'b0000_0000_0000_0100,
					PARA_ASSIGN		= 16'b0000_0000_0000_1000,
					PARA_WRITE		= 16'b0000_0000_0001_0000,
					PARA_SHIFT		= 16'b0000_0000_0010_0000,
					PARA_DELAY		= 16'b0000_0000_0100_0000,
					PARA_STORE		= 16'b0000_0000_1000_0000,
					PARA_READ2		= 16'b0000_0001_0000_0000,
					PARA_WAIT2		= 16'b0000_0010_0000_0000,
					PARA_ASSIGN1	= 16'b0000_0100_0000_0000,
					PARA_WAIT3		= 16'b0000_1000_0000_0000,
					PARA_ASSIGN2	= 16'b0001_0000_0000_0000,
					PARA_WRIT2		= 16'b0010_0000_0000_0000,
					PARA_SHIF2		= 16'b0100_0000_0000_0000,
					PARA_END		= 16'b1000_0000_0000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_para_state	<= PARA_IDLE;
		else begin
			case(r_para_state)
				PARA_IDLE	:begin
					r_para_state	<= PARA_WAIT;
					end
				PARA_WAIT	:begin
					if(i_read_complete_sig || r_load_factory_sig || f3_load_factor_para_after_load_user_para_vld)
						r_para_state	<= PARA_READ;
					else if(r_para_write_flag || r_fact_write_flag)
						r_para_state	<= PARA_ASSIGN;
					else if(r_coe_set_flag || r_code_set_flag || r_rssi_set_flag)
						r_para_state	<= PARA_READ2;
					end
				PARA_READ	:begin
					if(r_sram_addr_eth[7:0] >= `PARAMETER_NUM - 1'b1)
						r_para_state	<= PARA_END;
					end
				PARA_ASSIGN	:begin
					r_para_state	<= PARA_WRITE;
					end
				PARA_WRITE	:begin
					r_para_state	<= PARA_SHIFT;
					end
				PARA_SHIFT	:begin
					if(r_sram_addr_eth[7:0] >= `PARAMETER_NUM - 1'b1)
						r_para_state	<= PARA_STORE;
					else
						r_para_state	<= PARA_DELAY;
					end
				PARA_DELAY	:begin
					r_para_state	<= PARA_ASSIGN;
					end
				PARA_STORE	:begin
					r_para_state	<= PARA_END;
					end
				PARA_READ2	:begin
					r_para_state	<= PARA_WAIT2;
					end
				PARA_WAIT2	:begin
					r_para_state	<= PARA_ASSIGN1;
					end
				PARA_ASSIGN1:begin
					r_para_state	<= PARA_WAIT3;
					end
				PARA_WAIT3	:begin
					r_para_state	<= PARA_ASSIGN2;
					end
				PARA_ASSIGN2:begin
					r_para_state	<= PARA_WRIT2;
					end	
				PARA_WRIT2	:begin
					r_para_state	<= PARA_SHIF2;
					end
				PARA_SHIF2	:begin
					if(r_write_cnt >= 10'd511)
						r_para_state	<= PARA_END;
					else
						r_para_state	<= PARA_READ2;
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
			if(r_rssi_set_flag)
				r_sram_addr_base	<= 18'h04000 + (r_sram_addr_para << 4'd9);
			else if(r_coe_set_flag)
				r_sram_addr_base	<= 18'h10000 + (r_sram_addr_para << 4'd9);
			else if(r_code_set_flag)
				r_sram_addr_base	<= 18'h30000 + (r_sram_addr_para << 4'd9);
			end
		else if(r_para_state == PARA_END)
			r_sram_addr_base	<= 18'd0;

	//r_eth_rdaddr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_eth_rdaddr	<= 10'd0;
		else if(r_para_state == PARA_IDLE || r_para_state == PARA_END)
			r_eth_rdaddr	<= 10'd0;
		else if(r_para_state == PARA_SHIF2)
			r_eth_rdaddr	<= r_eth_rdaddr + 1'b1;
		else if(r_para_state == PARA_ASSIGN1)
			r_eth_rdaddr	<= r_eth_rdaddr + 1'b1;	
			
	//r_write_cnt
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_write_cnt		<= 10'd0;
		else if(r_para_state == PARA_IDLE)
			r_write_cnt		<= 10'd0;
		else if(r_para_state == PARA_SHIF2)
			r_write_cnt		<= r_write_cnt + 1'b1;
		else if(r_para_state == PARA_END)
			r_write_cnt		<= 10'd0;
			
	//r_sram_csen_eth
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_csen_eth	<= 1'b0;
		else if(r_para_state == PARA_IDLE)
			r_sram_csen_eth	<= 1'b0;
		else if(r_para_state == PARA_WAIT && (i_read_complete_sig || r_para_write_flag || r_load_factory_sig || r_fact_write_flag || f3_load_factor_para_after_load_user_para_vld))
			r_sram_csen_eth	<= 1'b1;
		else if(r_para_state == PARA_READ2)
			r_sram_csen_eth	<= 1'b1;
		else if(r_para_state == PARA_END)
			r_sram_csen_eth	<= 1'b0;
			
	//r_sram_wren_eth
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_wren_eth	<= 1'b1;
		else if(r_para_state == PARA_IDLE)
			r_sram_wren_eth	<= 1'b1;
		else if(r_para_state == PARA_WRIT2 || r_para_state == PARA_WRITE)
			r_sram_wren_eth	<= 1'b0;
		else
			r_sram_wren_eth	<= 1'b1;
			
	//r_sram_rden_eth
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_rden_eth	<= 1'b1;
		else if(r_para_state == PARA_IDLE)
			r_sram_rden_eth	<= 1'b1;
		else if(r_para_state == PARA_WAIT && (i_read_complete_sig || r_load_factory_sig || f3_load_factor_para_after_load_user_para_vld))
			r_sram_rden_eth	<= 1'b0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] >= `PARAMETER_NUM - 1'b1)
			r_sram_rden_eth	<= 1'b1;
			
	//r_sram_data_eth
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_data_eth	<= 16'd0;
		else if(r_para_state == PARA_END)
			r_sram_data_eth	<= 16'd0;
		else if(r_para_state == PARA_ASSIGN1)
			r_sram_data_eth[15:8] <= i_eth_data;
		else if(r_para_state == PARA_ASSIGN2)
			r_sram_data_eth[7:0] <= i_eth_data;
		else if(r_para_state == PARA_ASSIGN)begin
			case(r_sram_addr_eth[5:0])
				`INITIAL_FLAG		: r_sram_data_eth	<= 16'h5555;
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
				`TEMP_APDHV_BASE	: r_sram_data_eth	<= r_temp_apdhv_base;
				`TEMP_TEMP_BASE		: r_sram_data_eth	<= r_temp_temp_base;
				`TEMP_TEMP_COE		: r_sram_data_eth	<= r_temp_temp_coe;

				`DEVICE_STATUS		: r_sram_data_eth	<= {8'd0,r_device_mode};
				`PULSE_STANDARD		: r_sram_data_eth	<= r_pulse_stand;
				`TDC_WINDOW			: r_sram_data_eth	<= r_tdc_window;
				`APD_HV_BASE		: r_sram_data_eth	<= r_apd_hv_base;
				`MOTOR_PWM_INIT		: r_sram_data_eth	<= r_pwm_value_0;
				`RISE_START			: r_sram_data_eth	<= r_rise_start;
				`PULSE_START		: r_sram_data_eth	<= r_pulse_start;
				`ZERO_OFFSET		: r_sram_data_eth	<= r_zero_offset;
				`ANGLE_OFFSET		: r_sram_data_eth	<= r_angle_offset;
				`DIST_MIN			: r_sram_data_eth	<= r_distance_min;
				`DIST_MAX			: r_sram_data_eth	<= r_distance_max;
				`COE_TIMEP_H		: r_sram_data_eth	<= r_coe_timep[31:16];
				`COE_TIMEP_L		: r_sram_data_eth	<= r_coe_timep[15:0];
				`COE_VER_H			: r_sram_data_eth	<= r_coe_version[31:16];
				`COE_VER_L			: r_sram_data_eth	<= r_coe_version[15:0];
				`CHECK_SUM			: r_sram_data_eth	<= r_check_sum_set;
				`TEMP_DIST_H        : r_sram_data_eth	<= r_temp_dist[31:16];
				`TEMP_DIST_L        : r_sram_data_eth	<= r_temp_dist[15:0];
				`DIRT_POINTS		: r_sram_data_eth	<= {8'd0,r_dirt_points};
				`TDC_SWITCH         : r_sram_data_eth	<= {8'd0,r_tdc_switch};
				`FIXED_VALUE        : r_sram_data_eth	<= r_fixed_value;
				default				: r_sram_data_eth	<= 16'hFFFF;
				endcase
			end
						
	//r_sram_addr_eth
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_addr_eth	<= 18'd0;
		else if(r_para_state == PARA_IDLE)
			r_sram_addr_eth	<= 18'd0;
		else if(r_para_state == PARA_WAIT)begin
			if(i_read_complete_sig || r_para_write_flag)
				r_sram_addr_eth	<= 18'd0;
			else if(r_load_factory_sig || r_fact_write_flag || f3_load_factor_para_after_load_user_para_vld)
				r_sram_addr_eth	<= 18'h8000;
			end
		else if(r_para_state == PARA_READ)
			r_sram_addr_eth	<= r_sram_addr_eth + 1'b1;
		else if(r_para_state == PARA_DELAY)
			r_sram_addr_eth	<= r_sram_addr_eth + 1'b1;
		else if(r_para_state == PARA_ASSIGN2)
			r_sram_addr_eth	<= r_sram_addr_base + r_write_cnt;
		else if(r_para_state == PARA_END)
			r_sram_addr_eth	<= 18'd0;
			
	//r_check_sum_get
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_check_sum_get	<= 16'd0;
		else if(r_para_state == PARA_WAIT)
			r_check_sum_get	<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] < `PARAMETER_NUM - 1'b1)
			r_check_sum_get	<= r_check_sum_get + i_sram_data_eth;
			
	// //r_init_flag
	// always@(posedge i_clk_50m or negedge i_rst_n)
	// 	if(i_rst_n == 0)
	// 		r_init_flag	<= 1'b0;
	// 	else if(r_para_state == PARA_READ && (r_sram_addr_eth[7:0] == `INITIAL_FLAG) && load_para_lock_flag)begin
	// 		if(i_sram_data_eth != 16'h5555)
	// 			r_init_flag	<= 1'b1;
	// 		else
	// 			r_init_flag	<= 1'b0;
	// 		end
			
	// //r_check_sum_flag
	// always@(posedge i_clk_50m or negedge i_rst_n)
	// 	if(i_rst_n == 0)
	// 		r_check_sum_flag <= 1'b0;
	// 	else if(r_para_state == PARA_IDLE)
	// 		r_check_sum_flag <= 1'b0;
	// 	else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `PARAMETER_NUM - 1'b1)begin
	// 		if(r_check_sum_get == i_sram_data_eth)
	// 			r_check_sum_flag <= 1'b1;
	// 		else
	// 			r_check_sum_flag <= r_init_flag;
	// 		end

//add by luxuan 2024.0702 begin
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			load_para_end <= 1'b0;
		end
		else if(r_para_state == PARA_READ && (r_sram_addr_eth[7:0] == `PARAMETER_NUM - 1'b1))begin
			load_para_end <= 1'b1;
		end
		else begin
			load_para_end <= 1'b0;	
		end	
	end
	
	//load_para_first_flag align with load_para_end
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			load_para_first_flag <= 1'b1;
		end
		else if( load_para_first_flag && load_para_end)begin
			load_para_first_flag <= 1'b0;
		end		
		else if(~load_para_first_flag && (r_parameter_sig || save_user_sram_to_factory_flash_valid || save_factory_sram_to_user_flash_valid))begin
			load_para_first_flag <= 1'b1;
		end
	end

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			f0_load_para_first_flag <= 1'b0;
		end
		else begin
			f0_load_para_first_flag <= load_para_first_flag;
		end
	end		

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			temp_check_result_other <= 1'b0;
		end
		else begin
			temp_check_result_other <= (r_check_sum_get != 16'b0) || ((r_check_sum_get == 16'b0) && (r_serial_number != 32'd0)) ;
		end
	end	
    //temp_check_result align with load_para_end
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			temp_check_result <= 1'b0;
		end
		else begin
			temp_check_result <= (r_check_sum_get == i_sram_data_eth) && temp_check_result_other;
		end
	end	
    
	 //f0_r_check_sum_get align with load_para_end
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			f0_r_check_sum_get <= 16'b0;
		end
		else begin
			f0_r_check_sum_get <= r_check_sum_get;
		end
	end		

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			check_sum_get_reg1 <= 16'b0;
		end
		else if(load_para_end &&  load_para_first_flag)begin
			check_sum_get_reg1 <= f0_r_check_sum_get;
		end
	end	

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			check_sum_get_reg2 <= 16'b0;
		end
		else if(load_para_end && ~load_para_first_flag)begin
			check_sum_get_reg2 <= f0_r_check_sum_get;
		end
	end		

 	//check_result align with f0_load_para_end
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			check_result <= 2'b0;
		end
		else if(load_para_end &&  load_para_first_flag)begin
			check_result[0] <= temp_check_result;
		end
		else if(load_para_end && ~load_para_first_flag)begin
			check_result[1] <= temp_check_result;
		end		
	end	

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			load_para_lock_flag <= 1'b1;
		end
		else if(load_para_end &&  load_para_first_flag && temp_check_result)begin
			load_para_lock_flag <= 1'b0;
		end
		else if(~load_para_first_flag && (r_parameter_sig || save_user_sram_to_factory_flash_valid || save_factory_sram_to_user_flash_valid))begin
			load_para_lock_flag <= 1'b1;
		end		
	end	

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			load_factor_para_after_load_user_para_vld <= 1'b0;
		end
		else if(load_para_end && load_para_first_flag)begin
			load_factor_para_after_load_user_para_vld <= 1'b1;
		end
		else begin
			load_factor_para_after_load_user_para_vld <= 1'b0;	
		end	
	end

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			f0_load_para_end <= 1'b0;								
		end
		else begin
			f0_load_para_end <= load_para_end;
		end
	end	

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			f0_load_factor_para_after_load_user_para_vld <= 1'b0;
			f1_load_factor_para_after_load_user_para_vld <= 1'b0;
			f2_load_factor_para_after_load_user_para_vld <= 1'b0;
			f3_load_factor_para_after_load_user_para_vld <= 1'b0;									
		end
		else begin
			f0_load_factor_para_after_load_user_para_vld <= load_factor_para_after_load_user_para_vld;
			f1_load_factor_para_after_load_user_para_vld <= f0_load_factor_para_after_load_user_para_vld;
			f2_load_factor_para_after_load_user_para_vld <= f1_load_factor_para_after_load_user_para_vld;
			f3_load_factor_para_after_load_user_para_vld <= f2_load_factor_para_after_load_user_para_vld;	
		end
	end		

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			save_user_sram_to_factory_flash_valid <= 1'b0;							
		end
		else if(f0_load_para_end && ~f0_load_para_first_flag && (check_result ==2'b01))begin
			save_user_sram_to_factory_flash_valid <= 1'b1;				
		end
		else if(f0_load_para_end && ~f0_load_para_first_flag && (check_result ==2'b11) && (check_sum_get_reg1 != check_sum_get_reg2))begin
			save_user_sram_to_factory_flash_valid <= 1'b1;				
		end		
		else begin
			save_user_sram_to_factory_flash_valid <= 1'b0;				
		end		
	end		

	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			save_factory_sram_to_user_flash_valid <= 1'b0;							
		end
		else if(f0_load_para_end && ~f0_load_para_first_flag && (check_result ==2'b10))begin
			save_factory_sram_to_user_flash_valid <= 1'b1;				
		end
		else begin
			save_factory_sram_to_user_flash_valid <= 1'b0;				
		end		
	end	
	
//add by luxuan 2024.0702 end

	//r_check_sum_set
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_check_sum_set	<= 16'd0;
		else if(r_para_state == PARA_WAIT)
			r_check_sum_set	<= 16'd0;
		else if(r_para_state == PARA_WRITE && r_sram_addr_eth[7:0] < `PARAMETER_NUM - 1'b1)
			r_check_sum_set	<= r_check_sum_set + r_sram_data_eth;
			
	//r_parameter_read
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_parameter_read	<= 1'b0;
		else if(r_set_cmd_code == `LOAD_U_CFG && r_cmd_ack && w_auth_level)
			r_parameter_read	<= 1'b1;
		// else if(r_para_state == PARA_END && r_check_sum_flag == 1'b0)
		// 	r_parameter_read	<= 1'b1;
		else
			r_parameter_read	<= 1'b0;
			
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//标志位设�
	//r_parameter_sig 参数保存标志位对�
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_parameter_sig	<= 1'b0;
		else if(r_para_state == PARA_STORE)
			r_parameter_sig	<= r_para_write_flag;
		else
			r_parameter_sig	<= 1'b0;
			
	//r_para_write_flag = 1'b0; 参数保存标志位对�
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_para_write_flag	<= 1'b0;
		else if(r_set_cmd_code == `SAVE_U_PARA && r_cmd_ack && w_auth_level)
			r_para_write_flag	<= 1'b1;
		else if(r_para_state == PARA_END && r_load_factory_flag)
			r_para_write_flag	<= 1'b1;
		else if(r_para_state == PARA_END)
			r_para_write_flag	<= 1'b0;
			
	//r_factory_sig
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_factory_sig	<= 1'b0;
		else if(r_para_state == PARA_STORE)
			r_factory_sig	<= r_fact_write_flag;
		else
			r_factory_sig	<= 1'b0;
			
	//r_fact_write_flag = 1'b0
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_fact_write_flag	<= 1'b0;
		else if(r_set_cmd_code == `SAVE_F_PARA && r_cmd_ack && w_main_level)
			r_fact_write_flag	<= 1'b1;
		else if(r_para_state == PARA_END)
			r_fact_write_flag	<= 1'b0;
			
	//r_load_factory_sig
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_load_factory_sig	<= 1'b0;
		else if(r_set_cmd_code == `LOAD_F_CFG && r_cmd_ack && w_auth_level)
			r_load_factory_sig	<= 1'b1;
		else
			r_load_factory_sig	<= 1'b0;
			
	//r_load_factory_flag
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_load_factory_flag	<= 1'b0;
		else if(r_para_state == PARA_IDLE)
			r_load_factory_flag	<= 1'b0;
		else if(r_set_cmd_code == `LOAD_F_CFG && r_cmd_ack && w_auth_level)
			r_load_factory_flag	<= 1'b1;
		else if(r_para_state == PARA_END)
			r_load_factory_flag	<= 1'b0;
			
	//r_rssi_set_flag 
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_rssi_set_flag		<= 1'b0;
		else if(r_set_cmd_code == `SET_RSSI_COE && r_cmd_ack && w_main_level)
			r_rssi_set_flag		<= 1'b1;
		else
			r_rssi_set_flag		<= 1'b0;
			
	//r_coe_set_flag 系数设置标志�
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_coe_set_flag		<= 1'b0;
		else if(r_set_cmd_code == `SET_COE && r_cmd_ack && w_main_level)
			r_coe_set_flag		<= 1'b1;
		else
			r_coe_set_flag		<= 1'b0;
			
	//r_coe_write_flag 系数保存标志�
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_coe_write_flag	<= 1'b0;
		else if(r_set_cmd_code == `SAVE_COE && r_cmd_ack && w_main_level)
			r_coe_write_flag	<= r_coe_com_flag;
		else
			r_coe_write_flag	<= 1'b0;
			
	//r_code_seque_reg
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_code_seque_reg <= 16'd0;
		else if(r_set_cmd_code == `SET_CODE && r_cmd_ack && w_auth_level)
			r_code_seque_reg <= i_get_para0[15:0];
			
	//r_code_conti_flag = 1'b1;//连续�
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_code_conti_flag <= 1'b1;
		else if(r_set_cmd_code == `SET_CODE && r_cmd_ack && w_auth_level)begin
			if(r_code_seque_reg == i_get_para0[15:0])
				r_code_conti_flag <= r_code_conti_flag;
			else if(r_code_seque_reg + 1'b1 == i_get_para0[15:0])
				r_code_conti_flag <= r_code_conti_flag;
			else if(i_get_para0[15:0] == 16'd0)
				r_code_conti_flag <= 1'b1;
			else
				r_code_conti_flag <= 1'b0;
			end
			
	//r_code_integ_flag = 1'b0;//完整�
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_code_integ_flag <= 1'b0;
		else if(r_set_cmd_code == `SET_CODE && r_cmd_ack && w_auth_level)begin
			if(i_get_para0[6:0] == 7'd127)
				r_code_integ_flag <= 1'b1;
			else
				r_code_integ_flag <= 1'b0;
			end
			
/*	//r_code_right = 1'd1;//文件正确�
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_code_right <= 1'd1;
		else if(r_code_seque_reg == 16'd0 && r_set_cmd_code == `SET_CODE)begin
			if(r_eth_rdaddr == 16'h150 && i_eth_data != 8'hFF)
				r_code_right <= 1'd0;
			else if(r_eth_rdaddr == 16'h151 && i_eth_data != 8'hFF)
				r_code_right <= 1'd0;
			else if(r_eth_rdaddr == 16'h152 && i_eth_data != 8'hBD)
				r_code_right <= 1'd0;			
			else if(r_eth_rdaddr == 16'h153 && i_eth_data != 8'hB3)
				r_code_right <= 1'd0;
		end
		else
			r_code_right <= 1'd1;*/
			
	//r_code_packet_num
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_code_packet_num <= 3'd0;
		else if(r_set_cmd_code == `SAVE_CODE && r_cmd_ack && w_auth_level)
			r_code_packet_num <= i_get_para0[2:0];
			
	//r_code_set_flag 代码设置标志�
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_code_set_flag		<= 1'b0;
		else if(r_set_cmd_code == `SET_CODE && r_cmd_ack && w_auth_level)
			r_code_set_flag		<= 1'b1;
		else
			r_code_set_flag		<= 1'b0;

	//r_code_write_flag 代码保存标志�
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_code_write_flag	<= 1'b0;
		else if(r_set_cmd_code == `SAVE_CODE && r_cmd_ack && w_auth_level)
			r_code_write_flag	<= r_code_conti_flag & r_code_integ_flag;
		else
			r_code_write_flag	<= 1'b0;
			
	//r_sram_addr_para SRAM地址参数设置
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_sram_addr_para	<= 8'd0;
		else if(r_set_cmd_code == `SET_COE && r_cmd_ack && w_main_level)
			r_sram_addr_para	<= i_get_para0[7:0];
		else if(r_set_cmd_code == `SET_RSSI_COE && r_cmd_ack && w_main_level)
			r_sram_addr_para	<= i_get_para0[7:0];
		else if(r_set_cmd_code == `SET_CODE && r_cmd_ack && w_auth_level)
			r_sram_addr_para	<= i_get_para0[6:0];
			
	//r_telegram_flag_pre 单次标定取数标志�
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_telegram_flag_pre	<= 2'd0;
		else if(r_set_cmd_code == `CALI_DATA && r_cmd_ack)
			r_telegram_flag_pre	<= 2'b10;
		else if(r_set_cmd_code == `ONCE_DATA && r_cmd_ack)
			r_telegram_flag_pre	<= 2'b01;
		else if(i_packet_make || i_calib_make || ~i_connect_state)
			r_telegram_flag_pre	<= 2'd0;
			
	//r_loop_telegram_flag 连续取数标志�
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_loop_telegram_flag <= 1'b0;
		else if(r_set_cmd_code == `LOOP_DATA_SWITCH && r_cmd_ack)
			r_loop_telegram_flag <= i_get_para0[0];
		else if(~i_connect_state)
			r_loop_telegram_flag <= 1'b0;
			
	//r_telegram_flag
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_telegram_flag	<= 2'd0;
		else if(i_cmd_ack || ~i_connect_state)
			r_telegram_flag	<= 2'd0;
		else if(i_code_angle == 16'd0)begin
			if(r_loop_telegram_flag)
				r_telegram_flag	<= 2'b01;
			else
				r_telegram_flag	<= r_telegram_flag_pre;
			end


	//startup_flag
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			startup_flag		<= 1'b1;
		else if(f0_load_para_end && ~f0_load_para_first_flag)
			startup_flag		<= 1'b0;

	//r_rst_n
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rst_n		<= 1'b0;
		else if(f0_load_para_end && ~f0_load_para_first_flag && (check_result ==2'b11))
			r_rst_n		<= 1'b1;
		else if(f0_load_para_end && ~f0_load_para_first_flag && (check_result ==2'b00))
			r_rst_n		<= 1'b0;	

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			o_motor_rst_n		<= 1'b0;
		else if(startup_flag && f0_load_para_end && ~f0_load_para_first_flag && (check_result !=2'b00))
			o_motor_rst_n		<= 1'b1;
		else if(startup_flag && f0_load_para_end && ~f0_load_para_first_flag && (check_result ==2'b00))
			o_motor_rst_n		<= 1'b0;						
			
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
		else if(r_set_cmd_code == `LOGOUT && r_cmd_ack)begin
			r_login_state_02	<= 1'b0;
			r_login_state_03	<= 1'b0;
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
			
	//r_measure_switch
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_measure_switch	<= 1'b1;
		else if(r_set_cmd_code == `MEAS_SWITCH && r_cmd_ack && w_auth_level)
			r_measure_switch 	<= i_get_para0[0];
			
	//r_tdc_switch
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_switch	<= 8'b1;
        else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `TDC_SWITCH && i_sram_data_eth != 16'hFFFF)
		    r_tdc_switch    <= i_sram_data_eth[7:0];
	    else if(r_set_cmd_code == `SET_TDC_SWITCH && r_cmd_ack && w_auth_level)
		    r_tdc_switch	<= i_get_para0[7:0];
			
	//r_program_sig
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_program_sig <= 1'b0;
		else if(r_set_cmd_code == `RESET_DEV && r_cmd_ack && w_auth_level)
			r_program_sig <= 1'b1;
			
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
	//r_password_user
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_password_user			<= 32'hF4724744;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `PASSWORD_USER_H && i_sram_data_eth != 16'hFFFF)
			r_password_user[31:16]	<= i_sram_data_eth;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `PASSWORD_USER_L && i_sram_data_eth != 16'hFFFF)
			r_password_user[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_PASSWORD && r_cmd_ack && w_auth_level)begin
			if(i_get_para0[7:0] == 8'h03)
				r_password_user			<= i_get_para1;
			end
			
	//r_device_name
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_device_name			<= "C200";
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DEVIDE_NAME_H && i_sram_data_eth != 16'hFFFF)
			r_device_name[31:16]	<= i_sram_data_eth;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DEVIDE_NAME_L && i_sram_data_eth != 16'hFFFF)
			r_device_name[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_DEV_NAME && r_cmd_ack && w_auth_level)
			r_device_name			<= i_get_para0;

	//r_ip_addr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_ip_addr			<= 32'hC0A8016F;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_IP_ADDR_H && i_sram_data_eth != 16'hFFFF && i_sram_data_eth != 16'd0)
			r_ip_addr[31:16]	<= i_sram_data_eth;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_IP_ADDR_L && i_sram_data_eth != 16'hFFFF && i_sram_data_eth != 16'd0)
			r_ip_addr[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_IP && r_cmd_ack && w_auth_level)
			r_ip_addr 			<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0]};
		else if(r_set_cmd_code == `SET_GATEWAY && r_cmd_ack && w_auth_level)
			r_ip_addr[31:8] 	<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0]};
			
	//r_gate_way
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_gate_way			<= 32'hC0A80101;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_GATE_WAY_H && i_sram_data_eth != 16'hFFFF && i_sram_data_eth != 16'd0)
			r_gate_way[31:16]	<= i_sram_data_eth;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_GATE_WAY_L && i_sram_data_eth != 16'hFFFF && i_sram_data_eth != 16'd0)
			r_gate_way[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_GATEWAY && r_cmd_ack && w_auth_level)
			r_gate_way 			<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0]};
		else if(r_set_cmd_code == `SET_IP && r_cmd_ack && w_auth_level)
			r_gate_way[31:8] 	<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0]};
	
	//r_sub_mask
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sub_mask			<= 32'hFFFFFF00;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_SUB_MASK_H && i_sram_data_eth != 16'hFFFF && i_sram_data_eth != 16'd0)
			r_sub_mask[31:16]	<= i_sram_data_eth;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_SUB_MASK_L && i_sram_data_eth != 16'hFFFF && i_sram_data_eth != 16'd0)
			r_sub_mask[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_SUBNET && r_cmd_ack && w_auth_level)
			r_sub_mask 			<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0]};

	//r_mac_addr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_mac_addr			<= 48'h112233445566;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_MAC_ADDR_H && i_sram_data_eth != 16'hFFFF && i_sram_data_eth != 16'd0)
			r_mac_addr[47:32]	<= i_sram_data_eth;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_MAC_ADDR_M && i_sram_data_eth != 16'hFFFF && i_sram_data_eth != 16'd0)
			r_mac_addr[31:16]	<= i_sram_data_eth;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_MAC_ADDR_L && i_sram_data_eth != 16'hFFFF && i_sram_data_eth != 16'd0)
			r_mac_addr[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_MAC && r_cmd_ack && w_auth_level)
			r_mac_addr 			<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0], i_get_para4[7:0], i_get_para5[7:0]};

   //r_temp_dist
	always@(posedge i_clk_50m or negedge i_rst_n)
	  if(i_rst_n == 0)
        r_temp_dist <= 32'd01230258;
      else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `TEMP_DIST_H && i_sram_data_eth != 16'hFFFF)
		r_temp_dist[31:16]	<= i_sram_data_eth;
	  else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `TEMP_DIST_L && i_sram_data_eth != 16'hFFFF)
		r_temp_dist[15:0]	<= i_sram_data_eth;
	  else if(r_set_cmd_code == `SET_TEMP_DIST && r_cmd_ack && w_auth_level)
		r_temp_dist			<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0]};		




	//r_serial_number
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_serial_number			<= 32'h21050001;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `SERIAL_NUMBER_H && i_sram_data_eth != 16'hFFFF)
			r_serial_number[31:16]	<= i_sram_data_eth;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `SERIAL_NUMBER_L && i_sram_data_eth != 16'hFFFF)
			r_serial_number[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_SN && r_cmd_ack && w_main_level)
			r_serial_number			<= i_get_para0;

	//r_scan_freqence
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_scan_freqence			<= 16'd1500;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `SCAN_FREQUENCY && i_sram_data_eth != 16'hFFFF)
			r_scan_freqence			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_RESOLUTION && r_cmd_ack && w_auth_level)
			r_scan_freqence			<= i_get_para0[15:0];
			
	//r_angle_reso
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_reso			<= 16'd3333;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ANGLE_RESOLUTION && i_sram_data_eth != 16'hFFFF)
			r_angle_reso			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_RESOLUTION && r_cmd_ack && w_auth_level)
			r_angle_reso			<= i_get_para1[15:0];
			
	//r_start_angle
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_start_angle			<= 32'hFFF92230;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `START_ANGLE_H)
			r_start_angle[31:16]	<= i_sram_data_eth;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `START_ANGLE_L)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_start_angle[15:0]	<= i_sram_data_eth;
			else
				r_start_angle			<= 32'hFFF92230;
			end
		else if(r_set_cmd_code == `SET_ANGLE && r_cmd_ack && w_auth_level)begin
			if(i_get_para1 <= 32'h225510 || i_get_para1 >= 32'hFFF92230)
				r_start_angle			<= i_get_para1;
			end
			
	//r_stop_angle
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_stop_angle			<= 32'h00225510;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `STOP_ANGLE_H)
			r_stop_angle[31:16]	<= i_sram_data_eth;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `STOP_ANGLE_L)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_stop_angle[15:0]	<= i_sram_data_eth;
			else
				r_stop_angle		<= 32'h00225510;
			end
		else if(r_set_cmd_code == `SET_ANGLE && r_cmd_ack && w_auth_level)begin
			if(i_get_para2 <= 32'h225510 || i_get_para2 >= 32'hFFF92230)
				r_stop_angle			<= i_get_para2;
			end
			
	//r_data_layout
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_data_layout			<= 8'd0;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DATA_LAYOUT_FLAG && i_sram_data_eth != 16'hFFFF)
			r_data_layout			<= i_sram_data_eth[7:0];

	//r_device_mode
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_device_mode			<= 8'b0110_0000;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DEVICE_STATUS && i_sram_data_eth != 16'hFFFF)
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
		else if(r_set_cmd_code == `SET_TRAIL_SWITCH && r_cmd_ack && w_auth_level)
			r_device_mode[2]		<= i_get_para0[0];
		else if(r_set_cmd_code == `SET_DIRT_SWITCH && r_cmd_ack && w_auth_level)
			r_device_mode[1]		<= i_get_para0[0];			
			
	//r_dirt_points
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dirt_points			<= 8'd30;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DIRT_POINTS && i_sram_data_eth != 16'hFFFF)
			r_dirt_points			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_DIRT_SWITCH && r_cmd_ack && w_main_level)
			r_dirt_points			<= i_get_para1[7:0];

/*	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dirt_rise			<= 16'd1000;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DIRT_RISE && i_sram_data_eth != 16'hFFFF)
			r_dirt_rise			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_DIRT_SWITCH && r_cmd_ack && w_main_level)
			r_dirt_rise			<= i_get_para2[15:0];	*/
			
	//r_pulse_stand
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_stand			<= 16'd0;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `PULSE_STANDARD && i_sram_data_eth != 16'hFFFF)
			r_pulse_stand			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_UP_PARA && r_cmd_ack && w_main_level)
			r_pulse_stand			<= i_get_para0[15:0];
			
	//r_tdc_window
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_window			<= 16'h3036;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `TDC_WINDOW && i_sram_data_eth != 16'hFFFF)
			r_tdc_window			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_TDC_WIN && r_cmd_ack && w_main_level)
			r_tdc_window			<= {i_get_para0[7:0],i_get_para1[7:0]};
			
	//r_status_code
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_status_code	<= 8'd0;
		else
			r_status_code	<= i_status_code;
			
	   //r_fixed_value
   always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_fixed_value		<= 16'h0;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `FIXED_VALUE && i_sram_data_eth != 16'hFFFF)
			r_fixed_value		<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_FIXED_VALUE && r_cmd_ack && w_main_level)
			r_fixed_value		<= i_get_para0[15:0];

	//r_apd_hv_base
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_apd_hv_base			<= 16'h5B4;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `APD_HV_BASE && i_sram_data_eth != 16'hFFFF)
			r_apd_hv_base			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_HV_REF && r_cmd_ack && w_main_level)
			r_apd_hv_base			<= i_get_para0[15:0];
		else if(r_status_code != i_status_code && i_status_code == 8'd1 && r_config_mode[7])
			r_apd_hv_base			<= {4'd0,i_dac_value,2'd0};
			
	//r_temp_apdhv_base
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_temp_apdhv_base		<= 16'h5B4;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `TEMP_APDHV_BASE && i_sram_data_eth != 16'hFFFF)
			r_temp_apdhv_base		<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_TEMP_COE && r_cmd_ack && w_main_level)
			r_temp_apdhv_base		<= i_get_para0[15:0];
			

			
	//r_temp_temp_base
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_temp_temp_base		<= 16'd35;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `TEMP_TEMP_BASE && i_sram_data_eth != 16'hFFFF)
			r_temp_temp_base		<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_TEMP_COE && r_cmd_ack && w_main_level)
			r_temp_temp_base		<= i_get_para1[15:0];
			
	//r_temp_temp_coe
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_temp_temp_coe			<= 16'd15;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `TEMP_TEMP_COE && i_sram_data_eth != 16'hFFFF)
			r_temp_temp_coe			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_TEMP_COE && r_cmd_ack && w_main_level)
			r_temp_temp_coe			<= i_get_para2[15:0];
			
	//r_pwm_value_0
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pwm_value_0			<= 16'd700;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `MOTOR_PWM_INIT && i_sram_data_eth != 16'hFFFF)
			r_pwm_value_0			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_MOTOR_PWM && r_cmd_ack && w_main_level)
			r_pwm_value_0			<= i_get_para0[15:0];
		else if(r_status_code != i_status_code && i_status_code == 8'd1 && ~r_device_mode[7])
			r_pwm_value_0			<= i_pwm_value;
	//r_opto_regaddr  tjs  r_regaddr_opto
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_regaddr_opto		<= 16'h003f;
		else if(r_set_cmd_code == `SET_OPTO_PERIOD && r_cmd_ack && w_main_level)
			r_regaddr_opto		<= i_get_para0[15:0];			
	
	//r_rise_start
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rise_start			<= 16'd0;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `RISE_START && i_sram_data_eth != 16'hFFFF)
			r_rise_start			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_main_level)
			r_rise_start			<= i_get_para0[15:0];
			
	//r_pulse_start
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_start			<= 16'd0;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `PULSE_START && i_sram_data_eth != 16'hFFFF)
			r_pulse_start			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_main_level)
			r_pulse_start			<= i_get_para1[15:0];
			
	//r_coe_timep		= 32'd0;
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_coe_timep			<= 32'd0;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `COE_TIMEP_H && i_sram_data_eth != 16'hFFFF)
			r_coe_timep[31:16]	<= i_sram_data_eth;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `COE_TIMEP_L && i_sram_data_eth != 16'hFFFF)
			r_coe_timep[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_main_level)
			r_coe_timep			<= i_get_para2;
			
	//r_coe_version		= 32'd0;
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_coe_version			<= 32'd0;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `COE_VER_H && i_sram_data_eth != 16'hFFFF)
			r_coe_version[31:16]	<= i_sram_data_eth;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `COE_VER_L && i_sram_data_eth != 16'hFFFF)
			r_coe_version[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_main_level)
			r_coe_version			<= i_get_para3;
	
	//r_coe_com_flag	= 1'b0;
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_coe_com_flag			<= 1'b0;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_main_level)begin
			if(i_get_para4 == r_serial_number)
				r_coe_com_flag			<= 1'b1;
			else
				r_coe_com_flag			<= 1'b0;
			end
			
	//r_zero_offset
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_zero_offset			<= 16'h15A0;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ZERO_OFFSET && i_sram_data_eth != 16'hFFFF)
			r_zero_offset			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_ZERO_OFFSET && r_cmd_ack && w_main_level)
			r_zero_offset			<= {i_get_para0[7:0],i_get_para1[7:0]};	
			
	//r_angle_offset
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_offset			<= 16'h0E00;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ANGLE_OFFSET && i_sram_data_eth != 16'hFFFF)
			r_angle_offset			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_ANGLE_OFFSET && r_cmd_ack && w_main_level)
			r_angle_offset			<= {i_get_para0[7:0],i_get_para1[7:0]};		
			
	//r_distance_min
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_distance_min			<= 16'd50;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DIST_MIN && i_sram_data_eth != 16'hFFFF)
			r_distance_min			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_DIST_LMT && r_cmd_ack && w_main_level)
			r_distance_min			<= i_get_para0[15:0];
	
	//r_distance_max
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_distance_max			<= 16'd25000;
		else if(load_para_lock_flag && r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DIST_MAX && i_sram_data_eth != 16'hFFFF)
			r_distance_max			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_DIST_LMT && r_cmd_ack && w_main_level)
			r_distance_max			<= i_get_para1[15:0];
			
	//r_time_stamp_set
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_time_stamp_set	<= 80'h07D00101_000000_000000;
		else if(r_set_cmd_code == `SET_TIMESTAMP && r_cmd_ack && w_auth_level)begin
			r_time_stamp_set[79:64]	<= i_get_para0[15:0];
			r_time_stamp_set[63:56]	<= i_get_para1[7:0];
			r_time_stamp_set[55:48]	<= i_get_para2[7:0];
			r_time_stamp_set[47:40]	<= i_get_para3[7:0];
			r_time_stamp_set[39:32]	<= i_get_para4[7:0];
			r_time_stamp_set[31:24]	<= i_get_para5[7:0];
			r_time_stamp_set[23:0]		<= i_get_para6[23:0];
			end
			
	//r_time_stamp_sig
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_time_stamp_sig	<= 1'b0;
		else if(r_set_cmd_code == `SET_TIMESTAMP && r_cmd_ack && w_auth_level)
			r_time_stamp_sig	<= 1'b1;
		else
			r_time_stamp_sig	<= 1'b0;
			
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
	//r_set_cmd_code
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_set_cmd_code	<= 8'd0;
		else if(i_cmd_ack)
			r_set_cmd_code	<= i_get_cmd_code;
		else if((i_packet_make || i_calib_make) && r_telegram_flag != 2'd0)begin
			if(r_telegram_flag[1])
				r_set_cmd_code	<= `CALI_DATA;
			else begin
				if(r_loop_telegram_flag)
					r_set_cmd_code	<= `LOOP_DATA;
				else
					r_set_cmd_code	<= `ONCE_DATA;
				end
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
		else if(r_cmd_make)begin
			case(r_set_cmd_code)
				`LOGIN,`RESET_DEV:
					r_set_para0 <= {31'd0,	r_login_state_02|r_login_state_03};
				`LOGOUT:
					r_set_para0 <= {31'd0,	~(r_login_state_02|r_login_state_03)};
				`SET_PASSWORD:
					r_set_para0 <= {31'h0,	w_auth_level};
				`CHECK_PASSWORD:
					r_set_para0 <= {31'd0,	r_check_pass_state};
				`MEAS_SWITCH:
					r_set_para0 <= {31'd0,	r_measure_switch};
				`GET_DEV_STA:
					r_set_para0 <= {24'd0,	i_status_code};
				`GET_DEV_ID:
					r_set_para0 <= "C2XX";
				`GET_FW_VER:
					r_set_para0 <= `FIRMWARE_VERSION;
				`SET_DEV_NAME,`GET_DEV_NAME: 
					r_set_para0 <= r_device_name;
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
				`SET_SN,`GET_SN:
					r_set_para0 <= r_serial_number;
				`SET_RESOLUTION,`GET_RESOLUTION:begin
					r_set_para0 <= {16'd0,	r_scan_freqence};
					r_set_para1 <= {16'd0,	r_angle_reso};
					end
				`SET_ANGLE,`GET_ANGLE:begin
					r_set_para0 <= i_get_para0;
					r_set_para1 <= r_start_angle;
					r_set_para2 <= r_stop_angle;
					end
				`GET_TEMP:
					r_set_para0 <= {24'h0,	i_device_temp};
				`GET_ADC:begin
					r_set_para0 <= {16'h0,	i_apd_hv_value};
					r_set_para1 <= {16'h0,	i_apd_temp_value};
					r_set_para2 <= {22'h0,	i_dac_value};
				end	
				`SET_CALI_SWITCH,`GET_CALI_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[7]};
				`SET_LASING_SWITCH,`GET_LASING_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[6]};
				`SET_FILTER_SWITCH, `GET_FILTER_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[5]};
				`SET_COMP_SWITCH,`GET_COMP_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[4]};
				`SET_0_SWITCH,`GET_0_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[3]};
				`SET_TRAIL_SWITCH,`GET_TRAIL_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[2]};
				`SET_DIRT_SWITCH:begin
					r_set_para0 <= {31'd0,	r_device_mode[1]};	
					r_set_para1 <= {24'h0,	r_dirt_points};						
					end	
				`GET_DIRT_SWITCH:begin
					r_set_para0 <= {31'd0,	r_device_mode[1]};	
					r_set_para1 <= {24'h0,	r_dirt_points};	
					r_set_para2 <= {16'h0,	r_dirt_rise};						
					end
				`SET_UP_PARA:
					r_set_para0 <= {16'h0,	r_pulse_stand};
				`GET_UP_PARA:begin
					r_set_para0 <= {16'h0,	r_pulse_stand};
					r_set_para1 <= {16'h0,	i_pulse_get};
					r_set_para2 <= {16'h0,	i_pulse_rise};
					r_set_para3 <= {16'h0,	i_pulse_fall};
					end
				`SET_TDC_WIN,`GET_TDC_WIN:begin
					r_set_para0 <= {24'h0,	r_tdc_window[15:8]};
					r_set_para1 <= {24'h0,	r_tdc_window[7:0]};
				end
				`SET_ANGLE_OFFSET,`GET_ANGLE_OFFSET:begin
					r_set_para0 <= {24'h0,	r_angle_offset[15:8]};
					r_set_para1 <= {24'h0,	r_angle_offset[7:0]};
				end
				`SET_ZERO_OFFSET,`GET_ZERO_OFFSET:begin
					r_set_para0 <= {24'h0,	r_zero_offset[15:8]};
					r_set_para1 <= {24'h0,	r_zero_offset[7:0]};
				end
				`SET_HV_REF,`GET_HV_REF:
					r_set_para0 <= {16'h0,	r_apd_hv_base};
				`SET_MOTOR_PWM:
					r_set_para0 <= {16'h0,	r_pwm_value_0};
				`GET_MOTOR_PWM:
					r_set_para0 <= {16'h0,	i_pwm_value};
				`SET_TEMP_COE,`GET_TEMP_COE:begin
					r_set_para0 <= {16'h0,	r_temp_apdhv_base};
					r_set_para1 <= {16'h0,	r_temp_temp_base};
					r_set_para2 <= {16'h0,	r_temp_temp_coe};
					end
				`SET_DIST_LMT,`GET_DIST_LMT:begin
					r_set_para0 <= {16'h0,	r_distance_min};
					r_set_para1 <= {16'h0,	r_distance_max};
				end
				/*tjs*/
				`GET_OPTO_PERIOD,`SET_OPTO_PERIOD: begin
					r_set_para0 <= {16'h0,	r_regaddr_opto};
					r_set_para1 <= {16'h0,	i_data_opto_period[31:16]};
					r_set_para2 <= {16'h0,	i_data_opto_period[15:0]}; 	
				end
				`SET_TIMESTAMP:begin
					r_set_para0 <= {16'h0,	r_time_stamp_set[79:64]};
					r_set_para1 <= {24'h0,	r_time_stamp_set[63:56]};
					r_set_para2 <= {24'h0,	r_time_stamp_set[55:48]};
					r_set_para3 <= {24'h0,	r_time_stamp_set[47:40]};
					r_set_para4 <= {24'h0,	r_time_stamp_set[39:32]};
					r_set_para5 <= {24'h0,	r_time_stamp_set[31:24]};
					r_set_para6 <= {8'h0,	r_time_stamp_set[23:0]};
				end
				`GET_TIMESTAMP:begin
					r_set_para0 <= {16'h0,	w_time_stamp_get[79:64]};
					r_set_para1 <= {24'h0,	w_time_stamp_get[63:56]};
					r_set_para2 <= {24'h0,	w_time_stamp_get[55:48]};
					r_set_para3 <= {24'h0,	w_time_stamp_get[47:40]};
					r_set_para4 <= {24'h0,	w_time_stamp_get[39:32]};
					r_set_para5 <= {24'h0,	w_time_stamp_get[31:24]};
					r_set_para6 <= {8'h0,	w_time_stamp_get[23:0]};
				end
				`SET_COE_PARA:begin
					r_set_para0 <= {16'h0,	r_rise_start};
					r_set_para1 <= {16'h0,	r_pulse_start};
					r_set_para2 <= r_coe_timep;
					r_set_para3 <= r_coe_version;
					r_set_para4 <= i_get_para4;
					r_set_para5 <= {31'd0,	r_coe_com_flag};
				end
				`GET_COE_PARA:begin
					r_set_para0 <= {16'h0,	r_rise_start};
					r_set_para1 <= {16'h0,	r_pulse_start};
					r_set_para2 <= r_coe_timep;
					r_set_para3 <= r_coe_version;
				end

				`GET_DEBUG_INFO:begin
					r_set_para0 <= state_tsatic_value[31:0];
					r_set_para1 <= {28'h0,tdc_process_error[1:0],dist_report_error[1:0]};
				end

				`LOOP_DATA_SWITCH: 
					r_set_para0 <= {31'd0,	r_loop_telegram_flag};
				`LOOP_DATA,`ONCE_DATA:begin
					r_set_para0	<= {w_time_stamp_get[79:64],8'd0,i_status_code};
					r_set_para1	<= {16'h0,	i_scan_counter};
					r_set_para2	<= {16'h0,	i_telegram_no};
					r_set_para3	<= {16'h0,	r_scan_freqence};
					r_set_para4	<= {r_angle_reso,o_index_num};
					r_set_para5	<= {16'h0,	i_first_angle};
					r_set_para6	<= {16'h0,	i_packet_points};
					r_set_para7	<= w_time_stamp_get[63:32];
					r_set_para8	<= w_time_stamp_get[31:0];
					end
				`CALI_DATA:
					r_set_para0	<= {16'h0,	i_calib_points};
				`SET_COE:
					r_set_para0	<= {31'h0,	w_main_level};
				`SAVE_COE:
					r_set_para0	<= {31'h0,	r_coe_com_flag};
				`GET_COE:
					r_set_para0	<= i_get_para0;
				`SAVE_F_PARA:
					r_set_para0	<= {31'h0,	w_main_level};
				`LOAD_F_CFG:
					r_set_para0	<= {31'h0,	w_auth_level};
				`SAVE_U_PARA:
					r_set_para0	<= {31'h0,	w_auth_level};
				`LOAD_U_CFG:
					r_set_para0	<= {31'h0,	w_auth_level};
				`SET_CODE:
					r_set_para0	<= {31'h0,	r_code_conti_flag & i_code_right};
				`SET_RSSI_COE:
					r_set_para0	<= {31'h0,	w_main_level};
				`SAVE_CODE:begin
					r_set_para0	<= {29'h0,	r_code_packet_num};
					r_set_para1	<= {31'h0,	r_code_conti_flag & r_code_integ_flag};
					end
					
			    `SET_TEMP_DIST,`GET_TEMP_DIST: begin
					r_set_para0 <= {24'h0, r_temp_dist[31:24]};
					r_set_para1 <= {24'h0, r_temp_dist[23:16]};
					r_set_para2 <= {24'h0, r_temp_dist[15:8]};
					r_set_para3 <= {24'h0, r_temp_dist[7:0]};
					end
				`SET_TDC_SWITCH,`GET_TDC_SWITCH:
				    r_set_para0 <= {24'h0, r_tdc_switch};
				`SET_FIXED_VALUE,`GET_FIXED_VALUE:
				    r_set_para0 <= {16'h0, r_fixed_value};				
				default:r_set_para0 <= 32'h00000000;
				endcase
			end
			
	//r_packet_make
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_packet_make	<= 1'b0;
		else if(r_telegram_flag != 2'd0)
			r_packet_make	<= i_packet_make | i_calib_make;
		else
			r_packet_make	<= 1'b0;
			
	reg		   r_cmd_ack_reg;
	reg	[3:0]  r_delay_cnt;

	//r_cmd_make
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)begin
			r_cmd_ack_reg	<= 1'b0;
			r_cmd_make	<= 1'b0;
			r_delay_cnt <= 4'd0;
		end
		else if(r_set_cmd_code == `SAVE_CODE)begin
			if(w_cmd_ack_rise)
				r_cmd_ack_reg <= 1'b1;
			if(r_cmd_make == 1'b1)
				r_cmd_make	<= 1'b0;
			if(r_cmd_ack_reg )begin
				r_delay_cnt <= r_delay_cnt + 1'd1;
				if(r_delay_cnt >= 4'd2)begin
					r_delay_cnt <= 4'd2;
					if(i_flash_busy )
						r_cmd_make	<= 1'b0;
					else begin
						r_delay_cnt <= 4'd0;
						r_cmd_ack_reg <= 1'b0;
						r_cmd_make	<= 1'b1;
					end
				end
			end
		end
		else if(r_set_cmd_code != `ONCE_DATA && r_set_cmd_code != `CALI_DATA && r_set_cmd_code != `LOOP_DATA)
			r_cmd_make	<= w_cmd_ack_rise;
		else if(r_packet_make)
			r_cmd_make	<= 1'b1;
		else
			r_cmd_make	<= 1'b0;
			
	//r_cmd_make2
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_cmd_make2	<= 1'b0;
		else
			r_cmd_make2	<= r_cmd_make;
			
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
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
			if(r_config_mode[0])
				r_config_mode[7] <= 1'b0;
			else
				r_config_mode[7] <= r_device_mode[4];
			r_config_mode[6] <= r_measure_switch;
			end
			
	reg		r_dirt_mode;		
			
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_dirt_mode <= 1'd0;
		else
			r_dirt_mode <= r_device_mode[1];
			
	reg		[1:0]	r_filter_mode = 2'd0;
	//1:平滑滤波标志 1 = 开�0 = 关闭 0:拖尾滤波标志 1 = 开�0 = 关闭
	
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_filter_mode		<= 2'd0;
		else begin
			r_filter_mode[1]	<= r_device_mode[5];
			r_filter_mode[0]	<= r_device_mode[2];
			end
			
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_program_cnt <= 32'd0;
		else
			r_program_cnt <= r_program_cnt + r_program_sig;
			
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_program_n	<= 1'b1;
		else if(r_program_cnt >= 32'd5_000_000)
			r_program_n	<= 1'b0;

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
	assign		o_cmd_make = r_cmd_make2;
	assign		o_sram_csen_eth = r_sram_csen_eth;
	assign		o_sram_wren_eth = r_sram_wren_eth;
	assign		o_sram_rden_eth = r_sram_rden_eth;
	assign		o_sram_addr_eth = r_sram_addr_eth;
	assign		o_sram_data_eth = r_sram_data_eth;
    assign      o_regaddr_opto   = r_regaddr_opto;//tjs	
	assign		o_eth_rdaddr = r_eth_rdaddr;
	
	assign		o_ip_addr = r_ip_addr;
	assign		o_gate_way = r_gate_way;
	assign		o_sub_mask = r_sub_mask;
	assign		o_mac_addr = r_mac_addr;
	
	assign		o_config_mode = r_config_mode;
	assign		o_filter_mode = r_filter_mode;
	assign		o_pwm_value_0 = r_pwm_value_0;
	assign		o_tdc_window = r_tdc_window;
	assign		o_angle_offset = r_angle_offset;
	assign		o_zero_offset = r_zero_offset;
	assign		o_rise_start = r_rise_start;
	assign		o_pulse_start =	r_pulse_start;
	assign		o_apd_hv_base = r_apd_hv_base;
	assign		o_pulse_stand = r_pulse_stand;
	assign		o_distance_min = r_distance_min;
	assign		o_distance_max = r_distance_max;
	assign		o_temp_apdhv_base = r_temp_apdhv_base;
	assign		o_temp_temp_base = r_temp_temp_base;
	assign		o_temp_temp_coe = r_temp_temp_coe;
	
	assign		o_telegram_flag = r_telegram_flag;
	assign		o_program_n = r_program_n;
	assign		o_rst_n	 = r_rst_n;			
	assign		o_sram_store_flag = {r_code_packet_num,r_factory_sig,r_parameter_read,r_parameter_sig,r_coe_write_flag,r_code_write_flag};
	
	assign      o_temp_dist = r_temp_dist;
	assign      o_tdc_switch = r_tdc_switch;
	assign      o_fixed_value = r_fixed_value;
	
	assign      o_dirt_mode = r_dirt_mode;
	
	assign      o_dirt_points = r_dirt_points;
	
	assign      o_dirt_rise	   = r_dirt_rise;
	
	index_calculate U1
	(
		.i_clk_50m		(i_clk_50m),
		.i_rst_n		(i_rst_n),
		
		.i_angle_reso	(r_angle_reso),
		.i_start_angle	(r_start_angle),
		.i_stop_angle	(r_stop_angle),
		
		.o_start_index	(o_start_index),
		.o_stop_index	(o_stop_index),
		.o_index_num	(o_index_num)
	);
	
	time_stamp U2
	(
		.i_clk_50m			(i_clk_50m),
		.i_rst_n			(i_rst_n),
		
		.i_send_sig			(i_send_sig),
		.i_time_stamp_sig	(r_time_stamp_sig),
		.i_time_stamp_set	(r_time_stamp_set),
		
		.o_time_stamp_get	(w_time_stamp_get)
	);

endmodule 