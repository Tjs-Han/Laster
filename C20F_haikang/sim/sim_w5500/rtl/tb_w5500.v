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
// Last modified Date:     2025/04/27 13:47:55 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2025/04/27 13:47:55 
// Version:                V1.0 
// TEXT NAME:              tb_w5500.v 
// PATH:                   D:\Project\C20F_haikang\sim\sim_w5500\rtl\tb_w5500.v 
// Descriptions:            
//                          
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module tb_w5500(
);
 reg w_pll_25m;
 reg r_rst_n ;
 reg i_spi_miso=0 ;
 initial begin
    r_rst_n =0 ;
    w_pll_25m =0;
    #100 r_rst_n=1'b1;
 end
 always #20   w_pll_25m =~w_pll_25m;                                                               
 	w5500_control U8
	(
		.i_clk_50m			(w_pll_25m)				,
		.i_rst_n			(r_rst_n)				,
		
		// .o_spi_cs			(o_spi_cs)				,
		// .o_spi_dclk			(o_spi_dclk)			,
		// .o_spi_mosi			(o_spi_mosi)			,
		.i_spi_miso			(i_spi_miso)			
		//.o_w5500_rst		(o_w5500_rst)			,
		
		//.i_read_complete_sig(w_read_complete_sig)	,
		
		// .o_sram_csen_eth	(w_sram_csen_eth)		,
		// .o_sram_wren_eth	(w_sram_wren_eth)		,
		// .o_sram_rden_eth	(w_sram_rden_eth)		,
		// .o_sram_addr_eth	(w_sram_addr_eth)		,
		// .o_sram_data_eth	(w_sram_wrdata_eth)		,
		// .i_sram_data_eth	(w_sram_rddata_eth)		,
		
		// .i_packet_wren		(w_packet_wren)			,	
		// .i_packet_pingpang	(w_packet_pingpang)		,
		// .i_packet_wrdata	(w_packet_wrdata)		,
		// .i_packet_wraddr	(w_packet_wraddr)		,
		// .i_packet_make		(w_packet_make)			,
		// .i_packet_points	(w_packet_points)		,
		
		// .i_scan_counter		(w_scan_counter)		,
		// .i_telegram_no		(w_telegram_no)			,
		// .i_first_angle		(w_first_angle)			,
		
		// .i_calib_wren		(w_calib_wren)			,	
		// .i_calib_pingpang	(w_calib_pingpang)		,
		// .i_calib_wrdata		(w_calib_wrdata)		,
		// .i_calib_wraddr		(w_calib_wraddr)		,
		// .i_calib_make		(w_calib_make)			,
		// .i_calib_points		(w_calib_points)		,
		
		// .i_code_angle		(w_code_angle)			,
		// .i_pulse_get		(w_pulse_get)			,
		// .i_pulse_rise		(w_pulse_rise)			,
		// .i_pulse_fall		(w_pulse_fall)			,
		// .i_status_code		(w_status_code)			,
		// .i_apd_hv_value		(w_apd_hv_value)		,
		// .i_apd_temp_value	(w_apd_temp_value)		,
		// .i_device_temp		(w_device_temp)			,
		// .i_dac_value		(w_dac_value)			,
		// .i_pwm_value  		(w_pwm_value)			,//褰撳墠鐢垫満PWM�
		
	/* 	.o_config_mode		(w_config_mode)			,
		.o_filter_mode		(w_filter_mode)			,
		.o_pwm_value_0		(w_pwm_value_0)			,
		.o_stop_window		(w_stop_window)			,
		.o_zero_offset		(w_zero_offset)			,
		.o_angle_offset		(w_angle_offset)		,
		.o_rise_start 		(w_rise_start)			,
		.o_pulse_start 		(w_pulse_start)			,
		.o_apd_hv_base		(w_apd_hv_base)			,
		.o_distance_min		(w_distance_min)		,
		.o_distance_max		(w_distance_max)		,
		.o_temp_apdhv_base	(w_temp_apdhv_base)		,
		.o_temp_temp_base	(w_temp_temp_base)		,
		.o_temp_temp_coe	(w_temp_temp_coe)		,
		.o_start_index		(w_start_index)			,
		.o_stop_index		(w_stop_index)			,
		.o_index_num		(w_index_num)			,
		.o_pulse_set		(w_pulse_set)			,
		.o_pulse_mode		(w_pulse_mode)			,
		.o_telegram_flag	(w_telegram_flag)		,
		.o_sram_store_flag	(w_sram_store_flag)		,

		.save_user_sram_to_factory_flash_valid 	(save_user_sram_to_factory_flash_valid),
		.save_factory_sram_to_user_flash_valid  (save_factory_sram_to_user_flash_valid), */
		
/* 		.o_program_n		(o_program_n)			,
		.o_rst_n			(w_rst_n)               ,
		.i_motor_state      (w_motor_state)        ,

		.o_motor_rst_n      (o_motor_rst_n),
		
		.o_temp_dist        (w_temp_dist)          ,
		.o_tdc_switch       (w_tdc_switch)         ,
		.o_fixed_value      (w_fixed_value)        ,

		.dist_report_error   (dist_report_error)   ,
		.tdc_process_error   (tdc_process_error)   ,
		.state_tsatic_value	 (state_tsatic_value)  ,		
		
		.i_first_rise		(w_fisrt_rise)			,
		
		.i_flash_busy		(w_flash_busy)			,
		.i_iap_flag         (w_iap_flag)			,
		.o_dirt_mode		(w_dirt_mode)			,
		.o_dirt_points		(w_dirt_points)			,
        .o_regaddr_opto	    (o_ram_raddr        )   ,
        .i_data_opto_period (o_ram_rdata		)        */ 
		
    );  
     GSR GSR_INST(.GSR(1'b1));
     PUR PUR_INST(.PUR(1'b1));   	
endmodule                                                          
