// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: mpt2042_top
// Date Created 	: 2025/04/18 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module mpt2042_top
#(	
	parameter SPI_CPOL			    = 1'b1,
	parameter SPI_CPHA			    = 1'b1,
	parameter CLK_DIV_NUM			= 8'd4,
	parameter SPICOM_INRV_CLKCNT	= 8'd4
)
(
	input						i_lvds_divclk1,
	input						i_lvds_divclk2,
	input						i_clk_100m,
	input						i_rst_n,

	// tdc signal
	output [1:0]				o_tdc_enable,
	output [1:0]				o_tdc_resetn,
    output [1:0] 				o_tdc_spi_ssn,
    output [1:0] 				o_tdc_spi_clk,
	input  [1:0]				i_tdc_spi_miso,
    output [1:0]				o_tdc_spi_mosi,

	output						o_tdc_module_en1,
	output						o_tdc_module_en2,
	input  [3:0]				i_lvds_datain1,
	input  [3:0]				i_lvds_datain2,
	output [1:0]				o_decode_done,
	output						o_cdctdc_ready,

	input						i_tdc_strdy,
	input						i_laser_sync,
	input  [3:0]				i_tdc1_chnlmask,
	input  [3:0]				i_tdc2_chnlmask,
	input  [15:0]				i_code_angle1,
	input  [15:0]				i_code_angle2,
	input  [3:0]				i_laser_sernum,

	//tdc data
    output                      o_tdc_sig,
    output [15:0]               o_tdc_rdata,
    output [15:0]               o_tdc_fdata,
	output [15:0]				o_tdc_angle1,
	output [15:0]				o_tdc_angle2,
	output [3:0]				o_tdc_lasernum
);
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
	reg							r_tdc_sig;
	reg  [15:0]					r_tdc_rdata;
	reg  [15:0]					r_tdc_fdata;
	reg  [15:0]					r_tdc_angle1;
	reg  [15:0]					r_tdc_angle2;
	reg  [3:0]					r_tdc_lasernum;

    wire                        w_spicom_req1;
    wire [7:0]                  w_spi_wdata1;
    wire                        w_spicom_ready1;
    wire                        w_spicom_done1;
    wire [7:0]                  w_spi_rdbyte1;

    wire                        w_spicom_req2;
    wire [7:0]                  w_spi_wdata2;
    wire                        w_spicom_ready2;
    wire                        w_spicom_done2;
    wire [7:0]                  w_spi_rdbyte2;

	wire						w_cfgtdc_state;
	wire						w_cdctdc_ready1;
	wire						w_cdctdc_ready2;

    //decode signal
    wire                   		w_lvdsfifo_empty1;
    wire                  		w_lvdsfifo_ren1;
    wire [9:0]            		w_lvdsfifo_rdata1;

	wire                   		w_lvdsfifo_empty2;
    wire                  		w_lvdsfifo_ren2;
    wire [9:0]            		w_lvdsfifo_rdata2;

	wire           				w_data_valid1;
    wire [15:0]    				w_rise_data1;
    wire [15:0]    				w_fall_data1;
	wire           				w_data_valid2;
    wire [15:0]    				w_rise_data2;
    wire [15:0]    				w_fall_data2;
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
	always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
			r_tdc_sig	<= 1'b0;
            r_tdc_rdata	<= 16'd0;
			r_tdc_fdata	<= 16'd0;
		end else if(i_tdc1_chnlmask[3:2] == 2'b11) begin
			if(w_data_valid1) begin
				r_tdc_sig	<= 1'b1;
				r_tdc_rdata	<= w_rise_data1;
				r_tdc_fdata	<= w_fall_data1;
			end else begin
				r_tdc_sig	<= 1'b0;
			end
		end else if(i_tdc2_chnlmask[3:2] == 2'b11) begin
			if(w_data_valid2) begin
				r_tdc_sig	<= 1'b1;
				r_tdc_rdata	<= w_rise_data2;
				r_tdc_fdata	<= w_fall_data2;
			end else begin
				r_tdc_sig	<= 1'b0;
			end
		end
	end

	always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_tdc_angle1	<= 16'd0;
			r_tdc_angle2	<= 16'd0;
			r_tdc_lasernum	<= 4'd0;
		end else if(i_tdc_strdy) begin
			r_tdc_angle1	<= i_code_angle1;
			r_tdc_angle2	<= i_code_angle2;
			r_tdc_lasernum	<= i_laser_sernum + 1'b1;
		end else begin
			r_tdc_angle1	<= r_tdc_angle1;
			r_tdc_angle2	<= r_tdc_angle2;
			r_tdc_lasernum	<= r_tdc_lasernum;
		end
	end
	//--------------------------------------------------------------------------------------------------
	// instance domain
	//--------------------------------------------------------------------------------------------------

	mpt2042_cfg  u1_mpt2042_cfg
	(
		.i_clk                		( i_clk_100m               	),
		.i_rst_n              		( i_rst_n					),

		.o_module_en				( o_tdc_module_en1			),
        .o_tdc_enable               ( o_tdc_enable[0]			),
        .o_tdc_resetn               ( o_tdc_resetn[0]			),

		.o_spi_ssn					( o_tdc_spi_ssn[0]			),
		.o_spicom_req      			( w_spicom_req1				),
		.o_spi_wdata            	( w_spi_wdata1				),
		.i_spicom_ready           	( w_spicom_ready1			),
		.i_spicom_done      		( w_spicom_done1          	),
		.i_spi_rdbyte            	( w_spi_rdbyte1				),
		.o_cfgtdc_state				( w_cfgtdc_state1			),
        .o_gpio_temp                ( o_gpio_temp               )
	);
	
	mpt2042_spi_master #(
		.SPI_CPOL				    ( SPI_CPOL				    ),
		.SPI_CPHA				    ( SPI_CPHA				    ),
        .CLK_DIV_NUM                ( CLK_DIV_NUM           	),
        .SPICOM_INRV_CLKCNT         ( SPICOM_INRV_CLKCNT    	)
    )	
	u1_mpt2042_spi_master(	
		.i_clk 						( i_clk_100m                ),
		.i_rst_n					( i_rst_n					),

		.o_spi_dclk					( o_tdc_spi_clk[0] 			),
		.o_spi_mosi					( o_tdc_spi_mosi[0]			),
		.i_spi_miso					( i_tdc_spi_miso[0]			),

		.i_spicom_req				( w_spicom_req1				),
		.i_spi_wdata				( w_spi_wdata1				),
		.o_spicom_ready				( w_spicom_ready1			),
		.o_spicom_done				( w_spicom_done1			),
		.o_spi_rdbyte				( w_spi_rdbyte1				)
	);

	mpt2042_cfg  u2_mpt2042_cfg
	(
		.i_clk                		( i_clk_100m               	),
		.i_rst_n              		( i_rst_n					),

		.o_module_en				( o_tdc_module_en2			),
        .o_tdc_enable               ( o_tdc_enable[1]           ),
        .o_tdc_resetn               ( o_tdc_resetn[1]           ),

		.o_spi_ssn					( o_tdc_spi_ssn[1]			),
		.o_spicom_req      			( w_spicom_req2				),
		.o_spi_wdata            	( w_spi_wdata2              ),
		.i_spicom_ready           	( w_spicom_ready2           ),
		.i_spicom_done      		( w_spicom_done2          	),
		.i_spi_rdbyte            	( w_spi_rdbyte2				),
		.o_cfgtdc_state				( w_cfgtdc_state2			)
	);
	
	mpt2042_spi_master #(
		.SPI_CPOL				    ( SPI_CPOL				    ),
		.SPI_CPHA				    ( SPI_CPHA				    ),
        .CLK_DIV_NUM                ( CLK_DIV_NUM           	),
        .SPICOM_INRV_CLKCNT         ( SPICOM_INRV_CLKCNT    	)
    )	
	u2_mpt2042_spi_master(	
		.i_clk 						( i_clk_100m                ),
		.i_rst_n					( i_rst_n					),

		.o_spi_dclk					( o_tdc_spi_clk[1] 			),
		.o_spi_mosi					( o_tdc_spi_mosi[1]			),
		.i_spi_miso					( i_tdc_spi_miso[1]			),

		.i_spicom_req				( w_spicom_req2				),
		.i_spi_wdata				( w_spi_wdata2				),
		.o_spicom_ready				( w_spicom_ready2			),
		.o_spicom_done				( w_spicom_done2			),
		.o_spi_rdbyte				( w_spi_rdbyte2				)
	);

	lvds_ddrdata_top u1_lvds_dec
	(
		.i_lvds_divclk				( i_lvds_divclk1			),
		.i_clk_100m					( i_clk_100m				),
		.i_rst_n					( i_rst_n					),

		.i_lvds_datain				( i_lvds_datain1			),
		.o_decode_done				( o_decode_done[0]			),
		.o_cdctdc_ready				( w_cdctdc_ready1			),

		.o_lvdsfifo_empty			( w_lvdsfifo_empty1			),
		.i_lvdsfifo_ren				( w_lvdsfifo_ren1			),
		.o_lvdsfifo_rdata			( w_lvdsfifo_rdata1			)
	);

	mpt2042_dataprc u1_mpt2042_dataprc
	(
		.i_clk_100m					( i_clk_100m				),
		.i_rst_n      				( i_rst_n 					),

		.i_cdctdc_ready				( w_cdctdc_ready1			),
		.i_tdc_strdy				( i_tdc_strdy				),
		.i_laser_sync				( i_laser_sync				),
		.i_tdc_chnlmask				( i_tdc1_chnlmask			),
		.i_lvdsfifo_empty			( w_lvdsfifo_empty1			),
		.o_lvdsfifo_ren				( w_lvdsfifo_ren1			),
		.i_lvdsfifo_rdata			( w_lvdsfifo_rdata1			),

		.o_data_valid				( w_data_valid1				),
		.o_rise_data				( w_rise_data1				),
		.o_fall_data				( w_fall_data1				)
	);

	lvds_ddrdata_top u2_lvds_dec
	(
		.i_lvds_divclk				( i_lvds_divclk2			),
		.i_clk_100m					( i_clk_100m				),
		.i_rst_n					( i_rst_n					),

		.i_lvds_datain				( i_lvds_datain2			),
		.o_decode_done				( o_decode_done[1]			),
		.o_cdctdc_ready				( w_cdctdc_ready2			),

		.o_lvdsfifo_empty			( w_lvdsfifo_empty2			),
		.i_lvdsfifo_ren				( w_lvdsfifo_ren2			),
		.o_lvdsfifo_rdata			( w_lvdsfifo_rdata2			)
	);

	mpt2042_dataprc u2_mpt2042_dataprc
	(
		.i_clk_100m					( i_clk_100m				),
		.i_rst_n      				( i_rst_n 					),

		.i_cdctdc_ready				( w_cdctdc_ready2			),
		.i_tdc_strdy				( i_tdc_strdy				),
		.i_laser_sync				( i_laser_sync				),
		.i_tdc_chnlmask				( i_tdc2_chnlmask			),
		.i_lvdsfifo_empty			( w_lvdsfifo_empty2			),
		.o_lvdsfifo_ren				( w_lvdsfifo_ren2			),
		.i_lvdsfifo_rdata			( w_lvdsfifo_rdata2			),

		.o_data_valid				( w_data_valid2				),
		.o_rise_data				( w_rise_data2				),
		.o_fall_data				( w_fall_data2				)
	);

    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_cdctdc_ready	= w_cdctdc_ready1 & w_cdctdc_ready2;
	assign o_tdc_sig     	= r_tdc_sig;
    assign o_tdc_rdata      = r_tdc_rdata;
    assign o_tdc_fdata      = r_tdc_fdata;
	assign o_tdc_angle1     = r_tdc_angle1;
    assign o_tdc_angle2     = r_tdc_angle2;
	assign o_tdc_lasernum	= r_tdc_lasernum;
endmodule