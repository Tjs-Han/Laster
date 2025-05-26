// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: code_angle
// Date Created 	: 2025/05/15
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------
// File description	:code_angle
// -------------------------------------------------------------------------------------------------
// Revision History :V1.1
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module code_angle
#(  
    parameter SEC2NS_REFVAL	= 1000_000_000,
	parameter CLK_PERIOD_NS	= 10,
	parameter TOOTH_NUM     = 8'd100,
    parameter MOTOR_FREQ	= 100
)
(
	input			    i_clk,
	input			    i_rst_n,
    
	input			    i_zero_sign,
	input			    i_opto_rise,
    input			    i_angle_sync,
    output [15:0]       o_code_angle
);
    //----------------------------------------------------------------------------------------------
	// parameter and localparam define
	//----------------------------------------------------------------------------------------------
    localparam NORMAL_TOOTH_CLKNUM      = SEC2NS_REFVAL/CLK_PERIOD_NS/MOTOR_FREQ/TOOTH_NUM;
    localparam ST_IDLE                  = 4'd0;
    localparam ST_READY                 = 4'd1;
    localparam ST_CALPRE                = 4'd2;
    localparam ST_WAIT_MULCAL           = 4'd3;
    localparam ST_DIVIDER               = 4'd4;
    localparam ST_WAIT_DIVCAL           = 4'd5;
    localparam ST_CAL_DONE              = 4'd6;
    //----------------------------------------------------------------------------------------------
	// reg signal define
	//----------------------------------------------------------------------------------------------
    reg  [3:0]          r_angle_state           = ST_IDLE;
    reg  [7:0]          r_code_sernum           = 8'd0;
    reg  [15:0]         r_code_clkcnt           = 16'd0;
    reg  [15:0]         r_code_clknum           = NORMAL_TOOTH_CLKNUM;
    reg  [23:0]         r_cycle_clkcnt          = 24'd0;
    reg  [23:0]         r_laser_clktime         = 24'd0;
    reg  [7:0]          r_dly_clkcnt            = 8'd0;
    reg  [9:0]          r_mult1_dataA           = 10'd0;
    reg  [23:0]         r_mult1_dataB           = 24'd0;
    wire [33:0]         w_mult1_result;
    reg                 r_divider_en            = 1'b0;
    reg  [33:0]         r_divider_num           = 34'd0;
    reg  [15:0]         r_divider_den           = NORMAL_TOOTH_CLKNUM;
    wire                w_divider_caldone;
    wire [33:0]         w_divider_quo;
    reg  [15:0]         r_code_angle            = 16'd0;
    //----------------------------------------------------------------------------------------------
	// calculate output angle
	//----------------------------------------------------------------------------------------------
    // r_code_sernum
    always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n) begin
            r_code_sernum   <= 8'd0;
        end else if(i_zero_sign) begin
            r_code_sernum   <= 8'd0;
        end else if(i_opto_rise) begin  
            r_code_sernum   <= r_code_sernum + 1'b1;
        end 
    end

    //r_code_clkcnt
    always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n) begin
            r_code_clkcnt   <= 16'd0;
        end else if(i_opto_rise) begin
            r_code_clkcnt   <= 16'd0;
        end else begin  
            r_code_clkcnt   <= r_code_clkcnt + 1'b1;
        end 
    end

    //r_code_clknum
    always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n) begin
            r_code_clknum   <= NORMAL_TOOTH_CLKNUM;
        end else if(i_opto_rise) begin
            r_code_clknum   <= r_code_clkcnt;
        end else begin  
            r_code_clknum   <= r_code_clknum;
        end 
    end

    //r_cycle_clkcnt
    always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n) begin
            r_cycle_clkcnt  <= 24'd0;
        end else if(i_zero_sign) begin
            r_cycle_clkcnt  <= 24'd0;
        end else begin  
            r_cycle_clkcnt  <= r_cycle_clkcnt + 1'b1;
        end 
    end

    //r_laser_clktime
    always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n) begin
            r_laser_clktime <= 24'd0;
        end else if(i_angle_sync) begin
            r_laser_clktime <= r_cycle_clkcnt;
        end else begin  
            r_laser_clktime <= r_laser_clktime;
        end 
    end

    //----------------------------------------------------------------------------------------------
	// state machine
	//----------------------------------------------------------------------------------------------
    always@(posedge i_clk or negedge i_rst_n)begin
        if(i_rst_n == 0)begin
            r_mult1_dataA   <= 10'd0;
            r_mult1_dataB   <= 24'd0;
            r_divider_en    <= 1'b0;
            r_divider_num   <= 34'd0;
            r_divider_den   <= NORMAL_TOOTH_CLKNUM;
            r_code_angle    <= 16'd0;
            r_angle_state   <= ST_IDLE;
        end else begin
            case(r_angle_state)
                ST_IDLE: begin
                    r_mult1_dataA   <= 10'd0;
                    r_mult1_dataB   <= 24'd0;
                    r_divider_en    <= 1'b0;
                    r_divider_num   <= 34'd0;
                    r_divider_den   <= NORMAL_TOOTH_CLKNUM;
                    r_code_angle    <= 16'd0;
                    r_angle_state   <= ST_READY;
                end
                ST_READY: begin
                    if(i_angle_sync)
                        r_angle_state   <= ST_CALPRE;
                    else
                        r_angle_state   <= ST_READY;
                end
                ST_CALPRE: begin
                    r_angle_state   <= ST_WAIT_MULCAL;
                    r_divider_den   <= r_code_clknum;
                    r_mult1_dataB   <= r_laser_clktime;
                    if(r_code_sernum == 8'd0) begin
                        r_mult1_dataA   <= 10'd720;
                    end else begin
                        r_mult1_dataA   <= 10'd360;
                    end
                end
                ST_WAIT_MULCAL: begin
                    if(r_dly_clkcnt >= 8'd8) begin
                        r_angle_state   <= ST_DIVIDER;
                    end else begin
                        r_angle_state   <= ST_WAIT_MULCAL;
                    end
                end
                ST_DIVIDER: begin
                    r_divider_en    <= 1'b1;
                    r_divider_num   <= w_mult1_result[31:0];
                    r_angle_state   <= ST_WAIT_DIVCAL;
                end
                ST_WAIT_DIVCAL: begin
                    r_divider_en    <= 1'b0;
                    if(w_divider_caldone) begin
                        r_code_angle    <= w_divider_quo[15:0];
                        r_angle_state   <= ST_CAL_DONE;
                    end else begin
                        r_code_angle    <= r_code_angle;
                        r_angle_state   <= ST_WAIT_DIVCAL;
                    end
                end
                ST_CAL_DONE: begin
                    r_divider_en    <= 1'b0;
                    r_angle_state   <= ST_READY;
                end
                default:;
            endcase
        end
    end

    //r_dly_clkcnt
    always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n) begin
            r_dly_clkcnt  <= 8'd0;
        end else if(r_angle_state == ST_WAIT_MULCAL) begin
            r_dly_clkcnt  <= r_dly_clkcnt + 1'b1;
        end else begin  
            r_dly_clkcnt  <= 8'd0;
        end 
    end 
    //----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
	multiplier_10x32 u1_multiplier_10x32
	(
		.Clock				( i_clk					), 
		.ClkEn				( 1'b1                  ), 
		
		.Aclr				( 1'b0					), 
		.DataA				( r_mult1_dataA			), // input [9:0]
		.DataB				( r_mult1_dataB			), // input [23:0]
		.Result				( w_mult1_result        )  // output [33:0]
	);
    
    // divider_34x16 u_divider_34x16
    // (
    //     .clk                ( i_clk                 ),
    //     .rstn               ( i_rst_n               ),
    //     //--------input 
    //     .dvalid_in          ( r_divider_en          ),
    //     .numerator          ( r_divider_num         ),
    //     .denominator        ( r_divider_den         ),
    //     //--------output    
    //     .dvalid_out         ( w_divider_caldone     ),
    //     .quotient           ( w_divider_quo         ),
    //     .remainder          (                       )
    // );

    divider_32_16bit u_divider_code
	(
		.i_clk				( i_clk                 ),
		.i_rst_n			( i_rst_n				),

		.i_start			( r_divider_en			),
		.i_dividend			( r_divider_num		    ),
		.i_divisor			( r_divider_den			),
		.o_quotient			( w_divider_quo			),
		.o_done				( w_divider_caldone     ),
		.o_div0				(   				    )
	);
    //----------------------------------------------------------------------------------------------
	// output assign
	//----------------------------------------------------------------------------------------------
    assign o_code_angle = r_code_angle;

endmodule