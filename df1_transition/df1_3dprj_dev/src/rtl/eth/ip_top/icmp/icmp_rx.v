// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: icmp_rx
// Date Created     : 2024/10/08
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:icmp_rx
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
module icmp_rx
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

    output                      o_rec_en,
    output [ 7:0]               o_rec_data,
    output [15:0]               o_rec_byte_num,

    input  [47:0]                   i_lidar_mac,
    input  [31:0]                   i_lidar_ip,
    output                          o_icmp_rxdone,
    output [15:0]                   o_icmp_id,
    output [15:0]                   o_icmp_seq,
    output [31:0]                   o_reply_checksum
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	
    localparam DEST_IP  = {8'd192,8'd168,8'd1,8'd1}; 
    //state 
    localparam ST_IDLE          = 8'b0000_0000;
    localparam ST_ETH_HEAD      = 8'b0000_0001;
    localparam ST_IP_HEAD       = 8'b0000_0010;
    localparam ST_ICMP_HEAD     = 8'b0000_0100;
    localparam ST_ICMP_DATA     = 8'b0000_1000;
    localparam ST_WAIT_EOP      = 8'b0001_0000;
    localparam ST_RX_DONE       = 8'b0010_0000;
    localparam ST_RX_END        = 8'b0100_0000;

    localparam ETH_TYPE         = 16'h0800; //Ethernet protocol type IP
    localparam ICMP_TYPE        = 8'h01;    //ICMP protocol types
    //ICMP报文类型:回显请求
    localparam ECHO_REQUEST     = 8'h08; 
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
    reg  [31:0]     r_recv_desip        = 32'h0;
    reg  [47:0]     r_recv_srcmac       = 32'h0;
    reg  [31:0]     r_recv_srcip        = 32'h0;
    reg  [15:0]     r_eth_type          = 16'h0;
    reg  [5:0]      r_iphead_byte_num   = 6'd0 ;//IP header length
    reg  [15:0]     r_total_length      = 16'd0;//IP length
    reg  [1:0]      r_rec_encnt         = 2'd0 ;//8bit conv 32bit counter
    reg  [7:0]      r_icmp_type         = 8'h0; //ICMP Packet type: identifies error packets of error type or query report packets
    reg  [7:0]      r_icmp_code         = 8'h0;
    
    reg  [15:0]     r_icmp_checksum     = 16'h0; //Receive checksum
    reg  [15:0]     r_icmp_data_length  = 16'd0; //data length register
    reg  [15:0]     r_icmp_rxcnt        = 16'd0; //Received data count
    reg  [7:0]      r0_icmp_rxdata      = 8'h0;
    reg  [31:0]     r_reply_checksum_add= 32'h0;

    reg  [15:0]     r_icmp_id           = 16'h0;//ICMP identifier
    reg  [15:0]     r_icmp_seq          = 16'd0;//ICMP sequence
    reg  [31:0]     r_reply_checksum    = 32'h0;//Received data check

    reg             r_rec_en            = 1'b0;//以太网接收的数据使能信号
    reg  [ 7:0]     r_rec_data          = 8'h0;//以太网接收的数据
    reg  [15:0]     r_rec_byte_num      = 16'd0;//以太网接收的有效字数 单位:byte 

    reg             r_icmp_rxdone       = 1'b0;
    //--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------

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
                    r_next_state = ST_ICMP_HEAD;
                else if(r_error_en)
                    r_next_state = ST_RX_END;
                else
                    r_next_state = ST_IP_HEAD;
            end
            ST_ICMP_HEAD: begin
                if(r_skip_en)
                    r_next_state = ST_ICMP_DATA;
                else if(r_error_en)
                    r_next_state = ST_RX_END;
                else
                    r_next_state = ST_ICMP_HEAD;
            end
            ST_ICMP_DATA: begin
                if(r_skip_en)
                    r_next_state = ST_WAIT_EOP;
                else if(r_error_en)
                    r_next_state = ST_RX_END;
                else
                    r_next_state = ST_ICMP_DATA;
            end
            ST_WAIT_EOP: begin
                if(i_mac_packet_rxeop)
                    r_next_state = ST_RX_DONE;
                else
                    r_next_state = ST_WAIT_EOP;
            end
            ST_RX_DONE: r_next_state = ST_RX_END;
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
            r_recv_srcmac       <= 48'd0;
            r_recv_srcip        <= 32'd0;        
            r_eth_type          <= 16'd0;
            r_icmp_rxdone        <= 1'b0;

            r_iphead_byte_num   <= 6'd0;
            r_total_length      <= 16'd0;
            r_icmp_type         <= 8'd0;
            r_icmp_code         <= 8'd0;
            r_icmp_checksum     <= 16'd0;
            r_icmp_id           <= 16'd0;
            r_icmp_seq          <= 16'd0;

            r0_icmp_rxdata      <= 8'd0;
            r_reply_checksum    <= 32'd0;
            r_reply_checksum_add<= 32'd0;
            r_icmp_rxcnt        <= 16'd0;
            r_icmp_data_length  <= 16'd0;

            r_rec_encnt          <= 2'd0;
            r_rec_en              <= 1'b0;
            r_rec_data <= 32'd0;
        end
        else begin
            r_rec_en        <= 1'b0;
            r_skip_en       <= 1'b0;
            r_error_en      <= 1'b0;  
            r_icmp_rxdone   <= 1'b0;
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
                ST_IP_HEAD: begin
                    if(i_mac_packet_rxvld) begin
                        r_cnt <= r_cnt + 8'd1;
                        if(r_cnt == 8'd0)
                            r_iphead_byte_num <= {i_mac_packet_rxdata[3:0],2'd0};
                        else if (r_cnt == 8'd2) 
                            r_total_length[15:8] <= i_mac_packet_rxdata;
                        else if (r_cnt == 8'd3)
                            r_total_length[7:0] <= i_mac_packet_rxdata;
                        else if (r_cnt == 8'd4)
                            r_icmp_data_length <= r_total_length - 16'd28; 
				    	else if(r_cnt == 8'd9) begin
                            if(i_mac_packet_rxdata != ICMP_TYPE) begin                   
                                r_error_en <= 1'b1;               
                                r_cnt <= 8'd0;                        
                            end
                        end else if((r_cnt >= 8'd16) && (r_cnt <= 8'd18))
                            r_recv_desip <= {r_recv_desip[23:0],i_mac_packet_rxdata};
                        else if(r_cnt == 8'd19) begin
                            r_recv_desip <= {r_recv_desip[23:0],i_mac_packet_rxdata}; 
                            if((r_recv_desip[23:0] == i_lidar_ip[31:8])
                                && (i_mac_packet_rxdata == i_lidar_ip[7:0])) begin                             
                                r_skip_en <=1'b1; 
                                r_cnt <= 8'd0;
                            end else begin 
                                r_error_en <= 1'b1; 
                                r_cnt <= 8'd0;
                            end 
                        end 
				    	else;
                    end 
				    else;
                end
                ST_ICMP_HEAD : begin
                    if(i_mac_packet_rxvld) begin  //r_cnt ICMP首8个byte计数
                        r_cnt <= r_cnt + 1'b1;
                        if(r_cnt == 8'd0)
                            r_icmp_type <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd1)
                            r_icmp_code <= i_mac_packet_rxdata ;
                        else if(r_cnt == 8'd2)
                            r_icmp_checksum[15:8] <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd3)
                            r_icmp_checksum[7:0] <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd4)
                            r_icmp_id[15:8] <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd5)
                            r_icmp_id[7:0] <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd6)
                            r_icmp_seq[15:8] <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd7)begin
                            r_icmp_seq[7:0] <= i_mac_packet_rxdata;
                            //判断ICMP报文类型是否是回显请求
                            if(r_icmp_type == ECHO_REQUEST) begin
                                    r_skip_en <=1'b1;
                                    r_cnt <= 8'd0;
                            end else begin 
                                r_error_en <= 1'b1; 
                                r_cnt <= 8'd0;
                            end 
                        end 
				    	else;
                    end 
				    else;
                end 
                ST_ICMP_DATA : begin         
                    //receive data   
                    if(i_mac_packet_rxvld) begin
                        r_rec_encnt     <= r_rec_encnt + 2'd1;
                        r_icmp_rxcnt    <= r_icmp_rxcnt + 16'd1;
			    		r_rec_data      <= i_mac_packet_rxdata;
			    		r_rec_en        <= 1'b1;
    
			    		//Determine the number of parity of received data
                       if (r_icmp_rxcnt == r_icmp_data_length - 1) begin                      
                            r0_icmp_rxdata <= 8'h00;
                            if(r_icmp_data_length[0])		//Check whether the received data is an odd number
                                r_reply_checksum_add <= {8'd0,i_mac_packet_rxdata} + r_reply_checksum_add;                           
                            else
                                r_reply_checksum_add <= {r0_icmp_rxdata,i_mac_packet_rxdata} + r_reply_checksum_add;    
                        end else if(r_icmp_rxcnt < r_icmp_data_length) begin
                            r0_icmp_rxdata <= i_mac_packet_rxdata;
                            r_icmp_rxcnt <= r_icmp_rxcnt + 16'd1;
                            if (r_icmp_rxcnt[0] == 1'b1)
                                r_reply_checksum_add <= {r0_icmp_rxdata,i_mac_packet_rxdata} + r_reply_checksum_add; 
                            else
                                r_reply_checksum_add <= r_reply_checksum_add; 
                        end
			    		else;
                        if(r_icmp_rxcnt == r_icmp_data_length - 16'd1) begin
                            r_skip_en       <= 1'b1;
                            r_icmp_rxcnt    <= 16'd0;
                            r_rec_encnt     <= 2'd0;
                            r_rec_byte_num  <= r_icmp_data_length;
                        end 
			    		else;
                    end
			    	else;
                end
                ST_WAIT_EOP: begin
                    r_rec_en        <= 1'b0;
                    r_recv_srcmac   <= 48'h0;
                    r_recv_srcip    <= 32'h0;
                    r_recv_desmac   <= 48'h0;
                    r_recv_desip    <= 32'h0;
                end
                ST_RX_DONE: begin
                    r_icmp_rxdone       <= 1'b1;
                    r_reply_checksum    <= r_reply_checksum_add;
                end
                ST_RX_END: begin     
                    r_cnt <= 8'd0;
                    if(i_mac_packet_rxvld == 1'b0 && r_skip_en == 1'b0) begin// Single packet data is received
                        r_skip_en <= 1'b1;
                        r_reply_checksum_add <= 32'd0;
                    end else;
                end    
                default : ;
            endcase                                                        
        end
    end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_icmp_rxdone    = r_icmp_rxdone;
    assign o_rec_en         = r_rec_en;
    assign o_rec_data       = r_rec_data;
    assign o_rec_byte_num   = r_rec_byte_num;

    assign o_icmp_id        = r_icmp_id;
    assign o_icmp_seq       = r_icmp_seq;
    assign o_reply_checksum = r_reply_checksum;
endmodule