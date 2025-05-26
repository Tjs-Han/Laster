//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: index_cal
// Date Created 	: 2024/2/4 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
// File description	:index_cal
//				coe parameter cache in DDR, last round is cache in SRAM
//				SRAM addr cache two byte, DDR addr cache one byte
//				nocation coe addr
//--------------------------------------------------------------------------------------------------
// Revision History :V1.0
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------	
module index_cal
(
	input					i_clk,
	input					i_rst_n,

	input  [31:0]			i_rise_data,
	input  [31:0]			i_pulse_data,

	input					i_dist_precal_sig,
	input  [15:0]			i_dist_precal_angle1,
	input  [15:0]			i_dist_precal_angle2,
	input  [31:0]			i_rise_divid,
	input  [31:0]			i_pulse_start,
	input  [31:0]			i_pulse_divid,

	//fifo
	input					i_indfifo_rden,
	output [87:0]			o_indfifo_rdata,
	output					o_indfifo_empty,
	output					o_indfifo_full

);
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
	localparam MAX_RISE_VAULE		= 32'd98304; //45m incr=200ns/65536
	localparam ST_IDLE				= 8'b0000_0000,
			   ST_RISE_PRE			= 8'b0000_0001,
			   ST_RISE_INDEX		= 8'b0000_0010,
			   ST_PULSE_PRE			= 8'b0000_0100,
			   ST_PULSE_INDEX1		= 8'b0000_1000,
			   ST_PULSE_INDEX2		= 8'b0001_0000,
			   ST_CAL_PULSERE		= 8'b0010_0000,
			   ST_INDEX_CALDONE		= 8'b0100_0000,
			   ST_INDEX_END			= 8'b1000_0000;
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
	reg  [7:0]		r_index_state 		= ST_IDLE;	
	reg  [3:0]		r_index_flag		= 4'd0;
	reg  [15:0]		r_index_angle1		= 16'd0;
	reg  [15:0]		r_index_angle2		= 16'd0;
	reg  [15:0]		r_rise_index		= 16'd0;
	reg  [31:0]		r_rise_remain		= 32'd0;
	reg  [15:0]		r_pulse_index		= 16'd0;
	reg  [15:0]		r_pulse_index1		= 16'd0;
	reg  [15:0]		r_pulse_index2		= 16'd0;
	reg  [31:0]		r_pulse_remain		= 32'd0;
	reg  [31:0]		r_sub1_datab		= 32'd0;
	reg  [31:0]		r_sub2_datab		= 32'd0;
	reg  [3:0]		r_cal_dlycnt		= 4'd0;
	wire [31:0]		w_result_risere;
	wire [31:0]		w_result_pulsere;

	reg				r_indfifo_wren		= 1'b0;
	reg  [87:0]		r_indfifo_wrdata	= 88'h0;
    //----------------------------------------------------------------------------------------------
    // FSM(finite-state machine)
	// rise data step vaule is 256
	// pulse divide, step vaule is 128 and 512
    //----------------------------------------------------------------------------------------------	
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_index_flag	<= 4'b0000;
			r_index_angle1	<= 16'd0;
			r_index_angle2	<= 16'd0;
			r_rise_index	<= 16'd0;
			r_rise_remain	<= 32'd0;
			r_pulse_index	<= 16'd0;
			r_pulse_index1	<= 16'd0;
			r_pulse_index2	<= 16'd0;
			r_pulse_remain	<= 32'd0;
			r_sub1_datab	<= 32'd0;
			r_sub2_datab	<= 32'd0;
			r_index_state	<= ST_IDLE;
		end else begin
			case(r_index_state)
				ST_IDLE: begin //00
					r_index_flag	<= 4'b0000;
					if(i_dist_precal_sig)begin
						r_index_angle1	<= i_dist_precal_angle1;
						r_index_angle2	<= i_dist_precal_angle2;
						r_rise_index	<= 16'd0;
						r_rise_remain	<= 32'd0;
						r_pulse_index	<= 16'd0;
						r_pulse_index1	<= 16'd0;
						r_pulse_index2	<= 16'd0;
						r_pulse_remain	<= 32'd0;
						r_sub1_datab	<= 32'd0;
						r_sub2_datab	<= 32'd0;
						r_index_state	<= ST_RISE_PRE;
					end else
						r_index_state	<= ST_IDLE;
				end
				ST_RISE_PRE: begin //01
					if(i_rise_data >= MAX_RISE_VAULE)begin
						r_index_flag	<= 4'b1001;
						r_index_state	<= ST_INDEX_END;
					end else begin
						r_index_flag[2]	<= 1'b0;
						r_index_state	<= ST_RISE_INDEX;
					end
				end
				ST_RISE_INDEX: begin //02
					r_rise_index	<= i_rise_data[23:8];
					r_sub1_datab	<= {i_rise_data[31:8], 8'd0};
					r_index_state	<= ST_PULSE_PRE;
				end
				ST_PULSE_PRE: begin //04
					if(i_pulse_data	<= i_pulse_start)begin
						r_index_flag	<= 4'b1001;
						r_index_state	<= ST_INDEX_END;
					end else if(i_pulse_data >= i_pulse_divid)begin
						r_index_flag[1]	<= 1'b1;
						r_index_state	<= ST_PULSE_INDEX2;
					end else begin
						r_index_flag[1]	<= 1'b0;
						r_index_state	<= ST_PULSE_INDEX1;
					end
				end
				ST_PULSE_INDEX1:begin //08
					r_index_state	<= ST_CAL_PULSERE;
					r_pulse_index1	<= (i_pulse_data - i_pulse_start) >> 4'd7;
					r_pulse_index2	<= 16'd0;
				end
				ST_PULSE_INDEX2:begin //10
					r_index_state	<= ST_CAL_PULSERE;
					r_pulse_index1	<= (i_pulse_divid - i_pulse_start) >> 4'd7;
					r_pulse_index2	<= (i_pulse_data - i_pulse_divid) >> 4'd9;
				end
				ST_CAL_PULSERE: begin //20
					r_pulse_index	<= r_pulse_index1 + r_pulse_index2;
					r_sub2_datab	<= {9'h0, r_pulse_index1, 7'h0} + {7'h0, r_pulse_index2, 9'd0} + i_pulse_start;
					if(r_cal_dlycnt >= 4'd3)
						r_index_state	<= ST_INDEX_CALDONE;
					else
						r_index_state	<= ST_CAL_PULSERE;
				end
				ST_INDEX_CALDONE: begin //40
					r_rise_index	<= r_rise_index;
					r_rise_remain	<= w_result_risere;
					r_pulse_index	<= r_pulse_index;
					r_pulse_remain	<= w_result_pulsere;
					r_index_state	<= ST_INDEX_END;
					r_index_flag[3]	<= 1'b1;
				end
				ST_INDEX_END: begin //80
					r_index_state	<= ST_IDLE;
				end
				default:
					r_index_state	<= ST_IDLE;
			endcase
		end
	end

	//r_cal_dlycnt
	always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n)
			r_cal_dlycnt <= 4'd0;
		else if(r_index_state == ST_CAL_PULSERE)
			r_cal_dlycnt <= r_cal_dlycnt + 1'b1;
		else
			r_cal_dlycnt <= 4'd0;
	end

	//r_indfifo_wren, r_indfifo_wrdata
	always@(posedge i_clk or negedge i_rst_n)begin
		if(!i_rst_n) begin
			r_indfifo_wren		<= 1'b0;
			r_indfifo_wrdata	<= 88'h0;
		end else if(r_index_state == ST_INDEX_END) begin
			r_indfifo_wren		<= 1'b1;
			// r_indfifo_wrdata	<= {r_index_flag, r_rise_index, r_rise_remain[9:0], r_pulse_index, r_pulse_remain[9:0], r_index_angle1, r_index_angle2};
			r_indfifo_wrdata	<= {4'b1000, 16'd3, 10'd1, 16'd4, 10'd1, r_index_angle1, r_index_angle2};//4'b1001;
		end else begin
			r_indfifo_wren		<= 1'b0;
			r_indfifo_wrdata	<= 88'h0;
		end
	end
    //----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
	sub_ip u1_sub1_ip
	(
		.DataA			( i_rise_data			),
		.DataB			( r_sub1_datab			),
		.Result			( w_result_risere		)
	);

	sub_ip u2_sub2_ip
	(
		.DataA			( i_pulse_data			),
		.DataB			( r_sub2_datab			),
		.Result			( w_result_pulsere		)
	);

	sfifo128x88 u3_sfifo128x88
	(
        .Data           ( r_indfifo_wrdata		),
        .Clock          ( i_clk                 ), 
        .WrEn           ( r_indfifo_wren		), 
        .RdEn           ( i_indfifo_rden		), 
        .Reset          ( ~i_rst_n              ), 
        .Q              ( o_indfifo_rdata		), 
        .Empty          ( o_indfifo_empty		), 
        .Full           ( o_indfifo_full		)
	);
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	// assign	o_rise_index	= 16'd3;
	// assign	o_rise_remain	= 32'd0;
	// assign	o_pulse_index	= 16'd4;
	// assign	o_pulse_remain	= 32'd0;
endmodule 