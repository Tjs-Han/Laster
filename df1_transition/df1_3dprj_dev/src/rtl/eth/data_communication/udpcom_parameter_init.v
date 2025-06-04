// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: udpcom_parameter_init
// Date Created 	: 2024/10/25 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description :
// -------------------------------------------------------------------------------------------------
// Revision History  :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
`include "datagram_cmd_defines.v"
`include "parameter_ident_define.v"

module udpcom_parameter_init
#(  
    parameter DDR_DW        = 64,
    parameter DDR_AW        = 27,
	parameter USER_RDW      = 16
)
(
	input								i_clk,
	input								i_rst_n,
	output								o_parainit_done,
	//eth relation
	input  [15:0]						i_udprecv_desport,
	output [47:0]						o_lidar_mac,
	output [31:0]						o_lidar_ip,

	//com to dataparse		
	input  [31:0]						i_get_para0,
	input  [31:0]						i_get_para1,
	input  [31:0]						i_get_para2,
	input  [31:0]						i_get_para3,
	input  [31:0]						i_get_para4,
	input  [31:0]						i_get_para5,
	input  [31:0]						i_get_para6,
	input								i_udpfifo_rden,
	output								o_udpfifo_empty,
	output [47:0]						o_udpfifo_rdata,
	output [DDR_AW-1:0]                 o_ddr_addr_base,
	input								i_parse_done,
	input  [15:0]						i_rxcheck_code,
	input  [15:0]						i_get_cmd_id,

	//cache
	output [9:0]						o_cache_rdaddr,
	input  [7:0]						i_cache_rddata,

	//ddr interface
	output                              o_para2ddr_wren,
    output                              o_ddr2para_rden,
    output [DDR_AW-1:0]                 o_para2ddr_addr,
    output [DDR_DW-1:0]                 o_para2ddr_data,
	output								o_ddr2para_fifo_rden,
    input                              	i_ddr2para_fifo_empty,
    input  [DDR_DW-1:0]					i_ddr2para_fifo_data,
	//cali and loop data
	output								o_loopdata_flag,
	input								i_loop_make,
	input								i_loop_cycle_done,
	output								o_calibrate_flag,
	input								i_calib_make,
	input								i_calib_cycle_done,
	input								i_connect_state,
	input  [15:0]						i_code_angle,

	//input para vaule
	input                               i_flash_poweron_initdone,		
	input  [15:0]						i_apd_hv_value,
	input  [15:0]						i_apd_temp_value,
	input  [9:0]						i_dac_value,
	input  [7:0]						i_device_temp,
	//output parameter	
	output								o_laser_switch,
	output [7:0]						o_laser_setnum,
	output [31:0]						o_serial_number,
	output								o_userlink_state,
	input								i_broadcast_en,
	output [15:0]						o_config_mode,
	output [15:0]						o_tdc_window,
	output [15:0]						o_motor_switch,	
	output [15:0]						o_freq_motor1,
	output [15:0]						o_freq_motor2,
	output [15:0]						o_motor_pwm_setval1,
	output [15:0]						o_motor_pwm_setval2,
	output [15:0]						o_angle_offset1,
	output [15:0]						o_angle_offset2,
	output [31:0]						o_coe_version,
	output [15:0]						o_rise_divid,
	output [31:0]						o_pulse_start,
	output [31:0]						o_pulse_divid,
	output [31:0]						o_distance_min,
	output [31:0]						o_distance_max,
	output [15:0]						o_dist_diff,
	output [15:0]						o_temp_apdhv_base,
	output [15:0]						o_temp_temp_base,
	output [15:0]						o_hvcomp_switch,
	output								o_hvcp_switch,
	output								o_dicp_switch,		
	output [15:0]						o_start_index,
	output [15:0]						o_stop_index,
	output [15:0]						o_index_num,
	output [15:0]						o_cali_pointnum,

	input  [6:0]						i_hvcp_ram_rdaddr,
	output [15:0]						o_hvcp_rddata,

	input  [6:0]						i_dicp_ram_rdaddr,
	output [15:0]						o_dicp_rddata,

	output [1:0]						o_telegram_flag,
	output [7:0]						o_ddr_store_array,
	output								o_program_n		
);
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
	localparam DATA_BYTE_1K				= 8'd128;
	localparam DICP_DDRBASE_ADDR		= 27'h000_1000;	 //base 8k
	localparam HVCP_DDRBASE_ADDR		= 27'h000_2000;	 //base 16k
	localparam RSSI_DDRBASE_ADDR		= 27'h000_4000;	 //base 32k
	localparam COE_DDRBASE_ADDR			= 27'h001_0000;	 //base 128k
	localparam FIRM_DDRBASE_ADDR		= 32'h0080_0000; //base 16M

	localparam PARA_IDLE				= 24'b0000_0000_0000_0000_0000_0000;
	localparam PARA_WAIT				= 24'b0000_0000_0000_0000_0000_0001;
	localparam READ_DDR_EN				= 24'b0000_0000_0000_0000_0000_0010;
	localparam READ_DDR_FIFO			= 24'b0000_0000_0000_0000_0000_0100;
	localparam READ_FIFO_EN				= 24'b0000_0000_0000_0000_0000_1000;
	localparam READ_FIFO_DATA			= 24'b0000_0000_0000_0000_0001_0000;
	localparam READ_FIFO_DATA_REG		= 24'b0000_0000_0000_0000_0010_0000;
	localparam PARA_DATA_WRITE			= 24'b0000_0000_0000_0000_0100_0000;
	localparam PARA_DATA_CNT			= 24'b0000_0000_0000_0000_1000_0000;
	localparam WRITE_PARA2DDR_EN		= 24'b0000_0000_0000_0001_0000_0000;
	localparam WRITE_ADDR_INC			= 24'b0000_0000_0000_0010_0000_0000;
	localparam PARA_SHIFT				= 24'b0000_0000_0000_0100_0000_0000;
	localparam PARA_DELAY				= 24'b0000_0000_0000_1000_0000_0000;
	localparam PARA_STORE				= 24'b0000_0000_0001_0000_0000_0000;
	localparam DDR_BASE_ADDR			= 24'b0000_0000_0010_0000_0000_0000;
	localparam READ_CACHE_DATA			= 24'b0000_0000_0100_0000_0000_0000;
	localparam WRDDR_EN					= 24'b0000_0000_1000_0000_0000_0000;
	localparam WRDDR_ADDR_INCR			= 24'b0000_0001_0000_0000_0000_0000;
	localparam WRDDR_CNT				= 24'b0000_0010_0000_0000_0000_0000;
	localparam PARA_END					= 24'b0000_0100_0000_0000_0000_0000;
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
	reg  [23:0]				r_para_state 			= PARA_IDLE;
	reg						r_parainit_done			= 1'b0;
	reg						r_discal_flag			= 1'b0;

	reg						r_udpfifo_wren 			= 1'b0;
	reg  [47:0]				r_udpfifo_wrdata		= 48'h0;

	//ddr interface
	reg [31:0]				r_read_cnt				= 32'd0;
	reg  [7:0]				r_shift_num				= 8'd0;	
	reg [15:0]				r_write_cnt				= 16'd0;
	reg  [9:0]				r_cache_rdaddr			= 10'd0;
	reg                 	r_para2ddr_wren			= 1'b0;
    reg                 	r_ddr2para_rden			= 1'b0;
    reg  [DDR_AW-1:0]   	r_para2ddr_addr			= {DDR_AW{1'b0}};
    reg  [DDR_DW-1:0]   	r_para2ddr_data			= {DDR_DW{1'b0}};
	reg						r_ddr2para_fifo_rden	= 1'b0;
	reg  [15:0]				r_serial_num			= 16'd0;
	reg  [DDR_AW-1:0]   	r_ddr_addr_base			= {DDR_AW{1'b0}};
	//motor
	reg  [15:0]				r_motor_switch			= 16'h0000;
	reg	 [15:0]				r_angle_reso			= 16'd450;
	reg  [15:0]				r_freq_motor1			= 16'd10;
	reg  [15:0]				r_freq_motor2			= 16'd10;
	reg  [15:0]				r_pwmvalue_motor1		= 16'd999;
	reg  [15:0]				r_pwmvalue_motor2		= 16'd999;
	reg  [15:0]				r_angle_offset1			= 16'h0;
	reg  [15:0]				r_angle_offset2			= 16'h0;
	reg						r_loopdata_flag			= 1'b0;
	reg						r_calibrate_flag		= 1'b0;
	reg	 [31:0]				r_start_angle			= 32'hFFF24460;
	reg	 [31:0]				r_stop_angle			= 32'h002932E0;

	reg						r_para_write_flag 		= 1'b0;
	reg						r_fact_write_flag 		= 1'b0;
	reg						r_parameter_sig 		= 1'b0;
	reg						r_factory_sig 			= 1'b0;
	reg						r_load_factory_flag 	= 1'b0;
	reg						r_load_factory_sig 		= 1'b0;
	reg						r_rssi_set_flag			= 1'b0;
	reg						r_rssi_get_flag			= 1'b0;
	reg						r_coe_set_flag 			= 1'b0;
	reg						r_coe_get_flag			= 1'b0;
	reg						r_coe_write_flag 		= 1'b0;
	reg						r_code_set_flag 		= 1'b0;
	reg						r_code_write_flag 		= 1'b0;
	reg  [2:0]				r_code_packet_num 		= 3'd0;
	
	reg						r_userlink_state		= 1'b0;
	reg						r_login_state_02 		= 1'b0;
	reg						r_login_state_03 		= 1'b0;
	reg						r_check_pass_state 		= 1'b0;
	reg  [9:0]				r_eth_rdaddr 			= 10'd0;

	reg						r_init_flag 			= 1'b0;
	reg	 [15:0]				r_check_sum_set 		= 16'd0;
	reg	 [15:0]				r_check_sum_get 		= 16'd0;
	reg						r_check_sum_flag 		= 1'b0;
	reg						r_parameter_read 		= 1'b0;
	reg	 [31:0]				r_password_user 		= 32'hF4724744;
	reg	 [31:0]				r_device_name			= 32'h0;
	reg	 [47:0]				r_lidar_initmac			= 48'hAE_30_84_18_79_A1;
	reg	 [47:0]				r_lidar_mac				= 48'hAE_30_84_18_79_A1;
	reg	 [31:0]				r_lidar_initip			= 32'hC0A8016F;
	reg	 [31:0]				r_lidar_ip				= 32'hC0A8016F;
	reg	 [31:0]				r_gate_way				= 32'hC0A80101;
	reg	 [31:0]				r_sub_mask				= 32'hFFFFFF00;
	reg	 [31:0]				r_serial_number 		= 32'h25022716;

	reg  [7:0]				r_laser_switch			= 8'h0;
	reg  [7:0]				r_laser_setnum			= 8'h0;
	reg  [7:0]				r_device_mode			= 8'b1100_0000;
	reg  [15:0]				r_tdc_window			= 16'h4A50;
	reg  [15:0]				r_rise_divid			= 16'd0;
	reg  [31:0]				r_pulse_start			= 32'd408;
	reg  [31:0]				r_pulse_divid			= 32'd5656;
	reg  [15:0]				r_dist_diff				= 16'd0;
	reg  [15:0]				r_angle_offset			= 16'h0000;//16'd0;
	reg  [31:0]				r_distance_min			= 32'd50;
	reg  [31:0]				r_distance_max			= 32'd50000;
	reg  [15:0]				r_temp_apdhv_base		= 16'h5B4;
	reg  [15:0]				r_temp_temp_base		= 16'd35;
	reg  [15:0]				r_hvcomp_switch			= 16'h0;
	
	reg	 [31:0]				r_coe_timep				= 32'd0;
	reg	 [31:0]				r_coe_version			= 32'd0;
	reg						r_coe_com_flag			= 1'b0;

	reg	 [15:0] 			r_hvcp_wrdata 			= 16'd0;
	reg	 [6:0] 				r_hvcp_ram_wraddr 		= 7'd0;
	reg		 				r_hvcp_ram_wren 		= 1'b0;
	reg  [6:0] 				r_hvcp_ram_rdaddr 		= 7'd0;
	reg						r_hvcp_set_flag 		= 1'b0;

	reg	 [15:0] 			r_dicp_wrdata 			= 16'd0;
	reg	 [6:0] 				r_dicp_ram_wraddr 		= 7'd0;
	reg		 				r_dicp_ram_wren 		= 1'b0;
	reg  [6:0] 				r_dicp_ram_rdaddr 		= 7'd0;
	reg						r_dicp_set_flag 		= 1'b0;

	reg	 [1:0]				r_telegram_flag 		= 2'd0;
	reg	 [1:0]				r_telegram_flag_pre 	= 2'd0;
	reg						r_loop_telegram_flag	= 1'b0;
	reg						r_rst_n		  			= 1'b0;
	reg						r_measure_switch 		= 1'b1;
	reg  [7:0]				r_status_code 			= 8'd0;

	reg						r_code_conti_flag		= 1'b1;
	reg						r_code_integ_flag		= 1'b0;
	reg  [15:0]				r_code_seque_reg 		= 16'd0;

	reg						r_packet_make			= 1'b0;
	reg  [15:0]				r_set_cmd_id			= 16'h0;
	reg  [15:0]				r_cali_pointnum			= 16'h100;

	reg  [7:0]				r_parsedone_flag		= 8'h0;
	wire					w_parsedone_posedge;
	reg  [7:0]				r_loopback_flag			= 8'h0;
	wire					w_loop_ack;			
	reg  [7:0]				r_caliback_flag			= 8'h0;
	wire					w_calib_ack;	
	reg						r_cmd_ack				= 1'b0;
	reg  [15:0]				r_config_mode 			= 16'h0003;	//Default motor1 and motor2 stop

	wire					w_main_level;
	wire					w_auth_level;
    //----------------------------------------------------------------------------------------------
    // parse module communication
    //----------------------------------------------------------------------------------------------
	//r_set_cmd_id
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_set_cmd_id	<= 16'h0;
		else if(i_parse_done && i_udprecv_desport == 16'd55100)
			r_set_cmd_id	<= i_get_cmd_id;
		else
			r_set_cmd_id	<= r_set_cmd_id;
	end

	//r_parsedone_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_parsedone_flag	<= 8'h0;
		else
			r_parsedone_flag	<= {r_parsedone_flag[6:0], i_parse_done};
	end

	assign	w_parsedone_posedge = r_parsedone_flag[4] & (~r_parsedone_flag[5]);

	//r_loopback_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_loopback_flag	<= 8'h0;
		else
			r_loopback_flag	<= {r_loopback_flag[6:0], i_loop_make};
	end
	assign w_loop_ack = r_loopback_flag[3] & (~r_loopback_flag[4]);

	//r_caliback_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_caliback_flag	<= 8'h0;
		else
			r_caliback_flag	<= {r_caliback_flag[6:0], i_calib_make};
	end
	assign w_calib_ack = r_caliback_flag[3] & (~r_caliback_flag[4]);

	//r_cmd_ack
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_cmd_ack	<= 1'b0;
		else if(r_set_cmd_id != `ONCE_DATA && r_set_cmd_id != `CALI_DATA && r_set_cmd_id != `LOOP_DATA_SWITCH)
			r_cmd_ack	<= w_parsedone_posedge;
		else if(r_set_cmd_id == `CALI_DATA)
			r_cmd_ack	<= w_calib_ack;
		else if(r_set_cmd_id == `LOOP_DATA_SWITCH || r_set_cmd_id == `ONCE_DATA)
			r_cmd_ack	<= w_loop_ack;
		else
			r_cmd_ack	<= 1'b0;
	end

	//r_udpfifo_wren
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_udpfifo_wren	<= 1'b0;
		else if(i_broadcast_en)
			r_udpfifo_wren	<= 1'b1;
		else if(r_cmd_ack)
			r_udpfifo_wren	<= 1'b1;
		else if(i_parse_done && i_udprecv_desport == 16'd55600)
			r_udpfifo_wren	<= 1'b1;
		else
			r_udpfifo_wren	<= 1'b0;
	end

	//r_udpfifo_wrdata
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_udpfifo_wrdata	<= 48'h0;
		else if(i_broadcast_en)
			r_udpfifo_wrdata	<= {16'd55000, 16'h0100, 16'h0};
		else if(w_auth_level) begin
			if(r_cmd_ack && r_set_cmd_id == `CALI_DATA)
				r_udpfifo_wrdata	<= {16'd55200, 16'h0, r_set_cmd_id};
			else if(r_cmd_ack && (r_set_cmd_id == `ONCE_DATA || r_set_cmd_id == `LOOP_DATA_SWITCH))
				r_udpfifo_wrdata	<= {16'd55300, 16'h0, r_set_cmd_id};
			else if(r_cmd_ack)
				r_udpfifo_wrdata	<= {16'd55100, i_rxcheck_code, r_set_cmd_id};
			else if(i_parse_done && i_udprecv_desport == 16'd55600)
				r_udpfifo_wrdata	<= {16'd55600, i_rxcheck_code, i_get_cmd_id};
		end else begin
			if(r_cmd_ack && r_set_cmd_id == `CALI_DATA)
				r_udpfifo_wrdata	<= {16'd55200, 16'h0100, r_set_cmd_id};
			else if(r_cmd_ack && (r_set_cmd_id == `ONCE_DATA || r_set_cmd_id == `LOOP_DATA_SWITCH))
				r_udpfifo_wrdata	<= {16'd55300, 16'h0100, r_set_cmd_id};
			else if(r_cmd_ack)
				r_udpfifo_wrdata	<= {16'd55100, 16'h0100, r_set_cmd_id};
			else if(i_parse_done && i_udprecv_desport == 16'd55600)
				r_udpfifo_wrdata	<= {16'd55600, 16'h0100, i_get_cmd_id};
		end
	end

	//r_login_state_02
	//r_login_state_03
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)begin
			r_login_state_02	<= 1'b0;
			r_login_state_03	<= 1'b0;
		end else if(r_set_cmd_id == `LINK_REQ && r_parsedone_flag[0])begin
			if(i_get_para0 == 32'h00000002 && i_get_para1 == 32'h20210518)
				r_login_state_02	<= 1'b1;
			else if(i_get_para0 == 32'h00000003 && i_get_para1 == r_password_user)
				r_login_state_03	<= 1'b1;
		end else if(r_set_cmd_id == `DISCONNECT && r_parsedone_flag[0])begin
			r_login_state_02	<= 1'b0;
			r_login_state_03	<= 1'b0;
		end
	end
	assign w_main_level = r_login_state_02;
	assign w_auth_level = r_login_state_02 | r_login_state_03;
	//r_password_user
	// always@(posedge i_clk or negedge i_rst_n) begin
	// 	if(!i_rst_n)
	// 		r_password_user	<= 32'hF4724744;
	// 	else if(r_set_cmd_id == `SET_PASSWORD && r_parsedone_flag[1] && w_auth_level)begin
	// 		if(i_get_para0[7:0] == 8'h03)
	// 			r_password_user	<= i_get_para1;
	// 	end
	// end
    //----------------------------------------------------------------------------------------------
    // FSM(finite-state machine)
    //----------------------------------------------------------------------------------------------
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_para_state	<= PARA_IDLE;
		else begin
			case(r_para_state)
				PARA_IDLE: begin
					r_para_state	<= PARA_WAIT;
				end
				PARA_WAIT: begin
					if(i_flash_poweron_initdone || r_load_factory_sig)
						r_para_state	<= READ_DDR_EN;
					else if(r_para_write_flag || r_fact_write_flag)
						r_para_state	<= WRITE_PARA2DDR_EN;
					else if(r_coe_set_flag || r_code_set_flag || r_rssi_set_flag || r_hvcp_set_flag || r_dicp_set_flag)
						r_para_state	<= DDR_BASE_ADDR;
				end
				READ_DDR_EN:r_para_state	<= READ_DDR_FIFO;
				READ_DDR_FIFO: begin
					if(~i_ddr2para_fifo_empty)
						r_para_state	<= READ_FIFO_EN;
					else
						r_para_state	<= READ_DDR_FIFO;
				end
				READ_FIFO_EN: begin
					r_para_state	<= READ_FIFO_DATA;
				end
				READ_FIFO_DATA: begin
					r_para_state	<= READ_FIFO_DATA_REG;
				end
				READ_FIFO_DATA_REG: begin
					r_para_state	<= PARA_DATA_WRITE;
				end
				PARA_DATA_WRITE: begin
					r_para_state	<= PARA_DATA_CNT;
				end
				PARA_DATA_CNT: begin
					if(r_read_cnt >= `PARAMETER_NUM - 3'd4)
						r_para_state	<= PARA_END;
					else 
						r_para_state	<= READ_DDR_EN;
				end
				WRITE_PARA2DDR_EN: r_para_state	<= WRITE_ADDR_INC;
				WRITE_ADDR_INC: r_para_state	<= PARA_SHIFT;
				PARA_SHIFT: begin
					if(r_para2ddr_addr[7:0] >= `PARAMETER_NUM - 3'd4)
						r_para_state	<= PARA_STORE;
					else
						r_para_state	<= PARA_DELAY;
					end
				PARA_DELAY: begin
					r_para_state	<= WRITE_PARA2DDR_EN;
					end
				PARA_STORE: begin
					r_para_state	<= PARA_END;
				end
				DDR_BASE_ADDR:r_para_state	<= READ_CACHE_DATA;
				READ_CACHE_DATA: begin
					if(r_shift_num >= 4'd7)
						r_para_state	<= WRDDR_EN;
					else
						r_para_state	<= READ_CACHE_DATA;
				end
				WRDDR_EN: r_para_state	<= WRDDR_ADDR_INCR;
				WRDDR_ADDR_INCR: r_para_state	<= WRDDR_CNT;
				WRDDR_CNT	:begin
					if(r_write_cnt >= DATA_BYTE_1K)
						r_para_state	<= PARA_END;
					else
						r_para_state	<= READ_CACHE_DATA;
					end
				PARA_END	:begin
					r_para_state	<= PARA_WAIT;
					end
				default:r_para_state	<= PARA_IDLE;
			endcase
		end
	end
	//----------------------------------------------------------------------------------------------
	// ddr communication domain
	//----------------------------------------------------------------------------------------------
	// r_parainit_done
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_parainit_done	<= 1'b0;
		else if(i_flash_poweron_initdone)
			r_parainit_done	<= 1'b0;
		else if(r_para_state == PARA_END)
			r_parainit_done	<= 1'b1;
	end

	//r_read_cnt
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_read_cnt	<= 32'd0;
		else if(r_para_state == PARA_IDLE)
			r_read_cnt	<= 32'd0;
		else if(r_para_state == PARA_DATA_CNT)
			r_read_cnt	<= r_read_cnt + 4'd4;
		else if(r_para_state == PARA_END)
			r_read_cnt	<= 32'd0;
	end

	//r_ddr2para_rden active hign
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_ddr2para_rden	<= 1'b0;
		else if(r_para_state == PARA_IDLE)
			r_ddr2para_rden	<= 1'b0;
		else if(r_para_state == READ_DDR_EN)
			r_ddr2para_rden	<= 1'b1;
		else
			r_ddr2para_rden	<= 1'b0;
	end

	//r_ddr2para_fifo_rden active hign
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_ddr2para_fifo_rden	<= 1'b0;
		else if(r_para_state == PARA_IDLE)
			r_ddr2para_fifo_rden	<= 1'b0;
		else if(r_para_state == READ_FIFO_EN)
			r_ddr2para_fifo_rden	<= 1'b1;
		else
			r_ddr2para_fifo_rden	<= 1'b0;
	end

	//r_shift_num
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_shift_num	<= 4'd0;
		else if(r_para_state == READ_CACHE_DATA)
			r_shift_num	<= r_shift_num + 1'b1;	
		else
			r_shift_num	<= 4'd0;	
	end

	//r_para2ddr_wren
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_para2ddr_wren	<= 1'b0;
		else if(r_para_state == PARA_IDLE)
			r_para2ddr_wren	<= 1'b0;
		else if(r_para_state == WRITE_PARA2DDR_EN || r_para_state == WRDDR_EN)
			r_para2ddr_wren	<= 1'b1;
		else
			r_para2ddr_wren	<= 1'b0;
	end

	//r_para2ddr_data
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_para2ddr_data	<= {DDR_DW{1'b0}};
		else if(r_para_state == PARA_IDLE)
			r_para2ddr_data	<= {DDR_DW{1'b0}};
		else if(r_para_state == READ_CACHE_DATA || r_para_state == WRDDR_EN)
			r_para2ddr_data	<= {r_para2ddr_data[DDR_DW-9:0], i_cache_rddata};
		else if(r_para_state == WRITE_PARA2DDR_EN) begin
			case(r_para2ddr_addr[5:0])
				6'h00: r_para2ddr_data	<= {r_password_user, 32'h5555AAAA};//r_password_user = 32'hF4724744;
				6'h04: r_para2ddr_data	<= {r_lidar_ip, r_device_name};//r_lidar_ip = 32'hC0A8016F;	r_device_name = 32'h0;
				6'h08: r_para2ddr_data	<= {r_sub_mask, r_gate_way};//r_sub_mask = 32'hFFFFFF00; r_gate_way = 32'hC0A80101;
				6'h0c: r_para2ddr_data	<= {r_motor_switch, r_lidar_mac};//r_config_mode = 16'h0003; r_lidar_mac = 48'h112233445566;
				6'h10: r_para2ddr_data	<= {16'h0, r_angle_reso, r_serial_number};//r_angle_reso = 16'd1200; r_serial_number = 32'h24112601;
				6'h14: r_para2ddr_data	<= {32'h0, r_freq_motor2, r_freq_motor1};//r_freq_motor2 = 16'd10; r_freq_motor1 = 16'd10;
				6'h18: r_para2ddr_data	<= {r_stop_angle, r_start_angle};//r_stop_angle = 32'h002932E0; r_start_angle = 32'hFFF24460;
				6'h1c: r_para2ddr_data	<= {32'h0, r_angle_offset2, r_angle_offset1};//r_angle_offset2 = 16'h0; r_angle_offset1 = 16'h0;
				6'h20: r_para2ddr_data	<= {16'h0, r_hvcomp_switch, r_temp_temp_base, r_temp_apdhv_base};
				6'h24: r_para2ddr_data	<= {r_pulse_divid, r_pulse_start};
				6'h28: r_para2ddr_data	<= {r_distance_max, r_distance_min};
				default: r_para2ddr_data	<= {DDR_DW{1'b0}};
			endcase
		end
	end

	//r_para2ddr_addr 
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_para2ddr_addr	<= {DDR_AW{1'b0}};
		else if(r_para_state == PARA_IDLE)
			r_para2ddr_addr	<= {DDR_AW{1'b0}};
		else if(r_para_state == DDR_BASE_ADDR)
			r_para2ddr_addr	<= r_ddr_addr_base;
		else if(r_para_state == PARA_DATA_CNT || r_para_state == WRITE_ADDR_INC)
			r_para2ddr_addr	<= r_para2ddr_addr + 4'd4;
		else if(r_para_state == WRDDR_ADDR_INCR)
			r_para2ddr_addr	<= r_para2ddr_addr + 4'd4;
		else if(r_para_state == PARA_END)
			r_para2ddr_addr	<= {DDR_AW{1'b0}};
		else
			r_para2ddr_addr	<= r_para2ddr_addr;
	end

	//r_write_cnt
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_write_cnt		<= 16'd0;
		else if(r_para_state == PARA_IDLE)
			r_write_cnt		<= 16'd0;
		else if(r_para_state == WRDDR_CNT)
			r_write_cnt		<= r_write_cnt + 1'b1;
		else if(r_para_state == PARA_END)
			r_write_cnt		<= 16'd0;
	end
	
	//r_cache_rdaddr
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_cache_rdaddr	<= 10'd0;
		else if(r_para_state == PARA_IDLE || r_para_state == PARA_END)
			r_cache_rdaddr	<= 10'd0;
		else if(r_para_state == READ_CACHE_DATA)
			r_cache_rdaddr	<= r_cache_rdaddr + 1'b1;		
	end
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	// get parameter lidar according to cmd
	//--------------------------------------------------------------------------------------------------
	//r_rssi_set_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_rssi_set_flag	<= 1'b0;
		else if(r_set_cmd_id == `SET_RSSI_COE && r_parsedone_flag[1] && w_auth_level)
			r_rssi_set_flag	<= 1'b1;
		else
			r_rssi_set_flag	<= 1'b0;
	end

	//r_rssi_get_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_rssi_get_flag	<= 1'b0;
		else if(r_set_cmd_id == `GET_RSSI_COE && r_parsedone_flag[1] && w_auth_level)
			r_rssi_get_flag	<= 1'b1;
		else
			r_rssi_get_flag	<= 1'b0;
	end

	//r_coe_set_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_coe_set_flag	<= 1'b0;
		else if(r_set_cmd_id == `SET_COE && r_parsedone_flag[1] && w_auth_level)
			r_coe_set_flag	<= 1'b1;
		else
			r_coe_set_flag	<= 1'b0;
	end

	//r_coe_get_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_coe_get_flag	<= 1'b0;
		else if(r_set_cmd_id == `GET_COE && r_parsedone_flag[1] && w_auth_level)
			r_coe_get_flag	<= 1'b1;
		else
			r_coe_get_flag	<= 1'b0;
	end
	//r_parameter_read
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_parameter_read	<= 1'b0;
		else if(r_set_cmd_id == `LOAD_U_CFG && r_parsedone_flag[1] && w_auth_level)
			r_parameter_read	<= 1'b1;
		else
			r_parameter_read	<= 1'b0;
	end

	//r_para_write_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_para_write_flag	<= 1'b0;
		else if(r_set_cmd_id == `SAVE_U_PARA && r_parsedone_flag[1] && w_auth_level)
			r_para_write_flag	<= 1'b1;
		else if(r_para_state == PARA_END)
			r_para_write_flag	<= 1'b0;
	end

	//r_parameter_sig PARA_WAIT
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_parameter_sig	<= 1'b0;
		else if(r_para_state == PARA_STORE)
			r_parameter_sig	<= r_para_write_flag;
		else if(r_para_state == PARA_WAIT)
			r_parameter_sig	<= 1'b0;
	end

	//r_coe_com_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_coe_com_flag	<= 1'b0;
		else if(r_set_cmd_id == `SET_COE_PARA && r_parsedone_flag[1] && w_auth_level)begin
			if(i_get_para5 == r_serial_number)
				r_coe_com_flag	<= 1'b1;
			else
				r_coe_com_flag	<= 1'b0;
		end
	end

	//r_coe_write_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_coe_write_flag	<= 1'b0;
		else if(r_set_cmd_id == `SAVE_COE &&& r_parsedone_flag[1] && w_auth_level)
			r_coe_write_flag	<= 1'b1;
		else
			r_coe_write_flag	<= 1'b0;
	end

	//r_loopdata_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_loopdata_flag	<= 1'b0;
		else if(r_set_cmd_id == `LOOP_DATA_SWITCH && r_parsedone_flag[1])
			r_loopdata_flag	<= i_get_para0[0];
		else if(r_set_cmd_id == `ONCE_DATA) begin
			if(r_parsedone_flag[1])
				r_loopdata_flag	<= 1'b1;
			else if(i_loop_cycle_done)
				r_loopdata_flag	<= 1'b0;
		end
	end

	//r_calibrate_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_calibrate_flag	<= 1'b0;
		else if(r_set_cmd_id == `CALI_DATA && r_parsedone_flag[1])
			r_calibrate_flag	<= 1'b1;
		else if(i_calib_cycle_done)
			r_calibrate_flag	<= 1'b0;
		else
			r_calibrate_flag	<= r_calibrate_flag;
	end

	//r_ddr_addr_base
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_ddr_addr_base	<= {DDR_AW{1'b0}};
		else if(r_para_state == PARA_IDLE)
			r_ddr_addr_base	<= {DDR_AW{1'b0}};
		else if(r_para_state == PARA_WAIT)begin
			if(r_dicp_set_flag)
				r_ddr_addr_base	<= DICP_DDRBASE_ADDR;
			else if(r_hvcp_set_flag)
				r_ddr_addr_base	<= HVCP_DDRBASE_ADDR;
			else if(r_rssi_set_flag || r_rssi_get_flag)
				r_ddr_addr_base	<= RSSI_DDRBASE_ADDR + (r_serial_num << 4'd9);
			else if(r_coe_set_flag || r_coe_get_flag)
				r_ddr_addr_base	<= COE_DDRBASE_ADDR + (r_serial_num << 4'd9);
			else if(r_code_set_flag)
				r_ddr_addr_base	<= FIRM_DDRBASE_ADDR + (r_serial_num << 4'd9);
			end
		else if(r_para_state == PARA_END)
			r_ddr_addr_base	<= {DDR_AW{1'b0}};
	end
	
	//r_serial_num
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_serial_num	<= 16'd0;
		else if(r_set_cmd_id == `SET_COE && r_parsedone_flag[1] && w_main_level)
			r_serial_num	<= i_get_para0[15:0];
		else if(r_set_cmd_id == `GET_COE && r_parsedone_flag[1] && w_main_level)
			r_serial_num	<= i_get_para0[15:0];
		else if(r_set_cmd_id == `SET_RSSI_COE && r_parsedone_flag[1] && w_main_level)
			r_serial_num	<= i_get_para0[15:0];
		else if(r_set_cmd_id == `GET_RSSI_COE && r_parsedone_flag[1] && w_main_level)
			r_serial_num	<= i_get_para0[15:0];
		else if(r_set_cmd_id == `SET_CODE && r_parsedone_flag[1] && w_main_level)
			r_serial_num	<= i_get_para0[15:0];
	end
	//r_discal_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_discal_flag	<= 1'b0;
		else if(r_set_cmd_id == `SET_DISCAL_SWITCH && r_parsedone_flag[1] && w_main_level)
			r_discal_flag	<= i_get_para0[0];
	end

	//r_laser_switch
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_laser_switch	<= 8'h0;
		else if(r_set_cmd_id == `SET_LASER_SWITCH && r_parsedone_flag[1] && w_main_level) begin
			if(i_rxcheck_code == 16'h0000 && i_get_para0 <= 8'd7)
				r_laser_switch	<= i_get_para0[7:0];
			else
				r_laser_switch	<= r_laser_switch;		
		end
	end

	//r_laser_setnum
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_laser_setnum	<= 8'h0;
		else if(r_set_cmd_id == `SET_LASER_SERNUM && r_parsedone_flag[1] && w_main_level) begin
			if(i_rxcheck_code == 16'h0000 && i_get_para0 <= 8'd7)
				r_laser_setnum	<= i_get_para0[7:0];
			else
				r_laser_setnum	<= r_laser_setnum;		
		end
	end

	//r_lidar_initip
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_lidar_initip	<= 32'hC0A8016F;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h04 && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF)
			r_lidar_initip	<= i_ddr2para_fifo_data[63:32];
	end

	// //r_lidar_initip
	// always@(posedge i_clk or negedge i_rst_n) begin
	// 	if(!i_rst_n)
	// 		r_lidar_initip	<= 32'hC0A8016F;
	// 	else
	// 		r_lidar_initip	<= 32'hC0A8016F;
	// end
	//r_lidar_ip
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_lidar_ip	<= 32'hC0A8016F;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h04 && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF)
			r_lidar_ip	<= i_ddr2para_fifo_data[63:32];
		else if(r_set_cmd_id == `SET_INFO_IP && r_parsedone_flag[1] && w_main_level && i_rxcheck_code == 16'h0000)
			r_lidar_ip	<= i_get_para0;
	end

	//r_motor_switch
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_motor_switch	<= 16'h0000;
		end else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h0c && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF) begin
			r_motor_switch	<= i_ddr2para_fifo_data[63:48];
		end else if(r_set_cmd_id == `SET_MOTOR_SWITCH && r_parsedone_flag[1] && w_main_level && i_rxcheck_code == 16'h0000) begin
			r_motor_switch	<= i_get_para0[15:0];
		end
	end

	// //r_config_mode
	// always@(posedge i_clk or negedge i_rst_n) begin
	// 	if(!i_rst_n)
	// 		r_config_mode	<= 16'h0003;
	// 	else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h0c && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF)
	// 		r_config_mode	<= i_ddr2para_fifo_data[63:48];
	// 	else if(r_set_cmd_id == `SET_MOTOR_SWITCH && r_parsedone_flag[1] && w_main_level && i_rxcheck_code == 16'h0000)
	// 		r_config_mode[1:0]	<= i_get_para0[1:0];
	// end

	//r_lidar_initmac
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_lidar_initmac	<= 48'hAE_30_84_18_79_A1;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h0c && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF)
			r_lidar_initmac	<= i_ddr2para_fifo_data[47:0];
	end

	// //r_lidar_initmac
	// always@(posedge i_clk or negedge i_rst_n) begin
	// 	if(!i_rst_n)
	// 		r_lidar_initmac	<= 48'h112233445566;
	// 	else
	// 		r_lidar_initmac	<= 48'h112233445566;
	// end

	//r_lidar_mac
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_lidar_mac	<= 48'hAE_30_84_18_79_A1;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h0c && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF)
			r_lidar_mac	<= i_ddr2para_fifo_data[47:0];
		else if(r_set_cmd_id == `SET_INFO_MAC && r_parsedone_flag[1] && w_main_level && i_rxcheck_code == 16'h0000)begin
			r_lidar_mac[47:16]	<= i_get_para0;
			r_lidar_mac[15:0]	<= i_get_para1[15:0];
		end
	end

	//r_angle_reso
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_angle_reso	<= 16'd450;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h10 && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF)
			r_angle_reso	<= i_ddr2para_fifo_data[47:32];
		else if(r_set_cmd_id == `SET_ANGLE_RESO && r_parsedone_flag[1] && w_main_level)
			r_angle_reso	<= i_get_para0[15:0];
	end
	
	//r_serial_number
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_serial_number	<= 32'h25022716;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h10 && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF)
			r_serial_number	<= i_ddr2para_fifo_data[31:0];
		else if(r_set_cmd_id == `SET_INFO_SN && r_parsedone_flag[1] && w_main_level && i_rxcheck_code == 16'h0000)
			r_serial_number	<= i_get_para0;
	end

	//r_freq_motor1, r_freq_motor2
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_freq_motor1	<= 16'd71;
			r_freq_motor2	<= 16'd60;
		end else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h14 && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF) begin
			r_freq_motor1	<= i_ddr2para_fifo_data[31:16];
			r_freq_motor2	<= i_ddr2para_fifo_data[15:0];
		end else if(r_set_cmd_id == `SET_MOTOR_FREQ && r_parsedone_flag[1] && w_main_level && i_rxcheck_code == 16'h0000)begin
			if(i_get_para0[15:0] <= 16'd100 && i_get_para0[31:16] <= 16'd100) begin
				r_freq_motor1	<= i_get_para0[31:16];
				r_freq_motor2	<= i_get_para0[15:0];
			end
		end 
	end

	//r_pwmvalue_motor
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_pwmvalue_motor1	<= 16'd999;
			r_pwmvalue_motor2	<= 16'd999;
		end else if(r_set_cmd_id == `SET_MOTOR_PWM && r_parsedone_flag[1] && w_main_level)begin
			if(i_get_para0[15:0] <= 16'd1999 && i_get_para0[31:16] <= 16'd1999) begin
				r_pwmvalue_motor1	<= i_get_para0[15:0];
				r_pwmvalue_motor2	<= i_get_para0[31:16];
			end
		end 
	end

	//r_start_angle, r_stop_angle
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_start_angle	<= 32'hFFF24460;
			r_stop_angle	<= 32'h002932E0;
		end else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h18 && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF) begin
			r_start_angle	<= i_ddr2para_fifo_data[31:0];
			r_stop_angle	<= i_ddr2para_fifo_data[63:32];
		end else if(r_set_cmd_id == `SET_ANGLE && r_parsedone_flag[1] && w_main_level && i_rxcheck_code == 16'h0000) begin
			r_start_angle	<= i_get_para0;
			r_stop_angle	<= i_get_para1;
		end
	end

	//r_angle_offset1, r_angle_offset2
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_angle_offset1	<= 16'h0000;
			r_angle_offset2	<= 16'h0000;
		end else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h1c && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF) begin
			r_angle_offset1	<= i_ddr2para_fifo_data[15:0];
			r_angle_offset2	<= i_ddr2para_fifo_data[31:16];
		end else if(r_set_cmd_id == `SET_ANGLE_OFFSET && r_parsedone_flag[1] && w_main_level && i_rxcheck_code == 16'h0000) begin
			r_angle_offset1	<= i_get_para0[15:0];
			r_angle_offset2	<= i_get_para0[31:16];
		end
	end

	//r_temp_apdhv_base, r_temp_temp_base, r_hvcomp_switch
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_temp_apdhv_base	<= 16'h0333;
			r_temp_temp_base	<= 16'h001e;
			r_hvcomp_switch		<= 16'h0000;
		end else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h20 && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF) begin
			r_temp_apdhv_base	<= i_ddr2para_fifo_data[15:0];
			r_temp_temp_base	<= i_ddr2para_fifo_data[31:16];
			r_hvcomp_switch		<= i_ddr2para_fifo_data[47:32];
		end else if(r_set_cmd_id == `SET_HVCOMP_PARA && r_parsedone_flag[1] && w_main_level && i_rxcheck_code == 16'h0000) begin
			r_temp_apdhv_base	<= i_get_para0[15:0];
			r_temp_temp_base	<= i_get_para1[15:0];
			r_hvcomp_switch		<= i_get_para2[15:0];
		end
	end

	//r_pulse_start, r_pulse_divid
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_pulse_start	<= 32'd408;
			r_pulse_divid	<= 32'd5656;
		end else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h24 && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF) begin
			r_pulse_start	<= i_ddr2para_fifo_data[31:0];
			r_pulse_divid	<= i_ddr2para_fifo_data[63:32];
		end else if(r_set_cmd_id == `SET_COE_PARA && r_parsedone_flag[1] && w_main_level && i_rxcheck_code == 16'h0000) begin
			r_pulse_start	<= i_get_para0;
			r_pulse_divid	<= i_get_para1;
		end
	end

	//r_distance_min, r_distance_max
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_distance_min	<= 32'd50;
			r_distance_max	<= 32'd50000;
		end else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == 32'h28 && i_ddr2para_fifo_data != 64'hFFFF_FFFF_FFFF_FFFF) begin
			r_distance_min	<= i_ddr2para_fifo_data[31:0];
			r_distance_max	<= i_ddr2para_fifo_data[63:32];
		end else if(r_set_cmd_id == `SET_DIST_LMT && r_parsedone_flag[1] && w_main_level && i_rxcheck_code == 16'h0000) begin
			r_distance_min	<= i_get_para0;
			r_distance_max	<= i_get_para1;
		end
	end

	//r_cali_pointnum
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_cali_pointnum	<= 16'd100;
		end else if(r_set_cmd_id == `CALI_DATA && r_parsedone_flag[1] && w_main_level)begin
			r_cali_pointnum	<= i_get_para0[15:0];
		end 
	end
	//--------------------------------------------------------------------------------------------------
	// inst domain
	//--------------------------------------------------------------------------------------------------
	// angle2index u0_angle2index
	// (
	// 	.i_clk				( i_clk					),
	// 	.i_rst_n			( i_rst_n				),

	// 	.i_angle_reso		( r_angle_reso			),
	// 	.i_start_angle		( r_start_angle			),
	// 	.i_stop_angle		( r_stop_angle			),

	// 	.o_start_index		( o_start_index			),
	// 	.o_stop_index		( o_stop_index			),
	// 	.o_index_num		( o_index_num			)
	// );

	sfifo_64x48 u1_sfifo_64x48(
        .Data           	( r_udpfifo_wrdata		), //input [ARB_DW-1:0]
        .Clock          	( i_clk                 ), 
        .WrEn           	( r_udpfifo_wren		), 
        .RdEn           	( i_udpfifo_rden		), 
        .Reset          	( ~i_rst_n              ), 
        .Q              	( o_udpfifo_rdata		), 
        .Empty          	( o_udpfifo_empty		), 
        .Full           	( 	          			)
    );
	// cp_ram hvcp_ram_inst
	// (
	// 	.WrClock			( i_clk				), 
	// 	.WrClockEn			( r_hvcp_ram_wren		),
	// 	.WrAddress			( r_hvcp_ram_wraddr		), 
	// 	.Data				( r_hvcp_wrdata			), 
	// 	.WE					( 1'b1					), 
	// 	.RdClock			( i_clk				),  
	// 	.RdClockEn			( 1'b1					),
	// 	.RdAddress			( r_hvcp_ram_rdaddr		),
	// 	.Q					( o_hvcp_rddata			),
	// 	.Reset				( 1'b0					)
	// );
	
	// cp_ram dicp_ram_inst
	// (
	// 	.WrClock			( i_clk				), 
	// 	.WrClockEn			( r_dicp_ram_wren		),
	// 	.WrAddress			( r_dicp_ram_wraddr		), 
	// 	.Data				( r_dicp_wrdata			), 
	// 	.WE					( 1'b1					), 
	// 	.RdClock			( i_clk				),  
	// 	.RdClockEn			( 1'b1					),
	// 	.RdAddress			( r_dicp_ram_rdaddr		),
	// 	.Q					( o_dicp_rddata			),
	// 	.Reset				( 1'b0					)
	// );
	//--------------------------------------------------------------------------------------------------
	//output siganl assign define
	//--------------------------------------------------------------------------------------------------
	// assign o_parainit_done		= r_parainit_done;
	assign o_parainit_done		= 1'b1;
	// assign o_parainit_done		= r_discal_flag;
	// ack paremeter
	assign o_ddr_addr_base		= r_ddr_addr_base;
	//cache
	assign o_cache_rdaddr 		= r_cache_rdaddr;
	//ddr interface
	assign o_para2ddr_wren		= r_para2ddr_wren;
	assign o_ddr2para_rden		= r_ddr2para_rden;
	assign o_para2ddr_addr		= r_para2ddr_addr;
	assign o_para2ddr_data		= r_para2ddr_data;
	assign o_ddr2para_fifo_rden	= r_ddr2para_fifo_rden;
	assign o_ddr_store_array 	= {r_code_packet_num, r_factory_sig, r_parameter_read, r_parameter_sig, r_coe_write_flag, r_code_write_flag};
	// loop
	assign o_loopdata_flag		= r_loopdata_flag;
	// calib
	assign o_calibrate_flag		= r_calibrate_flag;
	// output parameter
	assign o_laser_switch		= r_laser_switch[0];
	assign o_laser_setnum		= r_laser_setnum;
	assign o_serial_number		= r_serial_number;
	assign o_userlink_state		= w_auth_level;
	assign o_lidar_mac			= r_lidar_initmac;
	assign o_lidar_ip 			= r_lidar_initip;
	assign o_config_mode 		= {14'h0, r_motor_switch[0], r_motor_switch[8]};
	assign o_motor_switch		= r_motor_switch;
	assign o_freq_motor1		= r_freq_motor1;
	assign o_freq_motor2		= r_freq_motor2;
	assign o_motor_pwm_setval1	= r_pwmvalue_motor1;
	assign o_motor_pwm_setval2	= r_pwmvalue_motor2;
	assign o_angle_offset1		= r_angle_offset1;
	assign o_angle_offset2		= r_angle_offset2;
	assign o_tdc_window 		= r_tdc_window;
	assign o_coe_version		= r_coe_version;
	assign o_rise_divid 		= r_rise_divid;
	assign o_pulse_start 		= r_pulse_start;
	assign o_pulse_divid 		= r_pulse_divid;
	assign o_distance_min 		= r_distance_min;
	assign o_distance_max 		= r_distance_max;
	assign o_temp_apdhv_base 	= r_temp_apdhv_base;
	assign o_temp_temp_base 	= r_temp_temp_base;
	assign o_hvcomp_switch		= r_hvcomp_switch;
	assign o_hvcp_switch 		= r_hvcomp_switch[8];
	assign o_dicp_switch 		= r_hvcomp_switch[0];
	assign o_dist_diff 			= r_dist_diff;
	assign o_cali_pointnum		= r_cali_pointnum;
endmodule 