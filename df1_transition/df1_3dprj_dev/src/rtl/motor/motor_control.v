// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: motor_control
// Date Created 	: 2024/9/2 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:motor_control
//				Drive motor rotation and Monitor motor running status
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------

module motor_control
#(
	parameter DEJTER_CLK_CNT	= 500
)
(
	input						i_clk_50m,
	input						i_rst_n,
	
	input  [1:0]				i_motor_sw,
	input   					i_motor_fg1,
	input   					i_motor_rd1,
    input  [15:0]				i_freq_motor1,
	input  [15:0]				i_motor_pwm_setval1,
	input   					i_motor_fg2,
	input   					i_motor_rd2,
	input  [15:0]				i_freq_motor2,
	input  [15:0]				i_motor_pwm_setval2,


	output  					o_motor_pwm1,
	output [15:0]				o_motor_state1,
	output [15:0]				o_pwm_value1,
	output [31:0]				o_actual_speed1,
	output  					o_motor_pwm2,
	output [15:0]				o_motor_state2,
	output [15:0]				o_pwm_value2,
	output [31:0]				o_actual_speed2,

	output						o_gpx2_measure_en
);
	//--------------------------------------------------------------------------------------------------
	// wire define
	//--------------------------------------------------------------------------------------------------
	wire						w_motor_fg1;
	wire						w_motor_fg2;
	//--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
	localparam HIGN_SPEED_MOTOR	= 4'h1;
	localparam LOW_SPEED_MOTOR	= 4'h2;
	//--------------------------------------------------------------------------------------------------
	// inst domain
	//--------------------------------------------------------------------------------------------------
	signal_dejitter	
	#(
		.DEJTER_CLK_CNT			( DEJTER_CLK_CNT			)
	)
	u0_signal_dejitter		
	(		
        .i_clk_50m				( i_clk_50m					),
        .i_rst_n				( i_rst_n					),
		.i_signal				( i_motor_fg1				),

		.o_signal				( w_motor_fg1				)
	);

	signal_dejitter	
	#(
		.DEJTER_CLK_CNT			( DEJTER_CLK_CNT			)
	)
	u1_signal_dejitter		
	(		
        .i_clk_50m				( i_clk_50m					),
        .i_rst_n				( i_rst_n					),
		.i_signal				( i_motor_fg2				),

		.o_signal				( w_motor_fg2				)
	);

	motor_drive u1_motor_drive(
		.i_clk_50m				( i_clk_50m					),
		.i_rst_n				( i_rst_n					),

		.i_motor_sw				( i_motor_sw[0]				),
		.i_motor_type			( HIGN_SPEED_MOTOR			),
		.i_freq_motor			( i_freq_motor1				),
		.i_motor_fg				( w_motor_fg1				),
		.i_motor_pwm_setval		( i_motor_pwm_setval1		),

		.o_motor_state			( o_motor_state1			),
		.o_pwm_value			( o_pwm_value1				),
		.o_actual_speed			( o_actual_speed1			),
		.o_motor_pwm			( o_motor_pwm1				)
    );

	motor_drive u2_motor_drive(
		.i_clk_50m				( i_clk_50m					),
		.i_rst_n				( i_rst_n					),

		.i_motor_sw				( i_motor_sw[1]				),
		.i_motor_type			( LOW_SPEED_MOTOR			),
		.i_freq_motor			( i_freq_motor2				),
		.i_motor_fg				( w_motor_fg2				),
		.i_motor_pwm_setval		( i_motor_pwm_setval2		),

		.o_motor_state			( o_motor_state2			),
		.o_pwm_value			( o_pwm_value2				),
		.o_actual_speed			( o_actual_speed2			),
		.o_motor_pwm			( o_motor_pwm2				)
    );
	assign o_gpx2_measure_en = 1'b1;
endmodule 