module sram_control
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input			i_sram_csen_flash	,
	input			i_sram_wren_flash	,
	input			i_sram_rden_flash	,
	input	[17:0]	i_sram_addr_flash	,
	input	[15:0]	i_sram_data_flash	,
	output	[15:0]	o_sram_data_flash	,
	
	input			i_sram_csen_eth		,
	input			i_sram_wren_eth		,
	input			i_sram_rden_eth		,
	input	[17:0]	i_sram_addr_eth		,
	inout	[15:0]	i_sram_data_eth		,
	output	[15:0]	o_sram_data_eth		,
	
	input	[17:0]	i_sram_addr_dist	,
	output	[15:0]	o_sram_data_dist	,
	
	output			o_sram_cs_n			,
	output			o_sram_ub_n			,
	output			o_sram_lb_n			,
	output			o_sram_oe_n			,
	output			o_sram_we_n			,
	output	[17:0]	o_sram_addr			,
	inout	[15:0]	io_sram_data			
);

	assign			o_sram_cs_n	= 1'b0;
	assign			o_sram_ub_n	= 1'b0;
	assign			o_sram_lb_n	= 1'b0;
	
	wire	[15:0]	w_sram_data		;		
	wire			w_sram_fe_en	;
	wire			w_sram_wren_fe	;
	wire			w_sram_rden_fe	;
	wire	[17:0]	w_sram_addr_fe	;
	
	assign			io_sram_data = (o_sram_we_n)?16'bz:w_sram_data;
	
	assign			w_sram_fe_en = i_sram_csen_eth | i_sram_csen_flash;
	
	assign			w_sram_wren_fe = (i_sram_csen_flash)?i_sram_wren_flash:i_sram_wren_eth;
	assign			w_sram_rden_fe = (i_sram_csen_flash)?i_sram_rden_flash:i_sram_rden_eth;
	assign			w_sram_addr_fe = (i_sram_csen_flash)?i_sram_addr_flash:i_sram_addr_eth;
	assign			w_sram_data	   = (i_sram_csen_flash)?i_sram_data_flash:i_sram_data_eth;
	
	assign			o_sram_oe_n = (w_sram_fe_en)?w_sram_rden_fe:1'b0;
	assign			o_sram_we_n = (w_sram_fe_en)?w_sram_wren_fe:1'b1;
	assign			o_sram_addr = (w_sram_fe_en)?w_sram_addr_fe:i_sram_addr_dist;
	
	assign			o_sram_data_dist 	= (w_sram_fe_en)?1'b0:io_sram_data;
	assign			o_sram_data_eth 	= (i_sram_csen_eth)?io_sram_data:1'b0;
	assign			o_sram_data_flash 	= (i_sram_csen_flash)?io_sram_data:1'b0;

endmodule 