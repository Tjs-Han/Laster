// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: encoder_control
// Date Created 	: 2025/05/14 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------
// File description	:encoder_control
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module encoder_control
#(
    parameter SEC2NS_REFVAL	= 1000_000_000,
	parameter CLK_PERIOD_NS	= 10,
    parameter MOTOR_FREQ    = 100,
    parameter TOOTH_NUM     = 100
)
(
	input			    i_clk,
	input			    i_rst_n,

	input			    i_cal_mode,
	input			    i_code_sigin,
	input			    i_motor_state,
	input  [3:0]	    i_reso_mode,//0 = 0.1  1 = 0.05  2 = 0.33
	input  [15:0]	    i_angle_offset,

	output [6:0]	    o_code_wraddr,
	output [31:0]	    o_code_wrdata,
	output			    o_code_wren,

	input			    i_angle_sync,
	output [15:0]	    o_code_angle
);
    //----------------------------------------------------------------------------------------------
	//	wire define
	//----------------------------------------------------------------------------------------------
    wire                w_opto_switch;
	wire          	    w_opto_rise;
    wire                w_zero_sign;
	//----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
    opto_switch #(            
        .SEC2NS_REFVAL      ( SEC2NS_REFVAL             ),       
        .CLK_PERIOD_NS      ( CLK_PERIOD_NS             ),       
        .TOOTH_NUM			( TOOTH_NUM					),
        .MOTOR_FREQ         ( MOTOR_FREQ                )
    )
    u1_opto_switch
    (
        .i_clk    	        ( i_clk					    ),
        .i_rst_n      	    ( i_rst_n					),

		.i_cal_mode			( i_cal_mode				),
        .i_code_sigin	    ( i_code_sigin				),

        .o_opto_switch	    ( w_opto_switch				) 
    );

    encoder_calculate u2_encoder_calculate
    (
        .i_clk    		    ( i_clk					    ),
        .i_rst_n      		( i_rst_n					),
        
        .i_opto_switch		( w_opto_switch				),
        
        .o_zero_sign		( w_zero_sign				),
        .o_opto_rise		( w_opto_rise				)
    );

    code_angle #( 
        .SEC2NS_REFVAL      ( SEC2NS_REFVAL             ),       
        .CLK_PERIOD_NS      ( CLK_PERIOD_NS             ),                         
        .TOOTH_NUM			( TOOTH_NUM					),
        .MOTOR_FREQ         ( MOTOR_FREQ                ) 
    )
	u3_code_angle
    (
        .i_clk    		    ( i_clk					    ),
        .i_rst_n      		( i_rst_n					),
        
        .i_zero_sign		( w_zero_sign				),
        .i_opto_rise		( w_opto_rise				),
        .i_angle_sync       ( i_angle_sync              ),

        .o_code_angle       ( o_code_angle              )
    );

    code_cnt u5_code_cnt
    (
        .i_clk    		    ( i_clk                     ),//100m时钟信号
        .i_rst_n      		( i_rst_n           		),//复位信号，低有效
        
		.i_motor_state		( i_motor_state				),
        .i_zero_sign		( w_zero_sign       		),//码盘零点信号
        .i_opto_rise		( w_opto_rise       		),//码盘上升沿信号

        .o_code_wraddr		( o_code_wraddr     		),
        .o_code_wrdata		( o_code_wrdata     		),
        .o_code_wren		( o_code_wren       		)
    );
    //----------------------------------------------------------------------------------------------
	// output assign
	//----------------------------------------------------------------------------------------------		
endmodule