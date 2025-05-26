// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: adc_control
// Date Created 	: 2024/9/2 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:adc control
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module adc_control
#(
	parameter AD_DW			= 8'd10
)
(
	input				i_clk_50m,
	input				i_rst_n,

	input				i_adc_start,

	output [AD_DW-1:0]  o_adc1_value,
	output [AD_DW-1:0]  o_adc2_value,

	output				o_adc_sclk,
	output				o_adc_cs1,
	output				o_adc_cs2,
	input				i_adc_sda		
);
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
	reg  [AD_DW-1:0]    r_adc1_value	= {AD_DW{1'b0}};
	reg  [AD_DW-1:0]    r_adc2_value	= {AD_DW{1'b0}};
    reg					r_adc_cs_cs		= 1'b0;
	
	wire				w_adc_cs;
	wire				w_adc_rx_done;
    wire [AD_DW-1:0]    w_adc_data;

	reg	[7:0]			r_adc_state 	= 8'd0;
	reg					r_adc_en 		= 1'b0;
	reg	[15:0]			r_adc_delay 	= 16'd0;
	//----------------------------------------------------------------------------------------------
	// parameter define
	//----------------------------------------------------------------------------------------------
	parameter			ADC_IDLE		= 8'b0000_0000,
						ADC_SAMP1		= 8'b0000_0010,
						ADC_WAIT1		= 8'b0000_0100,
						ADC_DELAY		= 8'b0000_1000,
						ADC_SAMP2		= 8'b0001_0000,
						ADC_WAIT2		= 8'b0010_0000,
						ADC_END			= 8'b0100_0000;
				
	
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_adc_state		<= ADC_IDLE;
		else begin
			case(r_adc_state)
				ADC_IDLE: begin
					if(i_adc_start)
						r_adc_state		<= ADC_SAMP1;
					else
						r_adc_state		<= ADC_IDLE;
				end
				ADC_SAMP1: r_adc_state		<= ADC_WAIT1;
				ADC_WAIT1: begin
					if(w_adc_rx_done)
						r_adc_state		<= ADC_DELAY;
					else
						r_adc_state		<= ADC_WAIT1;
				end
				ADC_DELAY: begin
					if(r_adc_delay >= 16'd999)
						r_adc_state		<= ADC_SAMP2;
					else
						r_adc_state		<= ADC_DELAY;
				end
				ADC_SAMP2: r_adc_state		<= ADC_WAIT2;
				ADC_WAIT2: begin
					if(w_adc_rx_done)
						r_adc_state		<= ADC_END;
					else
						r_adc_state		<= ADC_WAIT2;
				end
				ADC_END: r_adc_state		<= ADC_IDLE;
				default: r_adc_state		<= ADC_IDLE;
			endcase
		end
	end	
			
	//r_adc_en
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_adc_en	<= 1'b0;
		else if(r_adc_state == ADC_SAMP1 || r_adc_state == ADC_SAMP2)
			r_adc_en	<= 1'b1;
		else
			r_adc_en	<= 1'b0;
			
	//r_adc_cs_cs
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_adc_cs_cs		<= 1'b0;
		else if(r_adc_state == ADC_SAMP1)
			r_adc_cs_cs		<= 1'b0;
		else if(r_adc_state == ADC_SAMP2)
			r_adc_cs_cs		<= 1'b1;
		else if(r_adc_state	 == ADC_IDLE)
			r_adc_cs_cs		<= 1'b0;
			
	//r_adc_delay
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_adc_delay		<= 16'd0;
		else if(r_adc_state == ADC_DELAY)
			r_adc_delay		<= r_adc_delay + 1'b1;
		else
			r_adc_delay		<= 16'd0;
			
	//r_adc1_value
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_adc1_value	<= {AD_DW{1'b0}};
		else if(r_adc_state == ADC_WAIT1 && w_adc_rx_done)
			r_adc1_value	<= w_adc_data;
			
	//r_adc2_value
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_adc2_value	<= {AD_DW{1'b0}};
		else if(r_adc_state == ADC_WAIT2 && w_adc_rx_done)
			r_adc2_value	<= w_adc_data;
	//----------------------------------------------------------------------------------------------
	// output assign
	//----------------------------------------------------------------------------------------------   		
	assign	o_adc1_value = r_adc1_value;
	assign	o_adc2_value = r_adc2_value;	
	assign	o_adc_cs1 = (r_adc_cs_cs)? 1'b1 : w_adc_cs;
	assign	o_adc_cs2 = (r_adc_cs_cs)? w_adc_cs : 1'b1;

    //----------------------------------------------------------------------------------------------
	// inst
	//----------------------------------------------------------------------------------------------   
	AD_SPI u1_spi(
		.clk_50m			( i_clk_50m 		),
		.rst_n				( i_rst_n 			),
		.i_adc_rx_en		( r_adc_en 			),
		.i_adc_miso			( i_adc_sda 		),
		.o_adc_cs			( w_adc_cs 			),
		.o_adc_sclk			( o_adc_sclk 		),
		.o_adc_rx_done		( w_adc_rx_done 	),
		.o_adc_data			( w_adc_data 		)
	);
endmodule 