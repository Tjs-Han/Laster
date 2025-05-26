// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: udp_rx
// Date Created     : 2024/10/08
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:udp_rx
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
        Protocol                    : 8-bit Protocol Indicates the protocol used by the upper-layer data carried by the datagram. 
                                      The value is 1 for ICMP, 6 for TCP, and 17 for UDP.
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
module udp_rx
#(
    parameter BOARD_MAC = 48'h00_11_22_33_44_55,
    parameter BOARD_IP  = {8'd192,8'd168,8'd1,8'd10}
)
(
    input                       i_clk,
    input                       i_rst_n,

    input                       i_mac_packet_rxsop,
    input                       i_mac_packet_rxeop,
    input                       i_mac_packet_rxvld,
    input  [7:0]                i_mac_packet_rxdata,

    output                      o_udp_recram_wren, // Data received by the Ethernet enables signals
    output [10:0]               o_udp_recram_wraddr,
	output [7 :0]               o_udp_recram_wrdata,
    output                      o_udp_rxdone, // Ethernet single-packet data receiving completion signal
    output [15:0]               o_rec_byte_num,  // Valid word unit for Ethernet receiving :byte

    input  [47:0]                   i_lidar_mac,
    input  [31:0]                   i_lidar_ip,
    output [15:0]                   o_udprecv_desport,
    output [15:0]                   o_udprecv_srcport
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------
    //state 
    localparam  ST_IDLE         = 8'b0000_0000;
    localparam  ST_ETH_HEAD     = 8'b0000_0001;
    localparam  ST_IP_HEAD      = 8'b0000_0010;
    localparam  ST_UDP_HEAD     = 8'b0000_0100;
    localparam  ST_UDP_DATA     = 8'b0000_1000;
    localparam  ST_WAIT_EOP     = 8'b0001_0000;
    localparam  ST_RX_END       = 8'b0010_0000;
    
    localparam  ETH_TYPE    = 16'h0800   ; //Ethernet protocol type IP protocol
    localparam  UDP_TYPE    = 8'd17      ; //UDP protocol
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    //reg define
    reg  [7:0]      r_cur_state         = ST_IDLE;
    reg  [7:0]      r_next_state        = ST_IDLE;

    reg             r_skip_en           = 1'b0; 
    reg             r_error_en          = 1'b0; 
    reg  [7:0]      r_cnt               = 8'd0; 
    reg  [47:0]     r_recv_desmac       = 48'h0;
    reg  [15:0]     r_eth_type          = 16'h0;
    reg  [31:0]     r_recv_desip        = 32'h0;
    reg  [47:0]     r_recv_srcmac       = 32'h0;
    reg  [31:0]     r_recv_srcip        = 32'h0;
    reg  [15:0]     r_recv_srcport      = 16'd0;
    reg  [15:0]     r_recv_desport      = 16'd0;
    reg  [5:0]      r_ip_head_byte_num  = 6'd0; 
    reg  [15:0]     r_udp_byte_num      = 16'd0;
    reg  [15:0]     r_data_byte_num     = 16'd0;
    reg  [15:0]     r_data_cnt          = 16'd0;

    reg             r_udp_recram_wren   = 1'b0;
    reg  [10:0]     r_udp_recram_wraddr = 11'd0;
    reg  [7:0]      r_udp_recram_wrdata = 8'h0;
    reg             r_udp_rxdone        = 1'b0;
    reg  [15:0]     r_rec_byte_num      = 16'd0;
    reg  [47:0]     r_send_desmac;
    reg  [31:0]     r_send_desip;
    reg  [15:0]     r_udprecv_desport   = 16'd55100;
    reg  [15:0]     r_udprecv_srcport   = 16'd65000;
    //--------------------------------------------------------------------------------------------------
	// Three-stage state machine
	//--------------------------------------------------------------------------------------------------
    //(three-stage state machine) Synchronous timing describes state transitions
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)
            r_cur_state <= ST_IDLE;  
        else
            r_cur_state <= r_next_state;
    end

    //Combinational logic determines the state transition condition
    always @(*) begin
        r_next_state = ST_IDLE;
        case(r_cur_state)
            ST_IDLE : begin                     //wait preamble
                if(i_mac_packet_rxsop)
                    r_next_state = ST_ETH_HEAD;
                else
                    r_next_state = ST_IDLE;    
            end
            ST_ETH_HEAD : begin                 //receiving Ethernet frame headers
                if(r_skip_en)
                    r_next_state = ST_IP_HEAD;
                else if(r_error_en)
                    r_next_state = ST_RX_END;
                else
                    r_next_state = ST_ETH_HEAD;
            end  
            ST_IP_HEAD : begin
                if(r_skip_en)
                    r_next_state = ST_UDP_HEAD;
                else if(r_error_en)
                    r_next_state = ST_RX_END;
                else
                    r_next_state = ST_IP_HEAD;
            end
            ST_UDP_HEAD: begin
                if(r_skip_en)
                    r_next_state = ST_UDP_DATA;
                else if(r_error_en)
                    r_next_state = ST_RX_END;
                else
                    r_next_state = ST_UDP_HEAD;
            end
            ST_UDP_DATA: begin
                if(r_skip_en)
                    r_next_state = ST_WAIT_EOP;
                else if(r_error_en)
                    r_next_state = ST_RX_END;
                else
                    r_next_state = ST_UDP_DATA;
            end
            ST_WAIT_EOP: begin
                if(i_mac_packet_rxeop)
                    r_next_state = ST_RX_END;
                else
                    r_next_state = ST_WAIT_EOP;
            end                 
            ST_RX_END : begin                   //receive end
                if(r_skip_en)
                    r_next_state = ST_IDLE;
                else
                    r_next_state = ST_RX_END;
            end
            default : r_next_state = ST_IDLE;
        endcase                                          
    end 

    // Sequential circuit description status output, parsing Ethernet data
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_skip_en           <= 1'b0;
            r_error_en          <= 1'b0;
            r_cnt               <= 8'd0;
            r_recv_desmac       <= 48'd0;
            r_recv_desip        <= 32'd0;
            r_eth_type          <= 16'd0;
            r_recv_srcmac       <= 48'd0;
            r_recv_srcip        <= 32'd0;
            r_recv_srcport      <= 16'd0;
            r_recv_desport      <= 16'd0;
            r_udprecv_desport   <= 16'd55100;
            r_udprecv_srcport   <= 16'd65000;
            r_ip_head_byte_num  <= 6'd0;
            r_udp_byte_num      <= 16'd0;
            r_data_byte_num     <= 16'd0;
            r_udp_recram_wren   <= 1'b0;
            r_data_cnt          <= 16'd0;
            r_udp_recram_wraddr <= 11'd0;
            r_udp_recram_wrdata <= 8'h0;
            r_udp_rxdone        <= 1'b0;
            r_rec_byte_num      <= 16'd0;
        end
        else begin
            r_udp_recram_wren   <= 1'b0;
            r_skip_en           <= 1'b0;
            r_error_en          <= 1'b0;
            r_udp_rxdone        <= 1'b0;
            case(r_next_state)
                ST_IDLE: begin
                    r_cnt           <= 8'd0;
                    r_recv_desmac   <= 48'h0;
                    r_recv_desip    <= 32'd0;
                    if(i_mac_packet_rxsop) begin
                        r_cnt <= r_cnt + 1'b1;
                        r_recv_desmac <= {r_recv_desmac[39:0], i_mac_packet_rxdata};
                    end
                end
                ST_ETH_HEAD: begin
                    if(i_mac_packet_rxvld) begin
                        r_cnt <= r_cnt + 1'b1;
                        if(r_cnt < 8'd6) 
                            r_recv_desmac <= {r_recv_desmac[39:0], i_mac_packet_rxdata};
                        else if(r_cnt == 8'd6) begin
                            if((r_recv_desmac != i_lidar_mac)
                                && (r_recv_desmac != 48'hff_ff_ff_ff_ff_ff))           
                                r_error_en <= 1'b1;
                        end else if(r_cnt == 8'd12)
                            r_eth_type[15:8] <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd13) begin
                            r_eth_type[7:0] <= i_mac_packet_rxdata;
                            r_cnt <= 8'd0;
                            if(r_eth_type[15:8] == ETH_TYPE[15:8]
                                && i_mac_packet_rxdata == ETH_TYPE[7:0])
                                r_skip_en <= 1'b1;
                            else
                                r_error_en <= 1'b1;                   
                        end        
                    end  
                end
                ST_IP_HEAD : begin
                    if(i_mac_packet_rxvld) begin
                        r_cnt <= r_cnt + 1'b1;
                        if(r_cnt == 8'd0)
                            r_ip_head_byte_num <= {i_mac_packet_rxdata[3:0],2'd0};
    					else if(r_cnt == 8'd9) begin
                            if(i_mac_packet_rxdata != UDP_TYPE) begin                       
                                r_error_en <= 1'b1;               
                                r_cnt <= 8'd0;                        
                            end
                        end else if((r_cnt >= 8'd12) && (r_cnt <= 8'd15))
                            r_recv_srcip <= {r_recv_srcip[23:0],i_mac_packet_rxdata};
                        else if((r_cnt >= 8'd16) && (r_cnt <= 8'd18))
                            r_recv_desip <= {r_recv_desip[23:0],i_mac_packet_rxdata};
                        else if(r_cnt == 8'd19) begin
                            r_recv_desip <= {r_recv_desip[23:0],i_mac_packet_rxdata}; 
                            if((r_recv_desip[23:0] == i_lidar_ip[31:8])
                                && (i_mac_packet_rxdata == i_lidar_ip[7:0])) begin                           
                                    r_skip_en <=1'b1;                     
                                    r_cnt <= 5'd0;                         
                            end    
                            else begin                                  
                                r_error_en <= 1'b1;               
                                r_cnt <= 5'd0;
                            end                                                  
                        end                          
                    end                                
                end 
                ST_UDP_HEAD : begin
                    if(i_mac_packet_rxvld) begin
                        r_cnt <= r_cnt + 1'b1;
                        if(r_cnt == 8'd0)
                            r_recv_srcport[15:8]    <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd1)
                            r_recv_srcport[7:0] <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd2)
                            r_recv_desport[15:8]    <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd3)
                            r_recv_desport[7:0] <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd4)
                            r_udp_byte_num[15:8] <= i_mac_packet_rxdata;
                        else if(r_cnt == 5'd5)
                            r_udp_byte_num[7:0] <= i_mac_packet_rxdata;
                        else if(r_cnt == 5'd7) begin
                            r_data_byte_num <= r_udp_byte_num - 16'd8;    
                            r_skip_en <= 1'b1;
                            r_cnt <= 5'd0;
                        end  
                    end                 
                end          
                ST_UDP_DATA : begin 
                    r_udprecv_desport   <= r_recv_desport;
                    r_udprecv_srcport   <= r_recv_srcport;
                    if(i_mac_packet_rxvld) begin
                        r_data_cnt  <= r_data_cnt + 16'd1;
                        r_udp_recram_wren   <= 1'b1;
                        r_udp_recram_wrdata <= i_mac_packet_rxdata;
                        if(r_data_cnt == r_data_byte_num - 16'd1) begin
                            r_skip_en       <= 1'b1;
                            r_data_cnt      <= 16'd0;
                            r_udp_rxdone    <= 1'b1;               
                            r_rec_byte_num  <= r_data_byte_num;
                        end
                        if(r_data_cnt   >= 16'd1)
                            r_udp_recram_wraddr <= r_udp_recram_wraddr + 1'b1;
                    end  
                end
                ST_WAIT_EOP: begin
                    r_udp_recram_wren   <= 1'b0;
                    r_udp_recram_wraddr <= 11'd0;
                    r_recv_srcport      <= 16'd0;
                    r_recv_desport      <= 16'd0;
                    r_recv_desmac       <= 48'h0;
                    r_recv_desip        <= 32'h0;
                end
                ST_RX_END : begin
                    if(i_mac_packet_rxvld == 1'b0 && r_skip_en == 1'b0)
                        r_skip_en <= 1'b1; 
                end    
                default : ;
            endcase                                                        
        end
    end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_udp_recram_wren    = r_udp_recram_wren;
    assign o_udp_recram_wraddr  = r_udp_recram_wraddr;
    assign o_udp_recram_wrdata  = r_udp_recram_wrdata;
    assign o_udp_rxdone         = r_udp_rxdone;
    assign o_rec_byte_num       = r_rec_byte_num;
    assign o_udprecv_desport    = r_udprecv_desport;
    assign o_udprecv_srcport    = r_udprecv_srcport;
endmodule