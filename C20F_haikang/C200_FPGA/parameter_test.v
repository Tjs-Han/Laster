module parameter_test
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input			i_read_complete_sig	,
	
	output			o_sram_csen_eth		,
	output			o_sram_wren_eth		,
	output			o_sram_rden_eth		,
	output	[17:0]	o_sram_addr_eth		,
	output	[15:0]	o_sram_data_eth		,
	input	[15:0]	i_sram_data_eth		,
	
	output	[7:0]	o_config_mode		,
	output	[15:0]	o_pwm_value_0		,
	output	[15:0]	o_stop_window		,
	
	output			o_rst_n				
);

	reg		[9:0]	r_para_state = 10'd0;
	
	reg		[7:0]	r_config_mode = 8'd0;
	reg		[15:0]	r_pwm_value_0 = 16'd0;
	reg		[15:0]	r_stop_window = 16'd0;
	reg				r_rst_n		  = 1'b0;
	
	reg				r_sram_csen_eth = 1'b0;
	reg				r_sram_wren_eth = 1'b1;
	reg				r_sram_rden_eth = 1'b1;
	reg		[17:0]	r_sram_addr_eth = 18'd0;
	reg		[15:0]	r_sram_data_eth = 16'd0;
	
	parameter		PARA_IDLE		= 10'b00_0000_0000,
					PARA_WAIT		= 10'b00_0000_0010,
					PARA_READ		= 10'b00_0000_0100,
					PARA_ASSIGN1	= 10'b00_0000_1000,
					PARA_ASSIGN2	= 10'b00_0001_0000,
					PARA_ASSIGN3	= 10'b00_0010_0000,
					PARA_END		= 10'b00_0100_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_para_state		<= PARA_IDLE;
			r_config_mode 		<= 8'd0;
			r_pwm_value_0 		<= 16'd0;
			r_stop_window 		<= 16'd0;
			r_sram_csen_eth 	<= 1'b0;
			r_sram_wren_eth 	<= 1'b1;
			r_sram_rden_eth 	<= 1'b1;
			r_sram_addr_eth 	<= 18'd0;
			r_sram_data_eth 	<= 16'd0;
			r_rst_n				<= 1'b0;
			end
		else begin
			case(r_para_state)
				PARA_IDLE	:begin
					r_config_mode 		<= 8'd0;
					r_pwm_value_0 		<= 16'd0;
					r_stop_window 		<= 16'd0;
					r_sram_csen_eth 	<= 1'b0;
					r_sram_wren_eth 	<= 1'b1;
					r_sram_rden_eth 	<= 1'b1;
					r_sram_addr_eth 	<= 18'd0;
					r_sram_data_eth 	<= 16'd0;
					r_rst_n				<= 1'b0;
					r_para_state		<= PARA_WAIT;
					end
				PARA_WAIT	:begin
					if(i_read_complete_sig)begin
						r_rst_n				<= 1'b0;
						r_para_state		<= PARA_READ;
						end 
					end
				PARA_READ	:begin
					r_sram_csen_eth 	<= 1'b1;
					r_sram_rden_eth 	<= 1'b0;
					r_sram_addr_eth 	<= 18'd0;
					r_para_state		<= PARA_ASSIGN1;
					end
				PARA_ASSIGN1:begin
					r_sram_csen_eth 	<= 1'b1;
					r_sram_rden_eth 	<= 1'b0;
					r_sram_addr_eth 	<= 18'd1;
					r_config_mode		<= i_sram_data_eth[7:0];
					r_para_state		<= PARA_ASSIGN2;
					end
				PARA_ASSIGN2:begin
					r_sram_csen_eth 	<= 1'b1;
					r_sram_rden_eth 	<= 1'b0;
					r_sram_addr_eth 	<= 18'd2;
					r_pwm_value_0		<= i_sram_data_eth;
					r_para_state		<= PARA_ASSIGN3;
					end
				PARA_ASSIGN3:begin
					r_sram_csen_eth 	<= 1'b0;
					r_sram_rden_eth 	<= 1'b1;
					r_sram_addr_eth 	<= 18'd0;
					r_stop_window		<= i_sram_data_eth;
					r_para_state		<= PARA_END;
					end
				PARA_END	:begin
					r_para_state		<= PARA_WAIT;
					r_rst_n				<= 1'b1;
					end
				default	:r_para_state		<= PARA_IDLE;
				endcase
			end
			
	assign	o_sram_csen_eth	= r_sram_csen_eth;
	assign	o_sram_wren_eth	= r_sram_wren_eth;
	assign	o_sram_rden_eth	= r_sram_rden_eth;
	assign	o_sram_addr_eth	= r_sram_addr_eth;
	
	assign	o_config_mode = r_config_mode;
	assign	o_pwm_value_0 = r_pwm_value_0;
	assign	o_stop_window = r_stop_window;
	assign	o_rst_n		  = r_rst_n;

endmodule 