// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: ip_top
// Date Created     : 2024/10/21
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:ip_top
// Ethernet MAC frame format                             
// -------------------------------------------------------------------------------------------------                                 
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module ip_top
#(
    parameter BOARD_MAC = 48'h00_11_22_33_44_55,  
    parameter BOARD_IP  = {8'd192,8'd168,8'd1,8'd10},
    parameter DES_MAC   = 48'hff_ff_ff_ff_ff_ff,
    parameter DES_IP    = {8'd192,8'd168,8'd1,8'd102}
)
(
    input                       i_clk,
    input                       i_rst_n,

    input  [47:0]               i_des_mac,
    input  [31:0]               i_des_ip,
    input  [47:0]               i_lidar_mac,
    input  [31:0]               i_lidar_ip,
    

    input                       i_mac_packet_rxsop,
	input                       i_mac_packet_rxeop,
	input                       i_mac_packet_rxvld,
	input  [7:0]                i_mac_packet_rxdata,

    //icmp
    input                       i_icmp_tx_en,
    output                      o_icmp_txsop,
    output                      o_icmp_txeop,
    output                      o_icmp_txvld,
    output [7:0]                o_icmp_txdata,
    output                      o_icmp_rxdone,
    output                      o_icmp_txdone,

    //udp
    input  [15:0]               i_udpsend_srcport,
    input  [15:0]               i_udpsend_desport,
    output [15:0]               o_udprecv_desport,
    input                       i_udp_tx_en,
    output                      o_udp_txsop,
    output                      o_udp_txeop,
    output                      o_udp_txvld,
    output [7:0]                o_udp_txdata,
    output                      o_udp_rxdone,
    input  [10:0]               i_udp_recram_rdaddr,
    output [7:0]                o_udp_recram_rddata,
    output [10:0]               o_udp_txram_rdaddr,
    input  [7:0]                i_udp_txram_rddata,
    input  [15:0]               i_udp_txbyte_num,
    output [15:0]               o_udp_rxbyte_num,
    output                      o_udpcom_busy,
    output                      o_udp_txdone
    
);

    //--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------

	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    //wire define
    wire                        w_arp_rxdone;
    wire                        w_arp_rxtype;
    wire [47:0]                 w_send_desmac;
    wire [31:0]                 w_send_desip;

    wire                        w_icmp_txsop;
    wire                        w_icmp_txeop;
    wire                        w_icmp_txvld;
    wire [7:0]                  w_icmp_txdata;

	//----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
    //icmp
    icmp_top #(
        .BOARD_MAC              ( BOARD_MAC                 ),
        .BOARD_IP               ( BOARD_IP                  ),
        .DES_MAC                ( DES_MAC                   ),
        .DES_IP                 ( DES_IP                    )
    )
    u_icmp_top        
    (       
        .i_clk                  ( i_clk                     ),
        .i_rst_n                ( i_rst_n                   ),

        .i_des_mac              ( i_des_mac                 ),
        .i_des_ip               ( i_des_ip                  ),
        .i_lidar_mac            ( i_lidar_mac               ),
        .i_lidar_ip             ( i_lidar_ip                ),

        .i_mac_packet_rxsop     ( i_mac_packet_rxsop        ),
        .i_mac_packet_rxeop     ( i_mac_packet_rxeop        ),
        .i_mac_packet_rxvld     ( i_mac_packet_rxvld        ),
        .i_mac_packet_rxdata    ( i_mac_packet_rxdata       ),

        .i_icmp_tx_en           ( i_icmp_tx_en              ),

        .o_icmp_txsop           ( o_icmp_txsop              ),
        .o_icmp_txeop           ( o_icmp_txeop              ),
        .o_icmp_txvld           ( o_icmp_txvld              ),
        .o_icmp_txdata          ( o_icmp_txdata             ),

        .o_icmp_rxdone          ( o_icmp_rxdone             ),
        .o_icmp_txdone          ( o_icmp_txdone             )
    );                                           

    //udp
    udp_top #(
        .BOARD_MAC              ( BOARD_MAC                 ),
        .BOARD_IP               ( BOARD_IP                  ),
        .DES_MAC                ( DES_MAC                   ),
        .DES_IP                 ( DES_IP                    )
    )   
    u_udp_top
    (   
        .i_clk                  ( i_clk                     ),
        .i_rst_n                ( i_rst_n                   ),

        .i_des_mac              ( i_des_mac                 ),
        .i_des_ip               ( i_des_ip                  ),
        .i_lidar_mac            ( i_lidar_mac               ),
        .i_lidar_ip             ( i_lidar_ip                ),
        
        .i_mac_packet_rxsop     ( i_mac_packet_rxsop        ),
        .i_mac_packet_rxeop     ( i_mac_packet_rxeop        ),
        .i_mac_packet_rxvld     ( i_mac_packet_rxvld        ),
        .i_mac_packet_rxdata    ( i_mac_packet_rxdata       ),

        .i_udp_tx_en            ( i_udp_tx_en               ),

        .o_udp_txsop            ( o_udp_txsop               ),
        .o_udp_txeop            ( o_udp_txeop               ),
        .o_udp_txvld            ( o_udp_txvld               ),
        .o_udp_txdata           ( o_udp_txdata              ),
        .i_udpsend_srcport      ( i_udpsend_srcport         ),
        .i_udpsend_desport      ( i_udpsend_desport         ),

        .o_udpcom_busy          ( o_udpcom_busy             ),
        .o_udp_rxdone           ( o_udp_rxdone              ),
        .o_udp_txdone           ( o_udp_txdone              ),

        .i_udp_recram_rdaddr    ( i_udp_recram_rdaddr       ),
        .o_udp_recram_rddata    ( o_udp_recram_rddata       ),
        .o_udp_txram_rdaddr     ( o_udp_txram_rdaddr        ),
        .i_udp_txram_rddata     ( i_udp_txram_rddata        ),
        .i_udp_txbyte_num       ( i_udp_txbyte_num          ),
        .o_udp_rxbyte_num       ( o_udp_rxbyte_num          ),
        .o_udprecv_desport      ( o_udprecv_desport         )
    );      
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
endmodule
