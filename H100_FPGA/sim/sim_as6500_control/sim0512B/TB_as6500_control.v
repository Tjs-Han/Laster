	`timescale 1ns / 1ps 
	//****************************************VSCODE PLUG-IN**********************************// 
	//---------------------------------------------------------------------------------------- 
	// IDE :                   VSCODE      
	// VSCODE plug-in version: Verilog-Hdl-Format-2.4.20240526
	// VSCODE plug-in author : Jiang Percy 
	//---------------------------------------------------------------------------------------- 
	//****************************************Copyright (c)***********************************// 
	// Copyright(C)            COMPANY_NAME
	// All rights reserved      
	// File name:               
	// Last modified Date:     2025/04/29 15:15:20 
	// Last Version:           V1.0 
	// Descriptions:            
	//---------------------------------------------------------------------------------------- 
	// Created by:             Tjs
	// Created date:           2025/04/29 15:15:20 
	// Version:                V1.0 
	// TEXT NAME:              TB_as6500_control.v 
	// PATH:                   D:\Project\H100_FPGA\sim\sim_as6500_control\TB_as6500_control.v 
	// Descriptions:            
	//                          
	//---------------------------------------------------------------------------------------- 
	//****************************************************************************************// 
	
	module TB_as6500_control(
	);
	reg i_clk_50M	;
	reg i_clk_100M	;	
	reg i_rst_n		;
    
	reg i_angle_sync	;
	reg i_motor_state	;
	reg i_tdc_init		;
	reg i_tdc_spi_miso	;
	wire [5:0]next_state;

	initial begin
		i_rst_n =0 ;
		i_clk_50M =0;
		i_clk_100M =0;
		#100 i_rst_n =1'b1;

		i_angle_sync =1'b1;
		i_motor_state =1'b1;
		i_tdc_init=1'b1;//  valid low level
		i_tdc_spi_miso=1;
		#1000
			i_tdc_init=1'b0;
	end															   

	always #10  i_clk_50M	= ~i_clk_50M	;
	always #10	i_clk_100M	= ~i_clk_100M	;                               																   
	 
	
	as6500_control	U2
	(
		.i_clk_50m			(i_clk_50M)				,
		.i_clk_100m    		(i_clk_100M)			,
		.i_rst_n      		(i_rst_n)				,
		
		.i_angle_sync		(i_angle_sync)			,
		.i_motor_state		(i_motor_state)			,
		
		.i_tdc_init 		(i_tdc_init)			,
		.i_tdc_spi_miso		(i_tdc_spi_miso)		
		
		// .o_tdc_spi_mosi		(o_tdc_spi_mosi)		,
		// .o_tdc_spi_ssn 		(o_tdc_spi_ssn)			,
		// .o_tdc_spi_clk 		(o_tdc_spi_clk)			,

		// .o_rise_data		(w_rise_data)			,
		// .o_fall_data		(w_fall_data)			,
		// .o_tdc_err_sig		(o_tdc_err_sig)			,
		// .o_tdc_new_sig		(w_tdc_new_sig)			
	);

	endmodule  