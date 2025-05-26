module dist_measure
(
	input			i_clk_50m    		,
	input			i_clk_100m			,
	input			i_rst_n      		,
		
	input			i_angle_sync 		,//码盘信号标志，用以标志充电与出光
	input			i_opto_fall			,
	input	[7:0]	i_fall_cnt			,
	input			i_zero_sign			,
	input	[15:0]	i_zero_angle		,
	input			i_motor_state		,//1 = 调速完成 0 = 调速未完成
	input			i_measure_en		,
	input			i_sfim_switch		,
	input			i_rssi_switch		,
	input	[3:0]	i_reso_mode			,//分辨率
	input	[15:0]	i_zero_offset		,
	input	[15:0]	i_angle_offset		,
	input	[15:0]	i_start_index		,
	input	[15:0]	i_stop_index		,
	input	[15:0]	i_index_num			,
	
	input			i_tdc_init 			,
	input			i_tdc_spi_miso		,
	output			o_tdc_spi_mosi		,
	output			o_tdc_spi_ssn 		,
	output			o_tdc_spi_clk 		,
	
	input	[15:0]	i_rise_divid		,
	input	[15:0]	i_pulse_start		,
	input	[15:0]	i_pulse_divid		,
	input	[15:0]	i_distance_min		,
	input	[15:0]	i_distance_max		,
	input	[15:0]	i_dist_compen		,
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
	
	input   [63:0] i_ntp_get           ,
	input   [63:0] i_time_stamp_get    ,
	
	input			i_opto_switch		,
	input	[7:0]	i_opto_rddata		,
	output	[7:0]	o_opto_ram_rdaddr	,
	
	output	[15:0] 	o_code_angle_out	,
	
	output  [63:0]	o_ntp_first_get     ,
	output  [63:0]	o_time_stamp_first_get    ,
	
	output			o_tdc_err_sig				
);

	wire			w_tdc_new_sig;
	wire	[15:0]	w_angle_zero;
	
	wire	[15:0]	w_dist_data;
	wire	[15:0]	w_rssi_data;
	wire	[15:0]	w_rise_data;
	wire	[15:0]	w_fall_data;
	wire			w_dist_sig;
	
	wire	[63:0]	w_edge_data;
	wire	[15:0]	w_code_angle;
	wire			w_dist_sig_d;
	
	wire	[15:0]	w_dist_data_f;
	wire	[15:0]	w_rssi_data_f;
	wire	[15:0]	w_code_angle_f;
	wire			w_dist_sig_f;
	
	measure_para U1
	(
		.i_clk_50m    		(i_clk_50m)				,
		.i_rst_n      		(i_rst_n)				,
			
		.i_reso_mode		(i_reso_mode)			,
		.i_zero_offset		(i_zero_offset)			,
		.i_angle_offset		(i_angle_offset)		,
		.i_zero_angle		(i_zero_angle)			,
		.i_tdc_new_sig		(w_tdc_new_sig)			,
				
		.o_angle_zero		(w_angle_zero)			
	);
	
	as6500_control	U2
	(
		.i_clk_50m			(i_clk_50m)				,
		.i_clk_100m    		(i_clk_100m)			,
		.i_rst_n      		(i_rst_n)				,
		
		.i_angle_sync		(i_angle_sync)			,
		.i_motor_state		(i_motor_state)			,
		
		.i_tdc_init 		(i_tdc_init)			,
		.i_tdc_spi_miso		(i_tdc_spi_miso)		,
		.o_tdc_spi_mosi		(o_tdc_spi_mosi)		,
		.o_tdc_spi_ssn 		(o_tdc_spi_ssn)			,
		.o_tdc_spi_clk 		(o_tdc_spi_clk)			,

		.o_rise_data		(w_rise_data)			,//下降沿
		.o_fall_data		(w_fall_data)			,//下降沿
		.o_tdc_err_sig		(o_tdc_err_sig)			,
		.o_tdc_new_sig		(w_tdc_new_sig)			
	);
	
	dist_calculate U3
	(
		.i_clk_50m    		(i_clk_50m)				,
		.i_rst_n      		(i_rst_n)				,
		
		.i_rssi_switch		(i_rssi_switch)			,
		.i_tdc_new_sig		(w_tdc_new_sig)			,
		.i_rise_data		(w_rise_data)			,//上升沿
		.i_fall_data		(w_fall_data)			,//下降沿
		
		.i_rise_divid		(i_rise_divid)			,
		.i_pulse_start		(i_pulse_start)			,
		.i_pulse_divid		(i_pulse_divid)			,
		.i_distance_min		(i_distance_min)		,
		.i_distance_max		(i_distance_max)		,
		.i_dist_compen		(i_dist_compen)			,
		.o_coe_sram_addr	(o_coe_sram_addr)		,
		.i_coe_sram_data	(i_coe_sram_data)		,
		
		.o_dist_data		(w_dist_data)			,
		.o_rssi_data		(w_rssi_data)			,
		.o_dist_new_sig		(w_dist_sig)			
	);
	
	assign	o_code_angle_out = w_code_angle ;
	
	data_process_3 U4
	(
		.i_clk_50m    		(i_clk_50m)				,
		.i_rst_n      		(i_rst_n)				,
		
		.i_opto_switch		(i_opto_switch)			,
		.i_opto_rddata		(i_opto_rddata)			,
		.o_opto_ram_rdaddr	(o_opto_ram_rdaddr)		,
		
//		.i_angle_sync		(i_angle_sync)			,
		.i_opto_fall		(i_opto_fall)			,
		.i_zero_sign		(i_zero_sign)			,
		.i_fall_cnt			(i_fall_cnt)			,
		.i_reso_mode		(i_reso_mode)			,//分辨率
		.i_angle_zero		(w_angle_zero)			,
		
		.i_dist_sig			(w_dist_sig)			,
		.i_rise_data		(w_rise_data)			,//上升沿
		.i_fall_data		(w_fall_data)			,//下降沿
		.i_dist_data		(w_dist_data)			,
		.i_rssi_data		(w_rssi_data)			,
		
		.o_dist_sig			(w_dist_sig_d)			,
		.o_code_angle		(w_code_angle)			,
		.o_edge_data		(w_edge_data)			
	);
	
