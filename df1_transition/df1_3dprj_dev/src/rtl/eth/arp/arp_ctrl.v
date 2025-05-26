// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: arp_ctrl
// Date Created     : 2024/10/08
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:arp_ctrl
// Ethernet MAC frame format
/* 
    |—————————————|——————————————————————————————————————————————————————————————————————————————————————|
    |     MAC     | Preamble |   SFD  |   Ethernet frame header  |            DATA            |    FCS   |
    |—————————————|——————————|————————|——————————————————————————|————————————————————————————|——————————|
    |  BYTE NUM   |  7 Byte  | 1 Byte |         14 Byte          |        46~1500 Byte        |  4 Byte  |
    |————————————————————————————————————————————————————————————————————————————————————————————————————|
    |     ARP     |                                              |   ARP DATA  | Filling data |          |
    |————————————————————————————————————————————————————————————————————————————————————————————————————|
    |                                                            |   28 Byte   |   18 Byte    |          |
    |————————————————————————————————————————————————————————————————————————————————————————————————————|

    28 bytes ARP request/reply：
     ————————————|————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
    |  ARP DATA  | Hardware type | Protocol type | Hardware size | Protocol size | Opcode | Source MAC | Source IP | Destination MAC | Destination IP |
    |————————————|———————————————|———————————————|———————————————|———————————————|————————|————————————|———————————|—————————————————|————————————————|
    |  BYTE NUM  |    2 Byte     |    2 Byte     |    1 Byte     |    1 Byte     | 2 Byte |   6 Byte   |  4 Byte   |     6 Byte      |     4 Byte     |
     —————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
        Hardware type               : The type of hardware address, 1 represents an Ethernet address.
        Protocol type               : The type of the protocol address to be mapped is IP. Therefore, the type of the protocol is IP and the value is 0x0800
        Hardware size               : The length of the hardware address (MAC address), in bytes. For ARP requests or replies from Ethernet IP addresses, the value is 6.                          
        Protocol size               : The length of the IP address, in bytes. For ARP requests or replies from Ethernet IP addresses, the value is 4.
        Opcode                      : The operation code indicates that the packet is an ARP request or an ARP reply. 1 indicates the ARP request and 2 indicates the ARP reply.
        Source MAC                  : Hardware address of the sending end.
        Source IP                   : Protocol (IP) address of the sender, for example, 192.168.1.102.
        Destination MAC             : Because the MAC address of the receiver is not known during the ARP request, the field is the broadcast address, 
                                      that is, 48 'hFF_FF_FF_FF_FF_FF_FF_FF
        Destination IP              : Protocol (IP) address of the receiving end, for example, 192.168.1.10.
*/                                    
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module arp_ctrl
#(
    parameter BOARD_MAC = 48'h00_11_22_33_44_55,  
    parameter BOARD_IP  = {8'd192,8'd168,8'd1,8'd10},
    parameter DES_MAC   = 48'hff_ff_ff_ff_ff_ff,
    parameter DES_IP    = {8'd192,8'd168,8'd1,8'd102}
)
(
    input                       i_clk,
    input                       i_rst_n,

    input                       i_mac_packet_rxsop,
	input                       i_mac_packet_rxeop,
	input                       i_mac_packet_rxvld,
	input  [7:0]                i_mac_packet_rxdata,

    input                       i_arp_tx_en,
    input  [47:0]               i_lidar_mac,
    input  [31:0]               i_lidar_ip,
    output                      o_arp_txsop,
    output                      o_arp_txeop,
    output                      o_arp_txvld,
    output [7:0]                o_arp_txdata,

    output                      o_arp_rxdone,
    output                      o_arp_rxtype,
    output [47:0]               o_send_desmac,
    output [31:0]               o_send_desip,

    output                      o_tx_done      //eth send done signal
    
);

    //--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------

	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    //wire define
    wire            w_arp_rxdone;
    wire            w_arp_rxtype;
    wire [47:0]     w_send_desmac;
    wire [31:0]     w_send_desip;

    wire            w_crc_en;       // CRC start check en
    wire            w_crc_clr;      // CRC data reset
    wire [7:0]      w_crc_d8;       // enter the 8-bit data to be verified
    wire [31:0]     w_crc_data;     // CRC check data
    wire [31:0]     w_crc_next;     // CRC Next verification completes data

    wire            w_rxcrc32_en;
    wire  [7:0]     w_rxcrc32_datain;
    wire            w_rxcrc32_clr;
    wire [31:0]     w_rxcrc32_resdata;
    wire [31:0]     w_crc_last;
	//----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------

    assign  w_crc_d8 = o_arp_txdata;

    //ARP receive module  
    arp_rx #(
        .BOARD_MAC              ( BOARD_MAC                 ),
        .BOARD_IP               ( BOARD_IP                  )
    )       
    u_arp_rx        
    (       
        .i_clk                  ( i_clk                     ),
        .i_rst_n                ( i_rst_n                   ),

        .i_mac_packet_rxsop     ( i_mac_packet_rxsop        ),
        .i_mac_packet_rxeop     ( i_mac_packet_rxeop        ),
        .i_mac_packet_rxvld     ( i_mac_packet_rxvld        ),
        .i_mac_packet_rxdata    ( i_mac_packet_rxdata       ),

        .o_arp_rxdone           ( w_arp_rxdone              ),
        .o_arp_rxtype           ( w_arp_rxtype              ),
        .o_send_desmac          ( w_send_desmac             ),
        .o_send_desip           ( w_send_desip              ),

        .o_rxcrc32_en           ( w_rxcrc32_en              ),
        .o_rxcrc32_dataout      ( w_rxcrc32_datain          ),
        .o_rxcrc32_clr          ( w_rxcrc32_clr             ),
        .i_rxcrc32_resdata      ( w_rxcrc32_resdata         )
    );                                           

    //ARP send module
    arp_tx #(
        .BOARD_MAC              ( BOARD_MAC                 ),
        .BOARD_IP               ( BOARD_IP                  ),
        .DES_MAC                ( DES_MAC                   ),
        .DES_IP                 ( DES_IP                    )
    )   
    u_arp_tx    
    (   
        .i_clk                  ( i_clk                     ),
        .i_rst_n                ( i_rst_n                   ),
    
        .i_arp_tx_en            ( i_arp_tx_en               ),
        .i_arp_rx_type          ( w_arp_rxtype              ),
        .i_lidar_mac            ( i_lidar_mac               ),
        .i_lidar_ip             ( i_lidar_ip                ),
        .i_des_mac              ( w_send_desmac             ),
        .i_des_ip               ( w_send_desip              ),
        .i_crc_data             ( w_crc_data                ),
        .i_crc_next             ( w_crc_next[31:24]         ),
    
        .o_arp_txsop            ( o_arp_txsop               ),
        .o_arp_txeop            ( o_arp_txeop               ),
        .o_arp_txvld            ( o_arp_txvld               ),
        .o_arp_txdata           ( o_arp_txdata              ),
        .o_tx_done              ( o_tx_done                 ),
    
        .o_crc_en               ( w_crc_en                  ),
        .o_crc_clr              ( w_crc_clr                 )
    );      
    
    //CRC check module  
    crc32_d8 utx_crc32_d8(    
        .i_clk                  ( i_clk                     ),
        .i_rst_n                ( i_rst_n                   ),
        .i_data                 ( w_crc_d8                  ),
        .i_crc_en               ( w_crc_en                  ),
        .i_crc_clr              ( w_crc_clr                 ),
        .o_crc_data             ( w_crc_data                ),
        .o_crc_next             ( w_crc_next                )
    );
 
    crc32_d8 urx_crc32_d8(    
        .i_clk                  ( i_clk                     ),
        .i_rst_n                ( i_rst_n                   ),
        .i_data                 ( w_rxcrc32_datain          ),
        .i_crc_en               ( w_rxcrc32_en              ),
        .i_crc_clr              ( w_rxcrc32_clr             ),
        .o_crc_data             ( w_rxcrc32_resdata         ),
        .o_crc_next             ( w_crc_last                )
    );
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_arp_rxdone	    = w_arp_rxdone;
    assign o_arp_rxtype     = w_arp_rxtype;
    assign o_send_desmac    = w_send_desmac;
    assign o_send_desip     = w_send_desip;
endmodule
