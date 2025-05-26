module ntp_receive_parser
(
	input				i_clk				,
	input				i_rst_n				,
	
	input				i_cmd_parse			,
	
	input		[11:0]	i_recv_num			,
	output	reg			o_rd_req = 1'b0		,
	input		[7:0]	i_data_in			,
	
	output		[63:0]	o_ntp_server_get	,
	output		[63:0]	o_ntp_server_send	,
	output				o_ntp_recv_sig		,
	
	input              i_connect_state      ,
	output             o_ntp_server_sig
);

	localparam IDLE   				= 0;
	localparam READY				= 1;
	localparam RDEN					= 2;
	localparam SHIFT				= 3;
	localparam PARSE_DATA			= 4;
	localparam IN_DATA				= 5;
	localparam DONE					= 6;

	reg			[ 3:0]	r_state = IDLE;
	reg			[11:0]	r_byte_size = 12'd0;
	reg			[11:0]	r_byte_cnt = 12'd0;
	
	reg			[63:0]	r_ntp_server_get = 64'd0;
	reg			[63:0]	r_ntp_server_send = 64'd0;
	reg					r_ntp_recv_sig = 1'b0;	
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_byte_size <= 12'd0;
		else if (i_cmd_parse == 1'b1)
			r_byte_size <= i_recv_num;
	end

	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_byte_cnt <= 12'd0;
		else if (r_state == IN_DATA)
			r_byte_cnt <= r_byte_cnt + 16'd1;
		else if (r_state == IDLE || r_state == DONE)
			r_byte_cnt <= 12'd0;
	end

	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			o_rd_req <= 1'b0;
		else if (r_state == RDEN)
			o_rd_req <= 1'b1;
		else if (r_state == SHIFT)
			o_rd_req <= 1'b0;
		else if (r_state == PARSE_DATA && r_byte_cnt < r_byte_size - 16'd1)
			o_rd_req <= 1'b1;
		else
			o_rd_req <= 1'b0;
	end
		
	//r_ntp_server_get
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_ntp_server_get	<= 64'd0;
		else if (r_byte_cnt >= 12'd40 && r_byte_cnt <= 12'd47 && r_state == IN_DATA)
			r_ntp_server_get	<= {r_ntp_server_get[55:0],i_data_in};
	end
			
	//r_ntp_server_send
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_ntp_server_send	<= 64'd0;
		else if (r_byte_cnt >= 12'd48 && r_byte_cnt <= 12'd55 && r_state == IN_DATA)
			r_ntp_server_send	<= {r_ntp_server_send[55:0],i_data_in};
	end
			
	//r_ntp_recv_sig
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_ntp_recv_sig	<= 1'b0;
		else if(r_state == DONE)
			r_ntp_recv_sig	<= 1'b1;
		else
			r_ntp_recv_sig	<= 1'b0;
	end
	
	reg  r_ntp_server_sig ;
    reg  [63:0]r_time_cnt;	
	
/*	always @(posedge i_clk or negedge i_rst_n) 
	  if (!i_rst_n)
		r_time_cnt <= 64'd0;
	  else if(r_ntp_recv_sig==1'd1)
	    r_time_cnt <= 64'd0;
	  else if(r_time_cnt >= 64'd1500000000&&r_ntp_recv_sig==1'd0)
		r_time_cnt <= 64'd1500000000;
	  else
		r_time_cnt <= r_time_cnt + 1'd1;*/
		
	always @(posedge i_clk or negedge i_rst_n) 
	  if (!i_rst_n)
		r_time_cnt <= 64'd0;
	  else if(i_connect_state==1'd0)
		r_time_cnt <= 64'd0;
	  else if(r_time_cnt >= 64'd1500000000)begin
		if(r_ntp_recv_sig==1'd1)
	      r_time_cnt <= 64'd0;
		else
		  r_time_cnt <= r_time_cnt;
	    end
	  else if(r_ntp_recv_sig)
		r_time_cnt <= 64'd0;
	  else
		r_time_cnt <= r_time_cnt + 1'd1;
		

		
	always @(posedge i_clk or negedge i_rst_n) 
	  if (!i_rst_n)		
        r_ntp_server_sig <= 1'd1;
	  else if(i_connect_state==1'd0)
		r_ntp_server_sig <= 1'd1;
	  else if(r_time_cnt >= 64'd1500000000)
		r_ntp_server_sig <= 1'd0;
	  else
		r_ntp_server_sig <= 1'd1;
	

	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_state <= IDLE;
		else begin
			case(r_state)
				IDLE: 
					r_state <= READY;
				READY:
					if (i_cmd_parse == 1'b1 && i_recv_num >= 12'd56)
						r_state <= RDEN;
					else
						r_state <= READY;
				RDEN:
					r_state <= SHIFT;
				SHIFT:
					r_state	<= PARSE_DATA;
				PARSE_DATA: 
					if (r_byte_cnt >= r_byte_size)
						r_state <= DONE;
					else
						r_state <= IN_DATA;
				IN_DATA: 
					r_state <= PARSE_DATA;
				DONE: 
					r_state <= IDLE;
				default:
					r_state <= IDLE;
			endcase
		end
	end
	
	assign	o_ntp_server_get 	= r_ntp_server_get;
	assign	o_ntp_server_send 	= r_ntp_server_send;
	assign	o_ntp_recv_sig 		= r_ntp_recv_sig;
	assign	o_ntp_server_sig 	= r_ntp_server_sig;	

endmodule 