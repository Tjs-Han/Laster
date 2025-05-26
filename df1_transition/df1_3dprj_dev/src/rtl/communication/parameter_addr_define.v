// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: parameter_addr_define
// Date Created 	: 2023/11/01
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:parameter_addr_define
//              1、Store configuration parameters in a fixed area of the sram
//              2、Extract configuration parameters from the sram based on the address
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`define	PARAMETER_NUM		18'h200

`define DEVICE_MODE_CFG   	18'h00
`define SCAN_FREQUENCY		18'h01
`define ANGLE_RESOLUTION   	18'h02
`define	TDC_WINDOW			18'h03
`define ANGLE_OFFSET		18'h04
`define DIST_MIN			18'h05
`define DIST_MAX			18'h06
`define TEMP_APDHV_BASE		18'h07
`define TEMP_TEMP_BASE		18'h08
`define DIST_DIFF			18'h09
`define RSSI_MINVAL			18'h0A
`define RSSI_MAXVAL			18'h0B
// `define MOTOR_PWM_INIT		18'h0A

//sram addr strat 18'h40
`define TAIL_PARA_0			18'h40
`define TAIL_PARA_1			18'h41
`define TAIL_PARA_2			18'h42
`define TAIL_PARA_3			18'h43
`define TAIL_PARA_4			18'h44
`define TAIL_PARA_5			18'h45
`define TAIL_PARA_6			18'h46
`define TAIL_PARA_7			18'h47
`define TAIL_PARA_8			18'h48
`define TAIL_PARA_9			18'h49
`define TAIL_PARA_A			18'h4A
`define TAIL_PARA_B			18'h4B
`define TAIL_PARA_C			18'h4C
`define TAIL_PARA_D			18'h4D
`define TAIL_PARA_E			18'h4E
`define TAIL_PARA_F			18'h4F

//sram addr strat 18'h50
`define SMOOTH_PARA_0		18'h50
`define SMOOTH_PARA_1		18'h51
`define SMOOTH_PARA_2		18'h52
`define SMOOTH_PARA_3		18'h53
`define SMOOTH_PARA_4		18'h54
`define SMOOTH_PARA_5		18'h55
`define SMOOTH_PARA_6		18'h56
`define SMOOTH_PARA_7		18'h57
`define SMOOTH_PARA_8		18'h58
`define SMOOTH_PARA_9		18'h59
`define SMOOTH_PARA_A		18'h5A
`define SMOOTH_PARA_B		18'h5B
`define SMOOTH_PARA_C		18'h5C
`define SMOOTH_PARA_D		18'h5D
`define SMOOTH_PARA_E		18'h5E
`define SMOOTH_PARA_F		18'h5F

//sram addr strat 18'h60
`define TDC_PARA_0			18'h60
`define TDC_PARA_1			18'h61
`define TDC_PARA_2			18'h62
`define TDC_PARA_3			18'h63
`define TDC_PARA_4			18'h64
`define TDC_PARA_5			18'h65
`define TDC_PARA_6			18'h66
`define TDC_PARA_7			18'h67
`define TDC_PARA_8			18'h68
`define TDC_PARA_9			18'h69
`define TDC_PARA_A			18'h6A
`define TDC_PARA_B			18'h6B
`define TDC_PARA_C			18'h6C
`define TDC_PARA_D			18'h6D
`define TDC_PARA_E			18'h6E
`define TDC_PARA_F			18'h6F

//sram addr strat 18'h70
`define FIT_PARA_0			18'h70
`define FIT_PARA_1			18'h71
`define FIT_PARA_2			18'h72
`define FIT_PARA_3			18'h73
`define FIT_PARA_4			18'h74
`define FIT_PARA_5			18'h75
`define FIT_PARA_6			18'h76
`define FIT_PARA_7			18'h77
`define FIT_PARA_8			18'h78
`define FIT_PARA_9			18'h79
`define FIT_PARA_A			18'h7A
`define FIT_PARA_B			18'h7B
`define FIT_PARA_C			18'h7C
`define FIT_PARA_D			18'h7D
`define FIT_PARA_E			18'h7E
`define FIT_PARA_F			18'h7F

//sram addr strat 18'h80
`define JUMP_PARA_0			18'h80
`define JUMP_PARA_1			18'h81
`define JUMP_PARA_2			18'h82
`define JUMP_PARA_3			18'h83
`define JUMP_PARA_4			18'h84
`define JUMP_PARA_5			18'h85
`define JUMP_PARA_6			18'h86
`define JUMP_PARA_7			18'h87
`define JUMP_PARA_8			18'h88
`define JUMP_PARA_9			18'h89
`define JUMP_PARA_A			18'h8A
`define JUMP_PARA_B			18'h8B
`define JUMP_PARA_C			18'h8C
`define JUMP_PARA_D			18'h8D
`define JUMP_PARA_E			18'h8E
`define JUMP_PARA_F			18'h8F
