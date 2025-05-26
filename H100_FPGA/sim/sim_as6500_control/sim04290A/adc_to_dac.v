module adc_to_dac
(
	input			i_clk_50m    	,
	input			i_rst_n      	,
	
	input			i_dac_set_sig	,
	input	[9:0]	i_adc_temp_value,
	
	
	input	[15:0]	i_temp_apdhv_base	,
	input	[15:0]	i_temp_temp_base	,
	input	[15:0]	i_temp_temp_coe		,
	
	output			o_dac_start		,
	output	[9:0]	o_dac_value		,
	output	[7:0]	o_device_temp
);

	reg		[9:0]	r_adc_value = 10'd0;
	reg				r_adc_start = 1'b0;
	
	wire			w_temp_done;
	wire	[15:0]	w_temp_value;
	
	reg		[7:0]	r_dac_state = 8'd0;
	reg		[11:0]	r_dac_value = 12'd0;
	reg				r_dac_start = 1'b0;
	
	reg		[15:0]	r_apd_temp = 16'd0;
	
	reg		[7:0]	r_delay_cnt = 8'd0;
	reg 	[7:0]	r_mult1_dataA = 8'd0;
	reg 	[7:0]	r_mult1_dataB = 8'd0;
	reg				r_mult_en	  = 1'b0;
    wire	[15:0]	w_mult1_result;
	wire	[15:0]	w_mult2_result;
	wire	[15:0]	w_mult3_result;
	
	parameter		DAC_IDLE		= 8'b0000_0001,
					GET_TEMP_NOW	= 8'b0000_0010,
					MODE_CHOOSE		= 8'b0000_0100,
					DAC_PARA		= 8'b0000_1000,
					DAC_VALUE		= 8'b0001_0000,
					DAC_END			= 8'b0010_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dac_state		<= DAC_IDLE;
		else begin
			case(r_dac_state)
				DAC_IDLE	:begin
					if(i_dac_set_sig)
						r_dac_state		<= GET_TEMP_NOW;
					end
				GET_TEMP_NOW:begin
					if(w_temp_done)
						r_dac_state		<= MODE_CHOOSE;
					end
				MODE_CHOOSE	:begin
						r_dac_state		<= DAC_PARA;
					end
				DAC_PARA	:begin
					if(r_delay_cnt >= 8'd9)
						r_dac_state		<= DAC_VALUE;
					else
						r_dac_state		<= DAC_PARA;
					end
				DAC_VALUE	:
					r_dac_state		<= DAC_END;
				DAC_END		:
					r_dac_state		<= DAC_IDLE;
				default:r_dac_state		<= DAC_IDLE;
				endcase
			end
					
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_adc_start	<= 1'b0;
		else if(r_dac_state == GET_TEMP_NOW && ~w_temp_done)
			r_adc_start	<= 1'b1;
		else
			r_adc_start	<= 1'b0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_adc_value	<= 10'd0;
		else if(r_dac_state == GET_TEMP_NOW)
			r_adc_value	<= i_adc_temp_value;
		else
			r_adc_value	<= 10'd0;
		
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)		
			r_apd_temp <= 16'd0;
		else if(r_dac_state == GET_TEMP_NOW && w_temp_done)
			r_apd_temp <= w_temp_value;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)		
			r_dac_start <= 1'b0;
		else if(r_dac_state == DAC_END)
			r_dac_start <= 1'b1;
		else
			r_dac_start <= 1'b0;
			
	//r_delay_cnt
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_delay_cnt		<= 8'd0;
		else if(r_dac_state == DAC_PARA)
			r_delay_cnt		<= r_delay_cnt + 1'b1;
		else
			r_delay_cnt		<= 8'd0;
			
	//r_mult1_dataA
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_mult1_dataA	<= 8'd0;
		else if(r_dac_state == DAC_IDLE)
			r_mult1_dataA	<= 8'd0;
		else if(r_dac_state == DAC_PARA)begin
			if(o_device_temp[7] == 1'b1)begin
				if(i_temp_temp_base[7:0] >= 8'd30)
					r_mult1_dataA	<= {1'b0,i_temp_temp_coe[7:1]};
				else if(o_device_temp + 8'd30 <= i_temp_temp_base[7:0])
					r_mult1_dataA	<= {1'b0,i_temp_temp_coe[7:1]};
				else
					r_mult1_dataA	<= i_temp_temp_coe[7:0];
				end
			else begin
				if(o_device_temp + 8'd30 <= i_temp_temp_base[7:0])
					r_mult1_dataA	<= {1'b0,i_temp_temp_coe[7:1]};
				else if(o_device_temp >= i_temp_temp_base[7:0] + 8'd20)
					r_mult1_dataA	<= {i_temp_temp_coe[6:0],1'b0};
				else
					r_mult1_dataA	<= i_temp_temp_coe[7:0];
				end
			end
			
	//r_mult1_dataB
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_mult1_dataB	<= 8'd0;
		else if(r_dac_state == DAC_IDLE)
			r_mult1_dataB	<= 8'd0;
		else if(r_dac_state == DAC_PARA)begin
			if(o_device_temp[7] == 1'b1)begin
				if(i_temp_temp_base[7:0] >= 8'd30)
					r_mult1_dataB	<= i_temp_temp_base[7:0] - o_device_temp - 8'd30;
				else if(o_device_temp + 8'd30 <= i_temp_temp_base[7:0])
					r_mult1_dataB	<= i_temp_temp_base[7:0] - o_device_temp - 8'd30;
				else
					r_mult1_dataB	<= i_temp_temp_base[7:0] - o_device_temp;
				end
			else begin
				if(o_device_temp + 8'd30 <= i_temp_temp_base[7:0])
					r_mult1_dataB	<= i_temp_temp_base[7:0] - o_device_temp - 8'd30;
				else if(o_device_temp >= i_temp_temp_base[7:0] + 8'd20)
					r_mult1_dataB	<= o_device_temp - i_temp_temp_base[7:0] - 8'd20;
				else if(o_device_temp >= i_temp_temp_base[7:0])
					r_mult1_dataB	<= o_device_temp - i_temp_temp_base[7:0];
				else
					r_mult1_dataB	<= i_temp_temp_base[7:0] - o_device_temp;
				end
			end

	//r_mult_en
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_mult_en	  	<= 1'b0;
		else if(r_dac_state == DAC_PARA)
			r_mult_en	  	<= 1'b1;
		else
			r_mult_en	  	<= 1'b0;
				
	//r_dac_value
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dac_value		<= i_temp_apdhv_base;
		else if(r_dac_state == DAC_VALUE)begin
			if(o_device_temp[7] == 1'b1)begin
				if(i_temp_temp_base[7:0] >= 8'd30)begin
					if(i_temp_apdhv_base <= w_mult1_result + w_mult2_result)
						r_dac_value 	<= 12'd1150;
					else if(i_temp_apdhv_base - w_mult1_result - w_mult2_result >= 16'd1150)
						r_dac_value		<= i_temp_apdhv_base - w_mult1_result - w_mult2_result;
					else
						r_dac_value 	<= 12'd1150;
					end
				else if(o_device_temp + 8'd30 <= i_temp_temp_base[7:0])begin
					if(i_temp_apdhv_base <= w_mult1_result + w_mult2_result)
						r_dac_value 	<= 12'd1150;
					else if(i_temp_apdhv_base - w_mult1_result - w_mult2_result >= 16'd1150)
						r_dac_value		<= i_temp_apdhv_base - w_mult1_result - w_mult2_result;
					else
						r_dac_value 	<= 12'd1150;
					end
				else begin
					if(i_temp_apdhv_base <= w_mult1_result)
						r_dac_value 	<= 12'd1150;
					else if(i_temp_apdhv_base - w_mult1_result >= 16'd1150)
						r_dac_value	<= i_temp_apdhv_base - w_mult1_result;
					else
						r_dac_value 	<= 12'd1150;
					end
				end
			else begin
				if(o_device_temp + 8'd30 <= i_temp_temp_base[7:0])begin
					if(i_temp_apdhv_base <= w_mult1_result + w_mult2_result)
						r_dac_value 	<= 12'd1150;
					else if(i_temp_apdhv_base - w_mult1_result - w_mult2_result >= 16'd1150)
						r_dac_value		<= i_temp_apdhv_base - w_mult1_result - w_mult2_result;
					else
						r_dac_value 	<= 12'd1150;
					end
				else if(o_device_temp >= i_temp_temp_base[7:0] + 8'd20)begin
					if(i_temp_apdhv_base + w_mult1_result + w_mult3_result >= 16'd4000)
						r_dac_value		<= 12'd4000;
					else
						r_dac_value		<= i_temp_apdhv_base + w_mult1_result + w_mult3_result;
					end
				else if(o_device_temp >= i_temp_temp_base[7:0])begin
					if(i_temp_apdhv_base + w_mult1_result >= 16'd4000)
						r_dac_value		<= 12'd4000;
					else
						r_dac_value		<= i_temp_apdhv_base + w_mult1_result;
					end
				else begin
					if(i_temp_apdhv_base <= w_mult1_result)
						r_dac_value 	<= 12'd1150;
					else if(i_temp_apdhv_base - w_mult1_result >= 16'd1150)
						r_dac_value		<= i_temp_apdhv_base - w_mult1_result;
					else
						r_dac_value 	<= 12'd1150;
					end
				end
			end		
			
	assign	o_dac_start   = r_dac_start;
	assign	o_dac_value   = r_dac_value[11:2];
	assign	o_device_temp = r_apd_temp[15:8] - 8'd20;
	
	adc_to_temp U1
	(
		.i_clk_50m			(i_clk_50m),
		.i_rst_n			(i_rst_n),
		
		.i_adc_value		({r_adc_value,2'd0}),
		.i_adc_start		(r_adc_start),
		
		.o_temp_done		(w_temp_done),
		.o_temp_value		(w_temp_value)
	);
	
	multiplier3 U2
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(r_mult_en), 
		
		.Aclr				(1'b0), 
		.DataA				(r_mult1_dataA), 
		.DataB				(r_mult1_dataB), 
		.Result				(w_mult1_result)
	);
	
	multiplier3 U3
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(1'b1), 
		
		.Aclr				(1'b0), 
		.DataA				(8'd30), 
		.DataB				(i_temp_temp_coe[7:0]), 
		.Result				(w_mult2_result)
	);
	
	multiplier3 U4
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(1'b1), 
		
		.Aclr				(1'b0), 
		.DataA				(8'd20), 
		.DataB				(i_temp_temp_coe[7:0]), 
		.Result				(w_mult3_result)
	);	
endmodule 