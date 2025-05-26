module self_inspection
(
	input			i_clk_50m    	,
	input			i_rst_n      	,
	
	input			i_zero_sign		,
	input			i_calib_mode	,
	input			i_tdc_err_sig	,
	input			i_motor_state	,
	
	input	[15:0]	i_temp_apdhv_base	,
	input	[15:0]	i_temp_temp_base	,
	input	[15:0]	i_temp_temp_coe		,
	
	input	[31:0]	i_dist_coe_para		,
	input	[15:0]	i_dist_diff			,
	
	output	[7:0]	o_status_code	,
	output	[15:0]	o_apd_hv_value	,
	output	[15:0]	o_apd_temp_value,
	output	[7:0]	o_device_temp	,
	output	[9:0]	o_dac_value		,
	output	[15:0]	o_dist_compen	,
	
	output			o_measure_en	,
	output			o_led_state		,
	output			o_hv_en			,
	
	output			o_adc_sclk		,
	output			o_adc_cs1		,
	output			o_adc_cs2		,
	input			i_adc_sda		,
	
	output			o_dac_scl		,
	output			o_dac_cs		,
	output			o_dac_sda		
);
	
	reg				r_dac_start = 1'b0;
	
	wire	[9:0]	w_adc_hv_value;
	reg		[9:0]	r_adc_hv_value = 10'd0;
	wire	[9:0]	w_adc_temp_value;
	reg		[9:0]	r_adc_temp_value = 10'd0;
	
	reg		[7:0]	r_status_code = 8'd0;
	
	reg				r_measure_en = 1'd0;
	reg				r_hv_en = 1'd0;
	reg				r_led_state_hv = 1'b0;
	reg				r_led_state = 1'b1;
	reg		[23:0]	r_led_cnt = 24'd0;
	
	reg				r_temp_valid = 1'b0;
	
	reg				r_sample_flag = 1'b0;
	reg		[31:0]	r_sample_cnt = 32'd0;
	
	
	wire			w_adc_start;
	
	wire			w_dac_start;
	wire	[11:0]	w_dac_value;
	wire	[15:0]	w_adc_temp_average;
	
	reg		[3:0]	r_check_state = 4'd0;
	
	parameter		CHECK_IDLE 	= 4'b0000,
					CHECK_WAIT	= 4'b0010,
					CHECK_SETHV	= 4'b0100,
					CHECK_GETHV	= 4'b1000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_check_state	<= CHECK_IDLE;
		else begin
			case(r_check_state)
				CHECK_IDLE		:begin
					if(i_motor_state && ~i_tdc_err_sig)
						r_check_state	<= CHECK_WAIT;
					end
				CHECK_WAIT		:begin
					if(r_temp_valid)
						r_check_state	<= CHECK_SETHV;
					end
				CHECK_SETHV		:begin
					r_check_state	<= CHECK_GETHV;
					end
				CHECK_GETHV		:begin
					r_check_state	<= CHECK_IDLE;
					end
				default:r_check_state	<= CHECK_IDLE;
				endcase
			end
			
	//r_sample_cnt
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_sample_cnt	<= 32'd0;
		else if(r_sample_cnt >= 32'd1_666_666)
			r_sample_cnt	<= 32'd0;
		else
			r_sample_cnt	<= r_sample_cnt	+ 1'b1;
			
	//r_sample_flag
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_sample_flag	<= 1'b0;
		else if(r_sample_cnt >= 32'd1_666_666 && i_calib_mode)
			r_sample_flag	<= 1'b1;
		else
			r_sample_flag	<= 1'b0;
			
	//r_temp_valid
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_temp_valid	<= 1'b0;
		else if(i_motor_state)
			r_temp_valid	<= i_zero_sign | r_sample_flag;
			
	//r_adc_hv_value
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_adc_hv_value	<= 16'd0;
		else if(i_zero_sign || r_sample_flag)
			r_adc_hv_value	<= w_adc_hv_value;
			
	//r_adc_temp_value
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_adc_temp_value	<= 16'd0;
		else if(i_zero_sign || r_sample_flag)
			r_adc_temp_value	<= w_adc_temp_average;
			
	//r_dac_start
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dac_start		<=	1'b0;
		else if(r_check_state == CHECK_GETHV)
			r_dac_start		<=	1'b1;
		else
			r_dac_start		<=	1'b0;
			
			
			
			
	//r_status_code
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_status_code	<= 8'd0;
		else if(~i_motor_state)
			r_status_code	<= 8'd0;
		else if(i_tdc_err_sig)
			r_status_code	<= 8'd2;
		else if(o_device_temp >= 8'd85 && o_device_temp <= 8'hEA)
			r_status_code	<= 8'd3;
		else if(o_apd_hv_value + 5'd20 < o_dac_value)
			r_status_code	<= 8'd4;
		else if(o_apd_hv_value > o_dac_value + 5'd20)
			r_status_code	<= 8'd4;
		else 
			r_status_code	<= 8'd1;
			
	//r_hv_en
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_hv_en		<= 1'b0;
//		else if(r_status_code != 8'd0)
//			r_hv_en		<= 1'b0;
		else if(r_check_state == CHECK_SETHV)
			r_hv_en		<= 1'b1;
			
	//r_measure_en
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_measure_en	<= 1'b0;
		else if(r_status_code != 8'd0 && r_status_code != 8'd2)
			r_measure_en	<= 1'b1;
		else
			r_measure_en	<= 1'b0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_led_cnt		<= 24'd0;
		else if(r_led_cnt >= 24'd5_999_999)
			r_led_cnt		<= 24'd0;
		else
			r_led_cnt		<= r_led_cnt + 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_led_state_hv	<= 1'b0;
		else if(r_led_cnt >= 24'd5_999_999)
			r_led_state_hv	<= ~r_led_state_hv;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_led_state		<= 1'b1;
		else if(r_status_code == 8'd0)
			r_led_state		<= 1'b1;
		else if(r_status_code == 8'd2)
			r_led_state		<= r_led_state_hv;
		else
			r_led_state		<= 1'b0;
			
	assign		o_status_code	= r_status_code;
	assign		o_apd_hv_value	= r_adc_hv_value;
	assign		o_apd_temp_value = r_adc_temp_value;
	
	assign		o_measure_en	= r_measure_en;
	assign		o_led_state		= r_led_state;
	assign		o_hv_en			= r_hv_en;
	
	assign	w_adc_start = i_zero_sign | r_sample_flag;
	
	adc_control u1(
		.i_clk_50m		( i_clk_50m ),
		.i_rst_n		( i_rst_n ),
		
		.i_adc_start	( w_adc_start ),
		
		.o_adc1_value	( w_adc_temp_value ),
		.o_adc2_value	( w_adc_hv_value ),
		
		.o_adc_sclk		( o_adc_sclk ),
		.o_adc_cs1		( o_adc_cs1 ),
		.o_adc_cs2		( o_adc_cs2 ),
		.i_adc_sda		( i_adc_sda )
	);
	
	DA_SPI u2(
		.clk			( i_clk_50m ),
		.rst			( i_rst_n ),
		.tx_en			( w_dac_start ),
		.data_in		( {4'd0,o_dac_value,2'd0} ),
		.SCLK			( o_dac_scl ),
		.SYNC			( o_dac_cs ),
		.DIN			( o_dac_sda ),
		.tx_done		(			)
	);
	
	adc_to_dac u3
	(
		.i_clk_50m    		( i_clk_50m ),
		.i_rst_n      		( i_rst_n ),
		
		.i_dac_set_sig		( r_dac_start ),
		.i_adc_temp_value	( r_adc_temp_value ),
		
	
		
		.i_temp_apdhv_base	( i_temp_apdhv_base )	,
		.i_temp_temp_base	( i_temp_temp_base )	,
		.i_temp_temp_coe	( i_temp_temp_coe )	,
		
		.o_dac_start		( w_dac_start ),
		.o_dac_value		( o_dac_value ),
		.o_device_temp		( o_device_temp )
	);
	
	adc_to_dist u4
	(
		.i_clk_50m    		( i_clk_50m ),
		.i_rst_n      		( i_rst_n ),
		
		.i_dac_set_sig		( r_dac_start ),
		.i_device_temp		( o_device_temp ),
		
		.i_dist_coe_para	( i_dist_coe_para ),
		.i_dist_diff		( i_dist_diff ),
	
		.o_dist_compen		( o_dist_compen )
	);
	
	pluse_average u5
		
		
	
	(
		.i_clk_50m    		( i_clk_50m ),
		.i_rst_n      		( i_rst_n ),
		
		.i_pulse_sig		( i_zero_sign ),
		.i_pulse_get		( {6'd0,w_adc_temp_value} ),
		
		.o_pulse_average	( w_adc_temp_average )
	);

endmodule 