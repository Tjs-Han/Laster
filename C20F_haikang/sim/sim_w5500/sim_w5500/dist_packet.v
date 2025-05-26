module dist_packet
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input			i_measure_en		,
	input	[15:0]	i_code_angle 		,//�Ƕ�ֵ
	input	[15:0]	i_dist_data			,
	input	[15:0]	i_rssi_data			,
	input			i_dist_new_sig		,
	
	input	[15:0]	i_start_index		,
	input	[15:0]	i_stop_index		,
	input			i_transmit_flag		,
	input           i_motor_state       ,
		
	output			o_packet_wren		,
	output			o_packet_pingpang	,
	output	[7:0]	o_packet_wrdata		,
	output	[9:0]	o_packet_wraddr		,
	
	output			o_packet_make		,
	output	[15:0]	o_scan_counter		,
	output	[7:0]	o_telegram_no		,
	output	[15:0]	o_first_angle		,
	output	[15:0]	o_packet_points		,
	output  reg [1:0]   dist_report_error
	
);

	reg				r_packet_wren = 1'b0;
	reg		[7:0]	r_packet_wrdata = 8'd0;
	reg		[9:0]	r_packet_wraddr = 10'd0;

	reg				r_packet_pingpang = 1'b0;
	reg		[9:0]	r_packet_state = 9'd0;
	reg		[8:0]	r_packet_num = 9'd0;
	reg		[2:0]	r_shift_num = 3'd0;
	reg		[31:0]	r_packet_data = 32'd0;
	
	reg				r_packet_make = 1'b0;
	
	reg		[15:0]	r_scan_counter = 16'd0;
	reg		[7:0]	r_telegram_no = 8'd0;
	reg		[15:0]	r_first_angle = 16'd0;
	reg		[15:0]	r_packet_points = 16'd0;
	reg		[31:0]	r_time_stamp = 64'd0;
	reg		[15:0]	r_code_angle = 16'd0;
	
	reg		[31:0]	r_send_delay ;
	reg		[31:0]	r_need_delay ;
	reg		[7:0]	r_recv_points ;	

	reg     [15:0]	tmp_first_angle;

	reg     [15:0]	total_packet_number;	
	
	parameter	PACKET_IDLE		= 10'b00_0000_0000,
				PACKET_READY	= 10'b00_0000_0001,
				PACKET_WAIT		= 10'b00_0000_0010,
				PACKET_WAIT2	= 10'b00_0000_0100,
				PACKET_WRITE	= 10'b00_0000_1000,
				PACKET_SHIFT	= 10'b00_0001_0000,
				PACKET_SHIF2	= 10'b00_0010_0000,
				PACKET_SHIF3	= 10'b00_0100_0000,
				PACKET_END		= 10'b00_1000_0000,
				PACKET_DELAY	= 10'b01_0000_0000,
				PACKET_END_SEND	= 10'b10_0000_0000;			
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_state	<= PACKET_IDLE;
		else begin
			case(r_packet_state)
				PACKET_IDLE	:	if(i_code_angle == 16'd1)
									r_packet_state	<= PACKET_READY;
								else
									r_packet_state	<= PACKET_IDLE;
				PACKET_READY:	if(i_transmit_flag && i_code_angle == i_start_index)
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
				PACKET_SHIFT:	if(i_transmit_flag && r_shift_num >= 3'd3)
									r_packet_state	<= PACKET_SHIF2;
								else if(~i_transmit_flag)
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
				PACKET_END	:	begin
								if(r_recv_points < 8'd60)
									r_packet_state	<= PACKET_DELAY;
								else
									r_packet_state	<= PACKET_END_SEND;
								end
				PACKET_DELAY : begin
								if(r_send_delay > r_need_delay)
									r_packet_state	<= PACKET_END_SEND;
								else
									r_packet_state	<= PACKET_DELAY;
								end
				PACKET_END_SEND	:	r_packet_state	<= PACKET_IDLE;
				default		:	r_packet_state	<= PACKET_IDLE;
				endcase
			end
			
	//r_shift_num
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_shift_num		<= 3'd0;
		else if(r_packet_state	== PACKET_SHIFT)
			r_shift_num		<= r_shift_num + 1'b1;
		else if(r_packet_state	== PACKET_WAIT||r_packet_state	== PACKET_WAIT2)
			r_shift_num		<= 3'd0;
			
	//r_packet_data
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_data	<= 32'd0;
		else if(i_dist_new_sig)
			r_packet_data	<= {i_dist_data,i_rssi_data};
		else if(r_packet_state == PACKET_SHIFT)
			r_packet_data	<= {r_packet_data[23:0],8'd0};

	
	//r_packet_wren
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_wren	<= 1'b0;
		else if(r_packet_state == PACKET_WRITE)
			r_packet_wren	<= 1'b1;
		else
			r_packet_wren	<= 1'b0;
			
	//r_packet_wrdata
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_wrdata	<= 32'd0;
		else if(r_packet_state == PACKET_WRITE)
			r_packet_wrdata	<= r_packet_data[31:24];
			
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
		else if((r_packet_state == PACKET_WAIT || r_packet_state == PACKET_WAIT2)&&i_motor_state==1'd1)
			r_packet_num	<= r_packet_num + i_dist_new_sig;
		else if(r_packet_state == PACKET_END || r_packet_state	== PACKET_SHIF3)
			r_packet_num	<= 9'd0;
			
	//r_packet_pingpang
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_pingpang	<= 1'b0;
		else if(r_packet_state == PACKET_END_SEND || r_packet_state	== PACKET_SHIF3)
			r_packet_pingpang	<= ~r_packet_pingpang;
			
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
		else if(i_code_angle == 16'd3 && r_code_angle != 16'd3)
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
		else if(r_packet_state	== PACKET_END_SEND || r_packet_state	== PACKET_SHIF3)
			r_first_angle	<= (r_telegram_no << 7) - 16'd128;
			
	//r_packet_points
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_points	<= 16'd0;
		else if(r_packet_state	== PACKET_SHIF3)
			r_packet_points	<= 16'd128;
		else if((r_packet_state	== PACKET_END) && (total_packet_number[6:0] == 7'd0) )
			r_packet_points	<= 16'd128;
		else if(r_packet_state	== PACKET_END)
			r_packet_points	<= total_packet_number[6:0];				
			
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_recv_points <= 8'd0;
		else if(r_packet_state == PACKET_IDLE)
			r_recv_points <= 8'd0;
		else if(r_packet_state == PACKET_SHIF2 &&(r_packet_num >= 9'd128 || i_code_angle >= i_stop_index))
			r_recv_points <= r_packet_num;
						
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_send_delay <= 32'd0;
		else if(r_packet_state	== PACKET_DELAY)
			r_send_delay <= r_send_delay + 1'd1;
		else 
			r_send_delay <= 32'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_need_delay <= 32'd0;
		else if(r_recv_points < 8'd60)
			r_need_delay <= (8'd60 - r_recv_points) << 8'd12 ;
						
			
	//r_packet_make
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_make	<= 1'b0;
		else if(r_packet_state	== PACKET_END_SEND || r_packet_state	== PACKET_SHIF3)
			r_packet_make	<= 1'b1;
		else
			r_packet_make	<= 1'b0;
			
			

	assign 	o_packet_wren = r_packet_wren;
	assign	o_packet_wrdata = r_packet_wrdata;
	assign	o_packet_wraddr = r_packet_wraddr;
	assign	o_packet_pingpang = r_packet_pingpang;
	
	assign	o_scan_counter = r_scan_counter;
	assign	o_telegram_no = r_telegram_no - 1'b1;
	assign	o_first_angle = r_first_angle;
	assign	o_packet_points	= r_packet_points;
	assign	o_packet_make = i_measure_en & r_packet_make;


/////////debug add
    reg 	[15:0]	code_angle;
    reg 			code_angle_vld;	
    reg 			code_angle_vld_1;	
    reg 	[15:0]	last_code_angle;	
	reg             first_flag;	
	reg             first_flag_1;	
	reg             code_angle_vld_2;	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			code_angle	<= 16'b0;
		else 
			code_angle	<= i_code_angle;	

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			code_angle_vld	<= 1'b0;
		else
			code_angle_vld	<= i_measure_en && i_dist_new_sig ;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			code_angle_vld_1	<= 1'b0;
		else
			code_angle_vld_1	<= (i_code_angle >= i_start_index) && (i_code_angle <= i_stop_index) ;			
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			last_code_angle	<= 16'b0;
		else if(code_angle_vld)
			last_code_angle	<= code_angle;	

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			first_flag_1	<= 1'b1;
		else if( i_transmit_flag && (i_code_angle == 16'd1))
			first_flag_1	<= 1'b0;			
		else if(~i_transmit_flag)
			first_flag_1	<= 1'b1;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			tmp_first_angle	<= 16'b0;
		else if(i_code_angle == 16'd1)
			tmp_first_angle	<= 16'b0;	
		else if(~first_flag_1 && o_packet_make && (r_telegram_no == 8'd1))
			tmp_first_angle	<= r_packet_points;
		else if(~first_flag_1 && o_packet_make)
			tmp_first_angle	<= r_packet_points + tmp_first_angle;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			dist_report_error[0]	<= 1'b0;
		else if(~first_flag_1 && o_packet_make && (tmp_first_angle != r_first_angle))
			dist_report_error[0]	<= 1'b1;

		// else 
		// 	dist_report_error[0] 	<= 1'b0;						

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			first_flag	<= 1'b1;
		else if( i_transmit_flag && code_angle_vld && code_angle_vld_1)
			first_flag	<= 1'b0;			
		else if(~i_transmit_flag)
			first_flag	<= 1'b1;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			dist_report_error[1] <= 1'b0;		
		else if(~first_flag && code_angle_vld && code_angle_vld_1 && (code_angle != (last_code_angle + 16'd1)))
			dist_report_error[1] <= 1'b1;
			
		// else 
		// 	dist_report_error[1] <= 1'b0;


	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			code_angle_vld_2	<= 1'b0;
		else
			code_angle_vld_2	<= i_measure_en && i_dist_new_sig && (i_code_angle == i_start_index) ;			


////////////add by luxuan 2024.12.21
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			total_packet_number		<= 16'd0;
		else if(i_stop_index >=  i_start_index)
			total_packet_number		<= i_stop_index - i_start_index + 16'd1;
		else 
			total_packet_number		<= 16'd1;							

endmodule 