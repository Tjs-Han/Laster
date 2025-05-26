module w5500_control
(
	input			i_clk_50m			,
	input			i_rst_n				,
	
	output 			o_spi_cs			,
	output 			o_spi_dclk			,
	output			o_spi_mosi			,
	input			i_spi_miso			,
	output			o_w5500_rst			,
	
	input			i_read_complete_sig	,
	
	output			o_sram_csen_eth		,
	output			o_sram_wren_eth		,
	output			o_sram_rden_eth		,
	output	[17:0]	o_sram_addr_eth		,
	output	[15:0]	o_sram_data_eth		,
	input	[15:0]	i_sram_data_eth		,
	
	input			i_packet_wren		,	
	input			i_packet_pingpang	,
	input	[7:0]	i_packet_wrdata		,
	input	[9:0]	i_packet_wraddr		,
	input			i_packet_make		,
	input	[15:0]	i_packet_points		,
	
	input	[15:0]	i_scan_counter		,
	input	[7:0]	i_telegram_no		,
	input	[15:0]	i_first_angle		,
	
	input			i_calib_wren		,	
	input			i_calib_pingpang	,
	input	[7:0]	i_calib_wrdata		,
	input	[9:0]	i_calib_wraddr		,
	input			i_calib_make		,
	input	[15:0]	i_calib_points		,
	
	input	[15:0]	i_code_angle		,
	input	[15:0]	i_pulse_get			,
	input	[15:0]	i_pulse_rise		,
	input	[15:0]	i_pulse_fall		,
	input	[7:0]	i_status_code		,
	input	[15:0]	i_apd_hv_value		,
	input	[15:0]	i_apd_temp_value	,
	input	[7:0]	i_device_temp		,
	input	[9:0]	i_dac_value			,
	input	[15:0]	i_pwm_value			,
	input           i_motor_state      ,
	input           i_iap_flag         ,
	input			i_flash_busy		,
	
	input	[15:0] i_first_rise,

	input 	[1:0]   dist_report_error  ,
	input 	[1:0]	tdc_process_error  ,
	input   [31:0]	state_tsatic_value ,

	
	output	[7:0]	o_config_mode		,
	output	[1:0]	o_filter_mode		,
	output	[15:0]	o_pwm_value_0		,
	output	[15:0]	o_stop_window		,
	output	[15:0]	o_zero_offset		,
	output	[15:0]	o_angle_offset		,
	output	[15:0]	o_rise_start		,
	output	[15:0]	o_pulse_start		,
	output	[15:0]	o_apd_hv_base		,
	output	[15:0]	o_pulse_set			,
	output	[15:0]	o_distance_min		,
	output	[15:0]	o_distance_max		,
	output	[15:0]	o_temp_apdhv_base	,
	output	[15:0]	o_temp_temp_base	,
	output	[15:0]	o_temp_temp_coe		,
	output	[15:0]	o_start_index		,
	output	[15:0]	o_stop_index		,
	output	[15:0]	o_index_num			,
	
	output			o_pulse_mode		,
	output	[1:0]	o_telegram_flag		,
	output	[7:0]	o_sram_store_flag	,
	
	output			o_program_n			,
	output			o_rst_n				,
	output          o_motor_rst_n       ,


	output          save_user_sram_to_factory_flash_valid,
	output          save_factory_sram_to_user_flash_valid,	
	
	output  [31:0] o_temp_dist         ,
	output  [7:0]  o_tdc_switch        ,
	output  [15:0] o_fixed_value       ,
	output  		o_dirt_mode			,
	output  [7:0]  o_dirt_points		,
	output  [15:0]	o_regaddr_opto	   ,//tjs
    input   [31:0]  i_data_opto_period 

);

	wire			w_recv_data_req;
	wire	[ 7:0]	w_recv_data;
	wire	[15:0]	w_recv_num;
	wire			w_recv_ack;
	wire			w_cmd_ack;
	wire			w_connect_state;
	wire			w_send_data_req;
	wire			w_send_req;
	wire	[ 7:0]	w_send_data;
	wire	[ 7:0]	w_get_cmd_code;
	wire	[15:0]	w_send_num;
	wire	[10:0]	w_wr_addr;
	
	wire			w_send_sig;

	wire	[31:0]	w_get_para0;
	wire	[31:0]	w_get_para1;
	wire	[31:0]	w_get_para2;
	wire	[31:0]	w_get_para3;
	wire	[31:0]	w_get_para4;
	wire	[31:0]	w_get_para5;
	wire	[31:0]	w_get_para6;
	
	wire	[ 7:0]	w_set_cmd_code;
	wire			w_cmd_make;
	wire	[31:0]	w_set_para0;
	wire	[31:0]	w_set_para1;
	wire	[31:0]	w_set_para2;
	wire	[31:0]	w_set_para3;
	wire	[31:0]	w_set_para4;
	wire	[31:0]	w_set_para5;
	wire	[31:0]	w_set_para6;
	wire	[31:0]	w_set_para7;
	wire	[31:0]	w_set_para8;
	
	wire	[9:0]	w_eth_rdaddr;
	wire	[7:0]	w_eth_data;
	
	wire	[31:0]	w_ip_addr;
	wire	[31:0]	w_gate_way;
	wire	[31:0]	w_sub_mask;
	wire	[47:0]	w_mac_addr;
	
	wire			w_sram_csen_eth;
	wire			w_sram_wren_eth;
	wire			w_sram_rden_eth;
	wire	[17:0]	w_sram_addr_eth;
	
	wire			w_sram_csen;
	wire	[17:0]	w_sram_addr;
	
	assign	o_sram_csen_eth	= (w_sram_csen)?w_sram_csen:w_sram_csen_eth;
	assign	o_sram_wren_eth	= (w_sram_csen)?1'b1:w_sram_wren_eth;
	assign	o_sram_rden_eth	= (w_sram_csen)?1'b0:w_sram_rden_eth;
	assign	o_sram_addr_eth	= (w_sram_csen)?w_sram_addr:w_sram_addr_eth;
	
	spi_w5500_top u1(
		.clk 				( i_clk_50m ),
		.rst_n 				( o_rst_n ),

		.o_spi_cs 			( o_spi_cs ),
		.o_spi_dclk 		( o_spi_dclk ),
		.o_spi_mosi 		( o_spi_mosi ),
		.i_spi_miso 		( i_spi_miso ),
		.o_w5500_rst		( o_w5500_rst ),

		.i_ip 				( w_ip_addr ),//( {8'd192, 8'd168, 8'd1, 8'd111} )				,//
		.i_netmask			( w_sub_mask ),//( {8'd255, 8'd255, 8'd255, 8'd0} )				,//
		.i_gateway			( w_gate_way ),//( {8'd192, 8'd168, 8'd1, 8'd1} )				,//
		.i_mac				( w_mac_addr ),//( {8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66} ),//
		.i_port				( 16'd2111 ),

		.i_clk_div			( 16'd2 ),
		
		.i_send_data_req	( w_send_data_req ),
		.i_send_data		( w_send_data ),
		.i_send_wraddr		( w_wr_addr ),	
		.i_send_req			( w_send_req && w_connect_state ),
		.i_send_num			( w_send_num ),

		.i_recv_data_req	( w_recv_data_req ),
		.o_recv_data		( w_recv_data ),
		.o_recv_num			( w_recv_num ),
		.o_recv_ack			( w_recv_ack ),
		.o_connect_state	( w_connect_state ),
		.o_send_sig			( w_send_sig ),
		.i_motor_state		(i_motor_state)		,
		.i_cmd_done			(w_cmd_ack)	
	);
	
	wire			w_code_right ;

	datagram_parser u2(
		.clk 				( i_clk_50m ),
		.rst_n 				( o_rst_n ),

		.i_set_para0 		( w_set_para0 ),
		.i_set_para1		( w_set_para1 ),
		.i_set_para2		( w_set_para2 ),
		.i_set_para3		( w_set_para3 ),
		.i_set_para4		( w_set_para4 ),
		.i_set_para5		( w_set_para5 ),
		.i_set_para6		( w_set_para6 ),
		.i_set_para7		( w_set_para7 ),
		.i_set_para8		( w_set_para8 ),

		.o_get_para0		( w_get_para0 ),
		.o_get_para1		( w_get_para1 ),
		.o_get_para2		( w_get_para2 ),
		.o_get_para3		( w_get_para3 ),
		.o_get_para4		( w_get_para4 ),
		.o_get_para5		( w_get_para5 ),
		.o_get_para6		( w_get_para6 ),
		
		.i_packet_wren		( i_packet_wren ),	
		.i_packet_pingpang	( i_packet_pingpang ),
		.i_packet_wrdata	( i_packet_wrdata ),
		.i_packet_wraddr	( i_packet_wraddr ),
		
		.i_calib_wren		( i_calib_wren ),	
		.i_calib_pingpang	( i_calib_pingpang ),
		.i_calib_wrdata		( i_calib_wrdata ),
		.i_calib_wraddr		( i_calib_wraddr ),
		
		.i_eth_rdaddr		( w_eth_rdaddr ),
		.o_eth_data			( w_eth_data ),

		.i_set_cmd_code		( w_set_cmd_code ),
		.o_get_cmd_code		( w_get_cmd_code ),

		.i_cmd_make			( w_cmd_make ),
		.o_cmd_end			( w_send_req ),
		.o_sram_cs_n		( w_sram_csen ),
		.o_sram_addr		( w_sram_addr ),
		.i_sram_data		( i_sram_data_eth ),
		.o_wr_req			( w_send_data_req ),
		.o_wr_addr			( w_wr_addr ),
		.o_data_out			( w_send_data ),
		.o_send_num			( w_send_num ),

		.i_cmd_parse		( w_recv_ack ),
		.o_cmd_ack			( w_cmd_ack ),
		.o_rd_req			( w_recv_data_req ),
		.i_data_in			( w_recv_data ),
		.i_recv_num			( w_recv_num ),

		.o_busy				(  ),
		
		.i_first_rise		(i_first_rise),
		
		.i_iap_flag         (i_iap_flag) ,
		.o_code_right		(w_code_right)
	);

	parameter_init u3(
	
		.i_clk_50m    		( i_clk_50m ),
		.i_rst_n      		( i_rst_n ),
		
		.o_set_para0 		( w_set_para0 ),
		.o_set_para1		( w_set_para1 ),
		.o_set_para2		( w_set_para2 ),
		.o_set_para3		( w_set_para3 ),
		.o_set_para4		( w_set_para4 ),
		.o_set_para5		( w_set_para5 ),
		.o_set_para6		( w_set_para6 ),
		.o_set_para7		( w_set_para7 ),
		.o_set_para8		( w_set_para8 ),

		.i_get_para0		( w_get_para0 ),
		.i_get_para1		( w_get_para1 ),
		.i_get_para2		( w_get_para2 ),
		.i_get_para3		( w_get_para3 ),
		.i_get_para4		( w_get_para4 ),
		.i_get_para5		( w_get_para5 ),
		.i_get_para6		( w_get_para6 ),

		.o_set_cmd_code		( w_set_cmd_code ),
		.i_get_cmd_code		( w_get_cmd_code ),

		.i_cmd_ack			( w_cmd_ack ),
		.o_cmd_make			( w_cmd_make ),
		
		.i_packet_make		( i_packet_make ),
		.i_calib_make		( i_calib_make ),
		.i_connect_state	( w_connect_state ),
		
		.i_send_sig			( w_send_sig ),
		
		.i_scan_counter		( i_scan_counter ),
		.i_telegram_no		( i_telegram_no ),
		.i_first_angle		( i_first_angle ),
		.i_pulse_get		( i_pulse_get),
		.i_pulse_rise		( i_pulse_rise ),
		.i_pulse_fall		( i_pulse_fall ),
		.i_packet_points	( i_packet_points )	,
		.i_calib_points		( i_calib_points ),
		.i_code_angle		( i_code_angle ),
		
		.i_status_code		( i_status_code ),
		.i_apd_hv_value		( i_apd_hv_value ),
		.i_apd_temp_value	( i_apd_temp_value ),
		.i_device_temp		( i_device_temp ),
		.i_dac_value		( i_dac_value ),
		.i_pwm_value		( i_pwm_value ),

		.dist_report_error  (dist_report_error)	,
		.tdc_process_error  (tdc_process_error)	,
		.state_tsatic_value  (state_tsatic_value),

		
		.i_read_complete_sig( i_read_complete_sig ),
		.o_sram_csen_eth	( w_sram_csen_eth ),
		.o_sram_wren_eth	( w_sram_wren_eth ),
		.o_sram_rden_eth	( w_sram_rden_eth ),
		.o_sram_addr_eth	( w_sram_addr_eth ),
		.o_sram_data_eth	( o_sram_data_eth ),
		.i_sram_data_eth	( i_sram_data_eth ),
		
		.o_eth_rdaddr		( w_eth_rdaddr ),
		.i_eth_data			( w_eth_data ),
		
		.o_ip_addr			( w_ip_addr ),
		.o_gate_way			( w_gate_way ),
		.o_sub_mask			( w_sub_mask ),
		.o_mac_addr			( w_mac_addr ),
		
		.o_config_mode		( o_config_mode ),
		.o_filter_mode		( o_filter_mode ),
		.o_pwm_value_0		( o_pwm_value_0 ),
		.o_tdc_window		( o_stop_window ),
		.o_zero_offset		( o_zero_offset ),
		.o_angle_offset		( o_angle_offset ),
		.o_rise_start 		( o_rise_start ),
		.o_pulse_start 		( o_pulse_start ),
		.o_apd_hv_base		( o_apd_hv_base),
		.o_pulse_stand		( o_pulse_set ),
		.o_distance_min		( o_distance_min ),
		.o_distance_max		( o_distance_max ),
		.o_temp_apdhv_base	( o_temp_apdhv_base ),
		.o_temp_temp_base	( o_temp_temp_base ),
		.o_temp_temp_coe	( o_temp_temp_coe ),
		.o_start_index		( o_start_index ),
		.o_stop_index		( o_stop_index ),
		.o_index_num		( o_index_num ),
		
		.o_telegram_flag	( o_telegram_flag ),
		.o_sram_store_flag	( o_sram_store_flag ),
		.o_program_n		( o_program_n ),
		.o_rst_n			( o_rst_n ),
		.o_motor_rst_n      (o_motor_rst_n),
		
		.o_temp_dist        (o_temp_dist),
		.o_tdc_switch       (o_tdc_switch),
		.o_fixed_value      (o_fixed_value),
		
		.o_dirt_mode		(o_dirt_mode),
		.o_dirt_points		(o_dirt_points),

		.save_user_sram_to_factory_flash_valid 	(save_user_sram_to_factory_flash_valid),
		.save_factory_sram_to_user_flash_valid  (save_factory_sram_to_user_flash_valid),
		
		.i_flash_busy		(i_flash_busy),
		.i_code_right		(w_code_right),
		/****/
        .o_regaddr_opto	    (o_regaddr_opto),
        .i_data_opto_period (i_data_opto_period)


	);

endmodule 