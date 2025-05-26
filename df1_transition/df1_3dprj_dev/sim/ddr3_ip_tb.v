
// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: ddr3_ip_tb
// Date Created 	: 2024/8/27 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:
//
// -------------------------------------------------------------------------------------------------
// Revision History :
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------

module ddr3_ip_tb
#(
    parameter CMD_WIDTH     = 4,
    parameter DDR_DW        = 64,
    parameter DDR_AW        = 26,
    parameter DDR_BLW       = 5,
    parameter DM_WIDTH      = 8,
    parameter UFIFO_DW      = 16
)();
    //----------------------------------------------------------------------------------------------
    // Localparam define
    //----------------------------------------------------------------------------------------------
	localparam CFG_CLK_FREQ_M   = 100;
    //----------------------------------------------------------------------------------------------
    // reg and wire define
    //----------------------------------------------------------------------------------------------
    reg                         cfg_clk;
    reg                         cfg_rst_n;
    reg                         r_wddr_en;
    reg                         r_rddr_en;
    reg  [DDR_AW-1:0]           r_wddr_addr_base;
    reg  [DDR_AW-1:0]           r_rddr_addr_base;

    reg                         r_wrfifo_en;
    reg  [UFIFO_DW-1:0]         r_wrfifo_data;
    reg					        r_rdfifo_en;
    wire [UFIFO_DW-1:0]	        w_fifo_rddata;
    wire                        w_urfifo_empty;


    wire                        w_axi_clk_100m;
    wire                        w_mem_rst_n;
    wire                        w_init_start;   
    wire [CMD_WIDTH-1:0]        w_cmd;
    wire [DDR_AW-1:0]           w_addr;
    wire [DDR_BLW-1:0]          w_cmd_burst_cnt;
    wire                        w_cmd_valid;
    wire                        w_ofly_burst_len;

    wire [DDR_DW-1:0]           w_ddr3_wdata;
    wire [DM_WIDTH-1:0]         w_data_mask;
    wire [DDR_DW-1:0]           w_read_data;

    wire                        w_cmd_rdy;
    wire                        w_datain_rdy;
    wire                        w_init_done;
    wire                        w_rt_err;
    wire                        w_wl_err;
    wire                        w_rdata_valid;

    wire                        w_sclk;
    wire                        w_clocking_good;
    //----------------------------------------------------------------------------------------------
    // Clock define
    //----------------------------------------------------------------------------------------------
	initial begin
        cfg_clk = 0;
        forever #((1e3/CFG_CLK_FREQ_M)/2) cfg_clk = ~cfg_clk;
    end
    //----------------------------------------------------------------------------------------------
    // TestCase
    //----------------------------------------------------------------------------------------------
    initial begin
		cfg_rst_n = 0;

		#1000;
		@(posedge cfg_clk);
		cfg_rst_n = 1;
        #1000;

        // case0(r_data, o_uart_send_done);
        //----- TestCase Start -----
        // repeat(255) begin
        //     case0(r_data);
        //     #1500;
        // end
    end
    always@(posedge cfg_clk)begin
        if(!cfg_rst_n)begin
            r_wrfifo_en     <= 1'b0;
            r_wrfifo_data   <= {UFIFO_DW{1'b0}};
        end else if(w_init_done)begin
            if(r_wrfifo_data <= 16'd255)begin
                r_wrfifo_en     <= 1'b1;
                r_wrfifo_data   <= r_wrfifo_data + 1'b1;
            end else begin
                r_wrfifo_en     <= 1'b0;
                r_wrfifo_data   <= r_wrfifo_data;
            end
        end
    end
    //----------------------------------------------------------------------------------------------
    // test Case
    //----------------------------------------------------------------------------------------------
    // task automatic case0(
    //     input [7:0] i_data,
    //     input       send_done
    // );
    // begin
    //     $display("---- Case0 Normal Test Start ! ---- At: %dns", $time);
        
    //     fork          
    //     begin: DATA_IN_CH0  
    //         i_send_num  = 16'd1;
    //         repeat(255) begin
    //             if(send_done) begin
    //                 i_data_send = i_data_send +1'b1;
    //             end else begin
    //                 i_data_wren = 1'b1;
    //             end
    //         end
                    
    //     end
    //     join

    //     $display("---- Case0 Over ! ---- At: %dns", $time);
    // end
    // endtask

    //ddr3_ip 
    ddr3_ip u1_ddr3_ip (
        .clk_in                 ( cfg_clk               ), //input
        .rst_n                  ( cfg_rst_n             ), //input
        .mem_rst_n              ( w_mem_rst_n           ), //input

        // Input signals from the User I/F 
        .init_start             ( w_init_start          ), //input
        .cmd                    ( w_cmd                 ), //input [3:0] 
        .addr                   ( w_addr                ), //input [25:0]
        .cmd_burst_cnt          ( w_cmd_burst_cnt       ), //input [4:0] 
        .cmd_valid              ( w_cmd_valid           ), //input
        .ofly_burst_len         ( w_ofly_burst_len      ), //input

        .write_data             ( w_ddr3_wdata          ), //input [63:0] 
        .data_mask              ( w_data_mask           ), //input [7:0]
        .read_data              ( w_read_data           ), //output [63:0]

        // Output signals to the User I/F
        .cmd_rdy                ( w_cmd_rdy             ), //output
        .datain_rdy             ( w_datain_rdy          ), //output
        .init_done              ( w_init_done           ), //output
        .rt_err                 ( w_rt_err              ), //output
        .wl_err                 ( w_wl_err              ), //output
        .read_data_valid        ( w_rdata_valid     ), //output

        .sclk_out               ( w_sclk                ), //output
        .clocking_good          ( w_clocking_good       ), //output

        // Memory side signals 
        .em_ddr_data            ( em_ddr_data           ), //inout   [15:0]
        .em_ddr_reset_n         ( em_ddr_reset_n        ), //output
        .em_ddr_dqs             ( em_ddr_dqs            ), //inout   [1:0] 
        .em_ddr_dm              ( em_ddr_dm             ), //output  [1:0]
        .em_ddr_clk             ( em_ddr_clk            ), //output  [0:0]
        .em_ddr_cke             ( em_ddr_cke            ), //output  [0:0] 
        .em_ddr_ras_n           ( em_ddr_ras_n          ), //output
        .em_ddr_cas_n           ( em_ddr_cas_n          ), //output
        .em_ddr_we_n            ( em_ddr_we_n           ), //output
        .em_ddr_cs_n            ( em_ddr_cs_n           ), //output  [0:0] 
        .em_ddr_odt             ( em_ddr_odt            ), //output  [0:0]
        .em_ddr_addr            ( em_ddr_addr           ), //output  [12:0] 
        .em_ddr_ba              ( em_ddr_ba             )  //output  [2:0] 
    );

    ddr3_init_ctrl u1_ddr3_init_ctrl(
        .i_clk                  ( w_sclk                ),
        .i_rst_n                ( i_rst_n               ),

        .i_ddr_init_done        ( w_init_done           ),
        .o_mem_rst_n            ( w_mem_rst_n           ),
        .o_init_start           ( w_init_start          )
    );

    ddr3_rw_ctrl #(
        .CMD_WIDTH              ( CMD_WIDTH             ),
        .DDR_DW                 ( DDR_DW                ),
        .DDR_AW                 ( DDR_AW                ),
        .DDR_BLW                ( DDR_BLW               ),
        .DM_WIDTH               ( DM_WIDTH              ),
        .UFIFO_DW               ( UFIFO_DW              )
    )
    u2_ddr3_rw_ctrl
    (
        .i_clk                  ( w_sclk                ),
        .i_rst_n                ( i_rst_n               ),

        .i_wddr_en              ( r_wddr_en             ),
        .i_rddr_en              ( r_rddr_en             ),
        .i_wddr_addr_base       ( r_wddr_addr_base      ),
        .i_rddr_addr_base       ( r_rddr_addr_base      ),

        .i_init_done            ( w_init_done           ),
        .i_cmd_rdy              ( w_cmd_rdy             ),
        .i_datain_rdy           ( w_datain_rdy          ),
        .i_rt_err               ( w_rt_err              ),
        .i_wl_err               ( w_wl_err              ),
        .i_rdata_valid          ( w_rdata_valid         ),
        .i_rdata                ( w_read_data           ),

        .i_wrfifo_en            ( r_wrfifo_en           ),
        .i_wrfifo_data          ( r_wrfifo_data         ),
        .i_rdfifo_en            ( r_rdfifo_en           ),
        .o_fifo_rddata          ( w_fifo_rddata         ),
        .o_urfifo_empty         ( w_urfifo_empty        ),

        .o_cmd                  ( w_cmd                 ),
        .o_addr                 ( w_addr                ),
        .o_cmd_burst_cnt        ( w_cmd_burst_cnt       ),
        .o_cmd_valid            ( w_cmd_valid           ),
        .o_ofly_burst_len       ( w_ofly_burst_len      ),
        .o_ddr3_wdata           ( w_ddr3_wdata          ),
        .o_data_mask            ( w_data_mask           )
    );

endmodule
