module c25x_fpga
(
	input			i_clk_50m		,
	
	input			i_opto_switch	,
	
	output			o_program_n		,
	
	output			o_motor_pwm		,
	output      		o_laser_str  	,
	output			o_thre_high		,
	output			o_thre_pulse	,
	
	output			o_disable_tdc	,
	output			o_rstidx_tdc	,

	
	input   		i_tdc_init    	,
	input   		i_tdc_spi_miso	,
	output  		o_tdc_spi_mosi	,
	output  		o_tdc_spi_ssn	,
	output  		o_tdc_spi_clk	,
	
	output      	o_sram_cs_n		,
	output      	o_sram_ub_n		,
	output      	o_sram_lb_n		,
	output      	o_sram_oe_n		,
	output      	o_sram_we_n		,
	output	[17:0]	o_sram_addr		,
	inout	[15:0]	io_sram_data	,

	output			o_flash_wp		,
	output			o_flash_hold	,

	output			o_flash_cs		,
	output			o_flash_mosi	,
	input			i_flash_miso	,
	
	output 			o_spi_cs		,
	output 			o_spi_dclk		,
	output			o_spi_mosi		,
	input			i_spi_miso		,
	output			o_w5500_rst		,
	
	output			o_adc_sclk		,
	output			o_adc_cs1		,
	output			o_adc_cs2		,
	input			i_adc_sda		,
	
	output			o_dac_scl		,
	output			o_dac_cs		,
	output			o_dac_sda		,
	
	output			o_led_state		,
	output			o_hv_en						
);

	wire			w_pll_50m;
	wire			w_pll_50m_2;
	wire			w_pll_100m;
	
	reg				r_rst_n = 1'b0;
	reg		[15:0]	r_rst_cnt = 16'd0;
	
	assign	o_flash_wp		= 1'b1;
	assign	o_flash_hold	= 1'b1;

	always@(posedge w_pll_50m)
		if(r_rst_cnt <= 16'd24999)
			r_rst_cnt	<= r_rst_cnt + 1'b1;
		else
			r_rst_cnt	<= r_rst_cnt;
			
	always@(posedge w_pll_50m)
		if(r_rst_cnt <= 16'd24999)	
			r_rst_n		<= 1'b0;
		else
			r_rst_n		<= 1'b1;
			
	c25x_pll U1
	(
		.CLKI			(i_clk_50m)		, 
		
		.CLKOP			(w_pll_50m)		, 
		.CLKOS			(w_pll_50m_2)	,
		.CLKOS2			(w_pll_100m)
	);
	
	wire			w_rst_n; 
	wire	[15:0]	w_config_mode;
	wire	[15:0]	w_pwm_value_0;
	wire	[15:0]	w_pwm_value;
	wire			w_motor_switch;
	wire			w_motor_state;
	wire			w_zero_sign;
	wire			w_opto_fall;
	wire	[7:0]	w_fall_cnt;
	wire	[15:0]	w_zero_angle;
	wire			w_angle_sync;
	wire	[15:0]	w_stop_window;
	wire	[15:0]	w_angle_offset;
	wire	[5:0]	w_random_seed;
	
	wire	[1:0]  w_motor_sync;
	
	wire	 		w_opto_make;	
	wire			w_opto_wren;
	wire	[7:0]	w_opto_wrdata;
	wire	[9:0]	w_opto_wraddr;
	wire			w_send_opto_flag;
	
	rotate_control U2
	(
		.i_clk_50m			(w_pll_50m)		,
		.i_rst_n			(w_rst_n)		,
		
		.i_opto_switch		(i_opto_switch)	,
		.i_config_mode 		(w_config_mode)	,
		.i_pwm_value_0		(w_pwm_value_0)	,
		.i_motor_switch		(w_motor_switch),
		.i_random_seed		(w_random_seed)	,
		
		.o_motor_state		(w_motor_state)	,
		.o_pwm_value  		(w_pwm_value)	,
		.o_motor_pwm  		(o_motor_pwm)	,
		.o_opto_fall 		(w_opto_fall)	,
		.o_fall_cnt			(w_fall_cnt)	,
		.o_zero_angle		(w_zero_angle)	,
		.o_zero_sign		(w_zero_sign)	,
		.o_angle_sync 		(w_angle_sync) 	
		
		
	);
	
	wire			w_measure_en;
	wire			w_tdc_err_sig;
	
	wire	[7:0]	w_status_code;
	wire	[15:0]	w_apd_hv_value;
	wire	[15:0]	w_temp_apdhv_base;
	wire	[15:0]	w_temp_temp_base;
	wire	[15:0]	w_temp_temp_coe;
	wire	[15:0]	w_apd_temp_value;
	wire	[7:0]	w_device_temp;	
	
	wire	[9:0]	w_dac_value;
	wire	[31:0]	w_dist_coe_para;
	wire	[15:0]	w_dist_diff;
	wire	[15:0]	w_dist_compen;
	
	self_inspection U3
	(
		.i_clk_50m    		(w_pll_50m)			,
		.i_rst_n      		(w_rst_n)			,
		
		.i_zero_sign		(w_zero_sign)		,
		.i_calib_mode		(w_config_mode[0])	,
		.i_tdc_err_sig		(w_tdc_err_sig)		,
		.i_motor_state		(w_motor_state)		,
		
		.i_temp_apdhv_base	(w_temp_apdhv_base)	,
		.i_temp_temp_base	(w_temp_temp_base)	,
		.i_temp_temp_coe	(w_temp_temp_coe)	,
		.i_dist_coe_para	(w_dist_coe_para)	,
		.i_dist_diff		(w_dist_diff)		,
		
		.o_status_code		(w_status_code)		,
		.o_apd_hv_value		(w_apd_hv_value)	,
		.o_apd_temp_value	(w_apd_temp_value)	,
		.o_device_temp		(w_device_temp)		,
		.o_dac_value		(w_dac_value)		,
		.o_dist_compen		(w_dist_compen)		,
		
		.o_measure_en		(w_measure_en)		,
		.o_led_state		(o_led_state)		,
		.o_hv_en			(o_hv_en)			,
		
		.o_adc_sclk			(o_adc_sclk)		,
		.o_adc_cs1			(o_adc_cs1)			,
		.o_adc_cs2			(o_adc_cs2)			,
		.i_adc_sda			(i_adc_sda)			,
	
		.o_dac_scl			(o_dac_scl)			,
		.o_dac_cs			(o_dac_cs)			,
		.o_dac_sda			(o_dac_sda)
	);
	
	laser_control U4
	(
		.i_clk_50m    	(w_pll_100m)	,
		.i_rst_n      	(w_rst_n)		,
		
		.i_angle_sync 	(w_angle_sync)	,
		.i_stop_window	(w_stop_window)	,
			
		.o_laser_str  	(o_laser_str)	,
		.o_disable_tdc	(o_disable_tdc)	,
		.o_rstidx_tdc  	(o_rstidx_tdc)	,
		.o_thre_high  	(o_thre_high)	,
		.o_thre_pulse  	(o_thre_pulse)	
	);
	
	wire	[17:0]	w_coe_sram_addr;
	wire	[15:0]	w_coe_sram_data;
	
	wire	[15:0]	w_rise_divid;
	wire	[15:0]	w_pulse_start;
	wire	[15:0]	w_pulse_divid;
	wire	[15:0]	w_distance_min;
	wire	[15:0]	w_distance_max;
	
	wire	[15:0]	w_start_index;
	wire	[15:0]	w_stop_index;
	wire	[15:0]	w_index_num;
	
	wire	[1:0]	w_filter_mode;
	wire	[15:0]	w_tail_para;
	wire	[15:0]	w_tail_diffmin;
	wire	[15:0]	w_tail_diffmax;
	
	wire	[1:0]	w_telegram_flag;		
	wire			w_packet_wren;
	wire	[7:0]	w_packet_wrdata;
	wire	[9:0]	w_packet_wraddr;
	wire			w_pakcet_pingpang;
	wire			w_packet_make;
	wire	[15:0]	w_packet_points;

	wire	[15:0]	w_scan_counter;
	wire	[7:0]	w_telegram_no;
	wire	[15:0]	w_first_angle;
	wire	[15:0]	w_zero_offset;
	
	wire			w_calib_wren;
	wire	[7:0]	w_calib_wrdata;
	wire	[9:0]	w_calib_wraddr;
	wire			w_calib_pingpang;
	wire			w_calib_make;
	wire	[15:0]	w_calib_points;
	
	wire	[63:0]	w_ntp_get;
	wire	[63:0]	w_time_stamp_get;
	wire	[63:0]	w_ntp_first_get;
	wire	[63:0]	w_time_stamp_first_get;	
	
	wire	[15:0]	w_code_angle;
	
	wire	[7:0]	w_opto_ram_rdaddr;
	wire	[7:0]	w_opto_rddata;
	wire			w_opto_switch;
	
	dist_measure U5
	(
		.i_clk_50m    		(w_pll_50m)				,
		.i_clk_100m			(w_pll_50m_2)			,
		.i_rst_n      		(w_rst_n)				,
			
		.i_angle_sync 		(w_angle_sync)			,
		.i_fall_cnt 		(w_fall_cnt)			,
		.i_opto_fall 		(w_opto_fall)			,
		.i_zero_sign		(w_zero_sign)			,
		.i_zero_angle		(w_zero_angle)			,
		.i_motor_state		(w_motor_state)			,
		.i_measure_en		(w_measure_en)			,
		.i_sfim_switch		(w_config_mode[4])		,
		.i_rssi_switch		(w_config_mode[2])		,
		.i_reso_mode		(w_config_mode[11:8])	        ,
		.i_start_index		(w_start_index)			,
		.i_stop_index		(w_stop_index)			,
		.i_index_num		(w_index_num)			,
		.i_zero_offset		(w_zero_offset)			,
		.i_angle_offset		(w_angle_offset)		,
		.i_dist_compen		(w_dist_compen)		,
		
		.i_tdc_init 		(i_tdc_init)			,
		.i_tdc_spi_miso		(i_tdc_spi_miso)		,
		.o_tdc_spi_mosi		(o_tdc_spi_mosi)		,
		.o_tdc_spi_ssn 		(o_tdc_spi_ssn)			,
		.o_tdc_spi_clk 		(o_tdc_spi_clk)			,
		
		.i_rise_divid		(w_rise_divid)			,
		.i_pulse_start		(w_pulse_start)			,
		.i_pulse_divid		(w_pulse_divid)			,
		.i_distance_min		(w_distance_min)		,
		.i_distance_max		(w_distance_max)		,
		.o_coe_sram_addr	(w_coe_sram_addr)		,
		.i_coe_sram_data	(w_coe_sram_data)		,
		
		.i_telegram_flag	(w_telegram_flag)		,		
		.o_packet_wren		(w_packet_wren)			,	
		.o_packet_pingpang	(w_packet_pingpang)		,
		.o_packet_wrdata	(w_packet_wrdata)		,
		.o_packet_wraddr	(w_packet_wraddr)		,
		.o_packet_make		(w_packet_make)			,
		
		.o_scan_counter		(w_scan_counter)		,
		.o_telegram_no		(w_telegram_no)			,
		.o_first_angle		(w_first_angle)			,
		.o_packet_points	(w_packet_points)		,
		
		.o_calib_wren		(w_calib_wren)			,	
		.o_calib_pingpang	(w_calib_pingpang)		,
		.o_calib_wrdata		(w_calib_wrdata)		,
		.o_calib_wraddr		(w_calib_wraddr)		,
		.o_calib_make		(w_calib_make)			,
		.o_calib_points		(w_calib_points)		,
		
		.o_code_angle_out	(w_code_angle)			,
		
		.i_opto_switch		(w_opto_switch)			,
		.o_opto_ram_rdaddr	(w_opto_ram_rdaddr)		,
		.i_opto_rddata		(w_opto_rddata)			,
		
		.i_ntp_get          (w_ntp_get)            ,
	    .i_time_stamp_get   (w_time_stamp_get)     ,
		.o_ntp_first_get    (w_ntp_first_get)      ,
	    .o_time_stamp_first_get   (w_time_stamp_first_get)     ,		
		
		.o_tdc_err_sig		(w_tdc_err_sig)			
	);
	
	
	wire			w_sram_csen_flash;
	wire			w_sram_wren_flash;
	wire			w_sram_rden_flash;
	wire	[17:0]	w_sram_addr_flash;
	wire	[15:0]	w_sram_wrdata_flash;
	wire	[15:0]	w_sram_rddata_flash;
		
	wire			w_sram_csen_eth;
	wire			w_sram_wren_eth;
	wire			w_sram_rden_eth;
	wire	[17:0]	w_sram_addr_eth;
	wire	[15:0]	w_sram_wrdata_eth;
	wire	[15:0]	w_sram_rddata_eth;
	
	sram_control U6
	(
		.i_clk_50m    		(w_pll_50m)				,
		.i_rst_n      		(r_rst_n)				,
		
		.i_sram_csen_flash	(w_sram_csen_flash)		,
		.i_sram_wren_flash	(w_sram_wren_flash)		,
		.i_sram_rden_flash	(w_sram_rden_flash)		,
		.i_sram_addr_flash	(w_sram_addr_flash)		,
		.i_sram_data_flash	(w_sram_wrdata_flash)	,
		.o_sram_data_flash	(w_sram_rddata_flash)	,
		
		.i_sram_csen_eth	(w_sram_csen_eth)		,
		.i_sram_wren_eth	(w_sram_wren_eth)		,
		.i_sram_rden_eth	(w_sram_rden_eth)		,
		.i_sram_addr_eth	(w_sram_addr_eth)		,
		.i_sram_data_eth	(w_sram_wrdata_eth)		,
		.o_sram_data_eth	(w_sram_rddata_eth)		,
		
		.i_sram_addr_dist	(w_coe_sram_addr)		,
		.o_sram_data_dist	(w_coe_sram_data)		,
		
		.o_sram_cs_n		(o_sram_cs_n)			,
		.o_sram_ub_n		(o_sram_ub_n)			,
		.o_sram_lb_n		(o_sram_lb_n)			,
		.o_sram_oe_n		(o_sram_oe_n)			,
		.o_sram_we_n		(o_sram_we_n)			,
		.o_sram_addr		(o_sram_addr)			,
		.io_sram_data		(io_sram_data)			
	);
	
	wire			w_read_complete_sig;	
	wire	[7:0]	w_sram_store_flag;
	
	flash_control U7
	(
		.i_clk_50m    		(w_pll_50m)				,
		.i_rst_n      		(r_rst_n)				,

		.o_flash_cs			(o_flash_cs)			,
		.o_flash_mosi		(o_flash_mosi)			,
		.i_flash_miso		(i_flash_miso)			,
		
		.o_sram_csen_flash	(w_sram_csen_flash)		,
		.o_sram_wren_flash	(w_sram_wren_flash)		,
		.o_sram_rden_flash	(w_sram_rden_flash)		,
		.o_sram_addr_flash	(w_sram_addr_flash)		,
		.o_sram_data_flash	(w_sram_wrdata_flash)	,
		.i_sram_data_flash	(w_sram_rddata_flash)	,
		
		.i_factory_sig		(w_sram_store_flag[4])	,
		.i_parameter_read	(w_sram_store_flag[3])	,
		.i_parameter_sig	(w_sram_store_flag[2])	,
		.i_cal_coe_sig		(w_sram_store_flag[1])	,
		.i_code_data_sig	(w_sram_store_flag[0])	,
		.i_code_packet_num	(w_sram_store_flag[7:5]),
		
		
		
		.o_iap_flag         (w_iap_flag)           ,
		
		.o_read_complete_sig(w_read_complete_sig)	
	);
	
	w5500_control U8
	(
		.i_clk_50m			(w_pll_50m)				,
		.i_rst_n			(r_rst_n)				,
		
		.o_spi_cs			(o_spi_cs)				,
		.o_spi_dclk			(o_spi_dclk)			,
		.o_spi_mosi			(o_spi_mosi)			,
		.i_spi_miso			(i_spi_miso)			,
		.o_w5500_rst		(o_w5500_rst)			,
		
		.i_read_complete_sig(w_read_complete_sig)	,
		
		.o_sram_csen_eth	(w_sram_csen_eth)		,
		.o_sram_wren_eth	(w_sram_wren_eth)		,
		.o_sram_rden_eth	(w_sram_rden_eth)		,
		.o_sram_addr_eth	(w_sram_addr_eth)		,
		.o_sram_data_eth	(w_sram_wrdata_eth)		,
		.i_sram_data_eth	(w_sram_rddata_eth)		,
		
		.i_packet_wren		(w_packet_wren)			,	
		.i_packet_pingpang	(w_packet_pingpang)		,
		.i_packet_wrdata	(w_packet_wrdata)		,
		.i_packet_wraddr	(w_packet_wraddr)		,
		.i_packet_make		(w_packet_make)			,
		.i_packet_points	(w_packet_points)		,
		
		.i_scan_counter		(w_scan_counter)		,
		.i_telegram_no		(w_telegram_no)			,
		.i_first_angle		(w_first_angle)			,
		
		.i_calib_wren		(w_calib_wren)			,	
		.i_calib_pingpang	(w_calib_pingpang)		,
		.i_calib_wrdata		(w_calib_wrdata)		,
		.i_calib_wraddr		(w_calib_wraddr)		,
		.i_calib_make		(w_calib_make)			,
		.i_calib_points		(w_calib_points)		,
		
		.i_fall_cnt		(w_fall_cnt)			,
		.i_code_angle		(w_code_angle)			,
		.i_status_code		(w_status_code)			,
		.i_apd_hv_value		(w_apd_hv_value)		,
		.i_apd_temp_value	(w_apd_temp_value)		,
		.i_device_temp		(w_device_temp)			,
		.i_dac_value		(w_dac_value)			,
		.i_pwm_value  		(w_pwm_value)			,
		
		.o_motor_switch		(w_motor_switch)		,
		.o_config_mode		(w_config_mode)			,
		.o_pwm_value_0		(w_pwm_value_0)			,
		.o_stop_window		(w_stop_window)			,
		.o_zero_offset		(w_zero_offset)			,
		.o_angle_offset		(w_angle_offset)		,
		.o_rise_divid 		(w_rise_divid)			,
		.o_pulse_start 		(w_pulse_start)			,
		.o_pulse_divid		(w_pulse_divid)			,
		.o_distance_min		(w_distance_min)		,
		.o_distance_max		(w_distance_max)		,
		.o_dist_coe_para	(w_dist_coe_para)		,
		.o_dist_diff		(w_dist_diff)			,
		.o_temp_apdhv_base	(w_temp_apdhv_base)		,
		.o_temp_temp_base	(w_temp_temp_base)		,
		.o_temp_temp_coe	(w_temp_temp_coe)		,
		.o_start_index		(w_start_index)			,
		.o_stop_index		(w_stop_index)			,
		.o_index_num		(w_index_num)			,
		.o_random_seed		(w_random_seed)			,
		
		.o_telegram_flag	(w_telegram_flag)		,
		.o_sram_store_flag	(w_sram_store_flag)		,
		
		
	    .o_ntp_get          (w_ntp_get)            ,
	    .o_time_stamp_get   (w_time_stamp_get)     ,	
        .i_ntp_first_get    (w_ntp_first_get )     ,		
        .i_time_stamp_first_get    (w_time_stamp_first_get )     ,
		
		.i_opto_ram_rdaddr	(w_opto_ram_rdaddr),
		.o_opto_rddata		(w_opto_rddata)	,	
		.o_opto_switch		(w_opto_switch),
		
		
		.o_program_n		(o_program_n)			,
		.o_rst_n			(w_rst_n)               ,
		.i_iap_flag         (w_iap_flag)
	);



endmodule 