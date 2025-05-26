// -------------------------------------------------------------------------------------------------
// File description	:pluse average
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//				Output ADC sampling average
//--------------------------------------------------------------------------------------------------
module temp_adc_filter
(
	input				i_clk_50m,
	input				i_rst_n,

	input				i_cal_sig,
	input  [15:0]		i_temp_adcval,

	output [15:0]		o_adcval_fact
);
	//----------------------------------------------------------------------------------------------
	// reg define
	//----------------------------------------------------------------------------------------------
	reg [15:0]			r_adcval_fact	= 16'd0;
	reg	[15:0]			r_pulse_value1 	= 16'd0;
	reg	[15:0]			r_pulse_value2 	= 16'd0;
	reg	[15:0]			r_pulse_value3 	= 16'd0;
	reg	[15:0]			r_pulse_value4 	= 16'd0;
	reg	[15:0]			r_pulse_value5 	= 16'd0;
	reg	[15:0]			r_pulse_value6 	= 16'd0;
	reg	[15:0]			r_pulse_value7 	= 16'd0;
	reg	[15:0]			r_pulse_value8 	= 16'd0;

	reg [15:0]			r_diff_val34	= 16'd0;
	reg [15:0]			r_diff_val43	= 16'd0;
	reg [15:0]			r_diff_val45	= 16'd0;
	reg [15:0]			r_diff_val54	= 16'd0;
	//----------------------------------------------------------------------------------------------
	// sequence define
	//----------------------------------------------------------------------------------------------
	//adc val reg
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0) begin
			r_pulse_value1	<= 16'd0;
			r_pulse_value2	<= 16'd0;
			r_pulse_value3	<= 16'd0;
			r_pulse_value4	<= 16'd0;
			r_pulse_value5	<= 16'd0;
			r_pulse_value6	<= 16'd0;
			r_pulse_value7	<= 16'd0;
			r_pulse_value8	<= 16'd0;
		end else if(i_cal_sig) begin
			r_pulse_value8	<= r_pulse_value7;
			r_pulse_value7	<= r_pulse_value6;
			r_pulse_value6	<= r_pulse_value5;
			r_pulse_value5	<= r_pulse_value4;
			r_pulse_value4	<= r_pulse_value3;
			r_pulse_value3	<= r_pulse_value2;
			r_pulse_value2	<= r_pulse_value1;
			r_pulse_value1	<= i_temp_adcval;
		end
	end

	//adc val diff
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0) begin
			r_diff_val43	<= 16'd0;
			r_diff_val34	<= 16'd0;
			r_diff_val45	<= 16'd0;
			r_diff_val54	<= 16'd0;
		end else begin
			if(r_pulse_value4 > r_pulse_value3) begin
				r_diff_val43	<= r_pulse_value4 - r_pulse_value3;
				r_diff_val34	<= 16'd0;
			end else begin
				r_diff_val34	<= r_pulse_value3 - r_pulse_value4;
				r_diff_val43	<= 16'd0;
			end

			if(r_pulse_value5 > r_pulse_value4) begin
				r_diff_val54	<= r_pulse_value5 - r_pulse_value4;
				r_diff_val45	<= 16'd0;
			end else begin
				r_diff_val45	<= r_pulse_value4 - r_pulse_value5;
				r_diff_val54	<= 16'd0;
			end
		end
	end

	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_adcval_fact	<= 16'd0;
		else begin
			if(r_diff_val54 >= 16'd50 && r_diff_val34 >= 16'd50)
				r_adcval_fact	<= r_pulse_value5;
			else if(r_diff_val45 >= 16'd50 && r_diff_val43 >= 16'd50)
				r_adcval_fact	<= r_pulse_value3;
			else
				r_adcval_fact	<= r_pulse_value4;
		end
	end

	assign o_adcval_fact = (r_adcval_fact >> 4'd2);
endmodule 