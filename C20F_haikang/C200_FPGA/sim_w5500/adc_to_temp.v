module adc_to_temp
(
	input			i_clk_50m		,
	input			i_rst_n			,
	
	input	[11:0]	i_adc_value		,
	input			i_adc_start		,
	
	output			o_temp_done		,
	output	[15:0]	o_temp_value	
);

	reg		[9:0]	r_temp_state = 10'd0;
	reg		[11:0]	r_adc_value	= 12'd0;
	reg		[15:0]	r_temp_value = 16'd0;
	reg				r_temp_done = 1'b0;
	reg		[31:0]	r_temp_value_coe = 32'd0;
	reg		[4:0]	r_temp_num = 5'd0;
	reg		[7:0]	r_dealy_cnt = 8'd0;
	
	reg 	[15:0] r_mult1_dataA = 16'd0;
    reg 	[15:0] r_mult1_dataB = 16'd0;
	reg				r_mult_en	  = 1'b0;
    wire	[31:0] w_mult1_result;
	
	reg				r_cal_sig = 1'b0;
	reg 	[31:0] r_dividend = 32'd0;
	reg 	[15:0] r_divisor = 16'd0;
	wire	[15:0]	w_quotient;
	wire			w_cal_done;
	
	reg		[11:0] tempADValue[21:0];
	
	always@(posedge i_clk_50m)begin
		tempADValue[0] <= 16'd2853;
		tempADValue[1] <= 16'd2558;
		tempADValue[2] <= 16'd2271;
		tempADValue[3] <= 16'd1997;
		tempADValue[4] <= 16'd1742;
		tempADValue[5] <= 16'd1510;
		tempADValue[6] <= 16'd1302;
		tempADValue[7] <= 16'd1118;
		tempADValue[8] <= 16'd958;
		tempADValue[9] <= 16'd820;
		tempADValue[10] <= 16'd701;
		tempADValue[11] <= 16'd599;
		tempADValue[12] <= 16'd513;
		tempADValue[13] <= 16'd439;
		tempADValue[14] <= 16'd377;
		tempADValue[15] <= 16'd325;
		tempADValue[16] <= 16'd280;
		tempADValue[17] <= 16'd242;
		tempADValue[18] <= 16'd209;
		tempADValue[19] <= 16'd181;
		tempADValue[20] <= 16'd159;
		tempADValue[21] <= 16'd138;
		end
		
	parameter		TEMP_IDLE		= 10'b00_0000_0000,
					TEMP_WAIT		= 10'b00_0000_0001,
					TEMP_JUDGE		= 10'b00_0000_0010,
					TEMP_ASSIGN		= 10'b00_0000_0100,
					TEMP_CAL1		= 10'b00_0000_1000,
					TEMP_DELAY1		= 10'b00_0001_0000,
					TEMP_CAL2		= 10'b00_0010_0000,
					TEMP_DELAY2		= 10'b00_0100_0000,
					TEMP_CAL3		= 10'b00_1000_0000,
					TEMP_END		= 10'b01_0000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_adc_value		<= 12'd0;
			r_temp_value 	<= 16'd0;
			r_temp_done 	<= 1'b0;
			r_temp_value_coe <= 32'd0;
			r_temp_num 		<= 5'd0;
			r_dealy_cnt 	<= 8'd0;
			r_mult1_dataA 	<= 16'd0;
			r_mult1_dataB 	<= 16'd0;
			r_mult_en		<= 1'b0;
			r_cal_sig 		<= 1'b0;
			r_dividend	 	<= 32'd0;
			r_divisor 		<= 16'd0;
			r_temp_state	<= TEMP_IDLE;
			end
		else begin
			case(r_temp_state)
				TEMP_IDLE	:begin
					r_adc_value		<= 12'd0;
					r_temp_value 	<= 16'd0;
					r_temp_done 	<= 1'b0;
					r_temp_value_coe <= 32'd0;
					r_temp_num 		<= 5'd0;
					r_dealy_cnt 	<= 8'd0;
					r_mult1_dataA 	<= 16'd0;
					r_mult1_dataB 	<= 16'd0;
					r_mult_en		<= 1'b0;
					r_cal_sig 		<= 1'b0;
					r_dividend	 	<= 32'd0;
					r_divisor 		<= 16'd0;
					r_temp_state	<= TEMP_WAIT;
					end
				TEMP_WAIT:begin
					if(i_adc_start)begin
						r_adc_value		<= i_adc_value;
						r_temp_state	<= TEMP_JUDGE;
						end
					end
				TEMP_JUDGE:begin
					if(r_adc_value >= tempADValue[0])begin
						r_temp_value	<= {8'd0,8'd0};
						r_temp_state	<= TEMP_END;
						end
					else if(r_adc_value <= tempADValue[21])begin
						r_temp_value	<= {8'd105,8'd0};
						r_temp_state	<= TEMP_END;
						end
					else 
						r_temp_state	<= TEMP_ASSIGN;
					end
				TEMP_ASSIGN:begin
					if(r_adc_value >= tempADValue[r_temp_num])
						r_temp_state	<= TEMP_CAL1;
					else
						r_temp_num		<= r_temp_num + 1'b1;
					end
				TEMP_CAL1	:begin
					r_mult1_dataA 	<= tempADValue[r_temp_num-1] - r_adc_value;
					r_mult1_dataB 	<= 16'd1280;
					r_mult_en		<= 1'b1;
					r_temp_state	<= TEMP_DELAY1;
					end
				TEMP_DELAY1:begin
					if(r_dealy_cnt >= 8'd9)begin
						r_mult_en		<= 1'b0;
						r_dealy_cnt		<= 8'd0;
						r_temp_value_coe<= w_mult1_result;
						r_temp_state	<= TEMP_CAL2;
						end
					else
						r_dealy_cnt		<= r_dealy_cnt + 1'b1;
					end
				TEMP_CAL2	:begin
					r_mult1_dataA 	<= r_temp_num;
					r_mult1_dataB 	<= 16'd1280;
					r_mult_en		<= 1'b1;
					r_temp_state	<= TEMP_DELAY2;
					end
				TEMP_DELAY2 :begin
					if(r_dealy_cnt >= 8'd9)begin
						r_dealy_cnt		<= 8'd0;
						r_mult_en		<= 1'b0;
						r_temp_value	<= w_mult1_result;
						r_temp_state	<= TEMP_CAL3;
						end
					else
						r_dealy_cnt		<= r_dealy_cnt + 1'b1;
					end
				TEMP_CAL3:begin
					r_cal_sig 		<= 1'b1;
					r_dividend	 	<= r_temp_value_coe;
					r_divisor 		<= tempADValue[r_temp_num-1]-tempADValue[r_temp_num];
					if(w_cal_done)begin
						r_cal_sig 		<= 1'b0;
						r_temp_value	<= r_temp_value + w_quotient - 16'd1280;
						r_temp_state	<= TEMP_END;
						end
					end
				TEMP_END	:begin
					r_temp_done		<= 1'b1;
					r_temp_value	<= r_temp_value;
					r_temp_state	<= TEMP_IDLE;
					end
				default:r_temp_state	<= TEMP_IDLE;
				endcase
			end			
	assign	o_temp_done		= r_temp_done;
	assign	o_temp_value	= r_temp_value;
	
	multiplier U1
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(r_mult_en), 
		
		.Aclr				(1'b0), 
		.DataA				(r_mult1_dataA), 
		.DataB				(r_mult1_dataB), 
		.Result				(w_mult1_result)
	);
	
	division U2
	(
		.i_clk_50m			(i_clk_50m)	,
		.i_rst_n			(i_rst_n)	,
		
		.i_cal_sig			(r_cal_sig)	,
		.i_dividend			(r_dividend),
		.i_divisor			(r_divisor)	,

		.o_quotient			(w_quotient),
		.o_cal_done			(w_cal_done)
	);
				
endmodule 