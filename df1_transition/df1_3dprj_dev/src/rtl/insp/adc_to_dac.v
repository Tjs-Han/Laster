// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: adc_to_dac
// Date Created 	: 2023/09/14 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description :
// -------------------------------------------------------------------------------------------------
// Revision History  :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module adc_to_dac
#(
	parameter DAC_LIMIT_VALUE	= 10
)
(
	input				i_clk_50m,
	input				i_rst_n,

	input				i_dac_set_sig,
	input  [9:0]		i_adc_temp_value,

	input  [15:0]		i_temp_apdhv_base,
	input  [15:0]		i_temp_temp_base,

	input				i_hvcp_switch,
	output [6:0]		o_hvcp_ram_rdaddr,
	input  [15:0]		i_hvcp_rddata,

	output				o_dac_start,
	output [9:0]		o_dac_value,
	output [7:0]		o_device_temp
);
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
	reg [9:0]			r_adc_value 	= 10'd0;
	reg 				r_adc_start 	= 1'b0;
	reg [7:0]			r_dac_state 	= 8'd0;
	reg [11:0]			r_dac_value 	= 12'd0;
	reg 				r_dac_start 	= 1'b0;
	reg [15:0]			r_apd_temp 		= 16'd0;
	reg					r_para_start 	= 1'b0;

	wire				w_para_done;
	wire 				w_temp_done;
	wire [11:0]			w_dac_para;
	wire [15:0]			w_temp_value;
	wire [7:0]			w_temp_mask_base;
	//--------------------------------------------------------------------------------------------------
	// state machine define
	//--------------------------------------------------------------------------------------------------
	parameter		DAC_IDLE		= 8'b0000_0000,
					DAC_TEMP_NOW	= 8'b0000_0010,
					DAC_CHOOSE		= 8'b0000_0100,
					DAC_PARA		= 8'b0000_1000,
					DAC_ASSIGN		= 8'b0001_0000,
					DAC_VALUE		= 8'b0010_0000,
					DAC_END			= 8'b0100_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dac_state		<= DAC_IDLE;
		else begin
			case(r_dac_state)
				DAC_IDLE	:begin
					if(i_dac_set_sig)
						r_dac_state		<= DAC_TEMP_NOW;
				end
				DAC_TEMP_NOW:begin
					if(w_temp_done)
						r_dac_state		<= DAC_CHOOSE;
				end
				DAC_CHOOSE	:begin 
					if(i_hvcp_switch)
						r_dac_state		<= DAC_PARA;
					else
						r_dac_state		<= DAC_VALUE;
				end
				DAC_PARA	:
					r_dac_state		<= DAC_ASSIGN;
				DAC_ASSIGN	:begin
					if(w_para_done)
						r_dac_state		<= DAC_END;
				end
				DAC_VALUE	:
					r_dac_state		<= DAC_END;
				DAC_END		:
					r_dac_state		<= DAC_IDLE;
				default:r_dac_state		<= DAC_IDLE;
			endcase
		end
	//--------------------------------------------------------------------------------------------------
	// siganl define
	//--------------------------------------------------------------------------------------------------	
	//r_adc_start			
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_adc_start	<= 1'b0;
		else if(r_dac_state == DAC_TEMP_NOW && ~w_temp_done)
			r_adc_start	<= 1'b1;
		else
			r_adc_start	<= 1'b0;
	end

	//r_adc_value
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_adc_value	<= 10'd0;
		else if(r_dac_state == DAC_TEMP_NOW)
			r_adc_value	<= i_adc_temp_value;
		else
			r_adc_value	<= 10'd0;
	end

	//r_apd_temp
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)		
			r_apd_temp <= 16'd0;
		else if(r_dac_state == DAC_TEMP_NOW && w_temp_done)
			r_apd_temp <= w_temp_value;
	end

	//r_dac_start
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)		
			r_dac_start <= 1'b0;
		else if(r_dac_state == DAC_END)
			r_dac_start <= 1'b1;
		else
			r_dac_start <= 1'b0;
	end

	//r_para_start
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)				
			r_para_start <= 1'b0;
		else if(r_dac_state == DAC_PARA)
			r_para_start <= 1'b1;
		else
			r_para_start <= 1'b0;
	end

	//r_dac_value
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_dac_value		<= 12'd204;
		else if(r_dac_state == DAC_VALUE)
			r_dac_value		<= i_temp_apdhv_base[11:0];
		else if(r_dac_state == DAC_ASSIGN && w_para_done)
			r_dac_value		<= w_dac_para;
	end

	//w_temp_mask_base
	assign w_temp_mask_base = i_temp_temp_base[7:0] + 8'd20;
	//--------------------------------------------------------------------------------------------------
	// instance domain
	//--------------------------------------------------------------------------------------------------	
	adc_to_temp U1
	(
		.i_clk_50m			( i_clk_50m				),
		.i_rst_n			( i_rst_n				),
 
		.i_adc_value		( {r_adc_value,2'd0}	),
		.i_adc_start		( r_adc_start			),
 
		.o_temp_done		( w_temp_done			),
		.o_temp_value		( w_temp_value			)
	);
	
	dac_table u2
	(
		.i_clk_50m    		( i_clk_50m 			),
		.i_rst_n      		( i_rst_n 				),
		
		.i_para_start		( r_para_start 			),
		.i_apd_temp			( r_apd_temp[15:8] 		),
		.i_temp_apdhv_base	( i_temp_apdhv_base		),
		.i_temp_temp_base	( w_temp_mask_base 		),

		.o_hvcp_ram_rdaddr	( o_hvcp_ram_rdaddr 	),
		.i_hvcp_rddata		( i_hvcp_rddata 		),
		
		.o_para_done		( w_para_done 			),
		.o_dac_para			( w_dac_para 			)
	);
	//--------------------------------------------------------------------------------------------------
	//output siganl assign define
	//--------------------------------------------------------------------------------------------------
	assign	o_dac_start   = r_dac_start;
	assign	o_dac_value   = r_dac_value[11:2];
	// assign	o_dac_value   = 10'd204;
	assign	o_device_temp = r_apd_temp[15:8] - 8'd20;	
endmodule 