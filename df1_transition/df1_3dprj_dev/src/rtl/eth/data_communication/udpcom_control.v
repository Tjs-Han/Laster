// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: udpcom_control
// Date Created 	: 2024/10/25 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:udpcom_control
//				Optical communication module
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module udpcom_control
#(  
	parameter FIRMWARE_VERSION		= 32'h25041515,
    parameter DDR_DW        		= 64,
    parameter DDR_AW        		= 27,
	parameter USER_RDW      		= 16
)
(
	input								i_clk,
	input								i_rst_n,
	output								o_parainit_done,

	//udp communication 	
	input								i_udpcom_busy,	
    input					    		i_udp_rxdone,
	output					    		o_udp_rxram_rden,
	output [10:0]			    		o_udp_rxram_rdaddr,
	input  [ 7:0]			    		i_udp_rxram_data,
	input  [15:0]			    		i_udp_rxbyte_num,
	input  [15:0]						i_udprecv_desport,

    output 				        		o_udp_send_req,
    input  [10:0]               		i_udp_txram_rdaddr,
    output [7:0]                		o_udp_txram_rddata,
    output [15:0]			    		o_udp_txbyte_num,
	output [15:0]						o_udpsend_srcport,
	output [15:0]						o_udpsend_desport,
	//ddr interface
	output                              o_para2ddr_wren,
    output                              o_ddr2para_rden,
    output [DDR_AW-1:0]                 o_para2ddr_addr,
    output [DDR_DW-1:0]                 o_para2ddr_data,
	output								o_ddr2para_fifo_rden,
    input                              	i_ddr2para_fifo_empty,
    input  [DDR_DW-1:0]					i_ddr2para_fifo_data,
	output [7:0]						o_ddr_store_array,
	//calib and loop    
	output						        o_loopdata_flag,
	input  						        i_loop_make,
    input						        i_loop_pingpang,
	input						        i_loop_wren,	
	input  [7:0]				        i_loop_wrdata,
	input  [9:0]				        i_loop_wraddr,
	input  [15:0]				        i_loop_points,
	input						        i_loop_cycle_done,
	output								o_calibrate_flag,
	input  								i_calib_make,
	input								i_calib_wren,	
	input								i_calib_pingpang,
	input  [7:0]						i_calib_wrdata,
	input  [9:0]						i_calib_wraddr,
	input  [15:0]						i_calib_points,
	input								i_calib_cycle_done,
	input  [15:0]						i_code_angle,
	//code ram		
	input								i_code_wren1,
	input  [6:0]						i_code_wraddr1,
	input  [31:0]						i_code_wrdata1,
	input								i_code_wren2,
	input  [6:0]						i_code_wraddr2,
	input  [31:0]						i_code_wrdata2,
	//input para vaule		
	input                               i_flash_poweron_initdone,
	input  [15:0]						i_apd_hv_value,
	input  [15:0]						i_apd_temp_value,
	input  [9:0]						i_dac_value,
	input  [7:0]						i_device_temp,
	//output parameter
	output								o_laser_switch,
	output [7:0]						o_laser_setnum,
	output [47:0]						o_lidar_mac,
	output [31:0]						o_lidar_ip,
	output [15:0]						o_lidar_port,
	output [15:0]						o_config_mode,
	output [15:0]						o_freq_motor1,
	output [15:0]						o_freq_motor2,
	output [15:0]						o_motor_pwm_setval1,
	output [15:0]						o_motor_pwm_setval2,
	output [15:0]						o_angle_offset1,
	output [15:0]						o_angle_offset2,
	output [15:0]						o_stop_window,
	output [15:0]						o_rise_divid,
	output [31:0]						o_pulse_start,
	output [31:0]						o_pulse_divid,
	output [31:0]						o_distance_min,
	output [31:0]						o_distance_max,
	output [15:0]						o_temp_apdhv_base,
	output [15:0]						o_temp_temp_base,
	output								o_hvcp_switch,
	output								o_dicp_switch,
	output [15:0]						o_start_index,
	output [15:0]						o_stop_index,
	output [15:0]						o_index_num,
	output [15:0]						o_cali_pointnum,

	output [15:0]						o_dist_diff,
	output [1:0]						o_telegram_flag,

	output [63:0]						o_time_stamp_get,
    input  [63:0]						i_ntp_first_get,		
    input  [63:0]						i_time_stamp_first_get,

	input  [6:0]						i_hvcp_ram_rdaddr,
	output [15:0]						o_hvcp_rddata,
	input  [6:0]						i_dicp_ram_rdaddr,
	output [15:0]						o_dicp_rddata	
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
	wire							w_userlink_state;
	wire							w_broadcast_en;
	wire [10:0]						w_recv_rdaddr;
	wire [ 7:0]						w_recv_data;
	wire [15:0]						w_recv_num;
	wire 							w_recv_ack;
	wire							w_parse_done;
	wire 							w_cmd_ack;
	wire 							w_send_data_req;
	wire 							w_send_req;
	wire [ 7:0]						w_send_data;
	wire [15:0]						w_rxcheck_code;
	wire [15:0]						w_get_cmd_id;

	wire [31:0]						w_get_para0;
	wire [31:0]						w_get_para1;
	wire [31:0]						w_get_para2;
	wire [31:0]						w_get_para3;
	wire [31:0]						w_get_para4;
	wire [31:0]						w_get_para5;
	wire [31:0]						w_get_para6;
	wire [31:0]						w_get_para7;
	wire [31:0]						w_get_para8;

	wire [31:0]						w_serial_number;
	wire [31:0]						w_coe_version;
	wire [15:0]						w_hvcomp_switch;
	wire [15:0]						w_motor_switch;

	wire							w_rddr_usercmd;
	wire [DDR_AW-1:0]               w_ddr_addr_base;
	wire							w_ddr2para_rdencmd;
    wire [DDR_AW-1:0]               w_para2ddr_addrcmd;
	wire							w_ddr2para_fifo_rdencmd;

	wire							w_ddr2para_rden;
    wire [DDR_AW-1:0]               w_para2ddr_addr;
	wire							w_ddr2para_fifo_rden;

	wire [9:0]						w_cache_rdaddr;
	wire [7:0]						w_cache_rddata;

	wire							w_udpfifo_rden;
	wire							w_udpfifo_empty;
	wire [47:0]						w_udpfifo_rdata;
	//--------------------------------------------------------------------------------------------------
	// inst domain
	//--------------------------------------------------------------------------------------------------
	udpcom_datagram_parser #(
		.FIRMWARE_VERSION			( FIRMWARE_VERSION			),
        .DDR_DW                		( DDR_DW                	),
        .DDR_AW                		( DDR_AW                	)
    )
	u_datagram_parser(
	
		.i_clk 						( i_clk						),
		.i_rst_n					( i_rst_n		 			),

		.i_udp_rxdone           	( i_udp_rxdone              ),
        .o_udp_rxram_rdaddr     	( o_udp_rxram_rdaddr        ),
        .i_udp_rxram_data       	( i_udp_rxram_data        	),
        .i_udp_rxbyte_num       	( i_udp_rxbyte_num          ),

		.i_udpcom_busy				( i_udpcom_busy				),
        .o_udp_send_req         	( o_udp_send_req            ),
        .i_udp_txram_rdaddr     	( i_udp_txram_rdaddr        ),
        .o_udp_txram_rddata     	( o_udp_txram_rddata        ),
        .o_udp_txbyte_num       	( o_udp_txbyte_num          ),
		.o_udpsend_srcport			( o_udpsend_srcport			),
		.o_udpsend_desport			( o_udpsend_desport			),

		.o_get_para0				( w_get_para0 				),
		.o_get_para1				( w_get_para1 				),
		.o_get_para2				( w_get_para2 				),
		.o_get_para3				( w_get_para3 				),
		.o_get_para4				( w_get_para4 				),
		.o_get_para5				( w_get_para5 				),
		.o_get_para6				( w_get_para6 				),
		.o_rxcheck_code				( w_rxcheck_code			),
		.o_get_cmd_id				( w_get_cmd_id				),
		.o_parse_done				( w_parse_done				),
		.i_ddr_addr_base			( w_ddr_addr_base			),
		.o_udpfifo_rden				( w_udpfifo_rden			),
		.i_udpfifo_empty			( w_udpfifo_empty			),
		.i_udpfifo_rdata			( w_udpfifo_rdata			),
		//parameter cfg
		.i_serial_number			( w_serial_number			),
		.i_lidar_mac				( o_lidar_mac				),
		.i_lidar_ip                 ( o_lidar_ip                ),
		.i_config_mode				( o_config_mode 			),
		.i_motor_switch				( w_motor_switch			),
		.i_freq_motor1				( o_freq_motor1				),
		.i_freq_motor2				( o_freq_motor2				),
		.i_angle_offset1			( o_angle_offset1			),
		.i_angle_offset2			( o_angle_offset2			),
		.i_coe_version				( w_coe_version				),
		.i_rise_divid 				( o_rise_divid 				),
		.i_pulse_start 				( o_pulse_start 			),
		.i_pulse_divid 				( o_pulse_divid 			),
		.i_temp_apdhv_base			( o_temp_apdhv_base 		),
		.i_temp_temp_base			( o_temp_temp_base 			),
		.i_hvcomp_switch			( w_hvcomp_switch			),
		//ddr interface
		.o_rddr_usercmd				( w_rddr_usercmd			),
		.o_ddr2para_rden			( w_ddr2para_rdencmd		),
    	.o_para2ddr_addr			( w_para2ddr_addrcmd		),
		.o_ddr2para_fifo_rden		( w_ddr2para_fifo_rdencmd	),
    	.i_ddr2para_fifo_empty		( i_ddr2para_fifo_empty		),
    	.i_ddr2para_fifo_data		( i_ddr2para_fifo_data		),
		//cache for need write to ddr
		.i_cache_rdaddr				( w_cache_rdaddr			),
		.o_cache_rddata				( w_cache_rddata			),
		//code ram		
		.i_code_wren1				( i_code_wren1 				),
		.i_code_wraddr1				( i_code_wraddr1 			),
		.i_code_wrdata1				( i_code_wrdata1 			),
		.i_code_wren2				( i_code_wren2 				),
		.i_code_wraddr2				( i_code_wraddr2 			),
		.i_code_wrdata2				( i_code_wrdata2 			),
		//loop	
		.i_loop_points         		( i_loop_points            	),
		.i_loop_pingpang			( i_loop_pingpang 			),
		.i_loop_wren				( i_loop_wren 				),	
		.i_loop_wrdata				( i_loop_wrdata 			),
		.i_loop_wraddr				( i_loop_wraddr 			),
		//cali	
		.i_calib_points         	( i_calib_points            ),
		.i_calib_pingpang			( i_calib_pingpang 			),
		.i_calib_wren				( i_calib_wren 				),	
		.i_calib_wrdata				( i_calib_wrdata 			),
		.i_calib_wraddr				( i_calib_wraddr 			)
	);

	udpcom_parameter_init #(
        .DDR_DW                		( DDR_DW                	),
        .DDR_AW                		( DDR_AW                	),
        .USER_RDW					( USER_RDW               	)
    )	
	u_parameter_init	
	(	
		.i_clk    					( i_clk 					),
		.i_rst_n      				( i_rst_n		 			),
		.o_parainit_done			( o_parainit_done			),

		.i_udprecv_desport			( i_udprecv_desport			),
		.i_get_para0				( w_get_para0 				),
		.i_get_para1				( w_get_para1 				),
		.i_get_para2				( w_get_para2 				),
		.i_get_para3				( w_get_para3 				),
		.i_get_para4				( w_get_para4 				),
		.i_get_para5				( w_get_para5 				),
		.i_get_para6				( w_get_para6 				),
		.i_udpfifo_rden				( w_udpfifo_rden			),
		.o_udpfifo_empty			( w_udpfifo_empty			),
		.o_udpfifo_rdata			( w_udpfifo_rdata			),
		.i_parse_done				( w_parse_done				),
		.i_rxcheck_code				( w_rxcheck_code			),
		.i_get_cmd_id				( w_get_cmd_id 				),
		.o_userlink_state			( w_userlink_state			),
		.i_broadcast_en				( w_broadcast_en			),
		.o_ddr_addr_base			( w_ddr_addr_base			),
		//cache for need write to ddr
		.o_cache_rdaddr				( w_cache_rdaddr			),
		.i_cache_rddata				( w_cache_rddata			),
		//ddr interface	
		.o_para2ddr_wren			( o_para2ddr_wren			),
    	.o_ddr2para_rden			( w_ddr2para_rden			),
    	.o_para2ddr_addr			( w_para2ddr_addr			),
    	.o_para2ddr_data			( o_para2ddr_data			),
		.o_ddr2para_fifo_rden		( w_ddr2para_fifo_rden		),
    	.i_ddr2para_fifo_empty		( i_ddr2para_fifo_empty		),
    	.i_ddr2para_fifo_data		( i_ddr2para_fifo_data		),
		.o_ddr_store_array			( o_ddr_store_array			),
		//cali and loop data
		.o_loopdata_flag			( o_loopdata_flag			),
		.i_loop_make				( i_loop_make 				),
		.i_loop_cycle_done			( i_loop_cycle_done			),
		.o_calibrate_flag			( o_calibrate_flag			),
		.i_calib_make				( i_calib_make 				),
		.i_calib_cycle_done			( i_calib_cycle_done		),
		.i_code_angle				( i_code_angle				),
		//input para vaule
		.i_flash_poweron_initdone   ( i_flash_poweron_initdone  ),
		.i_apd_hv_value				( i_apd_hv_value			),
		.i_apd_temp_value			( i_apd_temp_value			),
		.i_dac_value				( i_dac_value				),
		.i_device_temp				( i_device_temp				),

		.i_connect_state			( 1'b1 						),
		.o_laser_switch				( o_laser_switch			),
		.o_laser_setnum				( o_laser_setnum			),
		.o_serial_number			( w_serial_number			),
		.o_lidar_mac				( o_lidar_mac				),
		.o_lidar_ip                 ( o_lidar_ip                ),
		.o_config_mode				( o_config_mode 			),
		.o_motor_switch				( w_motor_switch			),
		.o_freq_motor1				( o_freq_motor1				),
		.o_freq_motor2				( o_freq_motor2				),
		.o_motor_pwm_setval1    	( o_motor_pwm_setval1       ),
        .o_motor_pwm_setval2    	( o_motor_pwm_setval2       ),
		.o_angle_offset1			( o_angle_offset1			),
		.o_angle_offset2			( o_angle_offset2			),
		.o_tdc_window				( o_stop_window	 			),
		.o_coe_version				( w_coe_version				),
		.o_rise_divid 				( o_rise_divid 				),
		.o_pulse_start 				( o_pulse_start 			),
		.o_pulse_divid 				( o_pulse_divid 			),
		.o_distance_min				( o_distance_min 			),
		.o_distance_max				( o_distance_max 			),
		.o_dist_diff				( o_dist_diff 				),
		.o_temp_apdhv_base			( o_temp_apdhv_base 		),
		.o_temp_temp_base			( o_temp_temp_base 			),
		.o_hvcomp_switch			( w_hvcomp_switch			),
		.o_hvcp_switch				( o_hvcp_switch				),
		.o_dicp_switch				( o_dicp_switch				),
		.o_start_index				( o_start_index 			),
		.o_stop_index				( o_stop_index 				),
		.o_index_num				( o_index_num 				),
		.o_cali_pointnum			( o_cali_pointnum			),

		.i_hvcp_ram_rdaddr			( i_hvcp_ram_rdaddr 		),
		.o_hvcp_rddata				( o_hvcp_rddata 			),

		.i_dicp_ram_rdaddr			( i_dicp_ram_rdaddr 		),
		.o_dicp_rddata				( o_dicp_rddata 			),

		.o_telegram_flag			( o_telegram_flag 			),
		.o_program_n				( o_program_n 				)		
	);

	udp_broadcast u_udp_broadcast(
		.i_clk    					( i_clk 					),
		.i_rst_n      				( i_rst_n & o_parainit_done	),

		.i_userlink_state			( w_userlink_state			),
		.o_broadcast_en				( w_broadcast_en			)
	);
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_ddr2para_rden		= (w_rddr_usercmd)? w_ddr2para_rdencmd : w_ddr2para_rden;
	assign o_para2ddr_addr		= (w_rddr_usercmd)? w_para2ddr_addrcmd : w_para2ddr_addr;
	assign o_ddr2para_fifo_rden	= (w_rddr_usercmd)? w_ddr2para_fifo_rdencmd : w_ddr2para_fifo_rden;
endmodule 