// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: icmp_top
// Date Created     : 2024/10/21
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:icmp_top
// Ethernet MAC frame format
/*   —————————————————————————————————————————————————————————————————————————————————————————————————————————
    |  BYTE NUM   |  7 Byte  | 1 Byte |     14 Byte      |               46~1500 Byte              |  4 Byte  |
    |—————————————|———————————————————————————————————————————————————————————————————————————————————————————|
    |     MAC     | Preamble |   SFD  | Eth frame header |                  DATA                   |    FCS   |
    |—————————————|——————————|————————|——————————————————|—————————————————————————————————————————|——————————|
    |     IP      |                                      |    IP HEAD   |        IP DATA           |          |
    |————————————————————————————————————————————————————|——————————————|——————————|———————————————|——————————|
    |     ICMP    |                                      |              | ICMPHEAD |  ICMP DATA    |          |
    |————————————————————————————————————————————————————|——————————————|——————————|———————————————|——————————|
    |  USER DATA  |                                      |              |          |   USER DATA   |          |
    |————————————————————————————————————————————————————|——————————————|——————————|———————————————|——————————|
    |  BYTE NUM   |                                      |   20 Byte    |  8 Byte  |  18~1472 Byte |          |
     —————————————————————————————————————————————————————————————————————————————————————————————————————————

    IP protocol: 
    bit 0               4               8                               16          19                  24                          31
         ———————————————|———————————————|————————————————————————————————|———————————|———————————————————|———————————————————————————|------
        |    Version    |      IHL      |               TOS              |                        Total Length                       |      |
        |————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————|      |
        |                           Identification                       |   Flags   |               Fragment Offset                 |      |
        |————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————|      |
        |             TTL               |              Protocol          |                    Header Checksum                        |   IP HEAD 
        |————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————|      |
        |                                                     Source IP Address                                                      |      |
        |————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————|      |
        |                                                   Destination IP Address                                                   |      |
        |————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————|------
        Version                     :   This value is set to 0100 for IPv4 and 0110 for IPv6. The most commonly used version number of IP protocol is 4
        Internet Header Length(IHL) :   When there is no optional field, the IP header length is 20 bytes, so the header length value is 5.
        Type of service(TOS)        :   If the service type is 0, it indicates a common service.
        Total Length                :   Includes the IP header and IP data part, in bytes.
        Identification              :   Identifies each datagram sent by the host. The value is usually increased by 1 for each message sent.
        Flags                       :   
        Fragment Offset             :   
        Time To Live(TTL)           :   It is usually set to 64 or 128
        Protocol                    :   Indicates the protocol type used by the upper-layer data carried by the datagram. 
                                        The value is 1 for ICMP, 6 for TCP, and 17 for UDP.

        Header Checksum             :
        Source IP Address           :
        Destination IP Address      :

    ICMP protocol: 
    bit 0               4               8                               16          19                  24                          31
         ———————————————|———————————————|————————————————————————————————|———————————|———————————————————|———————————————————————————|------
        |              Type             |               Code             |                          checksum                         |      |
        |————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————|   ICMPHEAD
        |                            Identifier                          |                    Sequence number                        |      |
        |————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————|------

        Type                :   8 bits are used, ICMP Packet type, which identifies error packets of error type or query report packets.
        Code                :   8 bits are used, Based on the type of ICMP error packets, you can further analyze the cause of the error.
                                Different code values correspond to different errors.
                            (Type=0, Code=0):   ping ack.
                            (Type=8, Code=0):   ping req.
                            (Type=11,Code=0):   Timeout.
                            (Type=3, Code=0):   Network unreachable.
                            (Type=3, Code=1):   Host unreachable.
                            (Type=5, Code=0):   redirect.
*/     
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module icmp_top
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

    input                       i_icmp_tx_en,

    output                      o_icmp_txsop,
    output                      o_icmp_txeop,
    output                      o_icmp_txvld,
    output [7:0]                o_icmp_txdata,

    output                      o_icmp_rxdone,
    output                      o_icmp_txdone
);
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    //wire define
    wire                        w_rec_en;
    wire [ 7:0]                 w_rec_data;
    wire                        w_fifo_rden;
    wire [ 7:0]                 w_fifo_rdata;
    wire                        w_fifo_empty;
    wire                        w_fifo_full;
    wire [15:0]                 w_rec_byte_num;
    wire                        w_icmp_rxdone;
    wire [15:0]                 w_icmp_id;
    wire [15:0]                 w_icmp_seq;
    wire [31:0]                 w_reply_checksum;

    wire                        w_crc_en;       // CRC start check en
    wire                        w_crc_clr;      // CRC data reset
    wire [7:0]                  w_crc_d8;       // enter the 8-bit data to be verified
    wire [31:0]                 w_crc_data;     // CRC check data
    wire [31:0]                 w_crc_next;     // CRC Next verification completes data
    //----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
    assign  w_crc_d8 = o_icmp_txdata;

    //ICMP receive module  
    icmp_rx #(
        .BOARD_MAC              ( BOARD_MAC                 ),
        .BOARD_IP               ( BOARD_IP                  )
    )       
    u_icmp_rx        
    (       
        .i_clk                  ( i_clk                     ),
        .i_rst_n                ( i_rst_n                   ),

        .i_mac_packet_rxsop     ( i_mac_packet_rxsop        ),
        .i_mac_packet_rxeop     ( i_mac_packet_rxeop        ),
        .i_mac_packet_rxvld     ( i_mac_packet_rxvld        ),
        .i_mac_packet_rxdata    ( i_mac_packet_rxdata       ),

        .o_rec_en               ( w_rec_en                  ),
        .o_rec_data             ( w_rec_data                ),
        .o_icmp_rxdone          ( o_icmp_rxdone             ),
        .o_rec_byte_num         ( w_rec_byte_num            ),

        .i_lidar_mac            ( i_lidar_mac               ),
        .i_lidar_ip             ( i_lidar_ip                ),
        .o_icmp_id              ( w_icmp_id                 ),
        .o_icmp_seq             ( w_icmp_seq                ),
        .o_reply_checksum       ( w_reply_checksum          )
    );                                           

    //ICMP send module
    icmp_tx #(
        .BOARD_MAC              ( BOARD_MAC                 ),
        .BOARD_IP               ( BOARD_IP                  ),
        .DES_MAC                ( DES_MAC                   ),
        .DES_IP                 ( DES_IP                    )
    )   
    u_icmp_tx
    (   
        .i_clk                  ( i_clk                     ),
        .i_rst_n                ( i_rst_n                   ),
    
        .i_reply_checksum       ( w_reply_checksum          ),
        .i_icmp_id              ( w_icmp_id                 ),
        .i_icmp_seq             ( w_icmp_seq                ),
        .i_start_txen           ( i_icmp_tx_en              ),
        .i_tx_data              ( w_fifo_rdata              ),
        .i_tx_byte_num          ( w_rec_byte_num            ),
        .i_lidar_mac            ( i_lidar_mac               ),
        .i_lidar_ip             ( i_lidar_ip                ),
        .i_des_mac              ( i_des_mac                 ),
        .i_des_ip               ( i_des_ip                  ),
        .i_crc_data             ( w_crc_data                ),
        .i_crc_next             ( w_crc_next[31:24]         ),
    
        .o_tx_done              ( o_icmp_txdone             ),
        .o_tx_req               ( w_fifo_rden               ),
        .o_icmp_txvld           ( o_icmp_txvld              ),
        .o_icmp_txdata          ( o_icmp_txdata             ),
        .o_crc_en               ( w_crc_en                  ),
        .o_crc_clr              ( w_crc_clr                 )
    );      
    
    //FIFO
    synfifo_data_2048x8 icmp_synfifo_data_2048x8
	(
	    .Clock                  ( i_clk                     ),
	    .Reset                  ( ~i_rst_n                  ),
    
	    .WrEn                   ( w_rec_en                  ),
	    .Data                   ( w_rec_data         	    ),
	    .RdEn                   ( w_fifo_rden               ),
	    .Q                      ( w_fifo_rdata              ),
	    .Empty                  ( w_fifo_empty              ),
	    .Full                   ( w_fifo_full               )
	);

    //CRC check module  
    crc32_d8 u_crc32_d8(    
        .i_clk                  ( i_clk                     ),                      
        .i_rst_n                ( i_rst_n                   ),                          
        .i_data                 ( w_crc_d8                  ),            
        .i_crc_en               ( w_crc_en                  ),                          
        .i_crc_clr              ( w_crc_clr                 ),                         
        .o_crc_data             ( w_crc_data                ),                        
        .o_crc_next             ( w_crc_next                )                         
    );
endmodule