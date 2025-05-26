`define FIRMWARE_VERSION		32'h25042316

`define RESET_DEV				8'd0
`define LOGIN					8'd1
`define LOGOUT					8'd2
`define SET_PASSWORD			8'd3
`define CHECK_PASSWORD		8'd4
`define SAVE_F_PARA			8'd5
`define SAVE_U_PARA			8'd6
`define LOAD_F_CFG			8'd7
`define LOAD_U_CFG			8'd8
`define MEAS_SWITCH			8'd9
`define GET_DEV_ID			8'd10
`define GET_DEV_STA			8'd11
`define GET_FW_VER			8'd12
`define SET_DEV_NAME			8'd13
`define GET_DEV_NAME			8'd14
`define SET_IP					8'd15
`define GET_IP					8'd16
`define SET_GATEWAY			8'd17
`define GET_GATEWAY			8'd18
`define SET_SUBNET			8'd19
`define GET_SUBNET			8'd20
`define SET_MAC				8'd21
`define GET_MAC				8'd22
`define SET_SN 				8'd23
`define GET_SN 				8'd24
`define SET_RESOLUTION		8'd25 
`define GET_RESOLUTION		8'd26
`define SET_ANGLE				8'd27
`define GET_ANGLE				8'd28
`define SET_TIME_SWITCH		8'd29
`define GET_TIME_SWITCH		8'd30
`define SET_TIMESTAMP		8'd31
`define GET_TIMESTAMP		8'd32
`define SET_RSSI_SWITCH		8'd33
`define GET_RSSI_SWITCH		8'd34
`define SET_TRAIL_SWITCH	8'd35
`define GET_TRAIL_SWITCH	8'd36

`define SET_DIRT_SWITCH		8'd37
`define GET_DIRT_SWITCH		8'd38

`define ONCE_DATA				8'd48
`define LOOP_DATA_SWITCH	8'd49
`define LOOP_DATA 			8'd50

`define RESET_TDC				8'd64
`define GET_TEMP 				8'd65
`define GET_ADC				8'd66
`define SET_CALI_SWITCH		8'd67
`define GET_CALI_SWITCH		8'd68
`define SET_LASING_SWITCH	8'd69
`define GET_LASING_SWITCH	8'd70
`define SET_FILTER_SWITCH	8'd71
`define GET_FILTER_SWITCH	8'd72
`define SET_COMP_SWITCH		8'd73
`define GET_COMP_SWITCH		8'd74
`define SET_0_SWITCH			8'd75
`define GET_0_SWITCH			8'd76
`define SET_UP_PARA			8'd77
`define GET_UP_PARA			8'd78
`define SET_CHARGE_TIME		8'd79
`define GET_CHARGE_TIME		8'd80
`define SET_TDC_WIN			8'd81
`define GET_TDC_WIN			8'd82
`define GET_HV_VALUE		8'd83
`define SET_HV_REF			8'd84
`define GET_HV_REF			8'd85

`define SET_MOTOR_PWM			8'd88
`define GET_MOTOR_PWM			8'd89
`define SET_TEMP_COE			8'd90
`define GET_TEMP_COE			8'd91
`define SET_DIST_LMT			8'd92
`define GET_DIST_LMT			8'd93
`define SET_ANGLE_OFFSET	    8'd94
`define GET_ANGLE_OFFSET	    8'd95
`define SET_OPTO_PERIOD         8'd96 //tjs
`define GET_OPTO_PERIOD         8'd97

`define CALI_DATA				8'd100
`define SET_ZERO_OFFSET		    8'd101
`define GET_ZERO_OFFSET		    8'd102
`define SET_TEMP_DIST           8'd103
`define GET_TEMP_DIST           8'd104
`define SET_TDC_SWITCH         8'd105
`define GET_TDC_SWITCH         8'd106
`define SET_FIXED_VALUE        8'd107
`define GET_FIXED_VALUE        8'd108

`define SAVE_COE				8'd120
`define SET_COE 				8'd121
`define GET_COE 				8'd122
`define SET_COE_PARA			8'd123
`define GET_COE_PARA			8'd124

`define GET_DEBUG_INFO			8'd125

`define SET_RSSI_COE 			8'd140

`define SAVE_CODE				8'd150
`define SET_CODE 				8'd151

`define GET_WORK_MODE           8'd240
`define GET_IAP_PRO             8'd241
`define ERROR					8'd255

`define READ_DOWN				8'h00
`define WRITE_DOWN			8'h01
`define METHOD_DOWN			8'h02
`define READ_UP				8'h10
`define WRITE_UP				8'h11
`define METHOD_UP				8'h12