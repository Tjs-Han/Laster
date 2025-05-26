module C200_FPGA
(
	input			i_clk_50m		,
	input			i_rst_n			,
	
	input			i_opto_switch	,
	
	output			o_program_n		,
	
	output			o_motor_pwm		,
	output      	o_laser_str  	,//鍑哄厜淇″彿锛屽厖鐢靛悗绛夊緟2us鍑哄厜
	output      	o_tdc_start  	,//TDC涓绘尝绐楀彛
	output      	o_tdc_stop1  	,//TDC鍥炴尝绐楀彛
	output      	o_tdc_stop2  	,//TDC鍥炴尝绐楀彛	
	
	input       	i_tdc_init    	,
	input       	i_tdc_spi_miso	,
	output      	o_tdc_spi_mosi	,
	output      	o_tdc_spi_ssn	,
	output      	o_tdc_spi_clk	,
	output      	o_tdc_reset		,
	
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
	output			o_flash_clk		,
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

	wire			w_pll_25m;
	wire			w_pll_50m;
	wire			w_pll_200m;

	wire 			save_user_sram_to_factory_flash_valid;
	wire 			save_factory_sram_to_user_flash_valid;
	
	reg				r_rst_n = 1'b0;
	reg		[19:0]	r_rst_cnt = 20'd0;

	wire 	[1:0]   dist_report_error;
	wire 	[1:0]	tdc_process_error;
	wire    [31:0]	state_tsatic_value;

	wire    [15:0]  tdc_process_error_last_code;
	wire    [15:0]  tdc_process_error_current_code;
	
	
	always@(posedge w_pll_25m)
		if(r_rst_cnt <= 20'hffffe)
			r_rst_cnt	<= r_rst_cnt + 1'b1;
		else
			r_rst_cnt	<= r_rst_cnt;
			
	always@(posedge w_pll_25m)
		if(r_rst_cnt <= 20'hffffe)	
			r_rst_n		<= 1'b0;
		else
			r_rst_n		<= 1'b1;

	C200_PLL U1
	(
		.CLKI			(i_clk_50m)		, 
		
		.CLKOP			(w_pll_25m)		, 
		.CLKOS			(w_pll_50m)	, 
		.CLKOS2			(w_pll_100m)	
	);
	
	wire            o_motor_rst_n;
	wire			w_rst_n;
	wire	[7:0]	w_config_mode;
	wire	[15:0]	w_pwm_value_0;
	wire	[15:0]	w_pwm_value;
	wire			w_motor_state;
	wire			w_zero_sign;
	wire	[15:0]	w_code_angle;
	wire	[15:0]	w_zero_angle;
	wire			w_angle_sync;
	wire	[15:0]	w_stop_window;
	wire	[15:0]	w_angle_offset;
	
	wire			w_encoder_right;
	
	rotating_module U2
	(
		.i_clk_50m		(w_pll_25m)		,
		.i_rst_n		(o_motor_rst_n)		,
		
		.i_opto_switch	(i_opto_switch)	,//鐮佺洏淇″彿杈撳叆
		.i_config_mode 	(w_config_mode)	,
		//0:鏍囧畾妯″紡鏍囧織 1 = 鏍囧畾妯″紡 0 = 鏅€氭ā寮2:1:杞€熸ā寮忔爣蹇1 = 25Hz 0 = 15hz 
		//4:3:鍒嗚鲸鐜囨ā寮忔爣蹇3 = 0.5 2 = 0.33 1 = 0.25 0 = 0.2 
		//5:鍑哄厜妯″紡鏍囧織浣1 = 鍑哄厜妯″紡 0 = 涓嶅嚭鍏夋ā寮
		//6:娴嬭窛妯″紡 1锛氭祴璺濇ā寮0锛氫紤鐪犳ā寮
		//7:鑴夊妯″紡 1锛氳剦瀹芥ā寮0锛氭俯琛ユā寮
		.i_pwm_value_0	(w_pwm_value_0)	,//鐢垫満杞€熷垵濮嬪€
		.i_angle_offset	(w_angle_offset),
		
		
		.o_encoder_right(w_encoder_right),
		.o_motor_state	(w_motor_state)	,//1 = 璋冮€熷畬鎴0 = 璋冮€熸湭瀹屾垚
		.o_pwm_value  	(w_pwm_value)	,//褰撳墠鐢垫満PWM鍊
		.o_motor_pwm  	(o_motor_pwm)	,//鐢垫満PWM杈撳嚭
		.o_code_angle 	(w_code_angle)	,//瑙掑害鍊
		.o_zero_angle	(w_zero_angle)	,
		.o_zero_sign	(w_zero_sign)	,
		.o_angle_sync 	(w_angle_sync) 	 //鐮佺洏淇″彿鏍囧織锛岀敤浠ユ爣蹇楀厖鐢典笌鍑哄厜
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
	
	wire	[15:0]	w_apd_hv_base;
	wire	[15:0]	w_pulse_set;
	wire	[15:0]	w_pulse_get;
	
	wire	[9:0]	w_dac_value;
	
	wire    [31:0] w_temp_dist;
	wire            w_add_sub_flag;
	wire   [15:0]  w_dist_temp_value;
	
	wire			w_dirt_warn;
	wire			w_apd_err ;
	
	self_inspection U3
	(
		.i_clk_50m    		(w_pll_25m)			,
		.i_rst_n      		(w_rst_n)			,
		
		.i_zero_sign		(w_zero_sign)		,
		.i_pulse_mode		(w_config_mode[7])	,
		.i_calib_mode		(w_config_mode[0])	,
		.i_tdc_err_sig		(w_tdc_err_sig)		,
		.i_motor_state		(w_motor_state)		,
		
		.i_apd_hv_base		(w_apd_hv_base)		,
		.i_temp_apdhv_base	(w_temp_apdhv_base)	,
		.i_temp_temp_base	(w_temp_temp_base)	,
		.i_temp_temp_coe	(w_temp_temp_coe)	,
		.i_pulse_set		(w_pulse_set)		,
		.i_pulse_get		(w_pulse_get)		,
		
		.i_encoder_right    (w_encoder_right)  ,
		.i_apd_err			(w_apd_err)			,
		
		.o_status_code		(w_status_code)		,
		.o_apd_hv_value		(w_apd_hv_value)	,
		.o_apd_temp_value	(w_apd_temp_value)	,
		.o_device_temp		(w_device_temp)		,
		.o_dac_value		(w_dac_value)		,
		
		.o_measure_en		(w_measure_en)		,
		.o_led_state		(o_led_state)		,
		.o_hv_en			(o_hv_en)			,
		
		.o_adc_sclk			(o_adc_sclk)		,
		.o_adc_cs1			(o_adc_cs1)			,
		.o_adc_cs2			(o_adc_cs2)			,
		.i_adc_sda			(i_adc_sda)			,
	
		.o_dac_scl			(o_dac_scl)			,
		.o_dac_cs			(o_dac_cs)			,
		.o_dac_sda			(o_dac_sda)         ,
		
		.i_temp_comp_flag  (w_temp_dist[24])   ,
		.i_temp_base_value (w_temp_dist[23:16]) ,
		.i_temp_comp_coe   (w_temp_dist[15:0])  ,
		
		.o_add_sub_flag    (w_add_sub_flag)    ,
		.o_dist_temp_value (w_dist_temp_value) ,
		
		.i_dirt_warn		 (w_dirt_warn)	      ,
		.state_tsatic_value	 (state_tsatic_value)
		
	);
	
	laser_control U4
	(
		.i_clk_50m    	(w_pll_100m)	,
		.i_rst_n      	(w_rst_n)		,
		
		.i_angle_sync 	(w_angle_sync)	,//鐮佺洏淇″彿鏍囧織锛岀敤浠ユ爣蹇楀厖鐢典笌鍑哄厜
		.i_stop_window	(w_stop_window)	,//TDC绐楀彛璁剧疆
			
		.o_laser_str  	(o_laser_str)	,//鍑哄厜淇″彿锛屽厖鐢靛悗绛夊緟2us鍑哄厜
		.o_tdc_start  	(o_tdc_start)	,//TDC涓绘尝绐楀彛
		.o_tdc_stop1  	(o_tdc_stop1)	,//TDC鍥炴尝绐楀彛
		.o_tdc_stop2  	(o_tdc_stop2)	
	);
	
	wire	[17:0]	w_coe_sram_addr;
	wire	[15:0]	w_coe_sram_data;
	
	wire	[15:0]	w_rise_start;
	wire	[15:0]	w_pulse_start;
	wire	[15:0]	w_pulse_rise;
	wire	[15:0]	w_pulse_fall;
	wire	[15:0]	w_distance_min;
	wire	[15:0]	w_distance_max;
	wire	[15:0]	w_start_index;
	wire	[15:0]	w_stop_index;
	wire	[15:0]	w_index_num;
	
	wire	[1:0]	w_filter_mode;
	
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
	
	wire    [7:0]  w_tdc_switch;
	wire    [15:0] w_fixed_value;
	
	wire    		w_dirt_mode;
	wire    [7:0]	w_dirt_points;
//	wire    [15:0] w_dirt_rise;
	
	wire    [15:0] w_fisrt_rise;
	
	dist_measure U5
	(
		.i_clk_25m    		(w_pll_25m)				,
		.i_clk_50m    		(w_pll_50m)				,
		.i_rst_n      		(w_rst_n)				,
			
		.i_angle_sync 		(w_angle_sync)			,//鐮佺洏淇″彿鏍囧織锛岀敤浠ユ爣蹇楀厖鐢典笌鍑哄厜
		.i_code_angle 		(w_code_angle)			,//瑙掑害鍊
		.i_zero_angle		(w_zero_angle)			,
		.i_motor_state		(w_motor_state)			,//1 = 璋冮€熷畬鎴0 = 璋冮€熸湭瀹屾垚
		.i_measure_en		(w_measure_en)			,
		.i_reso_mode		(w_config_mode[4:3])	,//鍒嗚鲸鐜
		.i_start_index		(w_start_index)			,
		.i_stop_index		(w_stop_index)			,
		.i_index_num		(w_index_num)			,
		.i_zero_offset		(w_zero_offset)			,
		.i_filter_mode		(w_filter_mode)			,
		
		.i_tdc_init 		(i_tdc_init)			,
		.i_tdc_spi_miso		(i_tdc_spi_miso)		,
		.o_tdc_spi_mosi		(o_tdc_spi_mosi)		,
		.o_tdc_spi_ssn 		(o_tdc_spi_ssn)			,
		.o_tdc_spi_clk 		(o_tdc_spi_clk)			,
		.o_tdc_reset   		(o_tdc_reset)			,
		
		.i_rise_start		(w_rise_start)			,
		.i_pulse_start		(w_pulse_start)			,
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
		
		.o_pulse_get		(w_pulse_get)			,
		.o_pulse_rise		(w_pulse_rise)			,
		.o_pulse_fall		(w_pulse_fall)			,
		
		.o_tdc_err_sig		(w_tdc_err_sig)			,
		
		.o_apd_err			(w_apd_err)				,
		
		.i_add_sub_flag     (w_add_sub_flag)      ,
		.i_dist_temp_value  (w_dist_temp_value)   ,
		.i_tdc_switch       (w_tdc_switch[0])     ,
		.i_fixed_value      ({1'd0,w_fixed_value[14:0]}) ,
		.i_fixed_value_flag (w_fixed_value[15])    ,
		
		.o_dirt_warn		(w_dirt_warn)			,
		.i_dirt_mode		(w_dirt_mode)			,
		.i_dirt_points		(w_dirt_points)			,
		.i_dirt_rise		(w_fisrt_rise)			,

		.dist_report_error  (dist_report_error)		,
		.tdc_process_error  (tdc_process_error)     ,

		.tdc_process_error_last_code  (tdc_process_error_last_code)     ,
		.tdc_process_error_current_code  (tdc_process_error_current_code) 			
		
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
		.i_clk_50m    		(w_pll_25m)				,
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
	wire            w_iap_flag;
	wire			w_flash_busy;
	
	flash_control_2 U7
	(
		.i_clk_50m    		(w_pll_25m)				,
		.i_rst_n      		(r_rst_n)				,
		
		.o_flash_wp			(o_flash_wp)			,
		.o_flash_hold		(o_flash_hold)			,
		.o_flash_cs			(o_flash_cs)			,
		.o_flash_clk		(o_flash_clk)			,
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

		.save_user_sram_to_factory_flash_valid 	(save_user_sram_to_factory_flash_valid),
		.save_factory_sram_to_user_flash_valid  (save_factory_sram_to_user_flash_valid),		
		
		.o_iap_flag         (w_iap_flag)           ,
		
		.o_flash_busy		(w_flash_busy)			,
		
		.o_fisrt_rise		(w_fisrt_rise)			,
		
		.o_read_complete_sig(w_read_complete_sig)	
	);
	
	//assign state_tsatic_value = {tdc_process_error_last_code[15:0],tdc_process_error_current_code[15:0]};
	
	w5500_control U8
	(
		.i_clk_50m			(w_pll_25m)				,
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
		
		.i_code_angle		(w_code_angle)			,
		.i_pulse_get		(w_pulse_get)			,
		.i_pulse_rise		(w_pulse_rise)			,
		.i_pulse_fall		(w_pulse_fall)			,
		.i_status_code		(w_status_code)			,
		.i_apd_hv_value		(w_apd_hv_value)		,
		.i_apd_temp_value	(w_apd_temp_value)		,
		.i_device_temp		(w_device_temp)			,
		.i_dac_value		(w_dac_value)			,
		.i_pwm_value  		(w_pwm_value)			,//褰撳墠鐢垫満PWM鍊
		
		.o_config_mode		(w_config_mode)			,
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
		.save_factory_sram_to_user_flash_valid  (save_factory_sram_to_user_flash_valid),
		
		.o_program_n		(o_program_n)			,
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
		.o_dirt_points		(w_dirt_points)			
	);

endmodule 