//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: dist_calculate
// Date Created 	: 2023/12/19 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
// File description	:dist_calculate
//				distance and reflectivity calculation ctrl module
//--------------------------------------------------------------------------------------------------
// Revision History :V1.0
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------	
module dist_calculate
#(
	parameter DDR_AW 		    	= 27,
	parameter DDR_DW 		    	= 64,
	parameter DDR_COE_BASE_ADDR		= 27'h001_0000,
	parameter DDR_RSSI_BASE_ADDR	= 27'h000_4000
)
(
	input						i_clk,
	input						i_rst_n,
	input						i_discal_en,

	input						i_rssi_switch,
	input  [15:0]				i_code_angle1,
	input  [15:0]				i_code_angle2,
	input						i_tdc_newsig,
	input  [31:0]				i_rise_data,
	input  [31:0]				i_fall_data,
	
	input  [31:0]				i_rise_divid,
	input  [31:0]				i_pulse_start,
	input  [31:0]				i_pulse_divid,
	input  [31:0]				i_distance_min,
	input  [31:0]				i_distance_max,
	input  [15:0]				i_dist_compen,

	output						o_ddr_rden,
	output [DDR_AW-1:0]     	o_rdddr_addr_base,
	output						o_fifo_rden,
	input  [DDR_DW-1:0]			i_fifo_rddata,
	input						i_fifo_empty,

	output [31:0]				o_dist_data,
	output [15:0]				o_rssi_data,
	// output [31:0]				o_pulse_data,
	output [15:0]				o_rssi_tail,
	output [15:0]				o_dist_angle1,
	output [15:0]				o_dist_angle2,
	output						o_dist_newsig		
);
	//----------------------------------------------------------------------------------------------
	// wire define
	//----------------------------------------------------------------------------------------------
	wire						w_indfifo_rden;
	wire [87:0]					w_indfifo_rdata;
	wire						w_indfifo_empty;
	wire						w_indfifo_full;

	wire [31:0]					w_rise_data;
	wire [31:0]					w_pulse_data;
	wire						w_dist_precal_sig;
	wire [15:0]					w_dist_precal_angle1;
	wire [15:0]					w_dist_precal_angle2;

	wire [15:0]					w_discal_angle1;
	wire [15:0]					w_discal_angle2;
	wire						w_dist_flag;
	wire [31:0]					w_dist_data;

	wire						w_rssi_ddr_en;
	wire						w_ddr_rden_dist;
	wire						w_fifo_rden_dist;
	wire [DDR_AW-1:0]     		w_rdddr_addr_dist;
	wire						w_ddr_rden_rssi;
	wire						w_fifo_rden_rssi;
	wire [DDR_AW-1:0]     		w_rdddr_addr_rssi;
	//----------------------------------------------------------------------------------------------
	// module inst domain
	//----------------------------------------------------------------------------------------------
	data_pre u1_data_pre(
	
		.i_clk    				( i_clk						),
		.i_rst_n      			( i_rst_n					),
		.i_discal_en			( i_discal_en				),

		.i_tdc_newsig			( i_tdc_newsig				),
		.i_code_angle1			( i_code_angle1				),
		.i_code_angle2			( i_code_angle2				),
		.i_rise_data			( i_rise_data				),
		.i_fall_data			( i_fall_data				),

		.o_rise_data			( w_rise_data				),
		.o_pulse_data			( w_pulse_data				),
		.o_dist_precal_sig		( w_dist_precal_sig			),
		.o_dist_precal_angle1	( w_dist_precal_angle1		),
		.o_dist_precal_angle2	( w_dist_precal_angle2		)
	);

	index_cal u2_index_cal(
	
		.i_clk    				( i_clk						),
		.i_rst_n      			( i_rst_n					),

		.i_rise_data			( w_rise_data				),
		.i_pulse_data			( w_pulse_data				),

		.i_dist_precal_sig		( w_dist_precal_sig			),
		.i_dist_precal_angle1	( w_dist_precal_angle1		),
		.i_dist_precal_angle2	( w_dist_precal_angle2		),
		.i_rise_divid			( i_rise_divid				),
		.i_pulse_start			( i_pulse_start				),
		.i_pulse_divid			( i_pulse_divid				),

		.i_indfifo_rden			( w_indfifo_rden			),
		.o_indfifo_rdata		( w_indfifo_rdata			),
		.o_indfifo_empty		( w_indfifo_empty			),
		.o_indfifo_full			( w_indfifo_full			)
	
	);
	
	dist_cal 
	#(
	    .DDR_AW 		    	( DDR_AW                	),
	    .DDR_DW 		    	( DDR_DW                	),
		.DDR_COE_BASE_ADDR		( DDR_COE_BASE_ADDR			)
    )	
	u3_dist_cal	
	(	
		
		.i_clk    				( i_clk						),
		.i_rst_n      			( i_rst_n					),

		.o_indfifo_rden			( w_indfifo_rden			),
		.i_indfifo_rdata		( w_indfifo_rdata			),
		.i_indfifo_empty		( w_indfifo_empty			),
		.i_indfifo_full			( w_indfifo_full			),

		// .i_distance_min			( i_distance_min			),
		// .i_distance_max			( i_distance_max			),
		.i_distance_min			( 32'd50					),
		.i_distance_max			( 32'd50000					),
		.i_dist_compen			( i_dist_compen				),

		.i_rssi_ddr_en			( w_rssi_ddr_en				),
		.o_ddr_rden				( w_ddr_rden_dist			),
		.o_fifo_rden			( w_fifo_rden_dist			),
		.i_fifo_rddata			( i_fifo_rddata				),
		.o_rdddr_addr_base		( w_rdddr_addr_dist			),
		.i_fifo_empty			( i_fifo_empty				),

		.o_dist_flag			( w_dist_flag				),
		.o_discal_angle1		( w_discal_angle1			),
		.o_discal_angle2		( w_discal_angle2			),
		.o_dist_data			( w_dist_data				)		
	
	);
	
	rssi_cal 
	#(
	    .DDR_AW 		    	( DDR_AW                	),
	    .DDR_DW 		    	( DDR_DW                	),
		.DDR_RSSI_BASE_ADDR		( DDR_RSSI_BASE_ADDR		)
    )
	u4_rssi_cal
	(
	
		.i_clk    				( i_clk						),
		.i_rst_n      			( i_rst_n					),

		.i_rssi_switch			( i_rssi_switch				),
		.i_dist_flag			( w_dist_flag				),
		.i_code_angle1			( w_discal_angle1			),
		.i_code_angle2			( w_discal_angle2			),
		.i_pulse_data			( w_pulse_data				),
		.i_dist_data			( w_dist_data				),

		.o_rssi_ddr_en			( w_rssi_ddr_en				),
		.o_ddr_rden				( w_ddr_rden_rssi			),
		.o_fifo_rden			( w_fifo_rden_rssi			),
		.i_fifo_rddata			( i_fifo_rddata				),
		.o_rdddr_addr_base		( w_rdddr_addr_rssi			),
		.i_fifo_empty			( i_fifo_empty				),

		.o_rssi_data			( o_rssi_data				),
		.o_rssi_tail			( o_rssi_tail				),
		.o_rssical_angle1		( o_dist_angle1				),
		.o_rssical_angle2		( o_dist_angle2				),
		.o_rssical_newsig		( o_dist_newsig				)	
	);
	//----------------------------------------------------------------------------------------------
	// output assign define
	//----------------------------------------------------------------------------------------------
	assign o_ddr_rden			= (w_rssi_ddr_en)?w_ddr_rden_rssi:w_ddr_rden_dist;
	assign o_fifo_rden			= (w_rssi_ddr_en)?w_fifo_rden_rssi:w_fifo_rden_dist;
	assign o_rdddr_addr_base	= (w_rssi_ddr_en)?w_rdddr_addr_rssi:w_rdddr_addr_dist;
	assign o_dist_data			= w_dist_data;
endmodule 