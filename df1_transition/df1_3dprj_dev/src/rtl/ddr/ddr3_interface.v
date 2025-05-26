//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: ddr3_interface
// Date Created 	: 2024/11/18 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
// File description	:ddr3_interface module
//				
//--------------------------------------------------------------------------------------------------
// Revision History :			
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module ddr3_interface 
#(  
    parameter ARB_DW        = 96,
    parameter ST_WIDTH      = 8,
    parameter CMD_WIDTH     = 4,
    parameter DDR_DW        = 64,
    parameter DDR_AW        = 27,
    parameter DDR_BLW       = 5,
    parameter DM_WIDTH      = 8,
    parameter USER_RDW      = 16
)
(
    //----------------------------------------------------------------------------------------------
    // system siganl
    //----------------------------------------------------------------------------------------------
    input                               i_clk,
    input                               i_ddr_sclk,
    input                               i_rst_n,

    //ddr interface     
    input                               i_init_done,
    input                               i_cmd_rdy,
    input                               i_datain_rdy,
    input                               i_rt_err,
    input                               i_wl_err,
    input                               i_rdata_valid,
    input  [DDR_DW-1:0]                 i_ddr_rdata,
    output [CMD_WIDTH-1:0]              o_cmd,
    output [DDR_AW-1:0]                 o_addr,
    output [DDR_BLW-1:0]                o_cmd_burst_cnt,
    output                              o_cmd_valid,
    output                              o_ofly_burst_len,
    output [DDR_DW-1:0]                 o_ddr3_wdata,
    output [DM_WIDTH-1:0]               o_data_mask,

    // user interface
    // udp
    input                               i_udp2ddr_wren,
    input                               i_udp2ddr_rden,
    input  [DDR_AW-1:0]                 i_udp2ddr_addr,
    input  [DDR_DW-1:0]                 i_udp2ddr_data,
    output                              o_ddr2udp_valid,
    output [DDR_DW-1:0]                 o_ddr2udp_data,
    // para
    input                               i_para2ddr_wren,
    input                               i_ddr2para_rden,
    input  [DDR_AW-1:0]                 i_para2ddr_addr,
    input  [DDR_DW-1:0]                 i_para2ddr_data,
    input                               i_ddr2para_fifo_rden,
    output                              o_ddr2para_fifo_empty,
    output [DDR_DW-1:0]                 o_ddr2para_fifo_data,
    // flash        
    input                               i_flash2ddr_wren,
    input                               i_ddr2flash_rden,
    input  [DDR_AW-1:0]                 i_flash2ddr_addr,
    input  [DDR_DW-1:0]                 i_flash2ddr_data,
    input                               i_ddr2flash_fifo_rden,
    output                              o_ddr2flash_fifo_empty,
    output [DDR_DW-1:0]                 o_ddr2flash_fifo_data,
    // dist     
    input                               i_dist2ddr_wren,
    input                               i_dist2ddr_rden,
    input  [DDR_AW-1:0]                 i_dist2ddr_addr,
    input  [DDR_DW-1:0]                 i_dist2ddr_data,
    input                               i_ddr2dist_fifo_rden,
    output                              o_ddr2dist_fifo_empty,
    output [DDR_DW-1:0]                 o_ddr2dist_fifo_data
);
    //----------------------------------------------------------------------------------------------
    // reg and wire define 
    //----------------------------------------------------------------------------------------------
    wire                                w_arbfifo_rden;
    wire [ARB_DW-1:0]                   w_arbfifo_rddata;
    wire                                w_arbfifo_empty;
    wire [CMD_WIDTH-1:0]                w_req_type;
    //----------------------------------------------------------------------------------------------
    // localparam define 
    //----------------------------------------------------------------------------------------------

    //----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
    ddr3_rw_ctrl #(
        .CMD_WIDTH             			( CMD_WIDTH             	),
        .DDR_DW                			( DDR_DW                	),
        .DDR_AW                			( DDR_AW                	),
        .DDR_BLW               			( DDR_BLW               	),
        .DM_WIDTH              			( DM_WIDTH              	)
    )
    u1_ddr3_rw_ctrl
    (
		.i_ddr_sclk						( i_ddr_sclk                ),
        .i_rst_n                		( i_rst_n               	),

        .o_arbfifo_rden                 ( w_arbfifo_rden            ),
        .i_arbfifo_rddata               ( w_arbfifo_rddata          ),
        .i_arbfifo_empty                ( w_arbfifo_empty           ),
        .o_req_type                     ( w_req_type                ),

        .i_init_done            		( i_init_done           	),
        .i_cmd_rdy              		( i_cmd_rdy             	),
        .i_datain_rdy           		( i_datain_rdy          	),
        .i_rt_err               		( i_rt_err              	),
        .i_wl_err               		( i_wl_err              	),
        .i_rdata_valid          		( i_rdata_valid         	),
        .o_cmd                  		( o_cmd                 	),
        .o_addr                 		( o_addr                	),
        .o_cmd_burst_cnt        		( o_cmd_burst_cnt       	),
        .o_cmd_valid            		( o_cmd_valid           	),
        .o_ofly_burst_len       		( o_ofly_burst_len      	),
        .o_ddr3_wdata           		( o_ddr3_wdata          	),
        .o_data_mask            		( o_data_mask           	)
    );

    ddr_round_robin #(
        .CMD_WIDTH             			( CMD_WIDTH             	),
        .DDR_DW                			( DDR_DW                	),
        .DDR_AW                			( DDR_AW                	),
        .DDR_BLW               			( DDR_BLW               	),
        .DM_WIDTH              			( DM_WIDTH              	)
    )
    u2_ddr_round_robin
    (
        .i_clk                  		( i_clk                     ),
		.i_ddr_sclk						( i_ddr_sclk                ),
        .i_rst_n                		( i_rst_n               	),

        // udp
        .i_udp2ddr_wren                 ( i_udp2ddr_wren            ),
        .i_udp2ddr_rden                 ( i_udp2ddr_rden            ),
        .i_udp2ddr_addr                 ( i_udp2ddr_addr            ),
        .i_udp2ddr_data                 ( i_udp2ddr_data            ),
        .o_ddr2udp_valid                ( o_ddr2udp_valid           ),
        .o_ddr2udp_data                 ( o_ddr2udp_data            ),
        // para
        .i_para2ddr_wren                ( i_para2ddr_wren           ),
        .i_ddr2para_rden                ( i_ddr2para_rden           ),
        .i_para2ddr_addr                ( i_para2ddr_addr           ),
        .i_para2ddr_data                ( i_para2ddr_data           ),
        .i_ddr2para_fifo_rden           ( i_ddr2para_fifo_rden      ),
        .o_ddr2para_fifo_empty			( o_ddr2para_fifo_empty		),
        .o_ddr2para_fifo_data			( o_ddr2para_fifo_data		),
        // flash
        .i_flash2ddr_wren               ( i_flash2ddr_wren          ),
        .i_ddr2flash_rden               ( i_ddr2flash_rden          ),
        .i_flash2ddr_addr               ( i_flash2ddr_addr          ),
        .i_flash2ddr_data               ( i_flash2ddr_data          ),
        .i_ddr2flash_fifo_rden          ( i_ddr2flash_fifo_rden     ),
        .o_ddr2flash_fifo_empty         ( o_ddr2flash_fifo_empty    ),
        .o_ddr2flash_fifo_data          ( o_ddr2flash_fifo_data     ),
        // dist
        .i_dist2ddr_wren                ( i_dist2ddr_wren           ),
        .i_dist2ddr_rden                ( i_dist2ddr_rden           ),
        .i_dist2ddr_addr                ( i_dist2ddr_addr           ),
        .i_dist2ddr_data                ( i_dist2ddr_data           ),
        .i_ddr2dist_fifo_rden           ( i_ddr2dist_fifo_rden      ),
        .o_ddr2dist_fifo_empty          ( o_ddr2dist_fifo_empty     ),
        .o_ddr2dist_fifo_data           ( o_ddr2dist_fifo_data      ),
        // ddr interface
        .i_req_type                     ( w_req_type                ),
        .i_rdata_valid                  ( i_rdata_valid             ),
        .i_ddr_rdata                    ( i_ddr_rdata               ),
        .i_arbfifo_rden                 ( w_arbfifo_rden            ),
        .o_arbfifo_rddata               ( w_arbfifo_rddata          ),
        .o_arbfifo_empty                ( w_arbfifo_empty           )
    );
endmodule