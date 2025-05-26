// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: dist_measure
// Date Created 	: 2024/11/7 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:dist measure
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module dist_measure
#(
	parameter DDR_DW        		= 64,
    parameter DDR_AW        		= 27,
	parameter DDR_COE_BASE_ADDR		= 27'h001_0000,
	parameter DDR_RSSI_BASE_ADDR	= 27'h000_4000,
	parameter PACKET_DOT_NUM		= 16'd100
)
(
	input								i_clk,
	input								i_rst_n,
	input								i_discal_en,

	//ddr interface
    output                              o_ddr2dist_rden,
    output [DDR_AW-1:0]                 o_dist2ddr_addr,
	output								o_ddr2dist_fifo_rden,
	input  [DDR_DW-1:0]					i_ddr2dist_fifo_data,
    input                              	i_ddr2dist_fifo_empty,

	input								i_tdcsig_sync,
	input  [15:0]						i_tdcdata_rise,
   	input  [15:0]						i_tdcdata_fall,
	input  [15:0]						i_code_angle1,
	input  [15:0]						i_code_angle2,
	input  [3:0]						i_tdc_lasernum,
	input								i_motor_state,
	input								i_measure_en,
	input								i_rssi_switch,
	input  [3:0]						i_reso_mode,

	input  [31:0]						i_rise_divid,
	input  [31:0]						i_pulse_start,
	input  [31:0]						i_pulse_divid,
	input  [31:0]						i_distance_min,
	input  [31:0]						i_distance_max,
	input  [15:0]						i_dist_compen,

	input  [15:0]						i_start_index,
	input  [15:0]						i_stop_index,	

	input								i_busy,
	output								o_packet_wren,
	output								o_packet_pingpang,
	output [7:0]						o_packet_wrdata,
	output [11:0]						o_packet_wraddr,
	output								o_packet_make,
	output [15:0]						o_packet_points,

	output [15:0]						o_scan_counter,
	output [7:0]						o_telegram_no,
	output [15:0]						o_first_angle,

	//loop data			
	input								i_loopdata_flag,
	output								o_loop_make,
	output								o_loop_pingpang,
	output								o_loop_wren,
	output [7:0]						o_loop_wrdata,
	output [9:0]						o_loop_wraddr,
	output [15:0]						o_loop_points,
	output								o_loop_cycle_done,
	//calib data			
	input								i_calibrate_flag,
	input  [15:0]						i_cali_pointnum,
	output								o_calib_make,
	output								o_calib_pingpang,
	output								o_calib_wren,
	output [7:0]						o_calib_wrdata,
	output [9:0]						o_calib_wraddr,
	output [15:0]						o_calib_points,
	output								o_calib_cycle_done,
	output [15:0]						o_code_angle			
);
	//--------------------------------------------------------------------------------------------------
	// wire define
	//--------------------------------------------------------------------------------------------------
	wire [15:0]							w_code_angle_tdc;
	wire								w_tdc_new_sig;
	wire [15:0]							w_rise_data;
	wire [15:0]							w_fall_data;
	
	wire [31:0]							w_dist_data;
	wire [15:0]							w_rssi_data;
	wire [15:0]							w_rssi_tail;
	wire [31:0]							w_pulse_data;
	wire								w_dist_sig;
	wire [15:0]							w_dist_angle1;
	wire [15:0]							w_dist_angle2;
	//--------------------------------------------------------------------------------------------------
	// inst domain
	//--------------------------------------------------------------------------------------------------
	// dist_calculate 
	// #(
	// 	.DDR_DW							( DDR_DW					),
	//     .DDR_AW 		    			( DDR_AW                	),
	// 	.DDR_COE_BASE_ADDR				( DDR_COE_BASE_ADDR			),
	// 	.DDR_RSSI_BASE_ADDR				( DDR_RSSI_BASE_ADDR		)
    // )	
	// u_dist_calculate	
	// (	
	// 	.i_clk    						( i_clk						),
	// 	.i_rst_n      					( i_rst_n					),
	// 	.i_discal_en					( i_discal_en				),

	// 	.i_rssi_switch					( i_rssi_switch				),
	// 	.i_code_angle1 					( i_code_angle1				),
	// 	.i_code_angle2 					( i_code_angle2				),
	// 	.i_tdc_newsig					( i_tdcsig_sync				),
	// 	.i_rise_data					( i_tdcdata_rise	    	),
	// 	.i_fall_data					( i_tdcdata_fall	    	),

	// 	.i_rise_divid					( i_rise_divid				),
	// 	.i_pulse_start					( i_pulse_start				),
	// 	.i_pulse_divid					( i_pulse_divid				),
	// 	.i_distance_min					( i_distance_min			),
	// 	.i_distance_max					( i_distance_max			),
	// 	.i_dist_compen					( i_dist_compen				),

	// 	.o_ddr_rden						( o_ddr2dist_rden			),
	// 	.o_rdddr_addr_base				( o_dist2ddr_addr			),
	// 	.o_fifo_rden					( o_ddr2dist_fifo_rden		),
	// 	.i_fifo_rddata					( i_ddr2dist_fifo_data		),
	// 	.i_fifo_empty					( i_ddr2dist_fifo_empty		),

	// 	.o_dist_data					( w_dist_data				),
	// 	.o_rssi_data					( w_rssi_data				),
	// 	.o_rssi_tail					( w_rssi_tail				),
	// 	// .o_pulse_data					( w_pulse_data				),
	// 	.o_dist_newsig					( w_dist_sig				),
	// 	.o_dist_angle1 					( w_dist_angle1				),
	// 	.o_dist_angle2 					( w_dist_angle2				)
	// );

	calib_packet 
	#(
		.PACKET_DOT_NUM					( PACKET_DOT_NUM			)
	)		
	u_calib_data	
	(	
		.i_clk    						( i_clk						),
		.i_rst_n      					( i_rst_n					),

		.i_measure_en					( 1'b1						),
		.i_newsig_sync					( i_tdcsig_sync				),
		.i_code_angle1 					( i_code_angle1				),
		.i_tdc_lasernum					( i_tdc_lasernum			),
		.i_rise_data					( i_tdcdata_rise			),
		.i_fall_data					( i_tdcdata_fall			),

		.i_start_index					( i_start_index				),
		.i_stop_index					( i_stop_index				),
		.i_reso_mode					( i_reso_mode				),
		.i_calibrate_flag				( i_calibrate_flag			),
		.i_cali_pointnum				( i_cali_pointnum			),
		.i_busy							( i_busy					),

		.o_calib_pingpang				( o_calib_pingpang			),
		.o_calib_wrdata					( o_calib_wrdata			),
		.o_calib_wraddr					( o_calib_wraddr			),
		.o_calib_wren					( o_calib_wren				),

		.o_calib_make					( o_calib_make				),
		.o_calib_points					( o_calib_points			),
		.o_calib_cycle_done				( o_calib_cycle_done		)				
	);

	loop_packet 
	#(
		.PACKET_DOT_NUM					( PACKET_DOT_NUM			)
	)		
	u_loop_packet	
	(	
		.i_clk    						( i_clk						),
		.i_rst_n      					( i_rst_n					),
	
		.i_measure_en					( 1'b1						),
		.i_newsig_sync					( i_tdcsig_sync				),
		.i_code_angle1 					( i_code_angle1				),
		.i_code_angle2					( i_code_angle2				),
		.i_tdc_lasernum					( i_tdc_lasernum			),
		.i_rise_data					( i_tdcdata_rise			),
		.i_fall_data					( i_tdcdata_fall			),
		.i_dist_data					( w_dist_data				),
		.i_rssi_data					( w_rssi_data				),
	
		.i_start_index					( i_start_index				),
		.i_stop_index					( i_stop_index				),
		.i_reso_mode					( i_reso_mode				),
		.i_loopdata_flag				( i_loopdata_flag			),
		.i_busy							( i_busy					),
	
		.o_loop_pingpang				( o_loop_pingpang			),
		.o_loop_wrdata					( o_loop_wrdata				),
		.o_loop_wraddr					( o_loop_wraddr				),
		.o_loop_wren					( o_loop_wren				),
	
		.o_loop_make					( o_loop_make				),
		.o_loop_points					( o_loop_points				),
		.o_loop_cycle_done				( o_loop_cycle_done			)				
	);
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------	
	assign o_code_angle = w_dist_angle1;
endmodule 