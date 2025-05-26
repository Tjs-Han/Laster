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
	
	
	input	[7:0]	i_fall_cnt			,
	input	[7:0]	i_status_code		,
	input	[15:0]	i_apd_hv_value		,
	input	[15:0]	i_apd_temp_value	,
	input	[7:0]	i_device_temp		,
	input	[9:0]	i_dac_value			,
	input	[15:0]	i_pwm_value			,
	input           i_iap_flag         ,
	
	input	[15:0]	i_code_angle		,
	
	output			o_motor_switch		,
	output	[15:0]	o_config_mode		,
	output	[15:0]	o_pwm_value_0		,
	output	[15:0]	o_stop_window		,
	output	[15:0]	o_zero_offset		,
	output	[15:0]	o_angle_offset		,
	output	[15:0]	o_rise_divid		,
	output	[15:0]	o_pulse_start		,
	output	[15:0]	o_pulse_divid		,
	output	[15:0]	o_distance_min		,
	output	[15:0]	o_distance_max		,
	output	[31:0]	o_dist_coe_para		,
	output	[15:0]	o_dist_diff			,
	output	[15:0]	o_temp_apdhv_base	,
	output	[15:0]	o_temp_temp_base	,
	output	[15:0]	o_temp_temp_coe		,
	output	[15:0]	o_start_index		,
	output	[15:0]	o_stop_index		,
	output	[15:0]	o_index_num			,
	output	[5:0]	o_random_seed		,
	
	output	[1:0]	o_telegram_flag		,
	output	[7:0]	o_sram_store_flag	,
	
	output	[63:0]	o_ntp_get           ,
	output	[63:0]  o_time_stamp_get   ,
    input   [63:0]  i_ntp_first_get     ,		
    input   [63:0]  i_time_stamp_first_get ,
	
	input	[7:0]	i_opto_ram_rdaddr	,
	output	[7:0]	o_opto_rddata		,
	output			o_opto_switch		,
	
	
	output			o_program_n			,
	output			o_rst_n				



			
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
	
	wire			w_recv_data_req_udp;
	wire	[ 7:0]	w_recv_data_udp;
	wire	[11:0]	w_recv_num_udp;
	wire			w_recv_ack_udp;
	wire			w_send_data_req_udp;
	wire			w_send_req_udp;
	wire	[ 7:0]	w_send_data_udp;
	wire	[10:0]	w_send_num_udp;
	wire	[10:0]	w_wr_addr_udp;
	

	wire	[63:0]	w_ntp_set;
	wire			w_ntp_sig;
	wire			w_ntp_set_sig;
	
	wire            w_ntp_server_sig;

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
	
	spi_w5500_top_3 u1(
	
		.clk 				( i_clk_50m ),
		.rst_n 				( o_rst_n ),

		.o_spi_cs 			( o_spi_cs ),
		.o_spi_dclk 		( o_spi_dclk ),
		.o_spi_mosi 		( o_spi_mosi ),
		.i_spi_miso 		( i_spi_miso ),
		.o_w5500_rst		( o_w5500_rst ),

		.i_ip 				( w_ip_addr ),//
		.i_netmask			( w_sub_mask ),//
		.i_gateway			( w_gate_way ),//
		.i_mac				( w_mac_addr ),//
		.i_port				( 16'd2111 ),

		.i_clk_div			( 16'd1 ),
		
		.i_send_data_req_tcp( w_send_data_req ),
		.i_send_data_tcp	( w_send_data ),
		.i_send_wraddr_tcp	( w_wr_addr ),	
		.i_send_req_tcp		( w_send_req && w_connect_state ),
		.i_send_num_tcp		( w_send_num[10:0] ),

		.i_recv_data_req_tcp( w_recv_data_req ),
		.o_recv_data_tcp	( w_recv_data ),
		.o_recv_num_tcp		( w_recv_num[11:0] ),
		.o_recv_ack_tcp		( w_recv_ack ),
		
		.i_send_data_req_udp( w_send_data_req_udp ),
		.i_send_data_udp	( w_send_data_udp ),
		.i_send_wraddr_udp	( w_wr_addr_udp ),	
		.i_send_req_udp		( w_send_req_udp ),
		.i_send_num_udp		( w_send_num_udp ),

		.i_recv_data_req_udp( w_recv_data_req_udp ),
		.o_recv_data_udp	( w_recv_data_udp ),
		.o_recv_num_udp		( w_recv_num_udp ),
		.o_recv_ack_udp		( w_recv_ack_udp ),
		
		.o_connect_state	( w_connect_state ),
		
		.i_cmd_done			(w_cmd_ack)
	);

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
		.i_iap_flag         (i_iap_flag)
	);
	
	datagram_parser_udp u3(
	
		.i_clk 				( i_clk_50m ),
		.i_rst_n 			( i_rst_n ),

		.o_cmd_end			( w_send_req_udp ),
		.o_wr_req			( w_send_data_req_udp ),
		.o_wr_addr			( w_wr_addr_udp ),
		.o_data_out			( w_send_data_udp ),
		.o_send_num			( w_send_num_udp ),

		.i_cmd_parse		( w_recv_ack_udp ),
		.o_rd_req			( w_recv_data_req_udp ),
		.i_data_in			( w_recv_data_udp ),
		.i_recv_num			( w_recv_num_udp ),
		
		.i_ntp_get			( o_ntp_get ),
		.o_ntp_set			( w_ntp_set ),
		.i_ntp_sig			( w_ntp_sig ),
		.o_ntp_set_sig		( w_ntp_set_sig ),
		.i_connect_state	( w_connect_state ),
		.o_ntp_server_sig   (w_ntp_server_sig)
	);
	
	time_stamp_ntp u4(
	
		.i_clk 				( i_clk_50m ),
		.i_rst_n 			( i_rst_n ),
		
		.o_ntp_get			( o_ntp_get ),
		.i_ntp_set			( w_ntp_set ),
		.o_ntp_sig			( w_ntp_sig ),
		.i_ntp_set_sig		( w_ntp_set_sig )
	);

	parameter_init u5(
	
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
		
		.i_scan_counter		( i_scan_counter ),
		.i_telegram_no		( i_telegram_no ),
		.i_first_angle		( i_first_angle ),
		.i_packet_points	( i_packet_points )	,
		.i_calib_points		( i_calib_points ),
		.i_fall_cnt			( i_fall_cnt ),
		
		.i_code_angle		(i_code_angle),
		
		.i_status_code		( i_status_code ),
		.i_apd_hv_value		( i_apd_hv_value ),
		.i_apd_temp_value	( i_apd_temp_value ),
		.i_device_temp		( i_device_temp ),
		.i_dac_value		( i_dac_value ),
		.i_pwm_value		( i_pwm_value ),
		
		.i_ntp_get			( o_ntp_get ),
		
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
		.o_random_seed		( o_random_seed ),
		
		.o_motor_switch		( o_motor_switch ),
		.o_config_mode		( o_config_mode ),
		.o_pwm_value_0		( o_pwm_value_0 ),
		.o_tdc_window		( o_stop_window ),
		.o_zero_offset		( o_zero_offset ),
		.o_angle_offset		( o_angle_offset ),
		.o_rise_divid 		( o_rise_divid ),
		.o_pulse_start 		( o_pulse_start ),
		.o_pulse_divid 		( o_pulse_divid ),
		.o_distance_min		( o_distance_min ),
		.o_distance_max		( o_distance_max ),
		.o_dist_coe_para	( o_dist_coe_para ),
		.o_dist_diff		( o_dist_diff ),
		.o_temp_apdhv_base	( o_temp_apdhv_base ),
		.o_temp_temp_base	( o_temp_temp_base ),
		.o_temp_temp_coe	( o_temp_temp_coe ),
		.o_start_index		( o_start_index ),
		.o_stop_index		( o_stop_index ),
		.o_index_num		( o_index_num ),
		
		.i_ntp_server_sig   (w_ntp_server_sig),
		.o_time_stamp_get   (o_time_stamp_get),
		.i_ntp_first_get    (i_ntp_first_get) ,		
        .i_time_stamp_first_get (i_time_stamp_first_get),
		
		.i_opto_ram_rdaddr	(i_opto_ram_rdaddr),
		.o_opto_rddata		(o_opto_rddata)	,
		.o_opto_switch		(o_opto_switch),
		
		
		.o_telegram_flag	( o_telegram_flag ),
		.o_sram_store_flag	( o_sram_store_flag ),
		.o_program_n		( o_program_n ),
		.o_rst_n			( o_rst_n )			

	);

endmodule 