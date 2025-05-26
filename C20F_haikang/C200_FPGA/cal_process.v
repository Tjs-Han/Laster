module cal_process
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input			i_process_en		,
	input			i_post_sign			,
	input			i_now_sign			,
	input	[15:0]	i_tdc_para_1		,
	input	[15:0]	i_tdc_para_2		,
	input	[10:0]	i_addr_mid			,
	input	[15:0]	i_rise_data			,
	input	[10:0]	i_tdc_rd_addr		,
	
	output			o_process_done		,
	output	[15:0]	o_process_data		
);

	reg				r_process_done	= 1'b0;
	reg		[15:0]	r_process_data	= 16'd0;
	
	reg 	[15:0]	r_mult1_dataA = 16'd0;
	reg 	[15:0]	r_mult1_dataB = 16'd0;
    wire	[31:0]	w_mult1_result;
	reg		[3:0]	r_delay_cnt	  = 4'd0;
	
	reg		[21:0]	r_offset_value	= 22'd0;
	reg		[15:0]	r_offset_length	= 16'd0;
	reg		[9:0]	r_process_state	= 10'd0;
	
	parameter		PROCESS_IDLE		= 10'b00_0000_0000,
					PROCESS_WAIT		= 10'b00_0000_0010,
					PROCESS_DIFF		= 10'b00_0000_0100,
					PROCESS_PARA1		= 10'b00_0000_1000,
					PROCESS_ASSIGN1		= 10'b00_0001_0000,
					PROCESS_PARA2		= 10'b00_0010_0000,
					PROCESS_ASSIGN2		= 10'b00_0100_0000,
					PROCESS_ASSIGN3		= 10'b00_1000_0000,
					PROCESS_END			= 10'b01_0000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_process_done		<= 1'b0;
			r_process_data		<= 16'd0;
			r_offset_value		<= 22'd0;
			r_offset_length		<= 16'd0;
			r_mult1_dataA		<= 16'd0;
			r_mult1_dataB		<= 16'd0;
			r_delay_cnt			<= 4'd0;
			r_process_state		<= PROCESS_IDLE;
			end
		else begin
			case(r_process_state)
				PROCESS_IDLE	:begin
					r_process_done		<= 1'b0;
					r_offset_value		<= 22'd0;
					r_offset_length		<= 16'd0;
					r_mult1_dataA		<= 16'd0;
					r_mult1_dataB		<= 16'd0;
					r_delay_cnt			<= 4'd0;
					r_process_state		<= PROCESS_WAIT;
					end
				PROCESS_WAIT	:begin
					if(i_process_en)begin
						r_process_data		<= 16'd0;
						r_offset_value		<= 22'd0;
						r_offset_length		<= 16'd0;
						r_process_state		<= PROCESS_DIFF;
						end
					else
						r_process_state		<= PROCESS_WAIT;
					end
				PROCESS_DIFF	:begin
					if(i_tdc_rd_addr < i_addr_mid)begin
						r_offset_length		<= i_addr_mid - i_tdc_rd_addr;
						r_process_state		<= PROCESS_PARA1;
						end
					else if(i_tdc_rd_addr > i_addr_mid)begin
						r_offset_length		<= i_tdc_rd_addr - i_addr_mid;
						r_process_state		<= PROCESS_PARA2;
						end
					else 
						r_process_state		<= PROCESS_ASSIGN3;
					end
				PROCESS_PARA1	:begin
					r_mult1_dataA		<= i_tdc_para_1;
					r_mult1_dataB		<= r_offset_length;
					if(r_delay_cnt <= 4'd9)begin
						r_delay_cnt			<= r_delay_cnt + 1'b1;
						r_process_state		<= PROCESS_PARA1;
						end
					else begin
						r_delay_cnt			<= 4'd0;
						r_offset_value		<= w_mult1_result>>'d10;
						r_process_state		<= PROCESS_ASSIGN1;
						end
					end
				PROCESS_ASSIGN1	:begin
					if(i_post_sign)
						r_process_data		<= i_rise_data - r_offset_value;
					else
						r_process_data		<= i_rise_data + r_offset_value;
					r_process_done		<= 1'b1;
					r_process_state		<= PROCESS_END;
					end
				PROCESS_PARA2	:begin
					r_mult1_dataA		<= i_tdc_para_2;
					r_mult1_dataB		<= r_offset_length;
					if(r_delay_cnt <= 4'd9)begin
						r_delay_cnt			<= r_delay_cnt + 1'b1;
						r_process_state		<= PROCESS_PARA2;
						end
					else begin
						r_delay_cnt			<= 4'd0;
						r_offset_value		<= w_mult1_result>>'d10;
						r_process_state		<= PROCESS_ASSIGN2;
						end
					end
				PROCESS_ASSIGN2	:begin
					if(i_now_sign)
						r_process_data		<= i_rise_data + r_offset_value;
					else
						r_process_data		<= i_rise_data - r_offset_value;
					r_process_done		<= 1'b1;
					r_process_state		<= PROCESS_END;
					end
				PROCESS_ASSIGN3	:begin
					r_process_data		<= i_rise_data;
					r_process_done		<= 1'b1;
					r_process_state		<= PROCESS_END;
					end
				PROCESS_END		:begin
					r_process_done		<= 1'b0;
					r_process_state		<= PROCESS_IDLE;
					end
				default			:
					r_process_state		<= PROCESS_IDLE;
				endcase
			end
						
	assign		o_process_done	= r_process_done;
	assign		o_process_data	= r_process_data;						
					
	multiplier U1
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(1'b1), 
		
		.Aclr				(1'b0), 
		.DataA				(r_mult1_dataA), 
		.DataB				(r_mult1_dataB), 
		.Result				(w_mult1_result)
	);
						

endmodule 