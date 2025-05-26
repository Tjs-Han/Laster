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
// Last modified Date:     2025/04/25 15:41:01 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             tjs
// Created date:           2025/04/25 15:41:01 
// Version:                V1.1 
// TEXT NAME:              r.v 
// PATH:                   D:\Project\C20F_haikang\C200_FPGA\rtl_tjs\r.v 
// Descriptions:            
//    		2025/4/25	 Newly added modules statistics_cycle                      
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module rotating_module_1
(
	input			i_clk_50m		,
	input			i_rst_n			,
	
	input			i_opto_switch	,//码盘信号输入
	input	[7:0]	i_config_mode 	,//0:标定模式标志 1 = 标定模式 0 = 普通模�2:1:转速模式标�1 = 25Hz 0 = 15hz 4:3:分辨率模式标�3 = 0.5 2 = 0.33 1 = 0.25 0 = 0.2  5:出光模式标志�1 = 出光模式 0 = 不出光模�6:测距模式 1：测距模�0：休眠模�
	input	[15:0]	i_pwm_value_0	,//电机转速初始�
	input	[15:0]	i_angle_offset	,
	
	
	output			o_encoder_right ,
	output			o_motor_state	,//1 = 调速完�0 = 调速未完成
	output	[15:0]	o_pwm_value  	,//当前电机PWM�
	output			o_motor_pwm  	,//电机PWM输出
	output	[15:0]	o_code_angle 	,//角度�
	output	[15:0]	o_zero_angle	,
	output			o_zero_sign		,
	output			o_angle_sync 	,//码盘信号标志，用以标志充电与出光

    input   [5:0]   i_ram_raddr     ,
    output  [31:0]  o_ram_rdata     
);

	wire			w_cal_mode;
	wire	[1:0]	w_freq_mode;
	wire	[1:0]	w_reso_mode;
	wire			w_laser_mode;
	wire			w_measure_mode;
	
	assign	w_cal_mode		= i_config_mode[0];
	assign	w_freq_mode		= i_config_mode[2:1];
	assign	w_reso_mode		= i_config_mode[4:3];
	assign	w_laser_mode	= i_config_mode[5];
	assign	w_measure_mode	= i_config_mode[6];

	wire			w_opto_switch;
	opto_switch_filter U1
	(
		.i_clk_50m    		(i_clk_50m)		,
		.i_rst_n      		(i_rst_n)		,
		
		.i_opto_switch		(i_opto_switch)	,//码盘信号输入
		
		.o_opto_switch		(w_opto_switch)	 //码盘信号输出
	);
	
	motor_control U2
	(
		.i_clk_50m    		(i_clk_50m)		,
		.i_rst_n      		(i_rst_n)		,
		
		.i_cal_mode   		(w_cal_mode)	,//标定模式标志 1 = 标定模式 0 = 普通模�
		.i_freq_mode  		(w_freq_mode)	,//1 = 25Hz    0 = 15Hz
		.i_measure_mode		(w_measure_mode),
		.i_opto_switch		(i_opto_switch)	,//码盘信号输入
		.i_pwm_value_0		(i_pwm_value_0)	,
	
		.o_motor_state		(o_motor_state)	,//1 = 调速完�0 = 调速未完成
		.o_pwm_value  		(o_pwm_value)	,
		.o_motor_pwm  		(o_motor_pwm)	 //电机PWM输出
	);
	
	encoder_generate U3
	(
		.i_clk_50m    		(i_clk_50m)		,
		.i_rst_n      		(i_rst_n)		,
		
		.i_opto_switch		(w_opto_switch)	,//码盘信号输入
		.i_motor_state		(o_motor_state)	,//1 = 调速完�0 = 调速未完成
		.i_cal_mode   		(w_cal_mode)	,//标定模式标志 1 = 标定模式 0 = 普通模�
		.i_reso_mode  		(w_reso_mode)	,//1 = 0.33� 0 = 0.2�
		.i_freq_mode  		(w_freq_mode)	,//1 = 25Hz    0 = 15Hz
		.i_laser_mode 		(w_laser_mode)	,
		.i_angle_offset		(i_angle_offset),
		
		.o_encoder_right	(o_encoder_right),
		.o_zero_sign		(o_zero_sign)	,
		.o_code_angle 		(o_code_angle)	,//角度�
		.o_zero_angle		(o_zero_angle)	,
		.o_angle_sync 		(o_angle_sync) 	 //码盘信号标志，用以标志充电与出光
	);
    statistics_cycle u4( 
        .i_clk_50m          (i_clk_50m  ),// input			i_clk_50m    		,
        .i_rst_n            (i_rst_n    ),//input			i_rst_n      		,

        /*Statistics signal*/
        .i_opto_switch      (w_opto_switch  ),//input			i_opto_switch		,//码盘信号输入
        .i_zero_sign        (o_zero_sign  ),//input           i_zero_sign         ,//零点信号
        .i_motor_state      (i_motor_state    ),//input           i_motor_state       ,//调速完�
        /*ram read*/
        .i_ram_raddr        (i_ram_raddr    ),//input   [5:0]   i_ram_raddr         ,// ram read data addr
        .i_ram_ren          (1'b1           ),//input           i_ram_ren           ,// ram read enable
        .o_ram_rdata        (o_ram_rdata    )//output  [31:0]  o_ram_rdata         // ram read data                                                           
);
endmodule                                                          
