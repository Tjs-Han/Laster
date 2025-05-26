// -------------------------------------------------------------------------------------------------
// File description  :DA SPI PWM
// -------------------------------------------------------------------------------------------------
// Revision History  :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module	DA_SPI_pwm	(
	input				i_clk_50m,
	input				i_rst_n,
	input				i_init_load_done,
	input				i_tx_en,	
	input [9:0] 		i_data_in/*synthesis PAP_MARK_DEBUG="true"*/,

	output 				o_da_pwm

	);
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
	reg [15:0] 			r_pwm_cnt;
	reg [9:0]  			r_pwm_value; 
	reg					r_da_pwm;
	//--------------------------------------------------------------------------------------------------
	// sequence define
	//--------------------------------------------------------------------------------------------------
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_pwm_cnt <= 16'd0;
		else if(r_pwm_cnt >= 16'd1024)
			r_pwm_cnt <= 16'd0;
		else
			r_pwm_cnt <= r_pwm_cnt + 1'd1;
	end

	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_pwm_value <= 10'd200;
		else if(i_tx_en)
			r_pwm_value <= i_data_in;
	end

	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_da_pwm <= 1'd0;
		else if(i_init_load_done) begin
			if(r_pwm_value >= 10'd500) begin
				if(r_pwm_cnt <= 10'd500)
					r_da_pwm <= 1'd1;
				else
					r_da_pwm <= 1'd0;
			end else begin
				if(r_pwm_cnt <= r_pwm_value)
					r_da_pwm <= 1'd1;
				else
					r_da_pwm <= 1'd0;
			end
		end else
			r_da_pwm <= 1'd0;
	end

	// //Temporary
	// always@(posedge i_clk_50m or negedge i_rst_n) begin
	// 	if(i_rst_n == 1'b0)
	// 		r_da_pwm <= 1'd0;
	// 	else if(r_pwm_cnt <= 10'd820)
	// 		r_da_pwm <= 1'd0;
	// 	else
	// 		r_da_pwm <= 1'd1;
	// end

	assign o_da_pwm =	~r_da_pwm;	
		
		
endmodule		
			
			
			
			
			
			
			
	