// -------------------------------------------------------------------------------------------------
// File description	:HV control
//				The current APD temperature is converted from the AD value read by ADC chip,
//				the APD high voltage is adjusted in real time according to the parameters 
//				read from flash or externally configured parameters, and then output by DAC chip.
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module HV_control
(
	input				i_clk_50m,
	input				i_rst_n,

	input				i_init_load_done,
	input				i_calib_mode,
	input				i_measure_mode,
	input				i_motor_state,

	input  [15:0]		i_temp_apdhv_base,
	input  [15:0]		i_temp_temp_base,
	input  [15:0]		i_dist_diff,

	input				i_hvcp_switch,
	output [6:0]		o_hvcp_ram_rdaddr,
	input  [15:0]		i_hvcp_rddata,
	
	input				i_dicp_switch,
	output [6:0]		o_dicp_ram_rdaddr,
	input  [15:0]		i_dicp_rddata,

	output [1:0]		o_hv_status_monit,
	output [15:0]		o_apd_hv_value,
	output [15:0]		o_apd_temp_value,
	output [9:0]		o_dac_value,
	output [7:0]		o_device_temp,
	output [15:0]		o_dist_compen,

	output				o_measure_en,
	output				o_hv_en,

	output				o_adc_sclk,
	output				o_adc_cs1,
	output				o_adc_cs2,
	input				i_adc_sda,

	output				o_da_pwm		
);
	
	
	wire				w_adc_start;
	wire				w_dac_start;
	wire [11:0]			w_dac_value;
	wire [15:0]			w_adc_temp_average;
	wire [15:0]			w_temp_adc_vaule;
	wire [9:0]			w_adc_hv_value;
	wire [9:0]			w_adc_temp_value;
	reg	 [9:0]			r_adc_hv_value 		= 10'd0;
	reg  [15:0]			r_adc_temp_value 	= 16'd0;
	
	reg  				r_temp_monit		= 1'b0;
	reg  				r_hv_monit			= 1'b0;
	reg					r_measure_en 		= 1'd0;
	reg					r_hv_en 			= 1'd0;
	reg					r_temp_valid 		= 1'b0;
	reg					r_sample_flag 		= 1'b0;
	reg					r_init_flag			= 1'b0;
	reg [31:0]			r_adc_init_cnt		= 32'd0;
	reg [31:0]			r_sample_cnt 		= 32'd0;
	reg [3:0]			r_check_state 		= 4'd0;
	reg					r_dac_start 		= 1'b0;
	
	parameter			CHECK_IDLE 			= 4'b0000,
						CHECK_WAIT			= 4'b0010,
						CHECK_SETHV			= 4'b0100,
						CHECK_GETHV			= 4'b1000;
	
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_check_state	<= CHECK_IDLE;
		else begin
			case(r_check_state)
				CHECK_IDLE: begin
					r_check_state <= CHECK_WAIT;
				end
				CHECK_WAIT: begin
					if(r_temp_valid)
						r_check_state <= CHECK_SETHV;
				end
				CHECK_SETHV: begin
					r_check_state <= CHECK_GETHV;
				end
				CHECK_GETHV: begin
					r_check_state <= CHECK_IDLE;
				end
				default: begin
					r_check_state <= CHECK_IDLE;
				end
			endcase
		end
	end

	//r_adc_init_cnt
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0) begin
			r_init_flag		<= 1'b0;
			r_adc_init_cnt	<= 32'd0;
		end else if(r_adc_init_cnt < 32'd300_000_000) begin
			r_init_flag		<= 1'b0;
			r_adc_init_cnt	<= r_adc_init_cnt	+ 1'b1;
		end else begin
			r_init_flag		<= 1'b1;
			r_adc_init_cnt	<= r_adc_init_cnt;
		end
	end
			
	//r_sample_cnt
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0) begin
			r_sample_cnt	<= 32'd0;
			r_sample_flag	<= 1'b0;
		end else if(~r_init_flag) begin
			if(r_sample_cnt >= 32'd1700_000) begin
				r_sample_flag	<= 1'b1;
				r_sample_cnt	<= 32'd0;
			end else begin
				r_sample_flag	<= 1'b0;
				r_sample_cnt	<= r_sample_cnt	+ 1'b1;
			end
		end else if(r_init_flag) begin
			if(r_sample_cnt >= 32'd50_000_000) begin
				r_sample_flag	<= 1'b1;
				r_sample_cnt	<= 32'd0;
			end else begin
				r_sample_flag	<= 1'b0;
				r_sample_cnt	<= r_sample_cnt	+ 1'b1;
			end
		end
	end
	
	// //r_sample_flag
	// always@(posedge i_clk_50m or negedge i_rst_n) begin
	// 	if(i_rst_n == 1'b0)
	// 		r_sample_flag	<= 1'b0;
	// 	else if(r_sample_cnt >= 32'd50_000_000)
	// 		r_sample_flag	<= 1'b1;
	// 	else
	// 		r_sample_flag	<= 1'b0;
	// end
	
	//r_temp_valid
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_temp_valid	<= 1'b0;
		else if(i_motor_state)
			r_temp_valid	<= r_sample_flag;
	end	
	
	//r_adc_hv_value
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_adc_hv_value	<= 10'd0;
		else if(r_sample_flag)
			r_adc_hv_value	<= w_adc_hv_value;
	end		
	
	//r_adc_temp_value
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_adc_temp_value	<= 16'd0;
		else if(r_sample_flag)
			r_adc_temp_value	<= w_adc_temp_average;
	end
	
	//r_dac_start
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_dac_start		<=	1'b0;
		else if(r_check_state == CHECK_GETHV)
			r_dac_start		<=	1'b1;
		else
			r_dac_start		<=	1'b0;
	end		
	
	//r_temp_monit
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_temp_monit	<= 1'b0;
		else if(o_device_temp >= 8'd105 && o_device_temp <= 8'hEA)
			r_temp_monit	<= 1'b1;
		else
			r_temp_monit	<= 1'b0;
	end

	//r_hv_monit
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_hv_monit	<= 1'b0;
		else if(o_dac_value > 10'd526 || o_apd_hv_value > 10'd615)
			r_hv_monit	<= 1'b1;
		else
			r_hv_monit	<= 1'b0;
	end
	
	//r_hv_en
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)
			r_hv_en		<= 1'b0;
		else if(r_check_state == CHECK_SETHV)
			r_hv_en		<= 1'b1;
	end

	//--------------------------------------------------------------------------------------------------
	// instance domain
	//--------------------------------------------------------------------------------------------------
	adc_control u_adc_sample(
		.i_clk_50m			( i_clk_50m 				),
		.i_rst_n			( i_rst_n 					),

		.i_adc_start		( w_adc_start 				),

		.o_adc1_value		( w_adc_temp_value 			),//apd temp value
		.o_adc2_value		( w_adc_hv_value 			),//apd hv value

		.o_adc_sclk			( o_adc_sclk 				),
		.o_adc_cs1			( o_adc_cs1 				),
		.o_adc_cs2			( o_adc_cs2 				),
		.i_adc_sda			( i_adc_sda 				)
	);
	
	DA_SPI_pwm u_hvpwm_ctrl(
		.i_clk_50m			( i_clk_50m 				),
		.i_rst_n			( i_rst_n 					),
		.i_init_load_done	( i_init_load_done			),
		.i_tx_en			( w_dac_start 				),
		.i_data_in			( o_dac_value 				),

		.o_da_pwm			( o_da_pwm 					)
	);
	
	adc_to_dac u3
	(
		.i_clk_50m    		( i_clk_50m 				),
		.i_rst_n      		( i_rst_n 					),
		
		.i_dac_set_sig		( r_dac_start 				),
		.i_adc_temp_value	( r_adc_temp_value[9:0]		),
		
		.i_temp_apdhv_base	( i_temp_apdhv_base 		),
		.i_temp_temp_base	( i_temp_temp_base 			),

		.i_hvcp_switch		( i_hvcp_switch 			),
		.o_hvcp_ram_rdaddr	( o_hvcp_ram_rdaddr 		),
		.i_hvcp_rddata		( i_hvcp_rddata 			),

		.o_dac_start		( w_dac_start 				),
		.o_dac_value		( o_dac_value 				),
		.o_device_temp		( o_device_temp 			)
	);
	
	adc_to_dist_2 u4
	(
		.i_clk_50m    		( i_clk_50m 				),
		.i_rst_n      		( i_rst_n 					),
		
		.i_dac_set_sig		( r_dac_start 				),
		.i_device_temp		( o_device_temp 			),
		.i_temp_temp_base	( i_temp_temp_base[7:0] 	),
		.i_dist_diff		( i_dist_diff 				),
		
		.i_dicp_switch		( i_dicp_switch 			),
		.o_dicp_ram_rdaddr	( o_dicp_ram_rdaddr 		),
		.i_dicp_rddata		( i_dicp_rddata 			),
	
		.o_dist_compen		( o_dist_compen 			)
	);
	
	pluse_average u5
	(
		.i_clk_50m    		( i_clk_50m 				),
		.i_rst_n      		( i_rst_n 					),

		.i_pulse_sig		( r_sample_flag				),
		.i_pulse_get		( w_temp_adc_vaule[9:0] 	),
		
		.o_pulse_average	( w_adc_temp_average		)
	);
	
	temp_adc_filter u6
	(
		.i_clk_50m    		( i_clk_50m 				),
		.i_rst_n      		( i_rst_n 					),

		.i_cal_sig			( r_sample_flag				),
		.i_temp_adcval		( {4'b0000, w_adc_temp_value, 2'b00}),
		
		.o_adcval_fact		( w_temp_adc_vaule			)
	);
	//----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_hv_status_monit	= {r_temp_monit, r_hv_monit};
	assign o_apd_hv_value		= {6'h0, r_adc_hv_value};
	assign o_apd_temp_value 	= r_adc_temp_value;
	
	// assign o_measure_en		= r_measure_en;
	// assign o_hv_en			= r_hv_en & i_measure_mode;
	assign o_hv_en				= 1'b1;
	assign w_adc_start 			= r_sample_flag;
endmodule 