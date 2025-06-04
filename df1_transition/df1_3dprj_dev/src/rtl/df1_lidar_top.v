//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: df1_lidar_top
// Date Created 	: 2024/8/19 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
//	FIRMWARE_VERSION
//	0_00_00_001
//	|  |  |  |--------revised version
//	|  |  |-----------sub version
//	|  |--------------main version
//	|-----------------stage version 		0:Product Development Stage   	1:Mass Production Stage
//--------------------------------------------------------------------------------------------------
// File description	:df1_lidar_top module
//				The df1 device consists of an upper and lower signal control panel
//				This Project is the top-level module, instantiate each function module
//--------------------------------------------------------------------------------------------------
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------

module df1_lidar_top
#(
	parameter SEC2NS_REFVAL			= 1000_000_000,
	parameter CLK_PERIOD_NS			= 10,
	parameter OPTO_FREQ     		= 32'd800_000,
    parameter MOTOR1_FREQ    		= 71,
	parameter MOTOR2_FREQ    		= 60,
    parameter TOOTH_NUM     		= 8'd100,
	parameter CMD_WIDTH     		= 4,
    parameter DDR_DW        		= 64,
    parameter DDR_AW        		= 27,
    parameter DDR_BLW       		= 5,
    parameter DM_WIDTH      		= 8,
	parameter USER_RDW      		= 16
)
(
	input						i_clk_50m,
	input						i_ddrclk_100m,
	input						i_rst_n,

	input						i_code_sigin1,
	input						i_code_sigin2,
	output [7:0]				o_laser_str,
	// ddr3 inputs & outputs for memory interface
	inout  [15:0]        		em_ddr_data,
	output                      em_ddr_reset_n,
	inout  [1:0]    			em_ddr_dqs,
	output [1:0]      			em_ddr_dm,
	output          			em_ddr_clk,
	output          			em_ddr_cke,
	output                      em_ddr_ras_n,
	output                      em_ddr_cas_n,
	output                      em_ddr_we_n,
	output       				em_ddr_cs_n,
	output       				em_ddr_odt,
	output [13:0]        		em_ddr_addr,
	output [2:0]      	 		em_ddr_ba,

	// mdio interface with phy
	output  	           		o_phy_mdc,
	inout   	           		io_phy_mdio,
	output  	           		o_phy_reset_n,

	// eth phy interface
	input						i_ethphy_refclk,
	input						i_ethphy_rxdv,
	input  [1:0]				i_ethphy_rxd,
	output						o_ethphy_txen,
	output [1:0]				o_ethphy_txd,

	// motor signal
	input   					i_motor_fg1,
	input   					i_motor_rd1,
    output  					o_motor_pwm1,
	input   					i_motor_fg2,
	input   					i_motor_rd2,
    output  					o_motor_pwm2,
	
	// tdc signal
	output [1:0]				o_tdc_enable,
	output [1:0]				o_tdc_resetn,
    output [1:0] 				o_tdc_spi_ssn,
    output [1:0] 				o_tdc_spi_clk,
	input  [1:0]				i_tdc_spi_miso,
    output [1:0]				o_tdc_spi_mosi,
	input  [1:0]				i_tdc_interrupt,
	input						i_tdc1_lvds_serclk,
	input						i_tdc1_lvds_serdata,
	input						i_tdc2_lvds_serclk,
	input						i_tdc2_lvds_serdata,
	output [1:0]				o_decode_done,

	// hv signal
	output [1:0]				o_tempadc_sel,
	output						o_adc_sclk,
	output						o_adc_cs1,
	output						o_adc_cs2,
	input						i_adc_sda,
	output						o_da_pwm,
	output						o_hv_en,
	// flash siganl
	output						o_flash_cs,
	output						o_flash_mosi,
	input						i_flash_miso
);	
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	
    parameter SYSTEM_RESET_CLKCNT = 32'd10_000_000;
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
	// pll
	wire						w_pll_50m;
	wire						w_pll_100m;
	wire						w_pll_150m;
	wire						w_pll_locked;
	reg							r_ddrrst_n;
	wire						w_rst_n;
	reg 						r1_150mrst_sync	= 1'b0;
	reg 						r2_150mrst_sync	= 1'b0;
	reg 						r3_150mrst_sync	= 1'b0;
	reg 						r4_150mrst_sync	= 1'b0;
	wire						w_150mrst_n;
	reg  [31:0]					r_rst_dlycnt	= 32'd0;
    reg                         r_rst_n         = 1'b0;
	reg							r_initload_done	= 1'b0;
	wire						w_parainit_done;
	wire						w_laser_switch;
	wire [7:0]					w_laser_setnum;
	wire [3:0]					w_laser_sernum;
	wire						w_laser_sync;
	wire [3:0]					w_tdc1_chnlmask;
	wire [3:0]					w_tdc2_chnlmask;
    wire                      	w_tdc_sig;
    wire [15:0]               	w_tdc_rdata;
    wire [15:0]               	w_tdc_fdata;
	wire [15:0]					w_tdc_angle1;
	wire [15:0]					w_tdc_angle2;
	wire [3:0]					w_tdc_lasernum;
	//flash
	wire						w_flash_poweron_initdone;
	// ddr
	wire                        w_mem_rst_n;
    wire                        w_init_start;   
    wire [CMD_WIDTH-1:0]        w_cmd;
    wire [DDR_AW-1:0]           w_addr;
    wire [DDR_BLW-1:0]          w_cmd_burst_cnt;
    wire                        w_cmd_valid;
    wire                        w_ofly_burst_len;
    wire [DDR_DW-1:0]           w_ddr3_wdata;
    wire [DM_WIDTH-1:0]         w_data_mask;
    wire                        w_ddr_rst;
    wire [1:0]                  w_dqsdel;
    wire                        w_dqsbuf_pause;
    wire                        w_update_done;
    wire                        w_cmd_rdy;
    wire                        w_datain_rdy;
    wire                        w_init_done;
    wire                        w_rt_err;
    wire                        w_wl_err;
    wire                        w_rdata_valid;
    wire [DDR_DW-1:0]           w_read_data;
    wire                        w_dll_update;
    wire                        w_sclk;
    wire                        w_clocking_good;
	// motor1
	wire						w_cal_mode;
	wire [15:0]					w_freq_motor1;
	wire [15:0]					w_motor_pwm_setval1;
	wire [15:0]					w_motor_state1;
	wire [15:0]					w_pwm_value1;
	wire [31:0]					w_actual_speed1;
	
	// motor2
	wire [15:0]					w_freq_motor2;
	wire [15:0]					w_motor_pwm_setval2;
	wire [15:0]					w_motor_state2;
	wire [15:0]					w_pwm_value2;
	wire [31:0]					w_actual_speed2;
	
	// encoder
	wire [15:0]					w_config_mode;
	wire [ 3:0]					w_reso_mode;
	wire [ 1:0]					w_freq_mode;
	wire [15:0]					w_angle_offset1;
	wire [15:0]					w_angle_offset2;
	wire [7:0]					w_compen_rdaddr1;
	wire [15:0]					w_compen_rddata1;
	wire [15:0]					w_code_rddata1;
	wire [7:0]					w_compen_rdaddr2;
	wire [15:0]					w_compen_rddata2;
	wire [15:0]					w_code_rddata2;
	wire 						w_motor_state;
	wire						w_code_wren1;
	wire [6:0]					w_code_wraddr1;
	wire [31:0]					w_code_wrdata1;
	wire						w_code_wren2;
	wire [6:0]					w_code_wraddr2;
	wire [31:0]					w_code_wrdata2;
	
	wire [15:0]					w_code_angle1;
	wire [15:0]					w_code_angle2;
	wire 						w_angle_sync;
	wire						w_tdc_strdy;
	wire [1:0]					w_code_status_monit1;
	wire [1:0]					w_code_status_monit2;
	wire 						w_motor_status_monit;

	// tdc
	wire						w_tdc_module_en1;
	wire						w_tdc_module_en2;
	wire						w_cdctdc_ready;
	wire						w_iddr_sclk1;
	wire						w_iddr_sclk2;
	wire						w_cfgtdc_state;
	wire						w_iddr_ready1;
	wire						w_iddr_ready2;
	wire						w_iddr_synrst1;
	wire						w_iddr_synrst2;
	wire						w_iddr_update1;
	wire						w_iddr_update2;
	wire						w_iddr_alignwd1;
	wire						w_iddr_alignwd2;
	wire [7:0]					w_iddr_dcntl1;
	wire [7:0]					w_iddr_dcntl2;
	wire [3:0]					w_lvds_data1;
	wire [3:0]					w_lvds_data2;

	// hv ctrl
	wire [15:0]					w_temp_apdhv_base;
	wire [15:0]					w_temp_temp_base;
	wire						w_hvcp_switch;
	wire						w_dicp_switch;
	wire [15:0]					w_dist_diff;
	wire [6:0]					w_hvcp_ram_rdaddr;
	wire [15:0]					w_hvcp_rddata;
	wire [6:0]					w_dicp_ram_rdaddr;
	wire [15:0]					w_dicp_rddata;
	wire [15:0]					w_apd_hv_value;
	wire [15:0]					w_temp_temp_switch;
	wire [15:0]					w_apd_temp_value;
	wire [7:0]					w_device_temp;
	wire [9:0]					w_dac_value;
	wire						w_measure_en;
	wire [1:0]					w_hv_status_monit;

	// eth communication
	wire [15:0]					w_start_index;
	wire [15:0]					w_stop_index;
	wire						w_loopdata_flag;
	wire 						w_loop_make;
	wire 						w_loop_pingpang;
	wire 						w_loop_wren;
	wire [7:0]					w_loop_wrdata;
	wire [9:0]					w_loop_wraddr;
	wire [15:0]					w_loop_points;
	wire						w_loop_cycle_done;

	wire						w_calibrate_flag;
	wire [15:0]					w_cali_pointnum;
	wire 						w_calib_make;
	wire 						w_calib_pingpang;
	wire 						w_calib_wren;
	wire [7:0]					w_calib_wrdata;
	wire [9:0]					w_calib_wraddr;
	wire						w_calib_cycle_done;
	wire [15:0]					w_code_angle;
	
	wire [15:0]					w_code_angle_dist;
	wire [15:0]					w_calib_points;
	wire [15:0]					w_calipackdot_ordnum;
	// user and ddr interface
    // udp
    wire                        w_udp2ddr_wren;
    wire                        w_udp2ddr_rden;
    wire [DDR_AW-1:0]           w_udp2ddr_addr;
    wire [DDR_DW-1:0]           w_udp2ddr_data;
    wire                        w_ddr2udp_valid;
    wire [DDR_DW-1:0]           w_ddr2udp_data;
    // para     
    wire                      	w_para2ddr_wren;
	wire						w_ddr2para_rden;
    wire [DDR_AW-1:0]         	w_para2ddr_addr;
    wire [DDR_DW-1:0]         	w_para2ddr_data;
	wire						w_ddr2para_fifo_rden;
	wire						w_ddr2para_fifo_empty;
	wire [DDR_DW-1:0]			w_ddr2para_fifo_data;
	wire [7:0]					w_ddr_store_array;
    // flash        
    wire                        w_flash2ddr_wren;
    wire                        w_ddr2flash_rden;
    wire [DDR_AW-1:0]           w_flash2ddr_addr;
    wire [DDR_DW-1:0]           w_flash2ddr_data;
	wire						w_ddr2flash_fifo_rden;
    wire                        w_ddr2flash_fifo_empty;
    wire [DDR_DW-1:0]			w_ddr2flash_fifo_data;
    // dist     
	wire [31:0]					w_rise_divid;
	wire [31:0]					w_pulse_start;
	wire [31:0]					w_pulse_divid;
	wire [31:0]					w_distance_min;
	wire [31:0]					w_distance_max;
	wire [15:0]					w_dist_compen;
    wire                        w_dist2ddr_wren;
    wire                        w_ddr2dist_rden;
    wire [DDR_AW-1:0]           w_dist2ddr_addr;
    wire [DDR_DW-1:0]           w_dist2ddr_data;
	wire						w_ddr2dist_fifo_rden;
    wire                        w_ddr2dist_fifo_empty;
    wire [DDR_DW-1:0]			w_ddr2dist_fifo_data;
	//----------------------------------------------------------------------------------------------
	// 	synchronous clock and rst signal for system
	//	asynchronous reset with synchronous release
	//----------------------------------------------------------------------------------------------	
			
	pll u_pll(
		.CLKI					( i_clk_50m					), 
		.CLKOP					( w_pll_50m					), 
		.CLKOS					( w_pll_100m				),	
		.CLKOS2					( w_pll_150m				),
        .LOCK           		( w_pll_locked				)
	);	

	//r_rst_dlycnt
	always @(posedge i_clk_50m) begin
        if (~i_rst_n) begin
            r_rst_dlycnt 	<= 32'd0;
            r_rst_n 		<= 1'b0;
        end else if(r_rst_dlycnt >= SYSTEM_RESET_CLKCNT) begin
            r_rst_n			<= 1'b1;
            r_rst_dlycnt	<= r_rst_dlycnt;
		end else begin
			r_rst_n 		<= 1'b0;
			r_rst_dlycnt 	<= r_rst_dlycnt + 1'b1; 
		end
    end

	//r_ddrrst_n
	always @(posedge i_clk_50m) begin
        if (~i_rst_n)
			r_ddrrst_n	<= 1'b0;
		else if(r_rst_dlycnt >= 32'd50_000)
			r_ddrrst_n	<= 1'b1;
		else
			r_ddrrst_n	<= 1'b0;
	end

	always @(posedge w_pll_150m or negedge r_rst_n) begin
	    if (!r_rst_n) begin
	        r1_150mrst_sync <= 1'b0;
	        r2_150mrst_sync <= 1'b0;
			r3_150mrst_sync <= 1'b0;
			r4_150mrst_sync <= 1'b0;
	    end else begin
	        r1_150mrst_sync <= 1'b1;
	        r2_150mrst_sync	<= r1_150mrst_sync;
			r3_150mrst_sync	<= r2_150mrst_sync;
			r4_150mrst_sync	<= r3_150mrst_sync;
	    end
	end

	assign w_150mrst_n	= r2_150mrst_sync;
	assign w_rst_n		= w_pll_locked & r_rst_n;

	//r_initload_done
	always @(posedge w_pll_100m) begin
        if (~w_rst_n)
			r_initload_done	<= 1'b0;
		else
			r_initload_done	<= w_parainit_done;
	end
	//----------------------------------------------------------------------------------------------
	// instantiate each function module
	//----------------------------------------------------------------------------------------------
    //ddr3_ip 
    df1_ddr3_ip u_ddr3 (
        .ddr3_ipcore_clk_in             ( i_ddrclk_100m         	), //input
        .ddr3_ipcore_rst_n              ( r_ddrrst_n               	), //input
        .ddr3_ipcore_mem_rst_n          ( w_mem_rst_n           	), //input

        // Input signals from the User I/F 
        .ddr3_ipcore_init_start         ( w_init_start          	), //input
        .ddr3_ipcore_cmd                ( w_cmd                 	), //input [3:0] 
        .ddr3_ipcore_addr               ( w_addr                	), //input [26:0]
        .ddr3_ipcore_cmd_burst_cnt      ( w_cmd_burst_cnt       	), //input [4:0] 
        .ddr3_ipcore_cmd_valid          ( w_cmd_valid           	), //input
        .ddr3_ipcore_ofly_burst_len     ( w_ofly_burst_len      	), //input

        .ddr3_ipcore_write_data         ( w_ddr3_wdata          	), //input [63:0] 
        .ddr3_ipcore_data_mask          ( w_data_mask           	), //input [7:0]
        // .ddr_rst                ( w_ddr_rst             ),
        // .dqsdel                 ( w_dqsdel              ),
        // .dqsbuf_pause           ( w_dqsbuf_pause        ),
        // .update_done            ( w_update_done         ),
        // Output signals to the User I/F
        .ddr3_ipcore_cmd_rdy            ( w_cmd_rdy             	), //output
        .ddr3_ipcore_datain_rdy         ( w_datain_rdy          	), //output
        .ddr3_ipcore_init_done          ( w_init_done           	), //output
        .ddr3_ipcore_rt_err             ( w_rt_err              	), //output
        .ddr3_ipcore_wl_err             ( w_wl_err              	), //output
        .ddr3_ipcore_read_data_valid    ( w_rdata_valid         	), //output
        .ddr3_ipcore_read_data          ( w_read_data           	), //output [63:0]
        // .dll_update             ( w_dll_update          ),	

        .ddr3_ipcore_sclk_out           ( w_sclk                	), //output
        .ddr3_ipcore_clocking_good      ( w_clocking_good       	), //output

        // Memory side signals 
        .ddr3_ipcore_em_ddr_data        ( em_ddr_data           	), //inout   [15:0]
        .ddr3_ipcore_em_ddr_reset_n     ( em_ddr_reset_n        	), //output
        .ddr3_ipcore_em_ddr_dqs         ( em_ddr_dqs            	), //inout   [1:0] 
        .ddr3_ipcore_em_ddr_dm          ( em_ddr_dm             	), //output  [1:0]
        .ddr3_ipcore_em_ddr_clk         ( em_ddr_clk            	), //output  [0:0]
        .ddr3_ipcore_em_ddr_cke         ( em_ddr_cke            	), //output  [0:0] 
        .ddr3_ipcore_em_ddr_ras_n       ( em_ddr_ras_n          	), //output
        .ddr3_ipcore_em_ddr_cas_n       ( em_ddr_cas_n          	), //output
        .ddr3_ipcore_em_ddr_we_n        ( em_ddr_we_n           	), //output
        .ddr3_ipcore_em_ddr_cs_n        ( em_ddr_cs_n           	), //output  [0:0] 
        .ddr3_ipcore_em_ddr_odt         ( em_ddr_odt            	), //output  [0:0]
        .ddr3_ipcore_em_ddr_addr        ( em_ddr_addr           	), //output  [12:0] 
        .ddr3_ipcore_em_ddr_ba          ( em_ddr_ba             	)  //output  [2:0] 
    );

    ddr3_init_ctrl u1_ddr3_init_ctrl(
        .i_clk                  		( w_sclk                	),
        .i_rst_n                		( r_ddrrst_n               	),

        .i_ddr_init_done        		( w_init_done           	),
        .o_mem_rst_n            		( w_mem_rst_n           	),
        .o_init_start           		( w_init_start          	)
    );

    ddr3_interface #(
        .CMD_WIDTH             			( CMD_WIDTH             	),
        .DDR_DW                			( DDR_DW                	),
        .DDR_AW                			( DDR_AW                	),
        .DDR_BLW               			( DDR_BLW               	),
        .DM_WIDTH              			( DM_WIDTH              	)
    )
    u2_ddr3_interface
    (
        .i_clk                  		( w_pll_100m				),
		.i_ddr_sclk						( w_sclk					),
        .i_rst_n                		( r_ddrrst_n               	),

        .i_init_done            		( w_init_done           	),
        .i_cmd_rdy              		( w_cmd_rdy             	),
        .i_datain_rdy           		( w_datain_rdy          	),
        .i_rt_err               		( w_rt_err              	),
        .i_wl_err               		( w_wl_err              	),
        .i_rdata_valid          		( w_rdata_valid         	),
        .i_ddr_rdata					( w_read_data           	),
        .o_cmd                  		( w_cmd                 	),
        .o_addr                 		( w_addr                	),
        .o_cmd_burst_cnt        		( w_cmd_burst_cnt       	),
        .o_cmd_valid            		( w_cmd_valid           	),
        .o_ofly_burst_len       		( w_ofly_burst_len      	),
        .o_ddr3_wdata           		( w_ddr3_wdata          	),
        .o_data_mask            		( w_data_mask           	),

		// udp
        .i_udp2ddr_wren                 ( w_udp2ddr_wren            ),
        .i_udp2ddr_rden                 ( w_udp2ddr_rden            ),
        .i_udp2ddr_addr                 ( w_udp2ddr_addr            ),
        .i_udp2ddr_data                 ( w_udp2ddr_data            ),
        .o_ddr2udp_valid                ( w_ddr2udp_valid           ),
        .o_ddr2udp_data                 ( w_ddr2udp_data            ),
        // para
        .i_para2ddr_wren                ( w_para2ddr_wren           ),
		.i_ddr2para_rden               	( w_ddr2para_rden			),
        .i_para2ddr_addr                ( w_para2ddr_addr           ),
        .i_para2ddr_data                ( w_para2ddr_data           ),
		.i_ddr2para_fifo_rden			( w_ddr2para_fifo_rden		),
        .o_ddr2para_fifo_empty			( w_ddr2para_fifo_empty		),
        .o_ddr2para_fifo_data			( w_ddr2para_fifo_data		),
        // flash
        .i_flash2ddr_wren               ( w_flash2ddr_wren          ),
        .i_ddr2flash_rden               ( w_ddr2flash_rden          ),
        .i_flash2ddr_addr               ( w_flash2ddr_addr          ),
        .i_flash2ddr_data               ( w_flash2ddr_data          ),
		.i_ddr2flash_fifo_rden			( w_ddr2flash_fifo_rden		),
        .o_ddr2flash_fifo_empty			( w_ddr2flash_fifo_empty	),
        .o_ddr2flash_fifo_data			( w_ddr2flash_fifo_data		),
        // dist
        .i_dist2ddr_rden                ( w_ddr2dist_rden           ),
        .i_dist2ddr_addr                ( w_dist2ddr_addr           ),
        .i_ddr2dist_fifo_rden			( w_ddr2dist_fifo_rden		),
        .o_ddr2dist_fifo_empty			( w_ddr2dist_fifo_empty		),
        .o_ddr2dist_fifo_data			( w_ddr2dist_fifo_data		)
    );

	phy_mdio_ctrl u_phy_mdio_ctrl (
	    .i_clk_100m    					( w_pll_100m				),
	    .i_rst_n  						( w_rst_n					),

	    //input 				
	    .o_phy_mdc    					( o_phy_mdc					),
	    .io_phy_mdio					( io_phy_mdio				),
	    .o_phy_reset_n    				( o_phy_reset_n				)
	);

	eth_top u_eth_top (
	    .i_clk							( w_pll_100m				),
	    .i_rst_n  						( w_rst_n					),
		.o_parainit_done				( w_parainit_done			),


	    .i_ethphy_refclk				( i_ethphy_refclk			),
	    .i_ethphy_rxdv      			( i_ethphy_rxdv         	),
	    .i_ethphy_rxd       			( i_ethphy_rxd          	),
		.o_ethphy_txen					( o_ethphy_txen				),
		.o_ethphy_txd					( o_ethphy_txd				),
		//ddr interface
		.o_para2ddr_wren				( w_para2ddr_wren			),
    	.o_ddr2para_rden				( w_ddr2para_rden			),
    	.o_para2ddr_addr				( w_para2ddr_addr			),
    	.o_para2ddr_data				( w_para2ddr_data			),
		.o_ddr2para_fifo_rden			( w_ddr2para_fifo_rden		),
    	.i_ddr2para_fifo_empty			( w_ddr2para_fifo_empty		),
    	.i_ddr2para_fifo_data			( w_ddr2para_fifo_data		),
		.o_ddr_store_array				( w_ddr_store_array			),
		//input para vaule
		.i_flash_poweron_initdone		( w_flash_poweron_initdone	),
		.i_apd_hv_value					( w_apd_hv_value			),
		.i_apd_temp_value				( w_apd_temp_value			),
		.i_dac_value					( w_dac_value				),
		.i_device_temp					( w_device_temp				),
		//output	
		.o_laser_switch					( w_laser_switch			),	
		.o_laser_setnum					( w_laser_setnum			),
        .o_config_mode          		( w_config_mode             ),
		.o_motor_pwm_setval1			( w_motor_pwm_setval1		),
		.o_motor_pwm_setval2			( w_motor_pwm_setval2		),
        .o_freq_motor1          		( w_freq_motor1             ),
        .o_freq_motor2          		( w_freq_motor2             ),
		.o_angle_offset1				( w_angle_offset1			),
		.o_angle_offset2				( w_angle_offset2			),
		.o_temp_apdhv_base				( w_temp_apdhv_base 		),
		.o_temp_temp_base				( w_temp_temp_base 			),
		.o_hvcp_switch					( w_hvcp_switch				),
		.o_dicp_switch					( w_dicp_switch				),
		.o_start_index          		( w_start_index             ),
        .o_stop_index           		( w_stop_index              ),
		.o_pulse_start 					( w_pulse_start 			),
		.o_pulse_divid 					( w_pulse_divid 			),
		.o_distance_min					( w_distance_min 			),
		.o_distance_max					( w_distance_max 			),
		//code ram			
		.i_code_wren1					( w_code_wren1 				),
		.i_code_wraddr1					( w_code_wraddr1 			),
		.i_code_wrdata1					( w_code_wrdata1 			),
		.i_code_wren2					( w_code_wren2 				),
		.i_code_wraddr2					( w_code_wraddr2 			),
		.i_code_wrdata2					( w_code_wrdata2 			),
		//loop
		.o_loopdata_flag				( w_loopdata_flag			),
		.i_loop_make					( w_loop_make 				),
        .i_loop_pingpang       			( w_loop_pingpang          	),
        .i_loop_wren					( w_loop_wren 				),	
		.i_loop_wrdata					( w_loop_wrdata 			),
		.i_loop_wraddr					( w_loop_wraddr 			),
		.i_loop_points					( w_loop_points				),
		.i_loop_cycle_done				( w_loop_cycle_done			),
		//calib
		.o_calibrate_flag				( w_calibrate_flag			),
		.o_cali_pointnum				( w_cali_pointnum			),
		.i_calib_make					( w_calib_make 				),
        .i_calib_pingpang       		( w_calib_pingpang          ),
        .i_calib_wren					( w_calib_wren 				),	
		.i_calib_wrdata					( w_calib_wrdata 			),
		.i_calib_wraddr					( w_calib_wraddr 			),
		.i_calib_points					( w_calib_points			),
		.i_calib_cycle_done				( w_calib_cycle_done		),
		.i_code_angle					( w_code_angle				)	
	);

	flash_control #(
        .DDR_DW                			( DDR_DW                	),
        .DDR_AW                			( DDR_AW                	),
        .USER_RDW               		( USER_RDW               	)
    )
	u_flash_control
	(
		.i_clk							( w_pll_100m				),
		.i_rst_n      					( w_rst_n					),

		.o_flash_cs						( o_flash_cs				),
		.o_flash_mosi					( o_flash_mosi				),
		.i_flash_miso					( i_flash_miso				),

		.o_flash2ddr_wren               ( w_flash2ddr_wren          ),
        .o_ddr2flash_rden               ( w_ddr2flash_rden          ),
        .o_flash2ddr_addr               ( w_flash2ddr_addr          ),
        .o_flash2ddr_data               ( w_flash2ddr_data          ),
		.o_ddr2flash_fifo_rden			( w_ddr2flash_fifo_rden		),
        .i_ddr2flash_fifo_empty			( w_ddr2flash_fifo_empty	),
        .i_ddr2flash_fifo_data			( w_ddr2flash_fifo_data		),

		.i_factory_sig					( w_ddr_store_array[4]		),
		.i_parameter_read				( w_ddr_store_array[3]		),
		.i_parameter_sig				( w_ddr_store_array[2]		),
		.i_cal_coe_sig					( w_ddr_store_array[1]		),
		.i_code_data_sig				( w_ddr_store_array[0]		),

		.i_code_packet_num				( w_ddr_store_array[7:5]	),

		.o_flash_poweron_initload		( w_flash_poweron_initdone	)
	);

	motor_control u_motor_control(
		.i_clk_50m						( w_pll_50m					),
		.i_rst_n						( w_rst_n					),
		.i_motor_sw						( w_config_mode[1:0]		),

		//motor1		
		.i_motor_fg1					( i_motor_fg1				),
		.i_motor_rd1					( i_motor_rd1				),
		.i_freq_motor1					( w_freq_motor1				),
		.i_motor_pwm_setval1			( w_motor_pwm_setval1		),
		.o_motor_state1					( w_motor_state1			),
		.o_pwm_value1					( w_pwm_value1				),
		.o_actual_speed1				( w_actual_speed1			),
		.o_motor_pwm1					( o_motor_pwm1				),

		//motor2		
		.i_motor_fg2					( i_motor_fg2				),
		.i_motor_rd2					( i_motor_rd2				),
		.i_freq_motor2					( w_freq_motor2				),
		.i_motor_pwm_setval2			( w_motor_pwm_setval2		),
		.o_motor_state2					( w_motor_state2			),
		.o_pwm_value2					( w_pwm_value2				),
		.o_actual_speed2				( w_actual_speed2			),
		.o_motor_pwm2					( o_motor_pwm2				),

		.o_gpx2_measure_en				( w_gpx2_measure_en			)
	);

	rotate_control #(            
        .SEC2NS_REFVAL      			( SEC2NS_REFVAL             ),       
        .CLK_PERIOD_NS      			( CLK_PERIOD_NS             ),       
        .TOOTH_NUM						( TOOTH_NUM					),
        .OPTO_FREQ          			( OPTO_FREQ                 ),
        .MOTOR1_FREQ         			( MOTOR1_FREQ				),
		.MOTOR2_FREQ         			( MOTOR2_FREQ				)
    )
	u_rotate_control
	(
		.i_clk							( w_pll_100m				),
		.i_rst_n						( w_rst_n					),

		.i_code_sigin1					( i_code_sigin1				),
		.i_code_sigin2					( ~i_code_sigin2			),
		.i_calib_mode 					( ~w_config_mode[1:0]		),
		.i_motor_state1					( w_motor_state1[0]			),
		.i_motor_state2					( w_motor_state2[0]			),
		.i_reso_mode					( w_reso_mode				),
		.i_angle_offset1				( w_angle_offset1			),
		.i_angle_offset2				( w_angle_offset2			),

		.o_code_wren1					( w_code_wren1				),
		.o_code_wraddr1					( w_code_wraddr1			),
		.o_code_wrdata1					( w_code_wrdata1			),
		.o_code_wren2					( w_code_wren2				),
		.o_code_wraddr2					( w_code_wraddr2			),
		.o_code_wrdata2					( w_code_wrdata2			),

		.o_code_angle1					( w_code_angle1				),
		.o_code_angle2					( w_code_angle2				),
		.o_angle_sync 					( w_angle_sync				),
		.o_tdc_strdy					( w_tdc_strdy				),

		.o_codesig_monit1				( w_code_status_monit1		),	
		.o_codesig_monit2				( w_code_status_monit2		) 
	);

	laser_control u_laser_control
	(
		.i_clk_100m    					( w_pll_100m				),
		.i_rst_n      					( w_rst_n 					),
		.i_angle_sync 					( w_angle_sync				),//synchronizing signal
		.i_cdctdc_ready					( w_cdctdc_ready			),
		.i_laser_switch					( w_laser_switch			),
		.i_laser_setnum					( w_laser_setnum			),

		.o_laser_str  					( o_laser_str				),//signal of laser lighting
		.o_laser_sync					( w_laser_sync				),
		.o_tdc1_chnlmask				( w_tdc1_chnlmask			),
		.o_tdc2_chnlmask				( w_tdc2_chnlmask			),
		.o_laser_sernum					( w_laser_sernum			)
	);
	iddr_init u1_iddr_init
	(
		.i_clk							( w_pll_150m				),
		.i_rst_n						( w_150mrst_n				),

		.i_module_en					( w_tdc_module_en1			),
		.i_iddr_ready					( w_iddr_ready1				),
		.o_iddr_synrst					( w_iddr_synrst1			),
		.o_iddr_update					( w_iddr_update1			),
		.o_iddr_alignwd					( w_iddr_alignwd1			)
	);	

	iddr_init u2_iddr_init
	(
		.i_clk							( w_pll_150m				),
		.i_rst_n						( w_150mrst_n				),

		.i_module_en					( w_tdc_module_en2			),
		.i_iddr_ready					( w_iddr_ready2				),
		.o_iddr_synrst					( w_iddr_synrst2			),
		.o_iddr_update					( w_iddr_update2			),
		.o_iddr_alignwd					( w_iddr_alignwd2			)
	);
	
	iddrx2f u1_iddr_tdc1	
	(	
		.alignwd						( w_iddr_alignwd1			),//input
		.clkin							( i_tdc1_lvds_serclk		),//input
		.ready							( w_iddr_ready1				),//output
		.sclk							( w_iddr_sclk1				),//output
		.update							( w_iddr_update1			),//input
		// .sync_clk						( w_sync_clk				),//input
		.sync_clk						( w_pll_150m				),//input
		// .sync_reset						( w_iddr_synrst1			),//input
		.sync_reset						( 1'b0						),//input
		.datain							( i_tdc1_lvds_serdata		),//input
		.dcntl							( w_iddr_dcntl1				),//output
		.q								( w_lvds_data1				) //output
	);

	iddrx2f u2_iddr_tdc2	
	(	
		.alignwd						( w_iddr_alignwd2			),//input
		.clkin							( i_tdc2_lvds_serclk		),//input
		.ready							( w_iddr_ready2				),//output
		.sclk							( w_iddr_sclk2				),//output
		.update							( w_iddr_update2			),//input
		// .sync_clk						( w_sync_clk				),//input
		.sync_clk						( w_pll_150m				),//input
		// .sync_reset						( w_iddr_synrst2			),//input
		.sync_reset						( 1'b0						),//input
		.datain							( i_tdc2_lvds_serdata		),//input
		.dcntl							( w_iddr_dcntl2				),//output
		.q								( w_lvds_data2				) //output
	);

	mpt2042_top u_mpt2042_top
	(
		.i_lvds_divclk1					( w_iddr_sclk1				),
		.i_lvds_divclk2					( w_iddr_sclk2				),
		.i_clk_100m						( w_pll_100m				),
		.i_rst_n						( w_150mrst_n				),

		.o_tdc_enable					( o_tdc_enable				),
		.o_tdc_resetn					( o_tdc_resetn				),
		.o_tdc_spi_ssn					( o_tdc_spi_ssn				),
		.o_tdc_spi_clk					( o_tdc_spi_clk				),
		.i_tdc_spi_miso					( i_tdc_spi_miso			),
		.o_tdc_spi_mosi					( o_tdc_spi_mosi			),

		.o_tdc_module_en1				( w_tdc_module_en1			),
		.o_tdc_module_en2				( w_tdc_module_en2			),
		.i_lvds_datain1					( w_lvds_data1				),
		.i_lvds_datain2					( w_lvds_data2				),
		.o_decode_done					( o_decode_done				),
		.o_cdctdc_ready					( w_cdctdc_ready			),

		.i_tdc1_chnlmask				( w_tdc1_chnlmask			),
		.i_tdc2_chnlmask				( w_tdc2_chnlmask			),
		.i_tdc_strdy					( w_tdc_strdy				),
		.i_laser_sync					( w_laser_sync				),
		.i_code_angle1					( w_code_angle1				),
		.i_code_angle2					( w_code_angle2				),
		.i_laser_sernum					( w_laser_sernum			),

		.o_tdc_sig						( w_tdc_sig					),
		.o_tdc_rdata					( w_tdc_rdata				),
		.o_tdc_fdata					( w_tdc_fdata				),
		.o_tdc_angle1					( w_tdc_angle1				),
		.o_tdc_angle2					( w_tdc_angle2				),
		.o_tdc_lasernum					( w_tdc_lasernum			)
	);


	dist_measure #(
        .DDR_DW                			( DDR_DW                	),
        .DDR_AW                			( DDR_AW                	)
    ) 
	u_dist
	(
		.i_clk    						( w_pll_100m				),
		// .i_rst_n      					( w_rst_n & w_parainit_done	),
		.i_rst_n      					( r_initload_done			),
		// .i_discal_en					( w_parainit_done			),

		.i_tdcsig_sync 					( w_tdc_sig					),
		.i_tdcdata_rise					( w_tdc_rdata				),
		.i_tdcdata_fall					( w_tdc_fdata				),
		.i_code_angle1					( w_tdc_angle1				),
		.i_code_angle2					( w_tdc_angle2				),
		.i_tdc_lasernum					( w_tdc_lasernum			),
		.i_motor_state					( w_motor_state				),
		.i_measure_en					( 1'b1						),
		.i_rssi_switch					( w_config_mode[2]			),
		.i_reso_mode					( w_config_mode[11:8]		),
		.i_start_index					( w_start_index				),
		.i_stop_index					( w_stop_index				),

		.i_rise_divid					( w_rise_divid				),
		.i_pulse_start					( w_pulse_start				),
		.i_pulse_divid					( w_pulse_divid				),
		.i_distance_min					( w_distance_min			),
		.i_distance_max					( w_distance_max			),
		.i_dist_compen					( w_dist_compen				),

		// ddr interface
        .o_ddr2dist_rden               	( w_ddr2dist_rden          	),
        .o_dist2ddr_addr               	( w_dist2ddr_addr          	),
		.o_ddr2dist_fifo_rden			( w_ddr2dist_fifo_rden		),
        .i_ddr2dist_fifo_empty			( w_ddr2dist_fifo_empty		),
        .i_ddr2dist_fifo_data			( w_ddr2dist_fifo_data		),

		.i_loopdata_flag				( w_loopdata_flag			),
		.o_loop_make					( w_loop_make				),
		.o_loop_pingpang				( w_loop_pingpang			),
		.o_loop_wren					( w_loop_wren				),	
		.o_loop_wrdata					( w_loop_wrdata				),
		.o_loop_wraddr					( w_loop_wraddr				),
		.o_loop_points					( w_loop_points				),
		.o_loop_cycle_done				( w_loop_cycle_done			),

		.i_calibrate_flag				( w_calibrate_flag			),
		.i_cali_pointnum				( w_cali_pointnum			),
		.o_calib_make					( w_calib_make				),
		.o_calib_pingpang				( w_calib_pingpang			),
		.o_calib_wren					( w_calib_wren				),	
		.o_calib_wrdata					( w_calib_wrdata			),
		.o_calib_wraddr					( w_calib_wraddr			),
		.o_calib_points					( w_calib_points			),
		.o_calib_cycle_done				( w_calib_cycle_done		),
		.o_code_angle					( w_code_angle_dist			)		
	);

	HV_control  u_HV_control
	(
		.i_clk_50m    					( w_pll_50m					),
		.i_rst_n      					( w_rst_n 					),

		.i_measure_mode					( 1'b1						),
		.i_motor_state					( 1'b1						),

		.i_temp_apdhv_base				( w_temp_apdhv_base			),
		.i_temp_temp_base				( w_temp_temp_base			),
		.i_dist_diff					( w_dist_diff				),
		.i_hvcp_switch					( w_hvcp_switch				),
		.o_hvcp_ram_rdaddr				( w_hvcp_ram_rdaddr			),
		.i_hvcp_rddata					( w_hvcp_rddata				),	
		.i_dicp_switch					( w_dicp_switch				),
		.o_dicp_ram_rdaddr				( w_dicp_ram_rdaddr			),
		.i_dicp_rddata					( w_dicp_rddata				),

		.o_apd_hv_value					( w_apd_hv_value			),
		.o_apd_temp_value				( w_apd_temp_value			),
		.o_device_temp					( w_device_temp				),
		.o_dac_value					( w_dac_value				),
		.o_dist_compen					( w_dist_compen 			),

		.o_measure_en					( w_measure_en				),
		.o_hv_en						( o_hv_en					),
		.o_adc_sclk						( o_adc_sclk				),
		.o_adc_cs1						( o_adc_cs1					),
		.o_adc_cs2						( o_adc_cs2					),
		.i_adc_sda						( i_adc_sda					),

		.i_init_load_done				( r_initload_done			),
		.o_da_pwm						( o_da_pwm					),

		.o_hv_status_monit				( w_hv_status_monit			)

    );
endmodule 