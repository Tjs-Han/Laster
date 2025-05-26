module ntp_send_make
(
	input				i_clk				,
	input				i_rst_n				,
	
	input				i_ntp_sig			,
	input		[63:0]	i_ntp_get			,
	input		[63:0]	i_ntp_set			,
	input		[31:0]	i_root_delay		,
	input		[31:0]	i_root_disper		,
	
	output	reg			o_cmd_end			,
	output	reg			o_wr_req			,
	output	reg	[10:0]	o_wr_addr			,
	output	reg	[7:0]	o_data_out			,
	output		[10:0]	o_send_num			,
	
	output	reg	[63:0]	o_ntp_client_send = 64'd0	
);
	localparam IDLE   				= 0;
	localparam READY				= 1;
	localparam MAKE_DATA			= 2;
	localparam OUT_DATA				= 3;
	localparam DONE					= 4;
	
	reg			[ 3:0]	r_state = IDLE;
	reg			[10:0]	r_byte_cnt = 11'd0;
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_byte_cnt <= 11'd0;
		else if (r_state == OUT_DATA)
			r_byte_cnt <= r_byte_cnt + 1'b1;
		else if (r_state == IDLE || r_state == DONE)
			r_byte_cnt <= 11'd0;
	end
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			o_wr_req <= 1'b0;
		else if (r_state == MAKE_DATA)
			o_wr_req <= 1'b1;
		else
			o_wr_req <= 1'b0;
	end
	
	//o_wr_addr
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			o_wr_addr <= 11'd0;
		else if (r_state == OUT_DATA)
			o_wr_addr <= o_wr_addr + 1'b1;
		else if (r_state == IDLE)
			o_wr_addr <= 11'd0;
	end
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			o_cmd_end <= 1'b0;
		else if (r_state == DONE) 
			o_cmd_end <= 1'b1;
		else
			o_cmd_end <= 1'b0;
	end
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			o_ntp_client_send	<= 64'd0;
		else if(i_ntp_sig)
			o_ntp_client_send	<= i_ntp_get;
	end
	
	//When make data, output data to external FIFO
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			o_data_out <= 8'h0;
		else begin
			if (r_state == MAKE_DATA) begin
				if (r_byte_cnt == 11'd0)
					o_data_out <= 8'h1B;
				else if (r_byte_cnt == 11'd1)
					o_data_out <= 8'h02;
				else if (r_byte_cnt == 11'd2)
					o_data_out <= 8'h04;
				else if (r_byte_cnt == 11'd3)
					o_data_out <= 8'hEC;
				else if (r_byte_cnt == 11'd4)
					o_data_out <= i_root_delay[31:24];
				else if (r_byte_cnt == 11'd5)
					o_data_out <= i_root_delay[23:16];
				else if (r_byte_cnt == 11'd6)
					o_data_out <= i_root_delay[15:8];
				else if (r_byte_cnt == 11'd7)
					o_data_out <= i_root_delay[7:0];
				else if (r_byte_cnt == 11'd8)
					o_data_out <= i_root_disper[31:24];
				else if (r_byte_cnt == 11'd9)
					o_data_out <= i_root_disper[23:16];
				else if (r_byte_cnt == 11'd10)
					o_data_out <= i_root_disper[15:8];
				else if (r_byte_cnt == 11'd11)
					o_data_out <= i_root_disper[7:0];
				else if (r_byte_cnt <= 11'd15)
					o_data_out <= 8'h00;
				else if (r_byte_cnt == 11'd16)
					o_data_out <= i_ntp_set[63:56];
				else if (r_byte_cnt == 11'd17)
					o_data_out <= i_ntp_set[55:48];
				else if (r_byte_cnt == 11'd18)
					o_data_out <= i_ntp_set[47:40];
				else if (r_byte_cnt == 11'd19)
					o_data_out <= i_ntp_set[39:32];
				else if (r_byte_cnt == 11'd20)
					o_data_out <= i_ntp_set[31:24];
				else if (r_byte_cnt == 11'd21)
					o_data_out <= i_ntp_set[23:16];
				else if (r_byte_cnt == 11'd22)
					o_data_out <= i_ntp_set[15:8];
				else if (r_byte_cnt == 11'd23)
					o_data_out <= i_ntp_set[7:0];
				else if (r_byte_cnt == 11'd24)
					o_data_out <= o_ntp_client_send[63:56];
				else if (r_byte_cnt == 11'd25)
					o_data_out <= o_ntp_client_send[55:48];
				else if (r_byte_cnt == 11'd26)
					o_data_out <= o_ntp_client_send[47:40];
				else if (r_byte_cnt == 11'd27)
					o_data_out <= o_ntp_client_send[39:32];
				else if (r_byte_cnt == 11'd28)
					o_data_out <= o_ntp_client_send[31:24];
				else if (r_byte_cnt == 11'd29)
					o_data_out <= o_ntp_client_send[23:16];
				else if (r_byte_cnt == 11'd30)
					o_data_out <= o_ntp_client_send[15:8];
				else if (r_byte_cnt == 11'd31)
					o_data_out <= o_ntp_client_send[7:0];
				else
					o_data_out <= 8'h00;
			end
		end
	end

	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_state <= IDLE;
		else begin
			case(r_state)
				IDLE: 
					r_state <= READY;
				READY: 
					if (i_ntp_sig == 1'b1)
						r_state <= MAKE_DATA;
					else
						r_state <= READY;
				MAKE_DATA: 
					if (r_byte_cnt >= 11'd47)
						r_state <= DONE;
					else
						r_state <= OUT_DATA;
				OUT_DATA: 
					r_state <= MAKE_DATA;
				DONE: 
					r_state <= IDLE;
				default:
					r_state <= IDLE;
			endcase
		end
	end
	
	assign	o_send_num 	= 11'd48;

endmodule 