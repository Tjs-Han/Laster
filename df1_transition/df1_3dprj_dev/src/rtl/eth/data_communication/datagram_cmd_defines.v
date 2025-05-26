`define UDP_BROADCAST           16'h0000
`define HEARTBEAT               16'h0001
`define LINK_REQ                16'h0100
`define DISCONNECT			    16'h0101
`define SAVE_U_PARA				16'h0102
`define SET_INFO_IP			    16'h0103
`define SET_INFO_MAC            16'h0104
`define SET_INFO_DEVNAME        16'h0105
`define SET_INFO_SN             16'h0106
`define SET_LASER_SERNUM        16'h0107
`define SET_MOTOR_SWITCH        16'h0108
`define SET_HVCOMP_PARA			16'h0109
`define SET_MOTOR_FREQ			16'h010A



`define GET_INFO_IP			    16'h0200
`define GET_INFO_MAC            16'h0201
`define GET_INFO_FIRMWARE       16'h0202
`define GET_INFO_DEVNAME        16'h0203
`define GET_INFO_SN             16'h0204
`define GET_MOTOR_SWITCH        16'h0208
`define GET_HVCOMP_PARA			16'h0209
`define GET_MOTOR_FREQ			16'h020A

`define ONCE_DATA				16'h1000
`define LOOP_DATA_SWITCH        16'h1001
`define CALI_DATA				16'h2000
`define GET_CODE1 				16'h2001
`define GET_CODE2 				16'h2002

`define LOAD_F_CFG				16'd7
`define LOAD_U_CFG				16'd8
`define MEAS_SWITCH				16'd9
`define SET_GATEWAY				16'd17
`define GET_GATEWAY				16'd18
`define SET_SUBNET				16'd19
`define GET_SUBNET				16'd20
`define SET_MAC					16'd21
`define GET_MAC					16'd22
`define SET_SN 					16'd23
`define GET_SN 					16'd24

`define SET_ANGLE				16'd27
`define GET_ANGLE				16'd28
`define SET_ANGLE_RESO			16'd29
`define GET_ANGLE_RESO			16'd30

`define SET_TIMESTAMP			16'd31
`define GET_TIMESTAMP			16'd32
`define SET_RSSI_SWITCH			16'd33
`define GET_RSSI_SWITCH			16'd34
`define SET_TAIL_SWITCH			16'd35
`define GET_TAIL_SWITCH			16'd36
`define SET_DISCAL_SWITCH		16'd37
`define GET_DISCAL_SWITCH		16'd38

`define RESET_TDC				16'd64
`define GET_TEMP 				16'd65
`define GET_ADC					16'd66

`define SET_LASING_SWITCH		16'd69
`define GET_LASING_SWITCH		16'd70
`define SET_FILTER_SWITCH		16'd71
`define GET_FILTER_SWITCH		16'd72
`define SET_COMP_SWITCH			16'd73
`define GET_COMP_SWITCH			16'd74
`define SET_NTP_SWITCH			16'd75
`define GET_NTP_SWITCH			16'd76
`define SET_UP_PARA				16'd77
`define GET_UP_PARA				16'd78

`define SET_TDC_WIN				16'd81
`define GET_TDC_WIN				16'd82
`define GET_HV_VALUE			16'd83

`define SET_TAIL_PARA			16'd86
`define GET_TAIL_PARA			16'd87
`define SET_MOTOR_PWM			16'd88
`define GET_MOTOR_PWM			16'd89

`define SET_DIST_LMT			16'd92
`define GET_DIST_LMT			16'd93
`define SET_ANGLE_OFFSET		16'd94
`define GET_ANGLE_OFFSET		16'd95

`define SET_ZERO_OFFSET			16'd101
`define GET_ZERO_OFFSET			16'd102
`define	SET_TDC_SWITCH			16'd105
`define	GET_TDC_SWITCH			16'd106
`define	SET_DIST_DIFF			16'd107
`define	GET_DIST_DIFF			16'd108

`define SAVE_COE				16'd120
`define SET_COE 				16'd121
`define GET_COE 				16'd122
`define SET_COE_PARA			16'd123
`define GET_COE_PARA			16'd124

`define SET_RSSI_COE 			16'd140
`define GET_RSSI_COE 			16'd141

`define SAVE_CODE				16'd150
`define SET_CODE 				16'd151

`define SET_HVCP_DATA			16'd165
`define GET_HVCP_DATA			16'd166
`define SET_DICP_DATA			16'd167
`define GET_DICP_DATA			16'd168
`define GET_DIST_COMPEN			16'd169

`define GET_WORK_MODE           16'd240
`define GET_IAP_PRO             16'd241
`define ERROR					16'd255

`define CMD					    8'h00
`define ACK					    8'h01
`define MSG					    8'h02
