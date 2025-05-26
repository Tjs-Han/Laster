// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: arp_tx
// Date Created     : 2024/10/08
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:arp_tx
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

    ARP protocol：
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
module arp_tx
#(
    parameter BOARD_MAC = 48'h00_11_22_33_44_55,  
    parameter BOARD_IP  = {8'd192,8'd168,8'd1,8'd10},
    parameter DES_MAC   = 48'hff_ff_ff_ff_ff_ff,
    parameter DES_IP    = {8'd192,8'd168,8'd1,8'd102}
)
( 
    input                       i_clk,
    input                       i_rst_n,
    
    input                       i_arp_tx_en,
    input                       i_arp_rx_type,  //ARP Send type 0: request 1: reply
    input  [47:0]               i_lidar_mac,
    input  [31:0]               i_lidar_ip,
    input  [47:0]               i_des_mac,
    input  [31:0]               i_des_ip,
    input  [31:0]               i_crc_data,
    input  [7:0]                i_crc_next,

    output                      o_arp_txsop,
    output                      o_arp_txeop,
    output                      o_arp_txvld,
    output [7:0]                o_arp_txdata,
    output                      o_tx_done,      //eth send done signal

    output                      o_crc_en,
    output                      o_crc_clr
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	 
    //state 
    localparam  ST_IDLE         = 5'b0_0001; //wait send signal
    localparam  ST_PREAMBLE     = 5'b0_0010;
    localparam  ST_ETH_HEAD     = 5'b0_0100;
    localparam  ST_ARP_DATA     = 5'b0_1000;
    localparam  ST_CRC          = 5'b1_0000;

    localparam  ETH_TYPE        = 16'h0806;
    localparam  HD_TYPE         = 16'h0001;
    localparam  PROTOCOL_TYPE   = 16'h0800;
    localparam  MIN_DATA_NUM    = 16'd46;    

	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    reg                     r_tx_done;
    reg                     r_arp_tx_sop;
    reg                     r_arp_tx_eop;
    reg                     r_arp_txvld;
    reg  [7:0]              r_arp_txdata;
    reg                     r_crc_en;
    reg                     r_crc_clr;
    //reg define
    reg  [4:0]              r_cur_state;
    reg  [4:0]              r_next_state;
    reg  [7:0]              r_preamble[7:0];
    reg  [7:0]              r_eth_head[13:0];
    reg  [7:0]              r_arp_data[27:0];                        
    reg                     r0_tx_en;
    reg                     r1_tx_en; 
    reg			            r2_tx_en;
    reg                     r_skip_en;
    reg  [5:0]              r_cnt; 
    reg  [4:0]              r_data_cnt;
    reg                     r_tx_done_t; 

    //wire define                   
    wire                    r_pos_tx_en;
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    assign  r_pos_tx_en = (~r2_tx_en) & r1_tx_en;

    //对arp_tx_en信号延时打拍两次,用于采arp_tx_en的上升沿
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r0_tx_en <= 1'b0;
            r1_tx_en <= 1'b0;
    		r2_tx_en <= 1'b0;
        end else begin
            r0_tx_en <= i_arp_tx_en;
            r1_tx_en <= r0_tx_en;
    		r2_tx_en <= r1_tx_en;
        end
    end 
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
            ST_IDLE: begin
                if(r_skip_en)
                    r_next_state = ST_PREAMBLE;
                else
                    r_next_state = ST_IDLE;
            end                          
            ST_PREAMBLE: begin
                if(r_skip_en)
                    r_next_state = ST_ETH_HEAD;
                else
                    r_next_state = ST_PREAMBLE;
            end
            ST_ETH_HEAD: begin
                if(r_skip_en)
                    r_next_state = ST_ARP_DATA;
                else
                    r_next_state = ST_ETH_HEAD;      
            end              
            ST_ARP_DATA: begin
                if(r_skip_en)
                    r_next_state = ST_CRC;
                else
                    r_next_state = ST_ARP_DATA;
            end
            ST_CRC: begin
                if(r_skip_en)
                    r_next_state = ST_IDLE;
                else
                    r_next_state = ST_CRC;
            end
            default: r_next_state = ST_IDLE;
        endcase
    end

    // Sequential circuit description status output, send data
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_skip_en       <= 1'b0; 
            r_cnt           <= 6'd0;
            r_data_cnt      <= 5'd0;
            r_crc_en        <= 1'b0;
            r_arp_txvld     <= 1'b0;
            r_arp_txdata    <= 8'd0;
            r_tx_done_t     <= 1'b0; 
 
            //Preamble 7个8'h55 + SFD 1个8'hd5 
            r_preamble[0]   <= 8'h55;                
            r_preamble[1]   <= 8'h55;
            r_preamble[2]   <= 8'h55;
            r_preamble[3]   <= 8'h55;
            r_preamble[4]   <= 8'h55;
            r_preamble[5]   <= 8'h55;
            r_preamble[6]   <= 8'h55;
            r_preamble[7]   <= 8'hd5;

            //Ethernet frame header 
            r_eth_head[0]   <= DES_MAC[47:40];      // Destination MAC
            r_eth_head[1]   <= DES_MAC[39:32];
            r_eth_head[2]   <= DES_MAC[31:24];
            r_eth_head[3]   <= DES_MAC[23:16];
            r_eth_head[4]   <= DES_MAC[15:8];
            r_eth_head[5]   <= DES_MAC[7:0];        
            r_eth_head[6]   <= BOARD_MAC[47:40];    // Source MAC
            r_eth_head[7]   <= BOARD_MAC[39:32];    
            r_eth_head[8]   <= BOARD_MAC[31:24];    
            r_eth_head[9]   <= BOARD_MAC[23:16];    
            r_eth_head[10]  <= BOARD_MAC[15:8];    
            r_eth_head[11]  <= BOARD_MAC[7:0];     
            r_eth_head[12]  <= ETH_TYPE[15:8];     // eth type
            r_eth_head[13]  <= ETH_TYPE[7:0];  

            //ARP DATA 28 Bytes                          
            r_arp_data[0]   <= HD_TYPE[15:8];       //Hardware type 
            r_arp_data[1]   <= HD_TYPE[7:0];
            r_arp_data[2]   <= PROTOCOL_TYPE[15:8]; //Protocol type
            r_arp_data[3]   <= PROTOCOL_TYPE[7:0];
            r_arp_data[4]   <= 8'h06;               //Hardware size, 6
            r_arp_data[5]   <= 8'h04;               //Protocol size, 4
            r_arp_data[6]   <= 8'h00;               //Opcode two Bytes
            r_arp_data[7]   <= 8'h01;
            r_arp_data[8]   <= BOARD_MAC[47:40];
            r_arp_data[9]   <= BOARD_MAC[39:32];
            r_arp_data[10]  <= BOARD_MAC[31:24];
            r_arp_data[11]  <= BOARD_MAC[23:16];
            r_arp_data[12]  <= BOARD_MAC[15:8];
            r_arp_data[13]  <= BOARD_MAC[7:0];
            r_arp_data[14]  <= BOARD_IP[31:24];
            r_arp_data[15]  <= BOARD_IP[23:16];
            r_arp_data[16]  <= BOARD_IP[15:8];
            r_arp_data[17]  <= BOARD_IP[7:0];
            r_arp_data[18]  <= DES_MAC[47:40];
            r_arp_data[19]  <= DES_MAC[39:32];
            r_arp_data[20]  <= DES_MAC[31:24];
            r_arp_data[21]  <= DES_MAC[23:16];
            r_arp_data[22]  <= DES_MAC[15:8];
            r_arp_data[23]  <= DES_MAC[7:0];  
            r_arp_data[24]  <= DES_IP[31:24];
            r_arp_data[25]  <= DES_IP[23:16];
            r_arp_data[26]  <= DES_IP[15:8];
            r_arp_data[27]  <= DES_IP[7:0];
        end else begin
            r_skip_en <= 1'b0;
            r_crc_en <= 1'b0;
            r_arp_txvld <= 1'b0;
            r_tx_done_t <= 1'b0;
            case(r_next_state)
                ST_IDLE : begin
                    if(r_pos_tx_en) begin
                        r_skip_en <= 1'b1;
                        if((i_des_mac != 48'h0) || (i_des_ip != 32'h0)) begin
                            r_eth_head[0]   <= i_des_mac[47:40];
                            r_eth_head[1]   <= i_des_mac[39:32];
                            r_eth_head[2]   <= i_des_mac[31:24];
                            r_eth_head[3]   <= i_des_mac[23:16];
                            r_eth_head[4]   <= i_des_mac[15:8];
                            r_eth_head[5]   <= i_des_mac[7:0];
                            r_eth_head[6]   <= i_lidar_mac[47:40];    // Source MAC
                            r_eth_head[7]   <= i_lidar_mac[39:32];    
                            r_eth_head[8]   <= i_lidar_mac[31:24];    
                            r_eth_head[9]   <= i_lidar_mac[23:16];    
                            r_eth_head[10]  <= i_lidar_mac[15:8];    
                            r_eth_head[11]  <= i_lidar_mac[7:0];
                            
                            r_arp_data[8]   <= i_lidar_mac[47:40];
                            r_arp_data[9]   <= i_lidar_mac[39:32];
                            r_arp_data[10]  <= i_lidar_mac[31:24];
                            r_arp_data[11]  <= i_lidar_mac[23:16];
                            r_arp_data[12]  <= i_lidar_mac[15:8];
                            r_arp_data[13]  <= i_lidar_mac[7:0];
                            r_arp_data[14]  <= i_lidar_ip[31:24];
                            r_arp_data[15]  <= i_lidar_ip[23:16];
                            r_arp_data[16]  <= i_lidar_ip[15:8];
                            r_arp_data[17]  <= i_lidar_ip[7:0];
                            r_arp_data[18]  <= i_des_mac[47:40];
                            r_arp_data[19]  <= i_des_mac[39:32];
                            r_arp_data[20]  <= i_des_mac[31:24];
                            r_arp_data[21]  <= i_des_mac[23:16];
                            r_arp_data[22]  <= i_des_mac[15:8];
                            r_arp_data[23]  <= i_des_mac[7:0];  
                            r_arp_data[24]  <= i_des_ip[31:24];
                            r_arp_data[25]  <= i_des_ip[23:16];
                            r_arp_data[26]  <= i_des_ip[15:8];
                            r_arp_data[27]  <= i_des_ip[7:0];
                        end
                        if(i_arp_rx_type == 1'b0)
                            r_arp_data[7] <= 8'h02;            //ARP reply 
                        else 
                            r_arp_data[7] <= 8'h01;            //ARP request
                    end
                end                                                                   
                ST_PREAMBLE: begin
                    r_arp_txvld <= 1'b1;
                    r_arp_txdata <= r_preamble[r_cnt];
                    if(r_cnt == 6'd7) begin                        
                        r_skip_en <= 1'b1;
                        r_cnt   <= 6'd0;    
                    end else    
                        r_cnt <= r_cnt + 1'b1;
                end
                ST_ETH_HEAD : begin
                    r_arp_txvld <= 1'b1;
                    r_crc_en <= 1'b1;
                    r_arp_txdata <= r_eth_head[r_cnt];
                    if (r_cnt == 6'd13) begin
                        r_skip_en <= 1'b1;
                        r_cnt <= 6'd0;
                    end else    
                        r_cnt <= r_cnt + 1'b1;
                end                    
                ST_ARP_DATA : begin
                    r_crc_en <= 1'b1;
                    r_arp_txvld <= 1'b1;
                    //至少发送46个字节
                    if (r_cnt == MIN_DATA_NUM - 1'b1) begin    
                        r_skip_en <= 1'b1;
                        r_cnt <= 1'b0;
                        r_data_cnt <= 1'b0;
                    end else    
                        r_cnt <= r_cnt + 1'b1;  
                        
                    if(r_data_cnt <= 6'd27) begin
                        r_data_cnt <= r_data_cnt + 1'b1;
                        r_arp_txdata <= r_arp_data[r_data_cnt];
                    end else
                        r_arp_txdata <= 8'd0;                    //Padding,填充0
                end
                ST_CRC      : begin                          //发送CRC校验值
                    r_arp_txvld <= 1'b1;
                    r_cnt <= r_cnt + 1'b1;
                    if(r_cnt == 6'd0)
                        // r_arp_txdata <= 8'h49;
                        r_arp_txdata <= {~i_crc_next[0], ~i_crc_next[1], ~i_crc_next[2],~i_crc_next[3],
                                     ~i_crc_next[4], ~i_crc_next[5], ~i_crc_next[6],~i_crc_next[7]};
                    else if(r_cnt == 6'd1)
                        // r_arp_txdata <= 8'h2A;
                        r_arp_txdata <= {~i_crc_data[16], ~i_crc_data[17], ~i_crc_data[18],
                                     ~i_crc_data[19], ~i_crc_data[20], ~i_crc_data[21], 
                                     ~i_crc_data[22],~i_crc_data[23]};
                    else if(r_cnt == 6'd2) begin
                        // r_arp_txdata <= 8'hCE;
                        r_arp_txdata <= {~i_crc_data[8], ~i_crc_data[9], ~i_crc_data[10],
                                     ~i_crc_data[11],~i_crc_data[12], ~i_crc_data[13], 
                                     ~i_crc_data[14],~i_crc_data[15]};                              
                    end
                    else if(r_cnt == 6'd3) begin
                        // r_arp_txdata <= 8'h2F;
                        r_arp_txdata <= {~i_crc_data[0], ~i_crc_data[1], ~i_crc_data[2],~i_crc_data[3],
                                     ~i_crc_data[4], ~i_crc_data[5], ~i_crc_data[6],~i_crc_data[7]};  
                        r_tx_done_t <= 1'b1;
                        r_skip_en <= 1'b1;
                        r_cnt <= 1'b0;
                    end   
    				else;
                end                          
                default :;  
            endcase                                             
        end
    end            
    //--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)
            r_arp_tx_sop    <= 1'b0;
        else if(r_next_state == ST_PREAMBLE && r_cnt == 6'd0)
            r_arp_tx_sop    <= 1'b1;
        else
            r_arp_tx_sop    <= 1'b0;
    end
    
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)
            r_arp_tx_eop    <= 1'b0;
        else if(r_next_state == ST_CRC && r_cnt == 6'd3)
            r_arp_tx_eop    <= 1'b1;
        else
            r_arp_tx_eop    <= 1'b0;
    end

    //发送完成信号及crc值复位信号
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_tx_done <= 1'b0;
            r_crc_clr <= 1'b0;
        end
        else begin
            r_tx_done <= r_tx_done_t;
            r_crc_clr <= r_tx_done_t;
        end
    end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_tx_done        = r_tx_done;
    assign o_arp_txsop      = r_arp_tx_sop;
    assign o_arp_txeop      = r_arp_tx_eop;
    assign o_arp_txvld      = r_arp_txvld;
    assign o_arp_txdata     = r_arp_txdata;
    assign o_crc_en         = r_crc_en;
    assign o_crc_clr        = r_crc_clr;
endmodule