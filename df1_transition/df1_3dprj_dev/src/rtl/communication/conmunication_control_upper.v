// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: conmunication_control_upper
// Date Created 	: 2023/10/31 
// Version 			: V1.1
// -------------------------------------------------------------------------------------------------
// File description	:conmunication_control_upper
//				Optical communication module
//				new communication protocol
// -------------------------------------------------------------------------------------------------
// Revision History :
//			v1.0: old communication protocol
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module conmunication_control_upper
#(
	parameter FIRMWARE_VERSION			= 32'h23110312,
	parameter LOOP_PACKET_BYTE_NUM		= 16'd400,
	parameter CALI_PACKET_BYTE_NUM		= 16'd800,
	parameter LOOP_ERR_PERMIT_NUM		= 8'd6,
	parameter DDR_ADDR_BASE_LOOPPACKET1	= 32'h800000,//8M
	parameter DDR_ADDR_BASE_LOOPPACKET2	= 32'h810000,//8M+64K
	parameter DDR_ADDR_BASE_CALIPACKET1	= 32'h900000,//9M
	parameter DDR_ADDR_BASE_CALIPACKET2	= 32'h910000,//9M+64K
	parameter DEJTER_CLK_CNT			= 8,
	parameter USER_DW       			= 8,
	parameter FIFO_WDW      			= 32,
    parameter FIFO_RDW      			= 8,
	parameter AXI_WBL					= 16,//write channel BURST LENGTH = AWLEN/AWLEN+1
    parameter AXI_RBL					= 1,//read channel BURST LENGTH = AWLEN/ARLEN+1
	parameter AXI_WBL2					= 8,//write channel BURST LENGTH = AWLEN/AWLEN+1
    parameter AXI_RBL2					= 2,//read channel BURST LENGTH = AWLEN/ARLEN+1
	parameter AXI_AW 		    		= 32,
	parameter AXI_DW 		    		= 64
)
(
	input							i_clk_50m,
	input							i_clk_100m,
	input							i_rst_n,

	output							o_uart_tx,
	input							i_uart_rx/*synthesis PAP_MARK_DEBUG="true"*/,

	input							i_flash_initload_done,
	input							i_flash_save_done,
	//ddr			
	output							o_wrfifo_en,
	output [USER_DW-1:0]			o_wrfifo_data,
	output [AXI_AW-1:0]     		o_wrddr_addr_base,
	output							o_ddr_rden,
	output							o_fifo_rden,
	input  [USER_DW-1:0]			i_fifo_rddata,
	output [AXI_AW-1:0]     		o_rdddr_addr_base,
	input							i_rdfifo_empty,
	input							i_alfull_ddrdata_opt,

	output                   		o_ddr_rden2,
    output							o_fifo_rden2,
    input  [FIFO_RDW-1:0]			i_fifo_rddata2,
    output [AXI_AW-1:0]     		o_rdddr_addr_base2,
    input                  			i_rdfifo_empty2,
    input                  			i_rdfifo_alfull2,
    input                  			i_rddr_ready2,

	input							i_cycle_make_done,
	input							i_packet_pingpang,
	input  							i_packet_make,

	input							i_time_ram_wren,
	input  [5:0]					i_time_ram_wraddr,
	input  [127:0]					i_time_ram_wrdata,

	input							i_calib_pingpang,

	input  [7:0]					i_code_wraddr,
	input  [15:0]					i_code_wrdata,
	input							i_code_wren,

	input  [15:0]					i_code_angle,
	input  [15:0]					i_status_code,
	input  [15:0]					i_apd_hv_value,
	input  [15:0]					i_apd_temp_value,
	input  [7:0]					i_device_temp,
	input  [11:0]					i_dac_value,
	input  [15:0]					i_dist_compen,

	output [ 3:0]					o_reso_mode,
	output [ 1:0]					o_freq_mode,
	output [15:0]					o_config_mode,
	output [15:0]					o_stop_window,
	output [15:0]					o_angle_offset,
	output [15:0]					o_rise_divid,
	output [15:0]					o_pulse_start,
	output [15:0]					o_pulse_divid,
	output [15:0]					o_jump_para1,
	output [15:0]					o_jump_para2,
	output [15:0]					o_jump_para3,
	output [15:0]					o_jump_para4,
	output [15:0]					o_jump_para5,

	output [15:0]					o_tail_polar,
	output [15:0]					o_tail_para1,
	output [15:0]					o_tail_para2,
	output [15:0]					o_tail_para3,
	output [15:0]					o_tail_para4,
	output [15:0]					o_cluster_dist,
	output [15:0]					o_cluster_pulse,
	output [15:0]					o_distance_min,
	output [15:0]					o_distance_max,
	output [15:0]					o_temp_apdhv_base,
	output [15:0]					o_temp_temp_base,
	output [15:0]					o_temp_temp_switch,
	output [15:0]					o_start_index,
	output [15:0]					o_stop_index,
	output [15:0]					o_index_num,
	
	output [15:0]					o_dist_diff,
	output [15:0]					o_rssi_minval,
	output [15:0]					o_rssi_maxval,

	output [1:0]					o_telegram_flag,
	output 							o_calibrate_switch,

	output 							o_ddr2flash_wrsig,
	output 							o_save_fact_para,
	output							o_load_fact_para,
	output [31:0]					o_ddr2flash_addr_base,
	output [23:0]					o_flash_addr_offset,

	input  [7:0]					i_compen_rdaddr,
	output [15:0]					o_compen_rddata,
	output [15:0]					o_code_rddata,

	input  [6:0]					i_hvcp_ram_rdaddr,
	output [15:0]					o_hvcp_rddata,
	input  [6:0]					i_dicp_ram_rdaddr,
	output [15:0]					o_dicp_rddata,

	output							o_busy,
	output							o_program_n,
	output							o_init_load_done,
	output							o_rst_n				
);
	//----------------------------------------------------------------------------------------------
	// wire define
	//----------------------------------------------------------------------------------------------
	wire						w_light_rx/*synthesis PAP_MARK_DEBUG="true"*/;
	wire						w_rddr_usercmd;
	wire						w_ddr_rdencmd;
	wire						w_fifo_rdencmd;
	wire [AXI_AW-1:0]   		w_rdddr_addr_basecmd;

	wire						w_ddr_rden;
	wire						w_fifo_rden;
	wire [AXI_AW-1:0]   		w_rdddr_addr_base;

	wire 						w_optsend_req/*synthesis PAP_MARK_DEBUG="true"*/;
	wire						w_optsend_wren/*synthesis PAP_MARK_DEBUG="true"*/;
	wire [10:0]					w_optsend_wraddr;
	wire [7:0]					w_optsend_wrdata;
	wire [11:0]					w_optsend_num;

	wire						w_optrecv_rden;
	wire [10:0]					w_optrecv_rdaddr;
	wire [7:0]					w_optrecv_data;
	wire [10:0]					w_optrecv_num;
	wire						w_optrecv_done;

	wire						w_ack_cmd/*synthesis PAP_MARK_DEBUG="true"*/;
	wire						w_parse_done/*synthesis PAP_MARK_DEBUG="true"*/;
	wire [AXI_AW-1:0]			w_looppacket_raddr;
	wire [AXI_AW-1:0]			w_calipacket_raddr;
	wire						w_opt_recv_ack;
	wire						w_cali_addr_incr;
	wire [7:0]					w_get_cmd_code;
	wire [23:0]					w_optcom_bit_flag;

	wire						w_read_sram_csen;
	wire [17:0]					w_read_sram_addr;

	wire 						w_cache_rden;	
	wire [10:0]					w_cache_rdaddr;
	wire [ 7:0]					w_cache_rddata;

	wire [15:0]					w_config_mode/*synthesis PAP_MARK_DEBUG="true"*/;
	wire [15:0]					w_scan_freqence;
	wire [15:0]					w_angle_reso;
	wire [15:0]					w_start_angle;
	wire [15:0]					w_stop_angle;

	wire [5:0]					w_time_ram_rdaddr;
	wire [15:0]					w_looppackdot_ordnum;
	wire [15:0]					w_calipackdot_ordnum;

	signal_dejitter	
	#(
		.DEJTER_CLK_CNT			( DEJTER_CLK_CNT			)
	)
	u0_signal_dejitter
	(
        .i_clk_50m				( i_clk_50m					),
        .i_rst_n				( i_rst_n					),
		.i_signal				( i_uart_rx					),

		.o_signal				( w_light_rx				)
	);
	opt_communication u1_opt_communication(
	
		.clk 					( i_clk_50m 				),
		.i_clk_100m				( i_clk_100m				),
		.rst_n 					( i_rst_n 					),

		.i_uart_rx				( w_light_rx 				),
		.o_uart_tx				( o_uart_tx 				),

		.i_send_data_req		( w_optsend_wren 			),
		.i_send_data			( w_optsend_wrdata 			),
		.i_send_wraddr			( w_optsend_wraddr 			),	
		.i_send_req				( w_optsend_req 			),
		.i_send_num				( w_optsend_num 			),

		.i_recv_rdaddr			( w_optrecv_rdaddr 			),
		.o_recv_data			( w_optrecv_data 			),
		.o_recv_num				( w_optrecv_num				),
		.o_recv_ack				( w_optrecv_done 			)
	);

	optcom_datagram_parser 
	#(	
		.FIRMWARE_VERSION		( FIRMWARE_VERSION			),
		.LOOP_PACKET_BYTE_NUM	( LOOP_PACKET_BYTE_NUM		),
		.CALI_PACKET_BYTE_NUM	( CALI_PACKET_BYTE_NUM		),
		.USER_DW				( USER_DW					),
		.FIFO_WDW               ( FIFO_WDW                  ),
        .FIFO_RDW               ( FIFO_RDW                  ),
		.AXI_WBL		        ( AXI_WBL               	),
        .AXI_RBL		        ( AXI_RBL               	),
		.AXI_WBL2		        ( AXI_WBL2                  ),
        .AXI_RBL2		        ( AXI_RBL2                  ),
		.AXI_AW 		        ( AXI_AW                	),
	    .AXI_DW 		        ( AXI_DW                	)
	)
	u2_optcom_datagram_parser
	(
		.i_clk 					( i_clk_50m 				),
		.i_rst_n 				( i_rst_n		 			),

		//optcom_parameter_init communication siganl	
		.i_ack_cmd				( w_ack_cmd					),
		.o_parse_done			( w_parse_done 				),
		.i_looppacket_raddr_base( w_looppacket_raddr		),
		.i_calipacket_raddr_base( w_calipacket_raddr		),
		.o_opt_recv_ack			( w_opt_recv_ack			),
		.o_cali_addr_incr		( w_cali_addr_incr			),
		.o_get_cmd_code			( w_get_cmd_code			),
		.o_optcom_bit_flag		( w_optcom_bit_flag			),
		.o_ddr_wraddr_base		( o_wrddr_addr_base			),

		//save data from sram to flash	
		.o_ddr2flash_wrsig		( o_ddr2flash_wrsig			),
		.o_save_fact_para		( o_save_fact_para			),
		.o_load_fact_para		( o_load_fact_para			),
		.o_ddr2flash_addr_base	( o_ddr2flash_addr_base		),
		.o_flash_addr_offset	( o_flash_addr_offset		),

		//read ddr to user	
		.o_rddr_usercmd			( w_rddr_usercmd			),
		.o_ddr_rden				( w_ddr_rdencmd				),
		.o_fifo_rden			( w_fifo_rdencmd	 		),
		.i_fifo_rddata			( i_fifo_rddata				),
		.o_rdddr_addr_base		( w_rdddr_addr_basecmd		),
		.i_fifo_empty			( i_rdfifo_empty			),
		.i_alfull_ddrdata_opt	( i_alfull_ddrdata_opt		),

		//read pack data
		.o_ddr_rden2            ( o_ddr_rden2               ),
        .o_fifo_rden2           ( o_fifo_rden2              ),
        .i_fifo_rddata2         ( i_fifo_rddata2            ),
        .o_rdddr_addr_base2     ( o_rdddr_addr_base2        ),
        .i_rdfifo_empty2        ( i_rdfifo_empty2           ),
        .i_rdfifo_alfull2       ( i_rdfifo_alfull2          ),
        .i_rddr_ready2			( i_rddr_ready2				),

		//cache for need write to ddr
		.i_cache_rden			( w_cache_rden				),
		.i_cache_rdaddr			( w_cache_rdaddr			),
		.o_cache_rddata			( w_cache_rddata			),

		//check return	
		.i_device_temp			( {8'h0, i_device_temp}		),
		.i_apd_hv_value			( i_apd_hv_value			),
		.i_apd_temp_value		( i_apd_temp_value			),
		.i_dac_value			( {4'h0, i_dac_value}		),
		.i_dicp_value			( i_dist_compen				),

		//packet data	
		.i_config_mode			( w_config_mode				),
		.i_status_code			( i_status_code				),
		.i_looppackdot_ordnum	( w_looppackdot_ordnum		),
		.i_scan_freqence		( w_scan_freqence			),
		.i_angle_reso			( w_angle_reso				),
		.i_start_angle			( w_start_angle				),
		.i_stop_angle			( w_stop_angle				),
		.i_packet_pingpang		( i_packet_pingpang 		),

		.i_time_ram_wren		( i_time_ram_wren			),
		.i_time_ram_wraddr		( i_time_ram_wraddr			),
		.i_time_ram_wrdata		( i_time_ram_wrdata			),
		.i_time_ram_rdaddr		( w_time_ram_rdaddr			),

		//calibrated access	
		.i_calipackdot_ordnum	( w_calipackdot_ordnum		),
		//code ram	
		.i_code_wraddr			( i_code_wraddr 			),
		.i_code_wrdata			( i_code_wrdata 			),
		.i_code_wren			( i_code_wren 				),
		//optics communication	
		.o_optrecv_rden			( w_optrecv_rden			),
		.o_optrecv_rdaddr		( w_optrecv_rdaddr			),
		.i_optrecv_data			( w_optrecv_data			),
		.i_optrecv_num			( {1'b0, w_optrecv_num}		),
		.i_optrecv_done			( w_optrecv_done			),

		.o_optsend_wren			( w_optsend_wren			),	
		.o_optsend_wraddr		( w_optsend_wraddr			),
		.o_optsend_wrdata		( w_optsend_wrdata			),
		.o_optsend_req			( w_optsend_req				),		
		.o_optsend_num			( w_optsend_num				),

		.o_busy					( o_busy 					)

	);

	optcom_parameter_init 
	#(
		.LOOP_PACKET_BYTE_NUM		( LOOP_PACKET_BYTE_NUM		),
		.CALI_PACKET_BYTE_NUM		( CALI_PACKET_BYTE_NUM		),
		.LOOP_ERR_PERMIT_NUM		( LOOP_ERR_PERMIT_NUM		),
		.DDR_ADDR_BASE_LOOPPACKET1	( DDR_ADDR_BASE_LOOPPACKET1	),
		.DDR_ADDR_BASE_LOOPPACKET2	( DDR_ADDR_BASE_LOOPPACKET2	),
		.DDR_ADDR_BASE_CALIPACKET1	( DDR_ADDR_BASE_CALIPACKET1	),
		.DDR_ADDR_BASE_CALIPACKET2	( DDR_ADDR_BASE_CALIPACKET2	),
		.USER_DW					( USER_DW					),
		.AXI_WBL		        	( AXI_WBL               	),
        .AXI_RBL		        	( AXI_RBL               	),
		.AXI_AW 		        	( AXI_AW                	),
	    .AXI_DW 		        	( AXI_DW                	)
	)		
	u3_optcom_parameter_init	
	(	
		.i_clk_50m    			( i_clk_50m 				),
		.i_rst_n      			( i_rst_n		 			),
		.i_flash_initload_done	( i_flash_initload_done		),
		.i_flash_save_done		( i_flash_save_done			),

		//ddr ctrl siganl
		.o_wrfifo_en            ( o_wrfifo_en           	),
        .o_wrfifo_data          ( o_wrfifo_data         	),
        .o_ddr_rden             ( w_ddr_rden            	),
		.o_fifo_rden			( w_fifo_rden				),
		.i_fifo_rddata			( i_fifo_rddata				),
		.o_rdddr_addr_base		( w_rdddr_addr_base			),
		.i_rdfifo_empty			( i_rdfifo_empty			),

		//optcom_datagram_parser communication siganl
		.o_ack_cmd				( w_ack_cmd					),
		.i_parse_done			( w_parse_done 				),
		.o_looppacket_raddr		( w_looppacket_raddr		),
		.o_calipacket_raddr		( w_calipacket_raddr		),
		.o_time_ram_rdaddr		( w_time_ram_rdaddr			),
		.i_opt_recv_ack			( w_opt_recv_ack			),
		.i_cali_addr_incr		( w_cali_addr_incr			),
		.i_get_cmd_code			( w_get_cmd_code 			),	
		.i_wrddr_addr_base		( o_wrddr_addr_base			),
		.i_optcom_bit_flag		( w_optcom_bit_flag			),		
		.o_looppackdot_ordnum	( w_looppackdot_ordnum		),
		.o_calipackdot_ordnum	( w_calipackdot_ordnum		),

		.o_cache_rden			( w_cache_rden				),
		.o_cache_rdaddr			( w_cache_rdaddr			),
		.i_cache_rddata			( w_cache_rddata			),

		.i_cycle_make_done		( i_cycle_make_done			),
		.i_packet_make			( i_packet_make 			),
		.i_packet_pingpang		( i_packet_pingpang 		),
		.i_calib_pingpang		( i_calib_pingpang 			),
		.i_connect_state		( 1'b1 						),

		.i_code_angle			( i_code_angle 				),

		//temperature compensation	
		.i_hvcp_ram_rdaddr		( i_hvcp_ram_rdaddr 		),
		.o_hvcp_rddata			( o_hvcp_rddata 			),

		.i_dicp_ram_rdaddr		( i_dicp_ram_rdaddr 		),
		.o_dicp_rddata			( o_dicp_rddata 			),

		//encode compensation	
		.i_compen_rdaddr		( i_compen_rdaddr 			),
		.o_compen_rddata		( o_compen_rddata			),
		.o_code_rddata			( o_code_rddata				),

		//data out the parameters required by the upper layer
		.o_reso_mode			( o_reso_mode				),
		.o_freq_mode			( o_freq_mode				),			
		.o_config_mode			( w_config_mode 			),
		.o_scan_freqence		( w_scan_freqence			),
		.o_angle_reso			( w_angle_reso				),
		.o_tdc_window			( o_stop_window	 			),
		.o_angle_offset			( o_angle_offset 			),
		.o_distance_min			( o_distance_min 			),
		.o_distance_max			( o_distance_max 			),
		.o_temp_apdhv_base		( o_temp_apdhv_base 		),
		.o_temp_temp_base		( o_temp_temp_base 			),
		.o_dist_diff			( o_dist_diff 				),
		.o_rssi_minval			( o_rssi_minval				),
		.o_rssi_maxval			( o_rssi_maxval				),
		.o_start_index			( o_start_index 			),
		.o_stop_index			( o_stop_index 				),
		.o_index_num			( o_index_num 				),
	
		//FIT PARA	
		.o_rise_divid 			( o_rise_divid 				),
		.o_pulse_start 			( o_pulse_start 			),
		.o_pulse_divid 			( o_pulse_divid 			),
		//JUMP PARA
		.o_jump_para1	        ( o_jump_para1 				),
		.o_jump_para2	        ( o_jump_para2 				),
		.o_jump_para3	        ( o_jump_para3 				),
		.o_jump_para4	        ( o_jump_para4 				),
		.o_jump_para5	        ( o_jump_para5				),
		//TAIL PARA	
		.o_tail_polar			( o_tail_polar 				),
		.o_tail_para1			( o_tail_para1 				),
		.o_tail_para2			( o_tail_para2 				),
		.o_tail_para3			( o_tail_para3 				),
		.o_tail_para4			( o_tail_para4 				),
		.o_cluster_dist			( o_cluster_dist 			),
		.o_cluster_pulse		( o_cluster_pulse 			),
			
		.o_telegram_flag		( o_telegram_flag 			),
		.o_calibrate_switch		( o_calibrate_switch		),
		.o_program_n			( o_program_n 				),
		.o_init_load_done		( o_init_load_done			),
		.o_rst_n				( o_rst_n 					)	
	);
	//----------------------------------------------------------------------------------------------
	// output assign define
	//----------------------------------------------------------------------------------------------
	assign o_config_mode		= w_config_mode;
	assign o_ddr_rden			= (w_rddr_usercmd)?w_ddr_rdencmd:w_ddr_rden;
	assign o_fifo_rden			= (w_rddr_usercmd)?w_fifo_rdencmd:w_fifo_rden;
	assign o_rdddr_addr_base	= (w_rddr_usercmd)?w_rdddr_addr_basecmd:w_rdddr_addr_base;
endmodule 