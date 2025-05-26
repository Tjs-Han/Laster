module ntp_calculate
(
	input				i_clk				,
	input				i_rst_n				,
	
	input				i_ntp_recv_sig		,
	input		[63:0]	i_ntp_get			,
	input		[63:0]	i_ntp_client_send	,
	input		[63:0]	i_ntp_server_get	,
	input		[63:0]	i_ntp_server_send	,
	
	output		[63:0]	o_ntp_set			,
	output		[31:0]	o_root_delay		,
	output		[31:0]	o_root_disper		,
	output				o_ntp_set_sig		
);

	localparam IDLE   			= 0;
	localparam CAL1				= 1;
	localparam CAL2				= 2;
	localparam CAL3				= 3;
	localparam END				= 4;

	reg			[63:0]	r_ntp_set		= 64'd0;
	reg			[63:0]	r_root_delay	= 64'd0;
	reg			[63:0]	r_root_disper	= 64'd0;
	reg			[63:0]	r_root_middle1	= 64'd0;
	reg			[63:0]	r_root_middle2	= 64'd0;
	reg					r_ntp_set_sig	= 1'b0;
	
	reg			[3:0]	r_ntp_state = 4'd0;
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_root_delay	<= 64'd0;
		else if(r_ntp_state	== CAL1)
			r_root_delay	<= i_ntp_get + i_ntp_server_get - i_ntp_client_send - i_ntp_server_send;
	end
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)begin
			r_root_middle1	<= 64'd0;
			r_root_middle2	<= 64'd0;
		end
		else if(r_ntp_state	== CAL2)begin
			r_root_middle1	<= i_ntp_server_send + i_ntp_server_get;
			r_root_middle2	<= i_ntp_get + i_ntp_client_send;
		end
	end
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_root_disper	<= 64'd0;
		else if(r_ntp_state	== CAL3)begin
			if(r_root_middle1 >= r_root_middle2)
				r_root_disper	<= (r_root_middle1 - r_root_middle2) >> 1'b1;
			else
				r_root_disper	<= (r_root_middle2 - r_root_middle1) >> 1'b1;
			end
	end
			
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_ntp_set		<= 64'd0;
		else if(r_ntp_state	== CAL3)
			r_ntp_set		<= i_ntp_server_send + r_root_delay[63:1];
	end		
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_ntp_set_sig	<= 1'b0;
		else if(r_ntp_state	== END)
			r_ntp_set_sig	<= 1'b1;
		else
			r_ntp_set_sig	<= 1'b0;
	end	
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_ntp_state	<= IDLE;
		else begin
			case(r_ntp_state)
				IDLE:	if(i_ntp_recv_sig)
							r_ntp_state	<= CAL1;
						else
							r_ntp_state	<= IDLE;
				CAL1:	r_ntp_state	<= CAL2;
				CAL2:	r_ntp_state	<= CAL3;
				CAL3:	r_ntp_state	<= END;
				END:	r_ntp_state	<= IDLE;
				default:r_ntp_state	<= IDLE;
			endcase
		end
	end
	
	assign	o_ntp_set		= r_ntp_set;
	assign	o_root_delay	= r_root_delay[31:0];
	assign	o_root_disper	= r_root_disper[31:0];
	assign	o_ntp_set_sig	= r_ntp_set_sig;

endmodule 