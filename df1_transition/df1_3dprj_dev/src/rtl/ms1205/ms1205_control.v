// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: ms1205_control
// Date Created 	: 2023/08/15 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:ms1205_control
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module ms1205_control
(
	input				i_clk_50m,
	input				i_rst_n,
	
	input				i_angle_sync,
	input				i_motor_state,
	input  [15:0]		i_code_angle/*synthesis PAP_MARK_DEBUG="true"*/,
	
	input  [1:0]		i_tdc_init,
	input  [1:0]		i_tdc_spi_miso,
	output [1:0]		o_tdc_spi_mosi,
	output [1:0]		o_tdc_spi_ssn,
	output [1:0]		o_tdc_spi_clk,
	output [1:0]		o_tdc_reset,

	output [15:0]		o_rise_data,
	output [15:0]		o_fall_data,
	output				o_tdc_err_sig,
	output				o_tdc_new_sig,
	output [15:0]		o_code_angle_tdc
);
	//--------------------------------------------------------------------------------------------------
	// wire define
	//--------------------------------------------------------------------------------------------------
	wire [15:0]			w_rise_data;
	wire				w_tdc_err_sig_rise;
	wire				w_tdc_new_sig_rise;

	wire [15:0]			w_fall_data;
	wire				w_tdc_err_sig_fall;
	wire				w_tdc_new_sig_fall;
	
	

	ms1205_control_rise u1_ms1205_control_rise
	(
		.i_clk_50m    		( i_clk_50m				),
		.i_rst_n      		( i_rst_n				),
			
		.i_angle_sync 		( i_angle_sync			),
		.i_motor_state		( i_motor_state			),
	
		.i_tdc_init 		( i_tdc_init[0]			),
		.i_tdc_spi_miso		( i_tdc_spi_miso[0]		),
		.o_tdc_spi_mosi		( o_tdc_spi_mosi[0]		),
		.o_tdc_spi_ssn 		( o_tdc_spi_ssn[0]		),
		.o_tdc_spi_clk 		( o_tdc_spi_clk[0]		),
		.o_tdc_reset   		( o_tdc_reset[0]		),

		.o_rise_data		( w_rise_data			),
		.o_tdc_err_sig		( w_tdc_err_sig_rise	),
		.o_tdc_new_sig		( w_tdc_new_sig_rise	)
	);
	
	ms1205_control_fall u2_ms1205_control_fall
	(
		.i_clk_50m    		( i_clk_50m				),
		.i_rst_n      		( i_rst_n				),
			
		.i_angle_sync 		( i_angle_sync			),
		.i_motor_state		( i_motor_state			),
	
		.i_tdc_init 		( i_tdc_init[1]			),
		.i_tdc_spi_miso		( i_tdc_spi_miso[1]		),
		.o_tdc_spi_mosi		( o_tdc_spi_mosi[1]		),
		.o_tdc_spi_ssn 		( o_tdc_spi_ssn[1]		),
		.o_tdc_spi_clk 		( o_tdc_spi_clk[1]		),
		.o_tdc_reset   		( o_tdc_reset[1]		),

		.o_fall_data		( w_fall_data			),
		.o_tdc_err_sig		( w_tdc_err_sig_fall	),
		.o_tdc_new_sig		( w_tdc_new_sig_fall	)
	);

	ms1205_data u3_ms1205_data
	(
		.i_clk_50m    		( i_clk_50m				),
		.i_rst_n      		( i_rst_n				),
			
		.i_angle_sync 		( i_angle_sync			),
		.i_motor_state		( i_motor_state			),
		.i_code_angle 		( i_code_angle			),
		
		.i_rise_err_sig		( w_tdc_err_sig_rise	),
		.i_fall_err_sig		( w_tdc_err_sig_fall	),
		.i_rise_new_sig		( w_tdc_new_sig_rise	),
		.i_fall_new_sig		( w_tdc_new_sig_fall	),
	
		.i_rise_data		( w_rise_data			),
		.i_fall_data		( w_fall_data			),
		
		.o_rise_data		( o_rise_data			),
		.o_fall_data		( o_fall_data			),
		.o_tdc_err_sig		( o_tdc_err_sig			),
		.o_tdc_new_sig		( o_tdc_new_sig			),
		.o_code_angle_tdc 	( o_code_angle_tdc		)
	);
endmodule 