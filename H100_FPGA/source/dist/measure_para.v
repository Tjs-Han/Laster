module measure_para
(
	input				i_clk_50m    		,
	input				i_rst_n      		,
		
	input		[3:0]	i_reso_mode			,
	input		[15:0]	i_zero_offset		,
	input		[15:0]	i_angle_offset		,
	input		[15:0]	i_zero_angle		,
	input				i_tdc_new_sig		,
		
	output		[15:0]	o_angle_zero		
);

	reg		[15:0]	r_angle_zero	= 16'd0;

	reg		[7:0]	r_angle_reso 	= 8'd10;
	reg		[15:0]	r_zero_angle 	= 16'd0;
	wire	[31:0]	w_mult1_result;
	wire	[31:0]	w_mult2_result;
	reg		[15:0]	r_pulse_get		= 16'd0;
	reg		[15:0]	r_pulse_rise	= 16'd0;
	reg		[15:0]	r_pulse_fall	= 16'd0;
	
	reg 	[3:0]	reso_mode;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(~i_rst_n)
			reso_mode <= 4'd0;
		else
			reso_mode <= i_reso_mode;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(~i_rst_n)
			r_angle_reso	<= 8'd10;
		else if(reso_mode==4'd3)
			r_angle_reso	<= 8'd3;
		else if(reso_mode==4'd2)
			r_angle_reso	<= 8'd5;
		else if(reso_mode==4'd1)
			r_angle_reso	<= 8'd20;
		else if(reso_mode==4'd0)
			r_angle_reso	<= 8'd10;									
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_zero_angle <= 16'd0;
		else begin
			if(reso_mode == 4'd0)
				r_zero_angle <= w_mult1_result[15:0] + i_zero_offset[3:0];			//0.1°
			else if(reso_mode == 4'd1)
				r_zero_angle <= w_mult1_result[15:0] + {i_zero_offset[3:0],1'b0};	//0.05°    *2
			else if(reso_mode == 4'd2)
				r_zero_angle <= w_mult1_result[15:0] + {i_zero_offset[3:1]};	    //0.2°	   /2	
			else if(reso_mode == 4'd3)
				r_zero_angle <= w_mult1_result[15:0] + {i_zero_offset[3:2]};	    //0.3333°	/3.33	---> /4					
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_zero <= 16'd0;
		else begin
			if(reso_mode == 4'd0)
				r_angle_zero <= w_mult2_result[15:0] + i_angle_offset[3:0];
			else if(reso_mode == 4'd1)
				r_angle_zero <= w_mult2_result[15:0] + {i_angle_offset[3:0],1'b0};
			else if(reso_mode == 4'd2)
				r_angle_zero <= w_mult2_result[15:0] + {i_angle_offset[3:1]};
			else if(reso_mode == 4'd3)
				r_angle_zero <= w_mult2_result[15:0] + {i_angle_offset[3:2]};								
			end
						
	assign	o_angle_zero	= r_angle_zero;
				
	multiplier U1
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(1'b1), 
		
		.Aclr				(1'b0), 
		.DataA				({4'd0,i_zero_offset[15:4]}), 
		.DataB				({8'd0,r_angle_reso}), 
		.Result				(w_mult1_result)
	);
	
	multiplier U2
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(1'b1), 
		
		.Aclr				(1'b0), 
		.DataA				({4'd0,i_angle_offset[15:4]}), 
		.DataB				({8'd0,r_angle_reso}), 
		.Result				(w_mult2_result)
	);


endmodule 