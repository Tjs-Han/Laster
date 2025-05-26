// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: fifo_ip_tb
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

module gpx2_spi_master_tb
#(
    parameter CLK_DIV_NUM			= 4,
	parameter SPICOM_INRV_CLKCNT	= 5
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

    reg                         r_spi_miso;
    reg                         r_spicom_req;
    reg  [7:0]                  r_spi_wdata;

    wire                        w_spi_dclk;
    wire                        w_spi_mosi;
    wire                        w_spicom_ready;
    wire                        w_spi_rdvalid;
    wire [7:0]                  w_spi_rdbyte;
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
        case0(1'b1, 8'h25);
        #2000;
        // case0(1'b0);
        // case0(r_data, o_uart_send_done);
        //----- TestCase Start -----
        // repeat(255) begin
        //     case0(r_data);
        //     #1500;
        // end
        $finish;
    end
    // always@(posedge cfg_clk)begin
    //     if(!cfg_rst_n)begin
    //         r_wrfifo_en     <= 1'b0;
    //         r_wrfifo_data   <= {UFIFO_DW{1'b0}};
    //     end else if(w_init_done)begin
    //         if(r_wrfifo_data <= 16'd255)begin
    //             r_wrfifo_en     <= 1'b1;
    //             r_wrfifo_data   <= r_wrfifo_data + 1'b1;
    //         end else begin
    //             r_wrfifo_en     <= 1'b0;
    //             r_wrfifo_data   <= r_wrfifo_data;
    //         end
    //     end
    // end
    //----------------------------------------------------------------------------------------------
    // test Case
    //----------------------------------------------------------------------------------------------
    task automatic case0( 
        input           i_spicom_req,
        input  [7:0]    i_spi_wdata
    );
    begin
        $display("---- Case0 Normal Test Start ! ---- At: %dns", $time);
        
        fork          
        begin: DATA_GENR  
            r_spicom_req    = i_spicom_req;    
            r_spi_wdata     = i_spi_wdata;       
        end
        join

        $display("---- Case0 Over ! ---- At: %dns", $time);
    end
    endtask
    //----------------------------------------------------------------------------------------------
	// instantiate domain
	//----------------------------------------------------------------------------------------------
    gpx2_spi_master #(
        .CLK_DIV_NUM                ( CLK_DIV_NUM           ),
        .SPICOM_INRV_CLKCNT         ( SPICOM_INRV_CLKCNT    )
    )
    u_gpx2_spi_master
    (
		.i_clk 						( cfg_clk               ),
		.i_rst_n					( cfg_rst_n             ),

		.o_spi_dclk					( w_spi_dclk 			),
		.o_spi_mosi					( w_spi_mosi 			),
		.i_spi_miso					( r_spi_miso 			),

		.i_spicom_req				( r_spicom_req 			),
		.i_spi_wdata				( r_spi_wdata			),
		.o_spicom_ready				( w_spicom_ready		),
		.o_spi_rdvalid				( w_spi_rdvalid			),
		.o_spi_rdbyte				( w_spi_rdbyte 			)
	);
    // GSR GSR_INST(.GSR(1'b1));
    // PUR PUR_INST(.PUR(1'b1));
endmodule