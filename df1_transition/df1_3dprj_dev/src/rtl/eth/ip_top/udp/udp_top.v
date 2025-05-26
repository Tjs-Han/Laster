// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: udp_top
// Date Created     : 2024/10/08
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:udp_top
// Ethernet MAC frame format
/*   —————————————————————————————————————————————————————————————————————————————————————————————————————————
    |  BYTE NUM   |  7 Byte  | 1 Byte |     14 Byte      |               46~1500 Byte              |  4 Byte  |
    |—————————————|———————————————————————————————————————————————————————————————————————————————————————————|
    |     MAC     | Preamble |   SFD  | Eth frame header |                  DATA                   |    FCS   |
    |—————————————|——————————|————————|——————————————————|—————————————————————————————————————————|——————————|
    |     IP      |                                      |    IP HEAD   |        IP DATA           |          |
    |————————————————————————————————————————————————————|——————————————|——————————|———————————————|——————————|
    |     UDP     |                                      |              | UDP HEAD |   UDP DATA    |          |
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
        Version                     : This value is set to 0100 for IPv4 and 0110 for IPv6. The most commonly used version number of IP protocol is 4
        Internet Header Length(IHL) : When there is no optional field, the IP header length is 20 bytes, so the header length value is 5.
        Type of service(TOS)        : If the service type is 0, it indicates a common service.
        Total Length                : Includes the IP header and IP data part, in bytes.
        Identification              : Identifies each datagram sent by the host. The value is usually increased by 1 for each message sent.
        Flags                       :
        Fragment Offset             :
        Time To Live(TTL)           : It is usually set to 64 or 128
        Protocol                    :
        Header Checksum             :
        Source IP Address           :
        Destination IP Address      :
    UDP protocol: 
    bit 0               4               8                               16          19                  24                          31
         ———————————————|———————————————|————————————————————————————————|———————————|———————————————————|———————————————————————————|------
        |                       Source port number                       |                Destination port number                    |      |
        |————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————|   UDP HEAD
        |                            UDP Length                          |                     UDP Checksum                          |      |
        |————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————|------
*/                                    
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module udp_top
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

    input                       i_udp_tx_en,
    
    output                      o_udp_txsop,
    output                      o_udp_txeop,
    output                      o_udp_txvld,
    output [7:0]                o_udp_txdata,

    input  [15:0]               i_udpsend_srcport,
    input  [15:0]               i_udpsend_desport,
    output [15:0]               o_udprecv_desport,
    output                      o_udpcom_busy,
    output                      o_udp_rxdone,
    output                      o_udp_txdone,

    input  [10:0]               i_udp_recram_rdaddr,
    output [7:0]                o_udp_recram_rddata,
    output                      o_udp_txram_rden,
    output [10:0]               o_udp_txram_rdaddr,
    input  [7:0]                i_udp_txram_rddata,
    input  [15:0]               i_udp_txbyte_num,
    output [15:0]               o_udp_rxbyte_num

);
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    //wire define
    wire                        w_udp_recram_wren;
    wire [ 7:0]                 w_udp_recram_wrdata;
    wire [10:0]                 w_udp_recram_wraddr;
    wire                        w_rec_en;
    wire [ 7:0]                 w_rec_data;
    wire                        w_fifo_rden;
    wire [ 7:0]                 w_fifo_rdata;
    wire                        w_fifo_empty;
    wire                        w_fifo_full;
    wire [15:0]                 w_rec_byte_num;
    wire                        w_udp_rxdone;
    wire [15:0]                 w_icmp_id;
    wire [15:0]                 w_icmp_seq;
    wire [31:0]                 w_reply_checksum;

    wire                        w_crc_en;    // CRC start check en
    wire                        w_crc_clr;    // CRC data reset
    wire [7:0]                  w_crc_d8;    // enter the 8-bit data to be verified
    wire [31:0]                 w_crc_data;    // CRC check data
    wire [31:0]                 w_crc_next;    // CRC Next verification completes data

	//----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
    assign  w_crc_d8 = o_udp_txdata;

    //udp receive module
    udp_rx #(
        .BOARD_MAC              ( BOARD_MAC                 ),
        .BOARD_IP               ( BOARD_IP                  )
    )   
    u_udp_rx    
    (   
        .i_clk                  ( i_clk                     ),
        .i_rst_n                ( i_rst_n                   ),

        .i_mac_packet_rxsop     ( i_mac_packet_rxsop        ),
        .i_mac_packet_rxeop     ( i_mac_packet_rxeop        ),
        .i_mac_packet_rxvld     ( i_mac_packet_rxvld        ),
        .i_mac_packet_rxdata    ( i_mac_packet_rxdata       ),

        .o_udp_recram_wren      ( w_udp_recram_wren         ),
        .o_udp_recram_wraddr    ( w_udp_recram_wraddr       ),
        .o_udp_recram_wrdata    ( w_udp_recram_wrdata       ),
        .o_udp_rxdone           ( o_udp_rxdone              ),
        .o_rec_byte_num         ( o_udp_rxbyte_num          ),
        .o_udprecv_desport      ( o_udprecv_desport         ),
        .i_lidar_mac            ( i_lidar_mac               ),
        .i_lidar_ip             ( i_lidar_ip                )
    );                                    

    //udp send module
    udp_tx #(
        .BOARD_MAC              ( BOARD_MAC                 ),
        .BOARD_IP               ( BOARD_IP                  ),
        .DES_MAC                ( DES_MAC                   ),
        .DES_IP                 ( DES_IP                    )
    )
    u_udp_tx
    (
        .i_clk                  ( i_clk                     ),                      
        .i_rst_n                ( i_rst_n                   ), 

        .i_udp_start_txen       ( i_udp_tx_en               ), 
        .o_udp_txram_rdaddr     ( o_udp_txram_rdaddr        ),                  
        .i_udp_txdata           ( i_udp_txram_rddata        ),           
        .i_udp_txbyte_num       ( i_udp_txbyte_num          ),    
        .i_des_mac              ( i_des_mac                 ),
        .i_des_ip               ( i_des_ip                  ),
        .i_lidar_mac            ( i_lidar_mac               ),
        .i_lidar_ip             ( i_lidar_ip                ),
        .i_udpsend_srcport      ( i_udpsend_srcport         ),
        .i_udpsend_desport      ( i_udpsend_desport         ),
        .i_crc_data             ( w_crc_data                ),
        .i_crc_next             ( w_crc_next[31:24]         ),

        .o_udpcom_busy          ( o_udpcom_busy             ),
        .o_tx_done              ( o_udp_txdone              ),           
        .o_tx_req               ( o_udp_txram_rden          ),            
        .o_udp_txvld            ( o_udp_txvld               ),
        .o_udp_txdata           ( o_udp_txdata              ),      
        .o_crc_en               ( w_crc_en                  ),            
        .o_crc_clr              ( w_crc_clr                 )            
    );                                      

    dataram_2048x8 udprx_dataram(
		.WrClock		        ( i_clk                     ), 
		.WrClockEn		        ( w_udp_recram_wren         ),
		.WrAddress		        ( w_udp_recram_wraddr       ), 
		.Data			        ( w_udp_recram_wrdata       ), 
		.WE				        ( 1'b1 						), 
		.RdClock		        ( i_clk                     ),  
		.RdClockEn		        ( 1'b1 						),
		.RdAddress		        ( i_udp_recram_rdaddr       ),
		.Q				        ( o_udp_recram_rddata       ),
		.Reset			        ( 1'b0 						)
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