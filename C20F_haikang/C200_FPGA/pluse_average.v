module pluse_average
(
	input			i_clk_50m    	,
	input			i_rst_n      	,
	
	input			i_pulse_sig		,
	input	[15:0]	i_pulse_get		,
	
	output	[15:0]	o_pulse_average	
);

	reg		[19:0]	r_pulse_average = 16'd0;
	
	reg				r_pulse_sig = 1'b0;
	
	reg		[15:0]	r_pulse_value0 = 16'd0;
	reg		[15:0]	r_pulse_value1 = 16'd0;
	reg		[15:0]	r_pulse_value2 = 16'd0;
	reg		[15:0]	r_pulse_value3 = 16'd0;
	reg		[15:0]	r_pulse_value4 = 16'd0;
	reg		[15:0]	r_pulse_value5 = 16'd0;
	reg		[15:0]	r_pulse_value6 = 16'd0;
	reg		[15:0]	r_pulse_value7 = 16'd0;
	reg		[15:0]	r_pulse_value8 = 16'd0;
	reg		[15:0]	r_pulse_value9 = 16'd0;
	reg		[15:0]	r_pulse_valueA = 16'd0;
	reg		[15:0]	r_pulse_valueB = 16'd0;
	reg		[15:0]	r_pulse_valueC = 16'd0;
	reg		[15:0]	r_pulse_valueD = 16'd0;
	reg		[15:0]	r_pulse_valueE = 16'd0;
	reg		[15:0]	r_pulse_valueF = 16'd0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_pulse_sig	<= 1'b0;
		else
			r_pulse_sig	<= i_pulse_sig;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_pulse_value0	<= 16'd0;
			r_pulse_value1	<= 16'd0;
			r_pulse_value2	<= 16'd0;
			r_pulse_value3	<= 16'd0;
			r_pulse_value4	<= 16'd0;
			r_pulse_value5	<= 16'd0;
			r_pulse_value6	<= 16'd0;
			r_pulse_value7	<= 16'd0;
			r_pulse_value8	<= 16'd0;
			r_pulse_value9	<= 16'd0;
			r_pulse_valueA	<= 16'd0;
			r_pulse_valueB	<= 16'd0;
			r_pulse_valueC	<= 16'd0;
			r_pulse_valueD	<= 16'd0;
			r_pulse_valueE	<= 16'd0;
			r_pulse_valueF	<= 16'd0;
			end
		else if(i_pulse_sig)begin
			r_pulse_value0	<= r_pulse_value1;
			r_pulse_value1	<= r_pulse_value2;
			r_pulse_value2	<= r_pulse_value3;
			r_pulse_value3	<= r_pulse_value4;
			r_pulse_value4	<= r_pulse_value5;
			r_pulse_value5	<= r_pulse_value6;
			r_pulse_value6	<= r_pulse_value7;
			r_pulse_value7	<= r_pulse_value8;
			r_pulse_value8	<= r_pulse_value9;
			r_pulse_value9	<= r_pulse_valueA;
			r_pulse_valueA	<= r_pulse_valueB;
			r_pulse_valueB	<= r_pulse_valueC;
			r_pulse_valueC	<= r_pulse_valueD;
			r_pulse_valueD	<= r_pulse_valueE;
			r_pulse_valueE	<= r_pulse_valueF;
			r_pulse_valueF	<= i_pulse_get;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_pulse_average <= 20'd0;
		else if(r_pulse_sig)
			r_pulse_average <= 	r_pulse_value0[15:0] + r_pulse_value1[15:0] + r_pulse_value2[15:0] + r_pulse_value3[15:0] +
								r_pulse_value4[15:0] + r_pulse_value5[15:0] + r_pulse_value6[15:0] + r_pulse_value7[15:0] + 
								r_pulse_value8[15:0] + r_pulse_value9[15:0] + r_pulse_valueA[15:0] + r_pulse_valueB[15:0] + 
								r_pulse_valueC[15:0] + r_pulse_valueD[15:0] + r_pulse_valueE[15:0] + r_pulse_valueF[15:0] ;
								
	

    assign	o_pulse_average = (r_pulse_average[3:0] > 4'd7) ? (r_pulse_average[19:4] + 1'd1) : r_pulse_average[19:4];

endmodule 