module dist_measure
(
	input			i_clk_25m    		,
	input			i_clk_50m    		,
	input			i_rst_n      		,
		
	input			i_angle_sync 		,//�����źű�־�����Ա�־��������
	input	[15:0]	i_code_angle 		,//�Ƕ�ֵ
	input	[15:0]	i_zero_angle		,
	input			i_motor_state		,//1 = ������� 0 = ����δ���
	input			i_measure_en		,
	input	[1:0]	i_reso_mode			,//�ֱ���
	input	[15:0]	i_zero_offset		,
	input	[15:0]	i_start_index		,
	input	[15:0]	i_stop_index		,
	input	[15:0]	i_index_num			,
	input	[1:0]	i_filter_mode		,
	
	input			i_tdc_init 			,
	input			i_tdc_spi_miso		,
	output			o_tdc_spi_mosi		,
	output			o_tdc_spi_ssn 		,
	output			o_tdc_spi_clk 		,
	output			o_tdc_reset   		,
	
	input	[15:0]	i_rise_start		,
	input	[15:0]	i_pulse_start		,
	input	[15:0]	i_distance_min		,
	input	[15:0]	i_distance_max		,
	output	[17:0]	o_coe_sram_addr		,
	input	[15:0]	i_coe_sram_data		,
	
	input	[1:0]	i_telegram_flag		,		
	output			o_packet_wren		,
	output			o_packet_pingpang	,
	output	[7:0]	o_packet_wrdata		,
	output	[9:0]	o_packet_wraddr		,
	output			o_packet_make		,
	output	[15:0]	o_packet_points		,
	
	output	[15:0]	o_scan_counter		,
	output	[7:0]	o_telegram_no		,
	output	[15:0]	o_first_angle		,
	
	output			o_calib_pingpang	,
	output			o_calib_wren		,
	output	[7:0]	o_calib_wrdata		,
	output	[9:0]	o_calib_wraddr		,
	output			o_calib_make		,
	output	[15:0]	o_calib_points		,
	
	output	[15:0]	o_pulse_get			,
	output	[15:0]	o_pulse_rise		,
	output	[15:0]	o_pulse_fall		,
	
	output			o_tdc_err_sig	    ,
	
	output			o_dirt_warn			,
	
	output			o_apd_err			,
	
	input          i_add_sub_flag      ,
	input   [15:0] i_dist_temp_value   ,
	input          i_tdc_switch        ,
	
	input   [15:0] i_fixed_value       ,
	input          i_fixed_value_flag	,
	input          	i_dirt_mode			,
	input   [7:0]	i_dirt_points		,
	input   [15:0] i_dirt_rise	        ,

	output  wire [1:0]   dist_report_error,
	output  wire [1:0]   tdc_process_error,		
	output  wire [15:0]  tdc_process_error_last_code,		
	output  wire [15:0]  tdc_process_error_current_code				
	);

	wire			w_tdc_new_sig;
	
	wire	[15:0]	w_dist_data;
	wire	[15:0]	w_rssi_data;
	wire	[15:0]	w_rise_data;
	wire	[15:0]	w_fall_data;
	wire			w_dist_sig;
	
	wire	[15:0]	w_dist_data_f;
	wire	[15:0]	w_rssi_data_f;
	wire	[15:0]	w_code_angle_f;
	wire			w_dist_sig_f;
	
	wire	[15:0]	w_dist_data_t;
	wire	[15:0]	w_rssi_data_t;
	wire	[15:0]	w_code_angle_t;
	wire			w_dist_sig_t;

	gp22_control U1
	(
		.i_clk_50m    		(i_clk_50m)				,
		.i_rst_n      		(i_rst_n)				,
			
		.i_angle_sync 		(i_angle_sync)			,//�����źű�־�����Ա�־��������
		.i_code_angle 		(i_code_angle)			,//�Ƕ�ֵ
		.i_zero_angle		(i_zero_angle)			,
		.i_measure_en		(i_motor_state)			,//1 = ������� 0 = ����δ���
		.i_reso_mode		(i_reso_mode)			,//�ֱ���
		.i_stop_index		(i_stop_index)			,
		.i_zero_offset		(i_zero_offset)			,
		
		.i_gp22_init 		(i_tdc_init)			,
		.i_gp22_spi_miso	(i_tdc_spi_miso)		,
		.o_gp22_spi_mosi	(o_tdc_spi_mosi)		,
		.o_gp22_spi_ssn 	(o_tdc_spi_ssn)			,
		.o_gp22_spi_clk 	(o_tdc_spi_clk)			,
		.o_gp22_reset   	(o_tdc_reset)			,
		
		.o_apd_err			(o_apd_err)				,

		.o_rise_data		(w_rise_data)			,//������
		.o_fall_data		(w_fall_data)			,//�½���
		.o_pulse_get		(o_pulse_get)			,
		.o_pulse_rise		(o_pulse_rise)			,
		.o_pulse_fall		(o_pulse_fall)			,
		.o_tdc_err_sig		(o_tdc_err_sig)			,
		.o_tdc_new_sig		(w_tdc_new_sig)			
	);
	
	wire	[15:0]	w_code_angle_d;
	wire	     	w_cal_sig;
	wire	[15:0]	w_rise_data_d;
	wire	[15:0]	w_fall_data_d;
	wire            w_tdc_switch;

	
	
	tdc_process U2
	(
		.i_clk_50m    		(i_clk_25m)				,
		.i_rst_n      		(i_rst_n)				,
		
		.i_code_angle 		(i_code_angle)			,//�Ƕ�ֵ
		.i_tdc_new_sig		(w_tdc_new_sig)			,
		.i_rise_data		(w_rise_data)			,//������
		.i_fall_data		(w_fall_data)			,//�½���

		.i_start_index		(i_start_index)			,
		.i_stop_index		(i_stop_index)			,		
		
		.i_tdc_switch       (i_tdc_switch)         ,//tdc����
		
		.o_code_angle 		(w_code_angle_d)		,//�Ƕ�ֵ
		.o_cal_sig			(w_cal_sig)				,
		.o_rise_data		(w_rise_data_d)			,//������
		.o_fall_data		(w_fall_data_d)			,//�½���
		.i_reso_mode		(i_reso_mode)       	,

		.tdc_process_error	(tdc_process_error) 	,
		.tdc_process_error_last_code	(tdc_process_error_last_code) 	,
		.tdc_process_error_current_code	(tdc_process_error_current_code)				

	);
	
	
	wire	w_dirt_stop	;
	
	dist_calculate_4 U3
	(
		.i_clk_50m    		(i_clk_25m)				,
		.i_rst_n      		(i_rst_n)				,
		
		.i_dirt_warn		(o_dirt_warn)			,
		.i_stop_index		(i_stop_index)			,
		.i_code_angle 		(w_code_angle_d)			,//�Ƕ�ֵ
		.i_tdc_new_sig		(w_cal_sig)			,
		.i_rise_data		(w_rise_data_d)			,//������
		.i_fall_data		(w_fall_data_d)			,//�½���
		
		.i_rise_start		(i_rise_start)			,
		.i_pulse_start		(i_pulse_start)			,
		.i_distance_min		(i_distance_min)		,
		.i_distance_max		(i_distance_max)		,
		.o_coe_sram_addr	(o_coe_sram_addr)		,
		.i_coe_sram_data	(i_coe_sram_data)		,
		
		.o_dist_data		(w_dist_data)			,
		.o_rssi_data		(w_rssi_data)			,
		.o_dist_new_sig		(w_dist_sig)			,
		.i_add_sub_flag		(i_add_sub_flag)       ,
		.i_dist_temp_value	(i_dist_temp_value)    ,
		
		.i_fixed_value		(i_fixed_value)        ,
		.i_fixed_value_flag	(i_fixed_value_flag)	,
		
		.i_dirt_mode		(i_dirt_mode)			,
		.i_dirt_points		(i_dirt_points)			,
		.i_dirt_rise		(i_dirt_rise)			,
		.o_dirt_warn		(o_dirt_warn)
	);
	
	dist_filter U4
	(
		.i_clk_50m    		(i_clk_25m)				,
		.i_rst_n      		(i_rst_n)				,
		
		.i_code_angle 		(w_code_angle_d)		,//�Ƕ�ֵ
		.i_dist_data		(w_dist_data)			,
		.i_rssi_data		(w_rssi_data)			,
		.i_dist_new_sig		(w_dist_sig)			,
		
		.i_sfim_switch		(i_filter_mode[1])		,
		
		.o_code_angle 		(w_code_angle_f)		,//�Ƕ�ֵ
		.o_dist_data		(w_dist_data_f)			,
		.o_rssi_data		(w_rssi_data_f)			,
		.o_dist_new_sig		(w_dist_sig_f)	

	);
	
	dist_packet U5
	(
		.i_clk_50m    		(i_clk_25m)				,
		.i_rst_n      		(i_rst_n)				,
		
		.i_measure_en		(i_measure_en ),
		.i_code_angle 		(w_code_angle_f)		,//(i_code_angle)			,//�Ƕ�ֵ
		.i_dist_data		(w_dist_data_f)			,//(w_dist_data)			,
		.i_rssi_data		(w_rssi_data_f)			,//(w_rssi_data)			,
		.i_dist_new_sig		(w_dist_sig_f)			,//(w_dist_sig)				,
		
		.i_start_index		(i_start_index)			,
		.i_stop_index		(i_stop_index)			,
		.i_transmit_flag	(i_telegram_flag[0])	,
		
		.o_packet_pingpang	(o_packet_pingpang)		,
		.o_packet_wraddr	(o_packet_wraddr)		,
		.o_packet_wren		(o_packet_wren)			,
		.o_packet_wrdata	(o_packet_wrdata)		,
		
		.o_packet_make		(o_packet_make)			,
		.o_scan_counter		(o_scan_counter)		,
		.o_telegram_no		(o_telegram_no)			,
		.o_first_angle		(o_first_angle)			,
		.o_packet_points	(o_packet_points)	    ,
        .i_motor_state		(i_motor_state)	        ,
		.dist_report_error  (dist_report_error)			    
	);
	
	calib_packet U6
	(
		.i_clk_50m    		(i_clk_25m)				,
		.i_rst_n      		(i_rst_n)				,
		
		.i_measure_en		(i_measure_en)			,
		.i_code_angle 		(w_code_angle_d)			,//�Ƕ�ֵ
		.i_rise_data		(w_rise_data_d)			,//������
		.i_fall_data		(w_fall_data_d)			,//�½���
		.i_dist_data		(w_dist_data)			,
		.i_rssi_data		(w_rssi_data)			,///////////////////////////////////
		.i_dist_new_sig		(w_dist_sig)			,
		
		.i_start_index		(i_start_index)			,
		.i_stop_index		(i_stop_index)			,
		.i_calibrate_flag	(i_telegram_flag[1])	,
		
		.o_calib_pingpang	(o_calib_pingpang)		,
		.o_calib_wrdata		(o_calib_wrdata)		,
		.o_calib_wraddr		(o_calib_wraddr)		,
		.o_calib_wren		(o_calib_wren)			,
		
		.o_calib_make		(o_calib_make)			,
		.o_calib_points		(o_calib_points)				
	);
	
	
	
endmodule 