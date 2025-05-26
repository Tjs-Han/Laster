// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: rotate_control
// Date Created 	: 2025/05/14 
// Version 			: V1.1
// -------------------------------------------------------------------------------------------------
// File description	:rotate control module
//				3D lidar synchronization control signal and Angle value calculated
//				Include Code disk and photoelectric signal processing module
//				Output the radar's optical synchronization control signal(o_angle_sync) and the Angle value 
//				calculated based on the code disk(o_code_angle)
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
//			2D lidar encode 
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//				It should be noted that the motor module control function is not used 
//				for the time being 
//--------------------------------------------------------------------------------------------------
module rotate_control
#(
    parameter SEC2NS_REFVAL			= 1000_000_000,
	parameter CLK_PERIOD_NS			= 10,
	parameter OPTO_FREQ     		= 32'd300_000,
    parameter MOTOR1_FREQ    		= 71,
	parameter MOTOR2_FREQ    		= 60,
    parameter TOOTH_NUM     		= 100
)
(
	input						i_clk,
	input						i_rst_n,

	input						i_code_sigin1,
	input						i_code_sigin2,
	input  [1:0]				i_calib_mode,
	input			    		i_motor_state1,
	input			    		i_motor_state2,
	input  [3:0]				i_reso_mode,
	input  [15:0]				i_angle_offset1,
	input  [15:0]				i_angle_offset2,

	output						o_code_wren1,
	output [6:0]				o_code_wraddr1,
	output [31:0]				o_code_wrdata1,
	output						o_code_wren2,
	output [6:0]				o_code_wraddr2,
	output [31:0]				o_code_wrdata2,
	
	output [15:0]				o_code_angle1,
	output [15:0]				o_code_angle2,
	output						o_angle_sync,
	output						o_tdc_strdy,
	output [1:0]    			o_codesig_monit1,
	output [1:0]    			o_codesig_monit2
);		
    //----------------------------------------------------------------------------------------------
	//	reg and wire define
	//----------------------------------------------------------------------------------------------
	reg							r_sync_ready 	= 1'b0;
	wire						w_code_sigin1;
	wire						w_code_sigin2;
    //----------------------------------------------------------------------------------------------
	/*	
		r_sync_ready
		Signal Replication for Fan-Out Reduction
	*/
	//----------------------------------------------------------------------------------------------
    always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0) begin
            r_sync_ready	<= 1'b0;
        end else if(i_motor_state1 && i_motor_state2) begin
            r_sync_ready	<= 1'b1;
        end else begin
            r_sync_ready	<= 1'b0;
        end 
    end
	//----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
	opto_signal_dejitter u0_opto_signal_dejitter
	(
		.i_clk    			( i_clk						),
		.i_rst_n      		( i_rst_n					),

		.i_opto_signal		( i_code_sigin1				),
		.o_opto_signal		( w_code_sigin1				)
	);	

	opto_signal_dejitter u1_opto_signal_dejitter
	(
		.i_clk    			( i_clk						),
		.i_rst_n      		( i_rst_n					),

		.i_opto_signal		( i_code_sigin2				),
		.o_opto_signal		( w_code_sigin2				)
	);

	opto_emiperiod_cal #( 
        .SEC2NS_REFVAL      ( SEC2NS_REFVAL             ),       
        .CLK_PERIOD_NS      ( CLK_PERIOD_NS             ), 
        .OPTO_FREQ          ( OPTO_FREQ                 )
    )    
    u2_opto_emiperiod_cal
    (
        .i_clk    		    ( i_clk					    ),
        .i_rst_n      		( i_rst_n					),

        .i_sync_ready		( r_sync_ready				),
        .o_angle_sync		( o_angle_sync				),
        .o_tdc_strdy        ( o_tdc_strdy				)
    );

	encoder_control #(            
        .SEC2NS_REFVAL      ( SEC2NS_REFVAL				),       
        .CLK_PERIOD_NS      ( CLK_PERIOD_NS				),       
        .TOOTH_NUM			( TOOTH_NUM					),
        .MOTOR_FREQ         ( MOTOR1_FREQ				)
    )
	u3_encoder_control
	(
		.i_clk    			( i_clk						),
		.i_rst_n      		( i_rst_n					),

		.i_cal_mode   		( i_calib_mode[0]			),
		.i_code_sigin		( w_code_sigin1				),
		.i_motor_state		( i_motor_state1			),
		.i_reso_mode  		( i_reso_mode				),
		.i_angle_offset		( i_angle_offset1			),	

		.o_code_wren		( o_code_wren1				),
		.o_code_wraddr		( o_code_wraddr1			),
		.o_code_wrdata		( o_code_wrdata1			),

		.i_angle_sync 		( o_angle_sync				),
		.o_code_angle		( o_code_angle1				)
	);	
	
	encoder_control #(            
        .SEC2NS_REFVAL      ( SEC2NS_REFVAL             ),       
        .CLK_PERIOD_NS      ( CLK_PERIOD_NS             ),       
        .TOOTH_NUM			( TOOTH_NUM					),
        .MOTOR_FREQ         ( MOTOR2_FREQ				)
    )
	u4_encoder_control
	(
		.i_clk    			( i_clk						),
		.i_rst_n      		( i_rst_n					),

		.i_cal_mode   		( i_calib_mode[1]			),
		.i_code_sigin		( w_code_sigin2				),
		.i_motor_state		( i_motor_state2			),
		.i_reso_mode  		( i_reso_mode				),
		.i_angle_offset		( i_angle_offset2			),	

		.o_code_wren		( o_code_wren2				),
		.o_code_wraddr		( o_code_wraddr2			),
		.o_code_wrdata		( o_code_wrdata2			),
		
		.i_angle_sync 		( o_angle_sync				),
		.o_code_angle		( o_code_angle2				)
	);

endmodule 