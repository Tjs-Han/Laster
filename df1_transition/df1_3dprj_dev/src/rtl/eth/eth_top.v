// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: eth_top
// Date Created     : 2024/10/08
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:eth_top
// Ethernet MAC frame format
/* _____________________________________________________________________________________________________________
  |             |                         Management Frame Fields                                               |
  |             |———————————————————————————————————————————————————————————————————————————————————————————————|
  |             | Preamble |   SFD  | Destination MAC |   Source MAC   | Length/Type |      DATA     |    FCS   |
  |—————————————|——————————|————————|—————————————————|————————————————|—————————————|———————————————|——————————|
  |  BYTE NUM   |  7 Byte  | 1 Byte |       6 Byte    |     6 Byte     |    2 Byte   | 46~1500 Byte  |  4 Byte  |
  |—————————————————————————————————————————————————————————————————————————————————————————————————————————————|
  |             | Preamble + SFD    |           Ethernet frame header                | Ethernet DATA |   Check  |
   —————————————————————————————————————————————————————————————————————————————————————————————————————————————
        Preamble                    : The physical layer uses seven byte synchronization codes (alternating 0 and 1 (55-55-55-55-55-55-55-55)) 
                                      to synchronize data.
        Start Frame Delimiter(SFD)  : A one-byte SFD (fixed at 0xd5) is used to represent the beginning of a frame, which is followed by the Ethernet frame header
        Destination MAC address     : Physical MAC address of the receiver, which takes 6 bytes. MAC addresses can be divided into unicast addresses, multicast addresses, 
                                      and broadcast addresses.
                                      unicast addresses     : The lowest position of the first byte is 0. for example 00-00-00-11-11
                                      multicast addresses   : The lowest position of the first byte is 1. for example 01-00-00-11-11
                                      broadcast addresses   : All 48 bits are 1, that is, FF-FF-FF-FF-FF, which is used to mark all devices in the same network segment
        Source MAC address          : Physical MAC address of the sender, which takes 6 bytes
        Length/Type                 : Length/type has two meanings, When the value of the two bytes is less than 1536 (0x0600 in hexadecimal), 
                                      it indicates the length of the data segment in the Ethernet. If the value of the two bytes is greater than 1536, 
                                      it indicates the upper-layer protocol to which the data in the Ethernet belongs. 
                                      For example, 0x0800 indicates the IP protocol (Internet protocol) and 0x0806 indicates the ARP protocol (address resolution protocol).
        DATA                        : The length of a data segment on the Ethernet ranges from 46 bytes to 1500 bytes. 
                                      The Maximum 1500 is called the MTU (Maximum Transmission Unit) of Ethernet.
        Frame Check Sequence(FCS)   : In order to ensure the correct transmission of data, a 4-byte cyclic redundancy check code (CRC check) is added to the end of the data 
                                      to detect whether the data is transmitted incorrectly. 
                                      CRC data verification starts with the Ethernet frame header, which does not contain the Preamble and SFD
*/                                    
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module eth_top
#(  
    parameter FIRMWARE_VERSION		= 32'h25052120,
    parameter DDR_DW                = 64,
    parameter DDR_AW                = 27,
	parameter USER_RDW              = 16
)
(
    input                               i_clk,    //100Mhz
    input                               i_rst_n,
    output								o_parainit_done,

	input						        i_ethphy_refclk,
	input						        i_ethphy_rxdv,
	input						        i_ethphy_rxer,
	input  [1:0]				        i_ethphy_rxd,		//RMII rx data
	input						        i_ethphy_crsdv,
	output						        o_ethphy_txen,
	output [1:0]				        o_ethphy_txd,
	//ddr interface
	output                              o_para2ddr_wren,
    output                              o_ddr2para_rden,
    output [DDR_AW-1:0]                 o_para2ddr_addr,
    output [DDR_DW-1:0]                 o_para2ddr_data,
	output								o_ddr2para_fifo_rden,
    input                              	i_ddr2para_fifo_empty,
    input  [DDR_DW-1:0]				    i_ddr2para_fifo_data,
    output [7:0]						o_ddr_store_array,
    //code ram
	input						        i_code_wren1,
	input [6:0]					        i_code_wraddr1,
	input [31:0]				        i_code_wrdata1,
    input						        i_code_wren2,
	input [6:0]					        i_code_wraddr2,
	input [31:0]				        i_code_wrdata2,
    //input para vaule      
    input                               i_flash_poweron_initdone,
	input  [15:0]				        i_apd_hv_value,
	input  [15:0]				        i_apd_temp_value,
	input  [9:0]				        i_dac_value,
	input  [7:0]				        i_device_temp,
    //para output
    output [7:0]						o_laser_sernum,
    output [15:0]				        o_start_index,
	output [15:0]				        o_stop_index,
    output [31:0]						o_pulse_start,
	output [31:0]						o_pulse_divid,
	output [31:0]						o_distance_min,
	output [31:0]						o_distance_max,
    //motor     
    output [15:0]				        o_config_mode,
	output [15:0]				        o_freq_motor1,
	output [15:0]				        o_freq_motor2,
    output [15:0]				        o_motor_pwm_setval1,
	output [15:0]				        o_motor_pwm_setval2,
    output [15:0]                       o_angle_offset1,
    output [15:0]                       o_angle_offset2,
    //hv set        
    output [15:0]				        o_temp_apdhv_base,
	output [15:0]				        o_temp_temp_base,
	output						        o_hvcp_switch,
	output						        o_dicp_switch,
    //loop     
	output						        o_loopdata_flag,
	input  						        i_loop_make,
    input						        i_loop_pingpang,
	input						        i_loop_wren,	
	input  [7:0]				        i_loop_wrdata,
	input  [9:0]				        i_loop_wraddr,
	input  [15:0]				        i_loop_points,
	input						        i_loop_cycle_done,
    //calib     
	output						        o_calibrate_flag,
    output [15:0]                       o_cali_pointnum,
	input  						        i_calib_make,
    input						        i_calib_pingpang,
	input						        i_calib_wren,	
	input  [7:0]				        i_calib_wrdata,
	input  [9:0]				        i_calib_wraddr,
	input  [15:0]				        i_calib_points,
	input						        i_calib_cycle_done,
	input  [15:0]				        i_code_angle
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	
    parameter BOARD_MAC = 48'h7f_11_22_AA_BB_CC;
    parameter BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};
    parameter DES_MAC   = 48'h84_a9_38_a0_ad_0d;
    parameter DES_IP    = {8'd192,8'd168,8'd1,8'd102};
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    //clk
    wire                            w_ethphy_refclk;
    wire                            w_ethphy_refclk_90;
    // rmii signal      
    wire                            w_rmii_rxvld;
    wire [1:0]                      w_rmii_rxdata;

    //mac       
    wire                            w_mac_packet_rxsop;
	wire                            w_mac_packet_rxeop;
	wire                            w_mac_packet_rxvld;
	wire [7:0]                      w_mac_packet_rxdata;

    wire                            w_rmii_txen;
    wire [1:0]                      w_rmii_txd;

    wire                            w_eth_txsop;
    wire                            w_eth_txeop;
    wire                            w_eth_txvld;
    wire  [7:0]                     w_eth_txdata;

    // arp      
    wire                            w_arp_txsop;
    wire                            w_arp_txeop;
    wire                            w_arp_txvld;
    wire  [7:0]                     w_arp_txdata;

    wire [47:0]                     w_lidar_mac;
    wire [31:0]                     w_lidar_ip;
    wire                            w_arp_rxtype;
    wire                            w_arp_tx_en;
    wire [47:0]                     w_send_desmac;
    wire [31:0]                     w_send_desip;
    wire                            w_arp_rxdone;
    wire                            w_arp_tx_done;      //eth send done signal

    //icmp
    wire                            w_icmp_tx_en;
    wire                            w_icmp_txsop;
    wire                            w_icmp_txeop;
    wire                            w_icmp_txvld;
    wire [7:0]                      w_icmp_txdata;
    wire                            w_icmp_rxdone;
    wire                            w_icmp_txdone;
        
    // udp
    wire [15:0]                     w_udprecv_desport;
    wire [15:0]                     w_udpsend_srcport;
    wire [15:0]                     w_udpsend_desport;
    wire                            w_udp_tx_en;
    wire                            w_udp_txsop;
    wire                            w_udp_txeop;
    wire                            w_udp_txvld;
    wire [7:0]                      w_udp_txdata;
    wire                            w_udp_rxdone;
    wire [10:0]                     w_udp_rxram_rdaddr;
    wire [7:0]                      w_udp_rxram_rddata;
    wire [10:0]                     w_udp_txram_rdaddr;
    wire [7:0]                      w_udp_txram_rddata;
    wire [15:0]                     w_udp_txbyte_num;
    wire [15:0]                     w_udp_rxbyte_num;
    wire                            w_udpcom_busy;
    wire                            w_udp_txdone;
            
    reg                             r1_eth_crsdv    = 1'b0;
    reg                             r2_eth_crsdv    = 1'b0;
    reg  [1:0]          	        r1_eth_rxd		= 2'h0;
	reg  [1:0]          	        r2_eth_rxd		= 2'h0;
    reg  [7:0]                      r_rxdata        = 8'h0;
    wire                            w_eth_rxclk;
	//--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------

    //----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
    eth_pll u_eth_pll(
		.CLKI					    ( i_ethphy_refclk           ), 
		.CLKOP					    ( w_ethphy_refclk           ), 
		.CLKOS					    ( w_ethphy_refclk_90        )
    );  

    rmii_top u_rmii_top (       
	    .i_clk   		            ( i_clk                     ),
	    .i_rst_n  			        ( i_rst_n                   ),

        //rmii rx   
        .i_ethphy_refclk            ( i_ethphy_refclk           ),
        .i_ethphy_crsdv             ( i_ethphy_crsdv            ),
        .i_ethphy_rxer              ( i_ethphy_rxer             ),
	    .i_ethphy_rxdv              ( i_ethphy_rxdv             ),
	    .i_ethphy_rxd               ( i_ethphy_rxd              ),		//RMII rx data
        .o_rmii_rxvld               ( w_rmii_rxvld              ),
        .o_rmii_rxdata              ( w_rmii_rxdata             ),

        //rmii tx   
        .i_phy_refclk_90       	    ( w_ethphy_refclk_90        ),
		.i_rmii_txen                ( w_rmii_txen               ),
	    .i_rmii_txd                 ( w_rmii_txd                ),
        .o_ethphy_txen              ( o_ethphy_txen             ),
	    .o_ethphy_txd               ( o_ethphy_txd              )  
	);

    mac_top u_mac_top(  
	    .i_clk   		            ( i_clk                     ),
	    .i_rst_n  			        ( i_rst_n                   ),

        .i_rmii_rxvld               ( w_rmii_rxvld              ),
        .i_rmii_rxdata              ( w_rmii_rxdata             ),
        .o_rmii_txen                ( w_rmii_txen               ),
        .o_rmii_txd                 ( w_rmii_txd                ),

        .o_mac_packet_rx_sop        ( w_mac_packet_rxsop        ),
        .o_mac_packet_rx_eop        ( w_mac_packet_rxeop        ),
        .o_mac_packet_rx_vld        ( w_mac_packet_rxvld        ),
        .o_mac_packet_rx_dat        ( w_mac_packet_rxdata       ),

        .i_mac_packet_tx_sop        ( w_eth_txsop               ),
        .i_mac_packet_tx_eop        ( w_eth_txeop               ),
        .i_mac_packet_tx_vld        ( w_eth_txvld               ),
        .i_mac_packet_tx_dat        ( w_eth_txdata              )
    );

    arp_ctrl #( 
        .BOARD_MAC                  ( BOARD_MAC                 ),
        .BOARD_IP                   ( BOARD_IP                  ),
        .DES_MAC                    ( DES_MAC                   ),
        .DES_IP                     ( DES_IP                    )
    )       
    u_arp_ctrl      
    (       
        .i_clk   		            ( i_clk                     ),
	    .i_rst_n  			        ( i_rst_n & o_parainit_done ),

        .i_mac_packet_rxsop         ( w_mac_packet_rxsop        ),
	    .i_mac_packet_rxeop         ( w_mac_packet_rxeop        ),
	    .i_mac_packet_rxvld         ( w_mac_packet_rxvld        ),
	    .i_mac_packet_rxdata        ( w_mac_packet_rxdata       ),

        .i_arp_tx_en                ( w_arp_tx_en               ),
        .i_lidar_mac                ( w_lidar_mac               ),
        .i_lidar_ip                 ( w_lidar_ip                ),
        .o_arp_txsop                ( w_arp_txsop               ),
        .o_arp_txeop                ( w_arp_txeop               ),
        .o_arp_txvld                ( w_arp_txvld               ),
        .o_arp_txdata               ( w_arp_txdata              ),

        .o_arp_rxdone               ( w_arp_rxdone              ),
        .o_arp_rxtype               ( w_arp_rxtype              ),
        .o_send_desmac              ( w_send_desmac             ),
        .o_send_desip               ( w_send_desip              ),

        .o_tx_done                  ( w_arp_tx_done             )
    );

    ip_top #( 
        .BOARD_MAC                  ( BOARD_MAC                 ),
        .BOARD_IP                   ( BOARD_IP                  ),
        .DES_MAC                    ( DES_MAC                   ),
        .DES_IP                     ( DES_IP                    )
    )
    u_ip_top
    (
        .i_clk   		            ( i_clk                     ),
	    .i_rst_n  			        ( i_rst_n & o_parainit_done ),

        .i_mac_packet_rxsop         ( w_mac_packet_rxsop        ),
	    .i_mac_packet_rxeop         ( w_mac_packet_rxeop        ),
	    .i_mac_packet_rxvld         ( w_mac_packet_rxvld        ),
	    .i_mac_packet_rxdata        ( w_mac_packet_rxdata       ),

        .i_lidar_mac                ( w_lidar_mac               ),
        .i_lidar_ip                 ( w_lidar_ip                ),
        .i_des_mac                  ( w_send_desmac             ),
        .i_des_ip                   ( w_send_desip              ),

        //icmp  
        .i_icmp_tx_en               ( w_icmp_tx_en              ),
        .o_icmp_txsop               ( w_icmp_txsop              ),
        .o_icmp_txeop               ( w_icmp_txeop              ),
        .o_icmp_txvld               ( w_icmp_txvld              ),
        .o_icmp_txdata              ( w_icmp_txdata             ),
        .o_icmp_rxdone              ( w_icmp_rxdone             ),
        .o_icmp_txdone              ( w_icmp_txdone             ),

        //udp
        .i_udpsend_srcport          ( w_udpsend_srcport         ),
        .i_udpsend_desport          ( w_udpsend_desport         ),
        .o_udprecv_desport          ( w_udprecv_desport         ),
        .i_udp_tx_en                ( w_udp_tx_en               ),
        .o_udp_txsop                ( w_udp_txsop               ),
        .o_udp_txeop                ( w_udp_txeop               ),
        .o_udp_txvld                ( w_udp_txvld               ),
        .o_udp_txdata               ( w_udp_txdata              ),
        .o_udp_rxdone               ( w_udp_rxdone              ),
        .i_udp_recram_rdaddr        ( w_udp_rxram_rdaddr        ),
        .o_udp_recram_rddata        ( w_udp_rxram_rddata        ),
        .o_udp_txram_rdaddr         ( w_udp_txram_rdaddr        ),
        .i_udp_txram_rddata         ( w_udp_txram_rddata        ),
        .i_udp_txbyte_num           ( w_udp_txbyte_num          ),
        .o_udp_rxbyte_num           ( w_udp_rxbyte_num          ),
        .o_udpcom_busy              ( w_udpcom_busy             ),
        .o_udp_txdone               ( w_udp_txdone              )
    );

    udpcom_control #(
        .FIRMWARE_VERSION           ( FIRMWARE_VERSION          ),
        .DDR_DW                	    ( DDR_DW                	),
        .DDR_AW                	    ( DDR_AW                	),
        .USER_RDW				    ( USER_RDW               	)
    ) 
    u_udpcom_control
    (
        .i_clk   		            ( i_clk                     ),
	    .i_rst_n  			        ( i_rst_n				    ),
        .o_parainit_done			( o_parainit_done			),
        //udp communication 
        .i_udpcom_busy              ( w_udpcom_busy             ),
        .i_udp_rxdone               ( w_udp_rxdone              ),
        .o_udp_rxram_rdaddr         ( w_udp_rxram_rdaddr        ),
        .i_udp_rxram_data           ( w_udp_rxram_rddata        ),
        .i_udp_rxbyte_num           ( w_udp_rxbyte_num          ),
        .i_udprecv_desport			( w_udprecv_desport			),
        .o_udp_send_req             ( w_udp_send_req            ),
        .i_udp_txram_rdaddr         ( w_udp_txram_rdaddr        ),
        .o_udp_txram_rddata         ( w_udp_txram_rddata        ),
        .o_udp_txbyte_num           ( w_udp_txbyte_num          ),
        .o_udpsend_srcport			( w_udpsend_srcport			),
        .o_udpsend_desport          ( w_udpsend_desport         ),
    	//ddr interface 
		.o_para2ddr_wren		    ( o_para2ddr_wren			),
    	.o_ddr2para_rden		    ( o_ddr2para_rden			),
    	.o_para2ddr_addr		    ( o_para2ddr_addr			),
    	.o_para2ddr_data		    ( o_para2ddr_data			),
		.o_ddr2para_fifo_rden	    ( o_ddr2para_fifo_rden		),
    	.i_ddr2para_fifo_empty	    ( i_ddr2para_fifo_empty		),
    	.i_ddr2para_fifo_data	    ( i_ddr2para_fifo_data		),
        .o_ddr_store_array		    ( o_ddr_store_array			),
        //code ram	    
		.i_code_wren1			    ( i_code_wren1 				),
		.i_code_wraddr1			    ( i_code_wraddr1 			),
		.i_code_wrdata1			    ( i_code_wrdata1 			),
        .i_code_wren2			    ( i_code_wren2 				),
		.i_code_wraddr2			    ( i_code_wraddr2 			),
		.i_code_wrdata2			    ( i_code_wrdata2 			),
        //input para vaule
        .i_flash_poweron_initdone   ( i_flash_poweron_initdone  ),
		.i_apd_hv_value			    ( i_apd_hv_value			),
		.i_apd_temp_value		    ( i_apd_temp_value			),
		.i_dac_value			    ( i_dac_value				),
		.i_device_temp			    ( i_device_temp				),
        //output
        .o_laser_sernum				( o_laser_sernum			),
        .o_lidar_mac                ( w_lidar_mac               ),
        .o_lidar_ip                 ( w_lidar_ip                ),
        .o_config_mode              ( o_config_mode             ),
        .o_start_index              ( o_start_index             ),
        .o_stop_index               ( o_stop_index              ),
        .o_freq_motor1              ( o_freq_motor1             ),
        .o_freq_motor2              ( o_freq_motor2             ),
        .o_motor_pwm_setval1        ( o_motor_pwm_setval1       ),
        .o_motor_pwm_setval2        ( o_motor_pwm_setval2       ),
        .o_angle_offset1		    ( o_angle_offset1			),
		.o_angle_offset2		    ( o_angle_offset2			),
        .o_temp_apdhv_base          ( o_temp_apdhv_base         ),
        .o_temp_temp_base		    ( o_temp_temp_base 			),
		.o_hvcp_switch			    ( o_hvcp_switch				),
		.o_dicp_switch			    ( o_dicp_switch				),
        .o_pulse_start 				( o_pulse_start 			),
		.o_pulse_divid 				( o_pulse_divid 			),
		.o_distance_min				( o_distance_min 			),
		.o_distance_max				( o_distance_max 			),
    	//loop
		.o_loopdata_flag			( o_loopdata_flag			),
		.i_loop_make				( i_loop_make 				),
        .i_loop_pingpang       		( i_loop_pingpang          	),
        .i_loop_wren				( i_loop_wren 				),	
		.i_loop_wrdata				( i_loop_wrdata 			),
		.i_loop_wraddr				( i_loop_wraddr 			),
		.i_loop_points				( i_loop_points				),
		.i_loop_cycle_done			( i_loop_cycle_done			),
        //calib 
		.o_calibrate_flag		    ( o_calibrate_flag			),
        .o_cali_pointnum            ( o_cali_pointnum           ),
		.i_calib_make			    ( i_calib_make 				),
        .i_calib_pingpang           ( i_calib_pingpang          ),
        .i_calib_wren			    ( i_calib_wren 				),	
		.i_calib_wrdata			    ( i_calib_wrdata 			),
		.i_calib_wraddr			    ( i_calib_wraddr 			),
        .i_calib_points             ( i_calib_points            ),
		.i_calib_cycle_done		    ( i_calib_cycle_done        ),
		.i_code_angle			    ( i_code_angle				)
    );

    eth_ctrl u_eth_ctrl (
        .i_clk   		            ( i_clk                     ),
	    .i_rst_n  			        ( i_rst_n				    ),

        //arp   
        .o_arp_tx_en                ( w_arp_tx_en               ), 
        .i_arp_txsop                ( w_arp_txsop               ),
        .i_arp_txeop                ( w_arp_txeop               ),
        .i_arp_txvld                ( w_arp_txvld               ),
        .i_arp_txdata               ( w_arp_txdata              ),
        .i_arp_rxdone               ( w_arp_rxdone              ),
        .i_arp_tx_done              ( w_arp_tx_done             ),

        //icmp  
        .o_icmp_tx_en               ( w_icmp_tx_en              ),
        .i_icmp_txsop               ( w_icmp_txsop              ),
        .i_icmp_txeop               ( w_icmp_txeop              ),
        .i_icmp_txvld               ( w_icmp_txvld              ),
        .i_icmp_txdata              ( w_icmp_txdata             ),
        .i_icmp_rxdone              ( w_icmp_rxdone             ),
        .i_icmp_txdone              ( w_icmp_txdone             ), 

        //udp   
        .o_udp_tx_en                ( w_udp_tx_en               ),
        .i_udp_txsop                ( w_udp_txsop               ),
        .i_udp_txeop                ( w_udp_txeop               ),
        .i_udp_txvld                ( w_udp_txvld               ),
        .i_udp_txdata               ( w_udp_txdata              ),
        .i_udp_rxdone               ( w_udp_send_req            ),
        .i_udp_txdone               ( w_udp_txdone              ),

        //eth   
        .o_mac_packet_tx_sop        ( w_eth_txsop               ),
        .o_mac_packet_tx_eop        ( w_eth_txeop               ),
        .o_mac_packet_txvld         ( w_eth_txvld               ),
        .o_mac_packet_txdata        ( w_eth_txdata              )
    );
endmodule