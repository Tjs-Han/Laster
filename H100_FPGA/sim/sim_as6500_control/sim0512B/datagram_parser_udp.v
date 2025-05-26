module datagram_parser_udp
(
	input				i_clk 				,
	input				i_rst_n 			,

	output				o_cmd_end			,
	output				o_wr_req			,
	output		[10:0]	o_wr_addr			,
	output		[7:0]	o_data_out			,
	output		[10:0]	o_send_num			,

	input				i_cmd_parse			,
	output				o_rd_req			,
	input		[7:0]	i_data_in			,
	input		[11:0]	i_recv_num			,
	
	input		[63:0]	i_ntp_get			,
	output		[63:0]	o_ntp_set			,
	input				i_ntp_sig			,
	output				o_ntp_set_sig       ,
	
	input               i_connect_state     ,
	output              o_ntp_server_sig    
);

	wire		[63:0]	w_ntp_client_send;
	wire		[63:0]	w_ntp_server_get;
	wire		[63:0]	w_ntp_server_send;
	wire				w_ntp_recv_sig;		
	
	wire		[31:0]	w_root_delay;
	wire		[31:0]	w_root_disper;

	ntp_receive_parser u1
	(
		.i_clk				( i_clk ),
		.i_rst_n			( i_rst_n ),
		
		.i_cmd_parse		( i_cmd_parse ),
		
		.i_recv_num			( i_recv_num ),
		.o_rd_req			( o_rd_req ),
		.i_data_in			( i_data_in ),
		
		.o_ntp_server_get	( w_ntp_server_get ),
		.o_ntp_server_send	( w_ntp_server_send ),
		.o_ntp_recv_sig		( w_ntp_recv_sig ),
		.i_connect_state    (i_connect_state),
		.o_ntp_server_sig   (o_ntp_server_sig)
	);
	
	ntp_send_make u2
	(
		.i_clk				( i_clk ),
		.i_rst_n			( i_rst_n ),
		
		.i_ntp_sig			( i_ntp_sig ),
		.i_ntp_get			( i_ntp_get ),
		.i_ntp_set			( o_ntp_set ),
		.i_root_delay		( w_root_delay ),
		.i_root_disper		( w_root_disper ),
		
		.o_cmd_end			( o_cmd_end ),
		.o_wr_req			( o_wr_req ),
		.o_wr_addr			( o_wr_addr ),
		.o_data_out			( o_data_out ),
		.o_send_num			( o_send_num ),
		
		.o_ntp_client_send	( w_ntp_client_send )
	);
	
	ntp_calculate u3
	(
		.i_clk				( i_clk ),
		.i_rst_n			( i_rst_n ),
		
		.i_ntp_recv_sig		( w_ntp_recv_sig ),
		.i_ntp_get			( i_ntp_get ),
		.i_ntp_client_send	( w_ntp_client_send ),
		.i_ntp_server_get	( w_ntp_server_get ),
		.i_ntp_server_send	( w_ntp_server_send ),
		
		.o_ntp_set			( o_ntp_set ),
		.o_root_delay		( w_root_delay ),
		.o_root_disper		( w_root_disper ),
		.o_ntp_set_sig		( o_ntp_set_sig )
	);

endmodule 