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
	
	input	[63:0]	i_ntp_get			,
	
	input	[15:0]	i_scan_counter		,
	input	[7:0]	i_telegram_no		,
	input	[15:0]	i_first_angle		,
	input	[15:0]	i_packet_points		,
	input	[15:0]	i_calib_points		,
	
	input	[7:0]	i_fall_cnt			,
	input	[15:0]	i_code_angle		,

	input	[7:0]	i_status_code		,
	input	[15:0]	i_apd_hv_value		,
	input	[15:0]	i_apd_temp_value	,
	input	[7:0]	i_device_temp		,
	input	[9:0]	i_dac_value			,
	input	[15:0]	i_pwm_value			,
	
	output	[31:0]	o_ip_addr			,
	output	[31:0]	o_gate_way			,
	output	[31:0]	o_sub_mask			,
	output	[47:0]	o_mac_addr			,
	output	[5:0]	o_random_seed		,
	
	output			o_motor_switch		,
	output	[15:0]	o_config_mode		,
	output	[15:0]	o_pwm_value_0		,
	output	[15:0]	o_tdc_window		,
	output	[15:0]	o_rise_divid		,
	output	[15:0]	o_pulse_start		,
	output	[15:0]	o_pulse_divid		,
	output	[15:0]	o_angle_offset		,
	output	[15:0]	o_zero_offset		,

	output	[15:0]	o_temp_apdhv_base	,
	output	[15:0]	o_temp_temp_base	,
	output	[15:0]	o_temp_temp_coe		,
	
	output	[31:0]	o_dist_coe_para		,
	output	[15:0]	o_dist_diff			,
	
	
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
	
	
	input           i_ntp_server_sig    ,
	
	output	[63:0]	o_time_stamp_get    ,
	
	input	[7:0]	i_opto_ram_rdaddr	,  //码盘补偿
	output	[7:0]	o_opto_rddata		,	//码盘补偿
	output			o_opto_switch		,
	
	
	input   [63:0] i_ntp_first_get     ,
	input   [63:0] i_time_stamp_first_get,
	
	output	[1:0]	o_telegram_flag		,
	output	[7:0]	o_sram_store_flag	,	
	output			o_program_n			,
	output			o_rst_n				


);

	reg		[23:0]	r_para_state = 24'd0;
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
	reg		[8:0]	r_sram_addr_para = 9'd0;
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
	reg		[31:0]	r_device_name	= "H1XX";
	reg		[31:0]	r_ip_addr	= 32'hC0A8016F;
	reg		[31:0]	r_gate_way	= 32'hC0A80101;
	reg		[31:0]	r_sub_mask	= 32'hFFFFFF00;
	reg		[47:0]	r_mac_addr	= 48'h112233445566;
	reg		[31:0]	r_serial_number = 32'h21050001;
	reg		[15:0]	r_scan_freqence	= 16'd1500;
	reg		[15:0]	r_angle_reso	= 16'd500;
	reg		[31:0]	r_start_angle	= 32'hFFF92230;
	reg		[31:0]	r_stop_angle	= 32'h00225510;
	
	reg		[7:0]	r_device_mode	= 8'b1100_0000;//8'd0;//7：标定模式，6：出光模式，5：平滑开关，4：脉宽模�

	reg		[15:0]	r_tdc_window	= 16'h4A50;
	reg		[15:0]	r_pwm_value_0	= 16'd700;
	reg		[15:0]	r_rise_divid	= 16'd0;
	reg		[15:0]	r_pulse_start	= 16'd0;
	reg		[15:0]	r_pulse_divid	= 16'd0;
	reg		[31:0]	r_dist_coe_para	= 32'd0;
	reg		[15:0]	r_dist_diff		= 16'd0;
	reg		[15:0]	r_angle_offset	= 16'h0000;//16'd0;
	reg		[15:0]	r_zero_offset	= 16'h15E0;//16'd0;
	reg		[15:0]	r_distance_min	= 16'd50;
	reg		[15:0]	r_distance_max	= 16'd50000;
	reg		[15:0]	r_temp_apdhv_base	= 16'h5B4;
	reg		[15:0]	r_temp_temp_base	= 16'd35;
	reg		[15:0]	r_temp_temp_coe		= 16'd15;
	reg		[5:0]	r_random_seed	= 6'd0;
	
	reg		[31:0]	r_coe_timep		= 32'd0;
	reg		[31:0]	r_coe_version	= 32'd0;
	reg				r_coe_com_flag	= 1'b0;
	
	reg		[63:0]	r_time_stamp_set	= 64'd0;
	reg				r_time_stamp_sig	= 1'b0;

	
	reg		[1:0]	r_telegram_flag = 2'd0;
	reg		[1:0]	r_telegram_flag_pre = 2'd0;
	reg				r_loop_telegram_flag = 1'b0;
	reg				r_rst_n		  = 1'b0;
	reg				r_measure_switch = 1'b1;
	reg		[7:0]	r_status_code = 8'd0;
	
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

	reg				r_opto_data_set_flag ;

	reg				r_packet_make	= 1'b0;
	reg		[7:0]	r_set_cmd_code	= 8'd0;

	reg				r_cmd_make		= 1'b0;
	reg				r_cmd_make2		= 1'b0;
	
	reg				r_cmd_ack		= 1'b0;
	reg				r_cmd_ack1		= 1'b0;
	wire			w_cmd_ack_rise	;
	
	reg		[15:0]	r_config_mode = 16'd0;
	
	reg		[1:0]	r_delay_cnt		;

	reg		[7:0] 		r_opto_ram_wraddr;	
	reg		 			r_opto_ram_wren;	
	reg		[7:0] 		r_opto_ram_rdaddr;	
	reg		[7:0] 		r_opto_wrdata;	
	
	reg                 r_motor_switch;

	//15:12	转速挡位：0�Hz	1�Hz
	//11:8	分辨率挡位：0�°
	//7:脉宽模式 1：脉宽模�：温补模�
	//6:测距模式 1：测距模�：休眠模�
	//5:出光模式标志�= 出光模式 0 = 不出光模�
	//4:平滑滤波模式 1 = 平滑模式 0 = 普通模�
	//3:拖尾滤波模式 1 = 滤波模式 0 = 普通模�
	//2:
	//1:
	//0:标定模式标志 1 = 标定模式 0 = 普通模�
	


	parameter		PARA_IDLE					= 24'b0000_0000_0000_0000_0000_0000,
					PARA_WAIT					= 24'b0000_0000_0000_0000_0000_0010,
					PARA_READ_PRE				= 24'b0000_0000_0000_0000_0000_0100,
					PARA_READ_LOOP				= 24'b0000_0000_0000_0000_0000_1000,
					PARA_READ					= 24'b0000_0000_0000_0000_0001_0000,
					PARA_READ_OPTO_START		= 24'b0000_0000_0000_0000_0010_0000,
					PARA_READ_OPTO				= 24'b0000_0000_0000_0000_0100_0000,
					PARA_READ_OPTO_DELAY		= 24'b0000_0000_0000_0000_1000_0000,
					PARA_READ_OPTO_SHIFT		= 24'b0000_0000_0000_0001_0000_0000,
					PARA_READ_OPTO_SHIFT_DELAY	= 24'b0000_0000_0000_0010_0000_0000,					
					PARA_ASSIGN					= 24'b0000_0000_0000_0100_0000_0000,
					PARA_WRITE					= 24'b0000_0000_0000_1000_0000_0000,
					PARA_SHIFT					= 24'b0000_0000_0001_0000_0000_0000,
					PARA_DELAY					= 24'b0000_0000_0010_0000_0000_0000,
					PARA_STORE					= 24'b0000_0000_0100_0000_0000_0000,
					PARA_READ2					= 24'b0000_0000_1000_0000_0000_0000,
					PARA_WAIT2					= 24'b0000_0001_0000_0000_0000_0000,
					PARA_ASSIGN1				= 24'b0000_0010_0000_0000_0000_0000,
					PARA_WAIT3					= 24'b0000_0100_0000_0000_0000_0000,
					PARA_ASSIGN2				= 24'b0000_1000_0000_0000_0000_0000,
					PARA_WRIT2					= 24'b0001_0000_0000_0000_0000_0000,
					PARA_SHIF2					= 24'b0010_0000_0000_0000_0000_0000,
					PARA_END					= 24'b0100_0000_0000_0000_0000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_para_state	<= PARA_IDLE;
		else begin
			case(r_para_state)
				PARA_IDLE	:begin
					r_para_state	<= PARA_WAIT;
					end
				PARA_WAIT	:begin
					if(i_read_complete_sig || r_load_factory_sig)
						r_para_state	<= PARA_READ;
					else if(r_para_write_flag || r_fact_write_flag)
						r_para_state	<= PARA_ASSIGN;
					else if(r_coe_set_flag || r_code_set_flag || r_rssi_set_flag || r_opto_data_set_flag)
						r_para_state	<= PARA_READ2;
					end
				PARA_READ_PRE:begin
					r_para_state	<= PARA_READ_LOOP;
					end
				PARA_READ_LOOP:begin
					r_para_state	<= PARA_READ;
					end
				PARA_READ	:begin
					if(r_sram_addr_eth[7:0] >= `PARAMETER_NUM - 1'b1)begin 
						if(r_delay_cnt >= 2'd1)
							r_para_state	<= PARA_READ_OPTO_START;//r_para_state	<= PARA_END;
						else
							r_para_state	<= PARA_READ;
					end
					else
						r_para_state	<= PARA_READ_PRE;
					end
				PARA_READ_OPTO_START:begin
						r_para_state	<= PARA_READ_OPTO;
					end
				PARA_READ_OPTO: begin
						r_para_state	<= PARA_READ_OPTO_DELAY;
					end
				PARA_READ_OPTO_DELAY:begin
						r_para_state	<= PARA_READ_OPTO_SHIFT;
					end
				PARA_READ_OPTO_SHIFT: begin
						r_para_state	<= PARA_READ_OPTO_SHIFT_DELAY;
					end	
				PARA_READ_OPTO_SHIFT_DELAY: begin
					if(r_sram_addr_eth >= 16'h3013)
						r_para_state	<= PARA_END;
					else
						r_para_state	<= PARA_READ_OPTO;
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
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_delay_cnt <= 2'd0;
		else if(r_sram_addr_eth[7:0] >= `PARAMETER_NUM - 1'b1 && r_para_state == PARA_READ)
			r_delay_cnt <= r_delay_cnt + 1'd1 ;
		else
			r_delay_cnt <= 2'd0;
			
	//r_sram_addr_base
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_addr_base	<= 18'd0;
		else if(r_para_state == PARA_IDLE)
			r_sram_addr_base	<= 18'd0;
		else if(r_para_state == PARA_WAIT)begin
			if(r_opto_data_set_flag)
				r_sram_addr_base	<= 18'h03000 ;
			else if(r_rssi_set_flag)
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
		else if(r_para_state == PARA_WAIT && (i_read_complete_sig || r_para_write_flag || r_load_factory_sig || r_fact_write_flag ))
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
		else if(r_para_state == PARA_WAIT && (i_read_complete_sig || r_load_factory_sig))
			r_sram_rden_eth	<= 1'b0;
		else if(r_para_state == PARA_READ_OPTO_SHIFT && r_sram_addr_eth[7:0] >= 16'h13)
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
				
				`TEMP_APDHV_BASE	: r_sram_data_eth	<= r_temp_apdhv_base;
				`TEMP_TEMP_BASE		: r_sram_data_eth	<= r_temp_temp_base;
				`TEMP_TEMP_COE		: r_sram_data_eth	<= r_temp_temp_coe;

				`DEVICE_STATUS		: r_sram_data_eth	<= {8'd0,r_device_mode};
				`TDC_WINDOW			: r_sram_data_eth	<= r_tdc_window;
				`MOTOR_KIND			: r_sram_data_eth	<= {15'd0,r_motor_switch};
				`MOTOR_PWM_INIT		: r_sram_data_eth	<= r_pwm_value_0;
				`RISE_DIVID			: r_sram_data_eth	<= r_rise_divid;
				`PULSE_START		: r_sram_data_eth	<= r_pulse_start;
				`ZERO_OFFSET		: r_sram_data_eth	<= r_zero_offset;
				`ANGLE_OFFSET		: r_sram_data_eth	<= r_angle_offset;
				`PULSE_DIVID		: r_sram_data_eth	<= r_pulse_divid;
				
				`DIST_MIN			: r_sram_data_eth	<= r_distance_min;
				`DIST_MAX			: r_sram_data_eth	<= r_distance_max;
				`COE_TIMEP_H		: r_sram_data_eth	<= r_coe_timep[31:16];
				`COE_TIMEP_L		: r_sram_data_eth	<= r_coe_timep[15:0];
				`COE_VER_H			: r_sram_data_eth	<= r_coe_version[31:16];
				`COE_VER_L			: r_sram_data_eth	<= r_coe_version[15:0];
				`DIST_COE_H			: r_sram_data_eth	<= r_dist_coe_para[31:16];
				`DIST_COE_L			: r_sram_data_eth	<= r_dist_coe_para[15:0];
				`DIST_DIFF			: r_sram_data_eth	<= r_dist_diff;
				`CHECK_SUM			: r_sram_data_eth	<= r_check_sum_set;
				default				: r_sram_data_eth	<= 16'hFFFF;
				endcase
	
			end
						
	//r_sram_addr_eth
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_addr_eth	<= 18'd0;
		else if(r_para_state == PARA_IDLE)
			r_sram_addr_eth	<= 18'd0;
		else if(r_para_state == PARA_READ_OPTO_START)//读取码盘补偿数据
			r_sram_addr_eth	<= 18'h3000;
		else if(r_para_state == PARA_WAIT)begin
			if(i_read_complete_sig || r_para_write_flag)
				r_sram_addr_eth	<= 18'd0;
			else if(r_load_factory_sig || r_fact_write_flag)
				r_sram_addr_eth	<= 18'h8000;
			end
		else if(r_para_state == PARA_READ_PRE)begin
			if(r_sram_addr_eth == `PARAMETER_NUM - 1'b1)
				r_sram_addr_eth <= `PARAMETER_NUM - 1'b1 ;
			else
				r_sram_addr_eth	<= r_sram_addr_eth + 1'b1;
			end
		else if(r_para_state == PARA_READ_OPTO_SHIFT_DELAY)  //读取码盘补偿数据
			r_sram_addr_eth	<= r_sram_addr_eth + 1'b1;
		else if(r_para_state == PARA_DELAY)
			r_sram_addr_eth	<= r_sram_addr_eth + 1'b1;
		else if(r_para_state == PARA_ASSIGN2)
			r_sram_addr_eth	<= r_sram_addr_base + r_write_cnt;
		else if(r_para_state == PARA_END)
			r_sram_addr_eth	<= 18'd0;
			
			
		
	//r_opto_wrdata 
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_wrdata <= 8'd0 ;		
		else if(r_para_state == PARA_READ_OPTO)
			r_opto_wrdata <= i_sram_data_eth[15:8];
		else if(r_para_state == PARA_READ_OPTO_SHIFT)
			r_opto_wrdata <= i_sram_data_eth[7:0];	
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_ram_wraddr <= 8'd0;
		else if(r_para_state == PARA_READ_OPTO_DELAY || r_para_state == PARA_READ_OPTO_SHIFT_DELAY)
			r_opto_ram_wraddr <= r_opto_ram_wraddr + 1'd1;
		else if(r_para_state == PARA_END)
			r_opto_ram_wraddr <= 8'd0;
			
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_ram_wren <= 1'd0;
		else if(r_para_state == PARA_READ_OPTO || r_para_state == PARA_READ_OPTO_SHIFT)
			r_opto_ram_wren <= 1'd1;
		else
			r_opto_ram_wren <= 1'd0;


	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_ram_rdaddr <= 8'd0;
		else
			r_opto_ram_rdaddr <= i_opto_ram_rdaddr;
					
						
	//r_check_sum_get
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_check_sum_get	<= 16'd0;
		else if(r_para_state == PARA_WAIT)
			r_check_sum_get	<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] < `PARAMETER_NUM - 1'b1)
			r_check_sum_get	<= r_check_sum_get + i_sram_data_eth;

		

	//r_init_flag
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_init_flag	<= 1'b0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `INITIAL_FLAG)begin
			if(i_sram_data_eth != 16'h5555)
				r_init_flag	<= 1'b1;
			else
				r_init_flag	<= 1'b0;
			end
			
	//r_check_sum_flag
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_check_sum_flag <= 1'b0;
		else if(r_para_state == PARA_IDLE)
			r_check_sum_flag <= 1'b0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `PARAMETER_NUM - 1'b1 && r_delay_cnt >= 1'b1)begin
			if(r_check_sum_get == i_sram_data_eth)
				r_check_sum_flag <= 1'b1;
			else
				r_check_sum_flag <= r_init_flag;

		end
			

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
		else if(r_para_state == PARA_END && r_check_sum_flag == 1'b0)
			r_parameter_read	<= 1'b1;
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
			
	//r_para_write_flag = 1'b0;
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
			
			
	// r_opto_data_set_flag
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_opto_data_set_flag <= 1'd0;
		else if(r_set_cmd_code == `SET_OPTO_DATA && r_cmd_ack && w_main_level)
			r_opto_data_set_flag <= 1'd1;
		else
			r_opto_data_set_flag <= 1'd0;
			
			
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
			r_sram_addr_para	<= 9'd0;
		else if(r_set_cmd_code == `SET_COE && r_cmd_ack && w_main_level)
			r_sram_addr_para	<= i_get_para0[8:0];
		else if(r_set_cmd_code == `SET_RSSI_COE && r_cmd_ack && w_main_level)
			r_sram_addr_para	<= i_get_para0[8:0];
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
			
			
			
	reg	[15:0]		r_code_angle;	
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_code_angle <= 16'd0;
		else
			r_code_angle <= i_code_angle;
			
			
			
	//r_telegram_flag
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_telegram_flag	<= 2'd0;
		else if(i_cmd_ack || ~i_connect_state)
			r_telegram_flag	<= 2'd0;
		else if(r_code_angle == 16'd0)begin
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
			r_rst_n		<= r_check_sum_flag;


			
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
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `PASSWORD_USER_H)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_password_user[31:16]	<= i_sram_data_eth;
			else
				r_password_user[31:16]	<= 16'hF472;
			end
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `PASSWORD_USER_L)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_password_user[15:0]	<= i_sram_data_eth;
			else
				r_password_user[15:0]	<= 16'h4744;
			end
		else if(r_set_cmd_code == `SET_PASSWORD && r_cmd_ack && w_auth_level)begin
			if(i_get_para0[7:0] == 8'h03)
				r_password_user		<= i_get_para1;
			end
			
	//r_device_name
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_device_name			<= "H100";
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DEVIDE_NAME_H)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_device_name[31:16]	<= i_sram_data_eth;
			else
				r_device_name[31:16]	<= "H1";
			end
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DEVIDE_NAME_L)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_device_name[15:0]		<= i_sram_data_eth;
			else
				r_device_name[15:0]		<= "00";
			end
		else if(r_set_cmd_code == `SET_DEV_NAME && r_cmd_ack && w_auth_level)
			r_device_name			<= i_get_para0;

	//r_ip_addr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_ip_addr			<= 32'hC0A8016F;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_IP_ADDR_H)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_ip_addr[31:16]	<= i_sram_data_eth;
			else
				r_ip_addr[31:16]	<= 16'hC0A8;
			end
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_IP_ADDR_L)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_ip_addr[15:0]		<= i_sram_data_eth;
			else
				r_ip_addr[15:0]		<= 16'h016F;
			end
		else if(r_set_cmd_code == `SET_IP && r_cmd_ack && w_auth_level)begin
			if(i_get_para3[7:0] >= 8'd1 && i_get_para3[7:0] <= 8'd254)
				r_ip_addr 			<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0]};
			else
				r_ip_addr 			<= r_ip_addr;
			end
		else if(r_set_cmd_code == `SET_GATEWAY && r_cmd_ack && w_auth_level)
			r_ip_addr[31:8] 	<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0]};

			
	//r_gate_way
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_gate_way			<= 32'hC0A80101;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_GATE_WAY_H)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_gate_way[31:16]	<= i_sram_data_eth;
			else
				r_gate_way[31:16]	<= 16'hC0A8;
			end
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_GATE_WAY_L)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_gate_way[15:0]	<= i_sram_data_eth;
			else
				r_gate_way[15:0]	<= 16'h0101;
			end
		else if(r_set_cmd_code == `SET_GATEWAY && r_cmd_ack && w_auth_level)
			r_gate_way 			<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0]};
		else if(r_set_cmd_code == `SET_IP && r_cmd_ack && w_auth_level)
			r_gate_way[31:8] 	<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0]};

	
	//r_sub_mask
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sub_mask			<= 32'hFFFFFF00;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_SUB_MASK_H)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_sub_mask[31:16]	<= i_sram_data_eth;
			else
				r_sub_mask[31:16]	<= 16'hFFFF;
			end
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_SUB_MASK_L)begin
			if(i_sram_data_eth != 16'hFF00)
				r_sub_mask[15:0]	<= i_sram_data_eth;
			else
				r_sub_mask[15:0]	<= 16'hFF00;
			end
		else if(r_set_cmd_code == `SET_SUBNET && r_cmd_ack && w_auth_level)
			r_sub_mask 			<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0]};


	//r_mac_addr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_mac_addr			<= 48'h112233445566;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_MAC_ADDR_H && i_sram_data_eth != 16'hFFFF)
			r_mac_addr[47:32]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_MAC_ADDR_M && i_sram_data_eth != 16'hFFFF)
			r_mac_addr[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ETH_MAC_ADDR_L && i_sram_data_eth != 16'hFFFF)
			r_mac_addr[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_MAC && r_cmd_ack && w_auth_level)
			r_mac_addr 			<= {i_get_para0[7:0], i_get_para1[7:0], i_get_para2[7:0], i_get_para3[7:0], i_get_para4[7:0], i_get_para5[7:0]};


	//r_serial_number
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_serial_number			<= 32'h21050001;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `SERIAL_NUMBER_H && i_sram_data_eth != 16'hFFFF)
			r_serial_number[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `SERIAL_NUMBER_L && i_sram_data_eth != 16'hFFFF)
			r_serial_number[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_SN && r_cmd_ack && w_main_level)
			r_serial_number			<= i_get_para0;
			
	//r_random_seed
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_random_seed	<= 6'd0;
		else
			r_random_seed	<= 	r_serial_number[5:0] + r_serial_number[11:6] + r_serial_number[17:12] + r_serial_number[23:18] +
								r_serial_number[29:24] + r_serial_number[31:30];

	//r_scan_freqence
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_scan_freqence			<= 16'd1500;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `SCAN_FREQUENCY && i_sram_data_eth != 16'hFFFF)
			r_scan_freqence			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_RESOLUTION && r_cmd_ack && w_auth_level)begin
			if(i_get_para0[15:0] == 16'd3000 || i_get_para0[15:0] == 16'd1500)
				r_scan_freqence			<= i_get_para0[15:0];
			end
			
	//r_angle_reso
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_reso			<= 16'd500;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ANGLE_RESOLUTION && i_sram_data_eth != 16'hFFFF)
			r_angle_reso			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_RESOLUTION && r_cmd_ack && w_auth_level)begin
			if(i_get_para0[15:0] == 16'd1500 && i_get_para1[15:0] == 16'd500)
				r_angle_reso			<= i_get_para1[15:0];
			else if(i_get_para0[15:0] == 16'd3000 && i_get_para1[15:0] == 16'd1000)
				r_angle_reso			<= i_get_para1[15:0];
			else if(i_get_para0[15:0] == 16'd1500 && i_get_para1[15:0] == 16'd2000)
				r_angle_reso			<= i_get_para1[15:0];
			else if(i_get_para0[15:0] == 16'd1500 && i_get_para1[15:0] == 16'd3333)
				r_angle_reso			<= i_get_para1[15:0];								
			end
			
	//r_start_angle
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_start_angle			<= 32'hFFF92230;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `START_ANGLE_H)
			r_start_angle[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `START_ANGLE_L)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_start_angle[15:0]		<= i_sram_data_eth;
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
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `STOP_ANGLE_H)
			r_stop_angle[31:16]		<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `STOP_ANGLE_L)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_stop_angle[15:0]		<= i_sram_data_eth;
			else
				r_stop_angle			<= 32'h00225510;
			end
		else if(r_set_cmd_code == `SET_ANGLE && r_cmd_ack && w_auth_level)begin
			if(i_get_para2 <= 32'h225510 || i_get_para2 >= 32'hFFF92230)
				r_stop_angle			<= i_get_para2;
			end

	//r_device_mode
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_device_mode			<= 8'b1100_0000;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DEVICE_STATUS && i_sram_data_eth != 16'hFFFF)
			r_device_mode			<= i_sram_data_eth[7:0];
		else if(r_set_cmd_code == `SET_CALI_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[7]		<= i_get_para0[0];
		else if(r_set_cmd_code == `SET_LASING_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[6]		<= i_get_para0[0];
		else if(r_set_cmd_code == `SET_FILTER_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[5]		<= i_get_para0[0];
		else if(r_set_cmd_code == `SET_COMP_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[4]		<= i_get_para0[0];
		else if(r_set_cmd_code == `SET_NTP_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[3]		<= i_get_para0[0];
		else if(r_set_cmd_code == `SET_TDC_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[2]		<= i_get_para0[0];
		else if(r_set_cmd_code == `SET_RSSI_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[1]		<= i_get_para0[0];
		else if(r_set_cmd_code == `SET_OPTO_SWITCH && r_cmd_ack && w_main_level)
			r_device_mode[0]		<= i_get_para0[0];	


	reg		r_opto_switch ;		
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_switch <= 1'd0;
		else
			r_opto_switch <= r_device_mode[0] ;
			
	//r_tdc_window
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_window			<= 16'h4A50;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `TDC_WINDOW && i_sram_data_eth != 16'hFFFF)
			r_tdc_window			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_TDC_WIN && r_cmd_ack && w_main_level)
			r_tdc_window			<= {i_get_para0[7:0],i_get_para1[7:0]};
			
	//r_motor_switch
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_motor_switch		<= 1'b1;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `MOTOR_KIND)begin
			if(i_sram_data_eth != 16'hFFFF)
				r_motor_switch		<= i_sram_data_eth[0];
			else
				r_motor_switch		<= 1'b1;
		end
		else if(r_set_cmd_code == `SET_MOTOR_KIND && r_cmd_ack && w_main_level)
			r_motor_switch		<= i_get_para0[0];	
			
	//r_status_code
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_status_code	<= 8'd0;
		else
			r_status_code	<= i_status_code;
			
	//r_temp_apdhv_base
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_temp_apdhv_base		<= 16'h5B4;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `TEMP_APDHV_BASE && i_sram_data_eth != 16'hFFFF)
			r_temp_apdhv_base		<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_TEMP_COE && r_cmd_ack && w_main_level)
			r_temp_apdhv_base		<= i_get_para0[15:0];
			
	//r_temp_temp_base
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_temp_temp_base		<= 16'd35;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `TEMP_TEMP_BASE && i_sram_data_eth != 16'hFFFF)
			r_temp_temp_base		<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_TEMP_COE && r_cmd_ack && w_main_level)
			r_temp_temp_base		<= i_get_para1[15:0];
			
	//r_temp_temp_coe
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_temp_temp_coe			<= 16'd15;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `TEMP_TEMP_COE && i_sram_data_eth != 16'hFFFF)
			r_temp_temp_coe			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_TEMP_COE && r_cmd_ack && w_main_level)
			r_temp_temp_coe			<= i_get_para2[15:0];
			
	//r_pwm_value_0
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pwm_value_0			<= 16'd700;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `MOTOR_PWM_INIT && i_sram_data_eth != 16'hFFFF)
			r_pwm_value_0			<= i_sram_data_eth;
		else if(r_status_code != i_status_code && i_status_code == 8'd1 && ~r_device_mode[7])
			r_pwm_value_0			<= i_pwm_value;
		else if(r_set_cmd_code == `SET_MOTOR_PWM && r_cmd_ack && w_main_level)
			r_pwm_value_0			<= i_get_para0[15:0];
			
	//r_rise_divid
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rise_divid			<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `RISE_DIVID && i_sram_data_eth != 16'hFFFF)
			r_rise_divid			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_main_level)
			r_rise_divid			<= i_get_para0[15:0];
			
	//r_pulse_start
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_start			<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `PULSE_START && i_sram_data_eth != 16'hFFFF)
			r_pulse_start			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_main_level)
			r_pulse_start			<= i_get_para1[15:0];
			
	//r_pulse_divid
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_divid			<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `PULSE_DIVID && i_sram_data_eth != 16'hFFFF)
			r_pulse_divid			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_main_level)
			r_pulse_divid			<= i_get_para2[15:0];
			
	//r_coe_timep		= 32'd0;
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_coe_timep			<= 32'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `COE_TIMEP_H && i_sram_data_eth != 16'hFFFF)
			r_coe_timep[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `COE_TIMEP_L && i_sram_data_eth != 16'hFFFF)
			r_coe_timep[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_main_level)
			r_coe_timep			<= i_get_para3;
			
	//r_coe_version		= 32'd0;
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_coe_version			<= 32'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `COE_VER_H && i_sram_data_eth != 16'hFFFF)
			r_coe_version[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `COE_VER_L && i_sram_data_eth != 16'hFFFF)
			r_coe_version[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_main_level)
			r_coe_version			<= i_get_para4;
	
	//r_coe_com_flag	= 1'b0;
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_coe_com_flag			<= 1'b0;
		else if(r_set_cmd_code == `SET_COE_PARA && r_cmd_ack && w_main_level)begin
			if(i_get_para5 == r_serial_number)
				r_coe_com_flag			<= 1'b1;
			else
				r_coe_com_flag			<= 1'b0;
			end
			
	//r_zero_offset
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_zero_offset			<= 16'h15A0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ZERO_OFFSET && i_sram_data_eth != 16'hFFFF)
			r_zero_offset			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_ZERO_OFFSET && r_cmd_ack && w_main_level)
			r_zero_offset			<= {i_get_para0[7:0],i_get_para1[7:0]};	
			
	//r_angle_offset
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_offset			<= 16'h0E00;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `ANGLE_OFFSET && i_sram_data_eth != 16'hFFFF)
			r_angle_offset			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_ANGLE_OFFSET && r_cmd_ack && w_main_level)
			r_angle_offset			<= {i_get_para0[7:0],i_get_para1[7:0]};		
			
	//r_distance_min
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_distance_min			<= 16'd50;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DIST_MIN && i_sram_data_eth != 16'hFFFF)
			r_distance_min			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_DIST_LMT && r_cmd_ack && w_main_level)
			r_distance_min			<= i_get_para0[15:0];
	
	//r_distance_max
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_distance_max			<= 16'd25000;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DIST_MAX && i_sram_data_eth != 16'hFFFF)
			r_distance_max			<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_DIST_LMT && r_cmd_ack && w_main_level)
			r_distance_max			<= i_get_para1[15:0];
			
	//r_dist_coe_para
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dist_coe_para			<= 32'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DIST_COE_H && i_sram_data_eth != 16'hFFFF)
			r_dist_coe_para[31:16]	<= i_sram_data_eth;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DIST_COE_L && i_sram_data_eth != 16'hFFFF)
			r_dist_coe_para[15:0]	<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_DIST_COE && r_cmd_ack && w_main_level)
			r_dist_coe_para			<= {i_get_para0[15:0],i_get_para1[15:0]};
	
	//r_dist_diff
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dist_diff				<= 16'd0;
		else if(r_para_state == PARA_READ && r_sram_addr_eth[7:0] == `DIST_DIFF && i_sram_data_eth != 16'hFFFF)
			r_dist_diff				<= i_sram_data_eth;
		else if(r_set_cmd_code == `SET_DIST_DIFF && r_cmd_ack && w_main_level)
			r_dist_diff				<= {i_get_para0[7:0],i_get_para1[7:0]};
			
	//r_time_stamp_set
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_time_stamp_set	<= 64'd0;
		else if(r_set_cmd_code == `SET_TIMESTAMP && r_cmd_ack && w_auth_level)begin
			r_time_stamp_set[63:48]	<= i_get_para0[15:0];
			r_time_stamp_set[47:32]	<= i_get_para1[15:0];
			r_time_stamp_set[31:16]	<= i_get_para2[15:0];
			r_time_stamp_set[15:0]	<= i_get_para3[15:0];
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
					r_set_para0 <= "H1XX";
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
				`SET_NTP_SWITCH,`GET_NTP_SWITCH: 
					r_set_para0 <= {31'd0,	r_device_mode[3]};
				`SET_TDC_SWITCH,`GET_TDC_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[2]};
				`SET_RSSI_SWITCH,`GET_RSSI_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[1]};
				`SET_OPTO_SWITCH,`GET_OPTO_SWITCH:
					r_set_para0 <= {31'd0,	r_device_mode[0]};
				`SET_MOTOR_KIND,`GET_MOTOR_KIND:
					r_set_para0 <= {31'd0,	r_motor_switch};
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
				`SET_DIST_DIFF,`GET_DIST_DIFF:begin
					r_set_para0 <= {24'h0,	r_dist_diff[15:8]};
					r_set_para1 <= {24'h0,	r_dist_diff[7:0]};
				end
				`SET_DIST_COE,`GET_DIST_COE:begin
					r_set_para0 <= {16'h0,	r_dist_coe_para[31:16]};
					r_set_para1 <= {16'h0,	r_dist_coe_para[15:0]};
				end
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
				`SET_TIMESTAMP:begin
					r_set_para0 <= {16'h0,	r_time_stamp_set[63:48]};
					r_set_para1 <= {16'h0,	r_time_stamp_set[47:32]};
					r_set_para2 <= {16'h0,	r_time_stamp_set[31:16]};
					r_set_para3 <= {16'h0,	r_time_stamp_set[15:0]};
				end
				`GET_TIMESTAMP:begin
					r_set_para0 <= {16'h0,	o_time_stamp_get[63:48]};
					r_set_para1 <= {16'h0,	o_time_stamp_get[47:32]};
					r_set_para2 <= {16'h0,	o_time_stamp_get[31:16]};
					r_set_para3 <= {16'h0,	o_time_stamp_get[15:0]};
				end
				`SET_COE_PARA:begin
					r_set_para0 <= {16'h0,	r_rise_divid};
					r_set_para1 <= {16'h0,	r_pulse_start};
					r_set_para2 <= {16'h0,	r_pulse_divid};
					r_set_para3 <= r_coe_timep;
					r_set_para4 <= r_coe_version;
					r_set_para5 <= i_get_para5;
					r_set_para6 <= {31'd0,	r_coe_com_flag};
				end
				`GET_COE_PARA:begin
					r_set_para0 <= {16'h0,	r_rise_divid};
					r_set_para1 <= {16'h0,	r_pulse_start};
					r_set_para2 <= {16'h0,	r_pulse_divid};
					r_set_para3 <= r_coe_timep;
					r_set_para4 <= r_coe_version;
				end
				`LOOP_DATA_SWITCH: 
					r_set_para0 <= {31'd0,	r_loop_telegram_flag};
				`LOOP_DATA,`ONCE_DATA:begin
					if(r_device_mode[3]&&i_ntp_server_sig)begin
						r_set_para0	<= {16'hAAAA,8'd0,i_status_code};
						r_set_para7	<= i_ntp_first_get[63:32];
						r_set_para8	<= i_ntp_first_get[31:0];
						end
					else if(r_device_mode[3])
						begin
						r_set_para0	<= {16'hBBBB,8'd0,i_status_code};
						r_set_para7	<= i_ntp_first_get[63:32];
						r_set_para8	<= i_ntp_first_get[31:0];
						end
					else begin
						r_set_para0	<= {16'hCCCC,8'd0,i_status_code};
						r_set_para7	<= i_time_stamp_first_get[63:32];
						r_set_para8	<= i_time_stamp_first_get[31:0];
						end
					r_set_para1	<= {16'h0,	i_scan_counter};
					r_set_para2	<= {16'h0,	i_telegram_no};
					r_set_para3	<= {16'h0,	r_scan_freqence};
					r_set_para4	<= {r_angle_reso,o_index_num};
					r_set_para5	<= {16'h0,	i_first_angle};
					r_set_para6	<= {16'h0,	i_packet_points};
					end
				`CALI_DATA:
					r_set_para0	<= {16'h0,	i_calib_points};
				`SET_COE, `SET_RSSI_COE:
					r_set_para0	<= {31'h0,	w_main_level};
				`SET_OPTO_DATA :
					r_set_para0	<= {31'h0,	w_main_level};
				`SAVE_COE:
					r_set_para0	<= {31'h0,	r_coe_com_flag};
				`GET_COE, `GET_RSSI_COE ,`GET_OPTO_DATA:
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
					r_set_para0	<= {31'h0,	r_code_conti_flag};
				`SAVE_CODE:begin
					r_set_para0	<= {29'h0,	r_code_packet_num};
					r_set_para1	<= {31'h0,	r_code_conti_flag & r_code_integ_flag};
					end
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

	//r_cmd_make
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_cmd_make	<= 1'b0;
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
	
	//r_device_mode	= 8'b1100_0000;//8'd0;//7：标定模�：出光模�：脉宽模�：平滑开�：拖尾模�
	
	//reg		[15:0]	r_config_mode = 16'd0;
	//15:12	转速挡位：0�Hz	1�Hz
	//11:8	分辨率挡位：0�°,1: 0.05°
	//7:脉宽模式 1：脉宽模�：温补模�
	//6:测距模式 1：测距模�：休眠模�
	//5:出光模式标志�= 出光模式 0 = 不出光模�
	//4:平滑滤波模式 1 = 平滑模式 0 = 普通模�
	//3:tdc分割模式 1 = 开�= 关闭
	//2:rssi模式切换 1 = 归一�= 不归一�
	//1:
	//0:标定模式标志 1 = 标定模式 0 = 普通模�
	
	always@(posedge i_clk_50m or negedge o_rst_n)
		if(o_rst_n == 0)
			r_config_mode <= 16'd0;
		else begin
			if(r_scan_freqence == 16'd3000)
				r_config_mode[15:12]	<= 4'd0;
			else if(r_scan_freqence == 16'd1500)
				r_config_mode[15:12]	<= 4'd1;
				
			if(r_angle_reso == 16'd1000)		// 0.1°
				r_config_mode[11:8]	<= 4'd0;
			else if(r_angle_reso == 16'd500)	// 0.05°
				r_config_mode[11:8]	<= 4'd1;
			else if(r_angle_reso == 16'd2000)	// 0.2°
				r_config_mode[11:8]	<= 4'd2;	
			else if(r_angle_reso == 16'd3333)	// 0.3333°
				r_config_mode[11:8]	<= 4'd3;								
			
			if(r_config_mode[0])
				r_config_mode[7] 		<= 1'b0;
			else
				r_config_mode[7] 		<= r_device_mode[4];
			
			r_config_mode[6] 		<= r_measure_switch;
			r_config_mode[5] 		<= r_device_mode[6];
			r_config_mode[4]		<= r_device_mode[5];
			r_config_mode[3]		<= r_device_mode[2];
			r_config_mode[2]		<= r_device_mode[1];
			r_config_mode[0] 		<= r_device_mode[7];
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
	
	assign		o_eth_rdaddr = r_eth_rdaddr;
	
	assign		o_ip_addr = r_ip_addr;
	assign		o_gate_way = r_gate_way;
	assign		o_sub_mask = r_sub_mask;
	assign		o_mac_addr = r_mac_addr;
	assign		o_random_seed = r_random_seed;
	
	assign		o_motor_switch = r_motor_switch;
	assign		o_config_mode = r_config_mode;
	assign		o_pwm_value_0 = r_pwm_value_0;
	assign		o_tdc_window = r_tdc_window;
	assign		o_angle_offset = r_angle_offset;
	assign		o_zero_offset = r_zero_offset;
	assign		o_rise_divid = r_rise_divid;
	assign		o_pulse_start =	r_pulse_start;
	assign		o_pulse_divid =	r_pulse_divid;
	assign		o_distance_min = r_distance_min;
	assign		o_distance_max = r_distance_max;
	assign		o_temp_apdhv_base = r_temp_apdhv_base;
	assign		o_temp_temp_base = r_temp_temp_base;
	assign		o_temp_temp_coe = r_temp_temp_coe;
	assign		o_dist_coe_para = r_dist_coe_para;
	assign		o_dist_diff = r_dist_diff;
	assign		o_opto_switch = r_opto_switch ;
	
	assign		o_telegram_flag = r_telegram_flag;
	assign		o_program_n = r_program_n;

	assign		o_rst_n	 = (r_rst_n)?1'b1:1'b0;			

	assign		o_sram_store_flag = { r_code_packet_num,r_factory_sig,r_parameter_read,r_parameter_sig,r_coe_write_flag,r_code_write_flag};
	
	
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
		
		.i_time_stamp_sig	(r_time_stamp_sig),
		.i_time_stamp_set	(r_time_stamp_set),
		
		.o_time_stamp_get	(o_time_stamp_get)
	);
	
	opto_ram opto_ram_inst
	(
		.WrClock				(i_clk_50m), 
		.WrClockEn				(r_opto_ram_wren),
		.WrAddress				(r_opto_ram_wraddr), 
		.Data					(r_opto_wrdata), 
		.WE						(1'b1), 
		.RdClock				(~i_clk_50m),  
		.RdClockEn				(1'b1),
		.RdAddress				(r_opto_ram_rdaddr),
		.Q						(o_opto_rddata),
		.Reset					(1'b0)//(~rst_n)
	);	

endmodule 