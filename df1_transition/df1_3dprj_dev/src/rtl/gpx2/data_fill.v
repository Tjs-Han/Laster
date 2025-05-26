// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: jun gu
// Filename 		: data_fill
// Date Created 	: 2024/12/2 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:data_fill
//              if the TDC cannot measure the data, fill data is all 0
//              It is important to note the timing relationship between the output signal and the output Angle value
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module data_fill
(
	input				    i_clk,
	input				    i_rst_n,
    
    input                   i_tdcmodule_en,
	input				    i_angle_sync,
	input				    i_tdcsync_ready,
    input  [15:0]           i_code_angle1,
	input  [15:0]           i_code_angle2,
	input				    i_tdc_newsig,
	input  [31:0]	        i_rise_data,
	input  [31:0]	        i_fall_data,
    
	output					o_filldata_sig,
    output [15:0]           o_code_angle1,
	output [15:0]           o_code_angle2,
	output				    o_tdc_newsig,
	output [31:0]	        o_rise_data,
	output [31:0]	        o_fall_data				
);
	//--------------------------------------------------------------------------------------------------
	//localparam and parameter define
	//--------------------------------------------------------------------------------------------------
	localparam	ST_IDLE	        = 8'b0000_0000,
				ST_READY	    = 8'b0000_0001,
                ST_WAIT	        = 8'b0000_0010,
				ST_DLY	        = 8'b0000_0100,
                ST_DATA_FILL    = 8'b0000_1000,
                ST_OVER	        = 8'b0001_0000,
				ST_END	        = 8'b0010_0000;	
	//--------------------------------------------------------------------------------------------------
	// reg define
	//--------------------------------------------------------------------------------------------------
	reg				r_filldata_sig	= 1'b0;
	reg				r_tdc_newsig	= 1'b0;
	reg [31:0]		r_rise_data		= 32'd0;
	reg [31:0]		r_fall_data		= 32'd0;

	reg [7:0]		r_fill_state	= 8'h0;
	reg [15:0]		r_fill_delay	= 16'd0;
	reg [11:0]		r_fill_cnt		= 12'd0;

    reg [15:0]      r_code_angle1   = 16'd0;
	reg [15:0]      r_code_angle2   = 16'd0;
    reg             r_tdc_new_false = 1'b0;
    //----------------------------------------------------------------------------------------------
    // FSM(finite-state machine)
    //----------------------------------------------------------------------------------------------				
	always@(posedge i_clk, negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_filldata_sig	<= 1'b0;
			r_tdc_newsig	<= 1'b0;
            r_code_angle1   <= 16'd0;
			r_code_angle2   <= 16'd0;
			r_rise_data		<= 32'd0;
			r_fall_data		<= 32'd0;
			r_fill_delay	<= 16'd0;
			r_fill_cnt		<= 12'd0;
			r_fill_state	<= ST_IDLE;
		end else begin
			case(r_fill_state)
                ST_IDLE: begin
					r_filldata_sig	<= 1'b0;
                    r_tdc_newsig	<= 1'b0;
                    r_code_angle1   <= 16'd0;
					r_code_angle2   <= 16'd0;
			        r_rise_data		<= 32'd0;
			        r_fall_data		<= 32'd0;
			        r_fill_delay	<= 16'd0;
			        r_fill_cnt		<= 12'd0;
                    if(i_tdcmodule_en) 
                        r_fill_state	<= ST_READY;
                    else
                        r_fill_state	<= ST_IDLE;
                end
				ST_READY: begin
					r_filldata_sig	<= 1'b0;
                    r_tdc_newsig	<= 1'b0;
					if(i_angle_sync && i_tdcsync_ready) begin
						r_fill_cnt		<= 12'd0;
						r_fill_state	<= ST_WAIT;
					end else if(i_angle_sync)
						r_fill_state	<= ST_DLY;
					else
						r_fill_state	<= ST_READY;
				end
				ST_WAIT: begin
                    r_tdc_newsig	<= 1'b0;
					if(i_tdc_newsig)begin
                        r_code_angle1   <= i_code_angle1;
						r_code_angle2   <= i_code_angle2;
						r_rise_data		<= i_rise_data;
						r_fall_data		<= i_fall_data;
						r_fill_state	<= ST_OVER;
					end else if(r_fill_cnt >= 12'd150) begin
						r_fill_cnt		<= 12'd0;
						r_fill_state	<= ST_DATA_FILL;
					end else begin
						r_fill_cnt		<= r_fill_cnt + 1'b1;
						r_fill_state	<= ST_WAIT;
					end	
				end
				ST_DLY: begin
					if(r_fill_delay	>= 12'd80)begin
						r_fill_delay	<= 16'd0;
						r_fill_state	<= ST_DATA_FILL;
					end else begin
						r_fill_delay	<= r_fill_delay + 1'b1;
						r_fill_state	<= ST_DLY;
					end
				end
                ST_DATA_FILL: begin
					r_filldata_sig	<= 1'b1;
                    r_code_angle1   <= i_code_angle1;
					r_code_angle2   <= i_code_angle2;
                    r_rise_data		<= 32'd0;
					r_fall_data		<= 32'd0;
                    r_fill_state	<= ST_OVER;
                end
				ST_OVER: begin
					r_filldata_sig	<= 1'b0;
					r_fill_state	<= ST_END;
				end
				ST_END: begin
					r_tdc_newsig	<= 1'b1;
					r_fill_state	<= ST_READY;
				end
				default: begin
					r_tdc_newsig	<= 1'b0;
					r_rise_data		<= 32'd0;
					r_fall_data		<= 32'd0;
					r_fill_delay	<= 16'd0;
					r_fill_state	<= ST_IDLE;
				end
			endcase
		end
	end
 	//----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	// assign      o_filldata_sig	= r_filldata_sig;
	assign      o_filldata_sig	= 1'b0;
    assign		o_tdc_newsig	= r_tdc_newsig;
    assign      o_code_angle1   = r_code_angle1;
	assign      o_code_angle2   = r_code_angle2;
	assign		o_rise_data		= r_rise_data;
	assign		o_fall_data		= r_fall_data;

endmodule 