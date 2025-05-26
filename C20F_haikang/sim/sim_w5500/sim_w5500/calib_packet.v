module calib_packet
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
	input			i_calibrate_flag	,
		
	output			o_calib_wren		,
	output			o_calib_pingpang	,
	output	[7:0]	o_calib_wrdata		,
	output	[9:0]	o_calib_wraddr		,
	
	output	[15:0]	o_calib_points		,
	output			o_calib_make		
);

	reg				r_calib_wren = 1'b0;
	reg		[7:0]	r_calib_wrdata = 8'd0;
	reg		[9:0]	r_calib_wraddr = 10'd0;
	reg		[15:0]	r_calib_points = 16'd0;
	reg				r_calib_pingpang = 1'b0;
	reg				r_calib_make = 1'b0;
	
	reg		[7:0]	r_packet_state = 8'd0;
	reg		[8:0]	r_packet_num = 9'd0;
	reg		[2:0]	r_shift_num = 3'd0;
	reg		[63:0]	r_packet_data = 64'd0;
			
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
				PACKET_READY:	if(i_calibrate_flag && i_code_angle == i_start_index)
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
								else if(~i_calibrate_flag)
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
			r_packet_data	<= {i_rise_data,i_fall_data,i_dist_data,i_rssi_data};
		else if(r_packet_state == PACKET_SHIFT)
			r_packet_data	<= {r_packet_data[55:0],8'd0};
	
	//r_calib_wren
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_calib_wren	<= 1'b0;
		else if(r_packet_state == PACKET_WRITE)
			r_calib_wren	<= 1'b1;
		else
			r_calib_wren	<= 1'b0;
			
	//r_calib_wrdata
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_calib_wrdata	<= 32'd0;
		else if(r_packet_state == PACKET_WRITE)
			r_calib_wrdata	<= r_packet_data[63:56];
			
	//r_calib_wraddr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_calib_wraddr <= 10'd0;
		else if(r_packet_state	== PACKET_WAIT || r_packet_state == PACKET_IDLE)
			r_calib_wraddr <= 10'd0;
		else if(r_packet_state == PACKET_SHIFT)
			r_calib_wraddr <= r_calib_wraddr + 1'b1;
			
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
			
	//r_calib_pingpang
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_calib_pingpang	<= 1'b0;
		else if(r_packet_state == PACKET_END || r_packet_state	== PACKET_SHIF3)
			r_calib_pingpang	<= ~r_calib_pingpang;
			
	//r_calib_points
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_calib_points	<= 16'd0;
		else if(r_packet_state	== PACKET_END || r_packet_state	== PACKET_SHIF3)
			r_calib_points	<= r_packet_num;
			
	//r_calib_make
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_calib_make	<= 1'b0;
		else if(r_packet_state	== PACKET_END || r_packet_state	== PACKET_SHIF3)
			r_calib_make	<= 1'b1;
		else
			r_calib_make	<= 1'b0;

	assign 	o_calib_wren 		= r_calib_wren;
	assign	o_calib_wrdata 		= r_calib_wrdata;
	assign	o_calib_wraddr 		= r_calib_wraddr;
	assign	o_calib_pingpang 	= r_calib_pingpang;

	assign	o_calib_points		= r_calib_points;
	assign	o_calib_make 		= i_measure_en & r_calib_make;
	
endmodule 