/*	dist_filter U5
	(
		.i_clk_50m    		(i_clk_50m)				,
		.i_rst_n      		(i_rst_n)				,
		
		.i_code_angle		(w_code_angle)			,
		.i_dist_data		(w_edge_data[31:16])	,
		.i_rssi_data		(w_edge_data[15:0])	,
		.i_dist_new_sig		(w_dist_sig_d)			,
		
		.i_sfim_switch		(i_sfim_switch)			,
		
		.o_code_angle		(w_code_angle_f)		,
		.o_dist_data		(w_dist_data_f)			,
		.o_rssi_data		(w_rssi_data_f)			,
		.o_dist_new_sig		(w_dist_sig_f)			
	);*/
	
	dist_packet U6
	(
		.i_clk_50m    		(i_clk_50m)				,
		.i_rst_n      		(i_rst_n)				,
		
		.i_measure_en		(i_measure_en)			,
		.i_code_angle 		(w_code_angle)		,//角度值
		.i_dist_data		(w_edge_data[31:16])	,
		.i_rssi_data		(w_edge_data[15:0])	,
		.i_dist_new_sig		(w_dist_sig_d)			,
		
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
		.o_packet_points	(o_packet_points)		,
		
		.i_ntp_get          (i_ntp_get)            ,
		.i_time_stamp_get   (i_time_stamp_get)     ,
		.o_ntp_first_get    (o_ntp_first_get)      ,
	    .o_time_stamp_first_get (o_time_stamp_first_get)
		
	);
	
	calib_packet U7
	(
		.i_clk_50m    		(i_clk_50m)				,
		.i_rst_n      		(i_rst_n)				,
		
		.i_measure_en		(i_measure_en)			,
		.i_code_angle 		(w_code_angle)			,//角度值
		.i_edge_data		(w_edge_data)			,
		.i_dist_new_sig		(w_dist_sig_d)			,
		
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