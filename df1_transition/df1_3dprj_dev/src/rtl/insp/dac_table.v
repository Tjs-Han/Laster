//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: dac_table
// Date Created 	: 2023/10/31 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
// File description	:dac_table
//--------------------------------------------------------------------------------------------------
// Revision History :V1.0
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------	
module dac_table
(
	input				i_clk_50m,
	input				i_rst_n,

	input				i_para_start,
	input  [7:0]		i_apd_temp,
	input  [15:0] 		i_temp_apdhv_base,
	input  [7:0]		i_temp_temp_base,

	output [6:0]		o_hvcp_ram_rdaddr,
	input  [15:0]		i_hvcp_rddata,
	
	output				o_para_done,
	output [11:0]		o_dac_para			
);
	
	reg  [2:0]			r_table_state 		= 3'd0;
	reg					r_apdhv_incv		= 1'b0;
	reg	 [7:0]			r_temp_diff			= 8'd0;
	reg	 [7:0]			r_temp_value 		= 8'd0;
	reg					r_diff_value 		= 1'b0;
	reg	 [6:0]			r_hvcp_ram_rdaddr 	= 7'd0;
	reg	 [15:0]			r_dac_rdvalue1 		= 16'd0;
	
	reg  [15:0]			r_dac_para 			= 16'd0;
	reg					r_para_done 		= 1'b0;
	
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)	begin
			r_temp_diff			<= 8'd0;
			r_temp_value		<= 8'd0;
			r_diff_value		<= 1'b0;
			r_hvcp_ram_rdaddr	<= 7'd0;
			r_dac_rdvalue1		<= 16'd0;
			r_dac_para			<= 16'd0;
			r_para_done			<= 1'b0;
			r_table_state 		<= 3'd0;
		end else begin
			case(r_table_state)
				3'd0: begin
					r_apdhv_incv		<= 1'b0;
					r_temp_diff			<= 8'd0;
					r_temp_value		<= 8'd0;
					r_diff_value		<= 1'b0;
					r_hvcp_ram_rdaddr	<= 7'd0;
					r_dac_rdvalue1		<= 16'd0;
					r_para_done			<= 1'b0;
					if(i_para_start)
						r_table_state 		<= 3'd1;
				end
				3'd1: begin
					r_table_state	<= 3'd2;
					if(i_apd_temp >= i_temp_temp_base) begin
						r_apdhv_incv	<= 1'b1; 
						r_temp_diff		<= i_apd_temp - i_temp_temp_base;
					end else begin
						r_temp_diff		<= i_temp_temp_base - i_apd_temp;
						r_apdhv_incv	<= 1'b0;
					end
				end
				3'd2: begin
					r_temp_value	<= r_temp_diff << 4'd5; //pwm add 'd32 per temp
					r_table_state	<= 3'd3;
				end
				3'd3: begin
					r_table_state	<= 3'd4;
					if(r_apdhv_incv)
						r_dac_para	<= i_temp_apdhv_base + r_temp_value;
					else
						r_dac_para	<= i_temp_apdhv_base - r_temp_value;
				end
				3'd4: begin
					r_table_state 		<= 3'd5;
				end
				3'd5:	begin
					r_para_done			<= 1'b1;
					r_table_state 		<= 3'd0;
				end
			endcase
		end
	end
	//--------------------------------------------------------------------------------------------------
	//output siganl assign define
	//--------------------------------------------------------------------------------------------------			
	assign	o_para_done = r_para_done;
	assign	o_dac_para	= r_dac_para[11:0];
	assign	o_hvcp_ram_rdaddr = r_hvcp_ram_rdaddr;

endmodule 