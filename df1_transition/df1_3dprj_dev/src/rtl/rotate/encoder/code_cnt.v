//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: code_cnt
// Date Created 	: 2024/11/6 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
// File description	:code_cnt
//--------------------------------------------------------------------------------------------------
// Revision History :V1.0
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------	
module code_cnt
(
	input				i_clk,
	input				i_rst_n,

	input				i_motor_state,
	input				i_zero_sign,
	input				i_opto_rise,

	output [6:0]		o_code_wraddr,
	output [31:0]		o_code_wrdata,
	output				o_code_wren			
);
    //----------------------------------------------------------------------------------------------
	// parameter and localparam define
	//----------------------------------------------------------------------------------------------
	localparam ST_IDLE				= 8'b0000_0000;
    localparam ST_WAIT_STABLE       = 8'b0000_0001;
	localparam ST_READY				= 8'b0000_0010;
	localparam ST_OPTO_CYCRISE		= 8'b0000_0100;
	localparam ST_WRISE_RAM		    = 8'b0000_1000;

	//--------------------------------------------------------------------------------------------------
	//	reg define
	//--------------------------------------------------------------------------------------------------
	reg  [7:0]		r_code_state            = 8'h0;
	reg  [1:0]		r_zero_sign				= 2'b00;
	reg 			r_code_wren				= 1'b0;
	reg	 [6:0] 		r_code_wraddr 			= 7'd0;
	reg  [31:0] 	r_code_wrdata			= 32'h0;
	reg  [31:0]		r_code_clkcnt           = 32'd0;
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------			
    //--------------------------------------------------------------------------------------------------
    // FSM(finite-state machine)
    //--------------------------------------------------------------------------------------------------
	//r_zero_sign
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_zero_sign	<= 2'b00;
		else 
			r_zero_sign	<= {r_zero_sign[0], i_zero_sign};
	end

	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_code_wren		<= 1'b0;
			r_code_wraddr	<= 7'd0;
			r_code_wrdata	<= 32'd0;
			r_code_clkcnt	<= 32'd0;
            r_code_state	<= ST_IDLE;
		end else begin
			case(r_code_state)
				ST_IDLE: begin
                    r_code_wren		<= 1'b0;
			        r_code_wraddr	<= 7'd0;
			        r_code_wrdata	<= 32'd0;
			        r_code_clkcnt	<= 32'd0;
					if(i_motor_state)
                        r_code_state    <= ST_READY;
                    else
                        r_code_state    <= ST_IDLE;
				end
				ST_READY: begin
					r_code_wren		<= 1'b0;
					r_code_wraddr	<= 7'd0;
					r_code_wrdata	<= 32'd0;
					r_code_clkcnt	<= 32'd0;
					if(i_zero_sign || r_zero_sign[1])
						r_code_state	<= ST_OPTO_CYCRISE;
					else
						r_code_state	<= ST_READY;
				end
				ST_OPTO_CYCRISE: begin
					r_code_clkcnt	<= r_code_clkcnt + 1'b1;
					if(i_opto_rise) begin
                        r_code_wren		<= 1'b1;
                        r_code_wrdata	<= r_code_clkcnt;
						r_code_clkcnt	<= 32'd0;
						r_code_state	<= ST_WRISE_RAM;
					end else begin
						r_code_state        <= ST_OPTO_CYCRISE;
					end
				end
				ST_WRISE_RAM: begin
					r_code_wren	<= 1'b0;
					if(r_code_wraddr <= 7'd97) begin
						r_code_wraddr	<= r_code_wraddr + 1'b1;
						r_code_state		<= ST_OPTO_CYCRISE;
					end else begin
						r_code_state    <= ST_READY;
					end
				end
				default:;
			endcase
		end
	end
    //--------------------------------------------------------------------------------------------------
	// output assign domain
	//--------------------------------------------------------------------------------------------------			
	assign  o_code_wraddr 	= r_code_wraddr;
	assign  o_code_wrdata 	= r_code_wrdata;
	assign  o_code_wren 	= r_code_wren;

endmodule