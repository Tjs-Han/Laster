module data_packet
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input			i_measure_en		,
	input	[15:0]	i_code_angle 		,//角度值
	input	[15:0]	i_rise_data			,//上升沿
	input	[15:0]	i_fall_data			,//下降沿
	input	[15:0]	i_dist_data			,
	input	[15:0]	i_rssi_data			,
	input			i_dist_new_sig		,
	
	input	[15:0]	i_start_index		,
	input	[15:0]	i_stop_index		,
	input			i_transmit_flag		,
	input			i_calibrate_flag	,
		
	output			o_packet_wren		,
	output			o_pingorpang		,
	output	[7:0]	o_packet_wrdata		,
	output	[9:0]	o_packet_wraddr		,
	output			o_packet_make		,

	output	[15:0]	o_scan_counter		,
	output	[7:0]	o_telegram_no		,
	output	[15:0]	o_first_angle		,
	output	[15:0]	o_packet_points		
);

	reg				r_data_valid = 1'b0;
	reg		[7:0]	r_packet_wrdata = 8'd0;
	reg		[9:0]	r_packet_wraddr = 10'd0;

	reg				r_pingorpang = 1'b0;
	reg		[7:0]	r_packet_state = 8'd0;
	reg		[8:0]	r_packet_num = 9'd0;
	reg		[2:0]	r_shift_num = 3'd0;
	reg		[63:0]	r_packet_data = 64'd0;
	
	reg				r_packet_make = 1'b0;
	
	reg		[15:0]	r_scan_counter = 16'd0;
	reg		[7:0]	r_telegram_no = 8'd0;
	reg		[15:0]	r_first_angle = 16'd0;
	reg		[15:0]	r_packet_points = 16'd0;
	reg		[31:0]	r_time_stamp = 64'd0;
	reg		[15:0]	r_code_angle = 16'd0;
			
	parameter	PACKET_IDLE		= 8'b0000_0000,
				PACKET_READY	= 8'b0000_0001,
				PACKET_WAIT		= 8'b0000_0010,
				PACKET_WAIT2	= 8'b0000_0100,
				PACKET_WRITE	= 8'b0000_1000,
				PACKET_SHIFT	= 8'b0001_0000,
				PACKET_SHIF2	= 8'b0010_0000,
				PACKET_SHIF3	= 8'b0100_0000,
				PACKET_END		= 8'b1000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_state	<= PACKET_IDLE;
		else begin
			case(r_packet_state)
				PACKET_IDLE	:	if(i_code_angle == 16'd1)
									r_packet_state	<= PACKET_READY;
								else
									r_packet_state	<= PACKET_IDLE;
				PACKET_READY:	if((i_transmit_flag || i_calibrate_flag) && i_code_angle == i_start_index)
									r_packet_state	<= PACKET_WAIT;
								else
									r_packet_state	<= PACKET_READY;
				PACKET_WAIT	:	if(i_dist_new_sig)
									r_packet_state	<= PACKET_WRITE;
								else
									r_packet_state	<= PACKET_WAIT;
				PACKET_WAIT2:	if(i_dist_new_sig)
									r_packet_state	<= PACKET_WRITE;
								else
									r_packet_state	<= PACKET_WAIT2;
				PACKET_WRITE:	r_packet_state	<= PACKET_SHIFT;
				PACKET_SHIFT:	if(i_calibrate_flag && r_shift_num >= 3'd7)
									r_packet_state	<= PACKET_SHIF2;
								else if(i_transmit_flag && r_shift_num >= 3'd3)
									r_packet_state	<= PACKET_SHIF2;
								else if(~i_calibrate_flag && ~i_transmit_flag)
									r_packet_state	<= PACKET_IDLE;
								else
									r_packet_state	<= PACKET_WRITE;
				PACKET_SHIF2:	if(i_code_angle >= i_stop_index)
									r_packet_state	<= PACKET_END;
								else if(r_packet_num >= 9'd128)
									r_packet_state	<= PACKET_SHIF3;
								else
									r_packet_state	<= PACKET_WAIT2;
				PACKET_SHIF3:	r_packet_state	<= PACKET_WAIT;
				PACKET_END	:	r_packet_state	<= PACKET_IDLE;
				default		:	r_packet_state	<= PACKET_IDLE;
				endcase
			end
			
	//r_shift_num
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_shift_num		<= 3'd0;
		else if(r_packet_state	== PACKET_SHIFT)
			r_shift_num		<= r_shift_num + 1'b1;
		else if(r_packet_state	== PACKET_SHIF2)
			r_shift_num		<= 3'd0;
			
	//r_packet_data
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_data	<= 64'd0;
		else if(i_dist_new_sig)
			r_packet_data	<= {i_rise_data,i_fall_data,i_dist_data,8'd0,i_rssi_data[15:8]};
		else if(r_packet_state == PACKET_SHIFT)
			r_packet_data	<= {r_packet_data[55:0],8'd0};
	
	//r_data_valid
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_data_valid	<= 1'b0;
		else if(r_packet_state == PACKET_WRITE)
			r_data_valid	<= 1'b1;
		else
			r_data_valid	<= 1'b0;
			
	//r_packet_wrdata
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_wrdata	<= 32'd0;
		else if(r_packet_state == PACKET_WRITE)begin
			if(i_transmit_flag)
				r_packet_wrdata	<= r_packet_data[31:24];
			else if(i_calibrate_flag)
				r_packet_wrdata	<= r_packet_data[63:56];
			end
			
	//r_packet_wraddr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_wraddr <= 10'd0;
		else if(r_packet_state	== PACKET_WAIT || r_packet_state == PACKET_IDLE)
			r_packet_wraddr <= 10'd0;
		else if(r_packet_state == PACKET_SHIFT)
			r_packet_wraddr <= r_packet_wraddr + 1'b1;
			
	//r_packet_num
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_num	<= 9'd0;
		else if(r_packet_state == PACKET_IDLE)
			r_packet_num	<= 9'd0;
		else if(r_packet_state == PACKET_WAIT || r_packet_state == PACKET_WAIT2)
			r_packet_num	<= r_packet_num + i_dist_new_sig;
		else if(r_packet_state == PACKET_END || r_packet_state	== PACKET_SHIF3)
			r_packet_num	<= 9'd0;
			
	//r_pingorpang
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pingorpang	<= 1'b0;
		else if(r_packet_state == PACKET_END || r_packet_state	== PACKET_SHIF3)
			r_pingorpang	<= ~r_pingorpang;
			
	//r_code_angle
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_code_angle	<= 16'd0;
		else
			r_code_angle	<= i_code_angle;
			
	//r_scan_counter
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_scan_counter	<= 16'd0;
		else if(i_code_angle == 16'd0 && r_code_angle != 16'd0)
			r_scan_counter	<= r_scan_counter + i_measure_en;
			
	//r_telegram_no
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_telegram_no	<= 8'd0;
		else if(r_packet_state == PACKET_SHIF2 &&(r_packet_num >= 9'd128 || i_code_angle >= i_stop_index))
			r_telegram_no	<= r_telegram_no + 1'b1;
		else if(i_code_angle == 16'd0 && r_code_angle != 16'd0)
			r_telegram_no	<= 8'd0;
			
	//r_first_angle
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_first_angle	<= 16'd0;
		else if(r_packet_state == PACKET_WAIT && i_dist_new_sig)
			r_first_angle	<= i_code_angle;
			
	//r_packet_points
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_points	<= 16'd0;
		else if(r_packet_state	== PACKET_END || r_packet_state	== PACKET_SHIF3)
			r_packet_points	<= r_packet_num;
			
	//r_packet_make
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_make	<= 1'b0;
		else if(r_packet_state	== PACKET_END || r_packet_state	== PACKET_SHIF3)
			r_packet_make	<= 1'b1;
		else
			r_packet_make	<= 1'b0;

	assign 	o_packet_wren = r_data_valid;
	assign	o_packet_wrdata = r_packet_wrdata;
	assign	o_packet_wraddr = r_packet_wraddr;
	assign	o_pingorpang = r_pingorpang;
	
	assign	o_scan_counter = r_scan_counter;
	assign	o_telegram_no = r_telegram_no - 1'b1;
	assign	o_first_angle = r_first_angle - i_start_index;
	assign	o_packet_points	= r_packet_points;
	assign	o_packet_make = i_measure_en & r_packet_make;
	
endmodule 