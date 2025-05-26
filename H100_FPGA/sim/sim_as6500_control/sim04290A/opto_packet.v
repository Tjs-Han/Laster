module opto_packet(
	input i_clk_50m,
	input i_rst_n,
	
	input i_opto_rise,
	
	input i_send_opto_flag,
	
	input i_zero_sign ,
	input i_opto_fall ,	
	
	output 			o_opto_wren 		,
	output	[7:0]  o_opto_wrdata 		,
	output	[9:0]  o_opto_wraddr 	    ,	
	output			o_opto_make 	
	
);
	


	reg		[31:0] r_opto_one;
	reg		[31:0]	r_opto_reg;
	reg		[3:0]	r_shift_num;
	reg		[31:0]	r_opto_data;	
	reg		[7:0]	r_opto_wrdata;
	reg		[10:0]	r_opto_wraddr;
	reg				r_opto_wren;
	reg				r_opto_make;
	reg				r_zero_sign;
	reg				r_opto_fall;	
	
	always@(posedge i_clk_50m or negedge i_rst_n)//
	    if(i_rst_n == 0)begin
			r_zero_sign <= 1'd0;
			r_opto_fall <= 1'd0;
		end
		else begin
			r_zero_sign <= i_zero_sign;
			r_opto_fall <= i_opto_fall;
		end
			
	
	
	
	always@(posedge i_clk_50m or negedge i_rst_n)//
	    if(i_rst_n == 0)
			r_opto_one <= 32'd0;
		else if(r_zero_sign | r_opto_fall)
			r_opto_one <= 32'd0;
		else
			r_opto_one <= r_opto_one + 1'd1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//
	    if(i_rst_n == 0)
			r_opto_reg <= 32'd0;
		else if(r_opto_fall | r_zero_sign)
			r_opto_reg <= r_opto_one;
		else
			r_opto_reg <= r_opto_reg;
			
	reg  	[7:0]  r_state;
//	reg		[2:0]	r_shift_num = 3'd0;
//	reg		[63:0]	r_opto_data = 32'd0;
	reg  	[7:0]  r_packet_num;

			
	parameter	IDLE	= 8'b0000_0000,
				BEGIN	= 8'b0000_0001,
				WAIT	= 8'b0000_0010,
				WAIT1	= 8'b0000_0100,
				WRITE	= 8'b0000_1000,
				SHIFT	= 8'b0001_0000,
				SHIFT1	= 8'b0010_0000,
				END		= 8'b0100_0000;
					
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_state	<= IDLE;
		else begin
			case(r_state)
				IDLE : r_state <= WAIT;
				BEGIN : begin
					if(i_send_opto_flag)
						r_state <= WAIT;
					else
						r_state <= BEGIN;
					end
				WAIT : begin
					if(r_zero_sign)
						r_state <= WRITE;
					else
						r_state <= WAIT;
					end
				WAIT1 : begin
					if( r_opto_fall)
						r_state <= WRITE;
					else
						r_state <= WAIT1;
					end				
				WRITE:r_state <= SHIFT;
				SHIFT:begin
					if(r_shift_num >= 3'd3)
						r_state <= SHIFT1;
					else
						r_state <= WRITE;
					end
				SHIFT1:begin
					if(r_packet_num >= 'd39)
						r_state <= END;
					else
						r_state <= WAIT1;
					end
				END: r_state <= IDLE;
			default: r_state <= IDLE;
			endcase
		end
						
	//r_shift_num
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_shift_num		<= 3'd0;
		else if(r_state	== SHIFT)
			r_shift_num		<= r_shift_num + 1'b1;
		else if(r_state	== SHIFT1)
			r_shift_num		<= 3'd0;
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_data	<= 32'd0;
		else if(r_zero_sign | r_opto_fall)
			r_opto_data	<= r_opto_reg;
		else if(r_state == SHIFT)
			r_opto_data	<= {r_opto_data[23:0],8'd0};
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_wrdata	<= 8'd0;
		else if(r_state == WRITE)
			r_opto_wrdata	<= r_opto_data[31:24];
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_packet_num	<= 8'd0;
		else if(r_state == IDLE)
			r_packet_num	<= 8'd0;
		else if(r_state ==WAIT1)
			r_packet_num	<= r_packet_num + r_opto_fall;
		else if(r_state == END )
			r_packet_num	<= 8'd0;
			

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_wraddr <= 10'd0;
		else if(r_state	== WAIT || r_state == IDLE)
			r_opto_wraddr <= 10'd0;
		else if(r_state == SHIFT)
			r_opto_wraddr <= r_opto_wraddr + 1'b1;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_wren	<= 1'b0;
		else if(r_state == WRITE)
			r_opto_wren	<= 1'b1;
		else
			r_opto_wren	<= 1'b0;
						
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_make	<= 1'b0;
		else if(r_state	== END )
			r_opto_make	<= 1'b1;
		else
			r_opto_make	<= 1'b0;
	
	assign 	o_opto_wren 		= r_opto_wren;
	assign	o_opto_wrdata 		= r_opto_wrdata;
	assign	o_opto_wraddr 		= r_opto_wraddr;
	assign	o_opto_make 		= r_opto_make;	
	
	
	
	
	endmodule	
	
	
	