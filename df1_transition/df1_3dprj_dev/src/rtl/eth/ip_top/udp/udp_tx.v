// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: udp_tx
// Date Created     : 2024/10/21
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:udp_tx
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
module udp_tx
#(
    parameter BOARD_MAC         = 48'h00_11_22_33_44_55,  
    parameter BOARD_IP          = {8'd192,8'd168,8'd1,8'd10},
    parameter DES_MAC           = 48'hff_ff_ff_ff_ff_ff,
    parameter DES_IP            = {8'd192,8'd168,8'd1,8'd102},
    parameter BOARD_PORT_NUM    = 16'd65000
)
(    
    input                           i_clk,
    input                           i_rst_n,

    input                           i_udp_start_txen,
    output                          o_tx_req,
    output [10:0]                   o_udp_txram_rdaddr,
	input  [ 7:0]                   i_udp_txdata,
    input  [15:0]                   i_udp_txbyte_num,
    input  [15:0]                   i_udpsend_srcport,
    input  [15:0]                   i_udpsend_desport,
    input  [47:0]                   i_des_mac,
    input  [31:0]                   i_des_ip,
    input  [47:0]                   i_lidar_mac,
    input  [31:0]                   i_lidar_ip,
    input  [31:0]                   i_crc_data,
    input  [ 7:0]                   i_crc_next,

    output                          o_udpcom_busy,
    output                          o_tx_done,
    output                          o_udp_txvld,
    output [7:0]                    o_udp_txdata,
    output                          o_crc_en,
    output                          o_crc_clr
);

	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	
    localparam  ST_IDLE         = 8'b0000_0000;
    localparam  ST_CHECK_SUM    = 8'b0000_0001;
    localparam  ST_PREAMBLE     = 8'b0000_0010;
    localparam  ST_ETH_HEAD     = 8'b0000_0100;
    localparam  ST_IP_HEAD      = 8'b0000_1000;
    localparam  ST_TX_DATA      = 8'b0001_0000;
    localparam  ST_CRC          = 8'b0010_0000;
    localparam  ST_TX_DONE      = 8'b0100_0000;

    localparam  ETH_TYPE        = 16'h0800;  //以太网协议类型 IP协议
    localparam  UDP_TYPE        = 8'd17; //UDP protocol
    //------------------------------------------------
	/*	
        The minimum Ethernet data contains 46 bytes, 
        the IP header contains 20 bytes and the ICMP header contains 8 bytes 
        So the data must be at least 46-20-8=18 bytes
    */
    //-----------------------------------------------
    localparam  MIN_DATA_NUM = 16'd18;
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    //reg define
    reg  [7:0]      r_cur_state;
    reg  [7:0]      r_next_state;        
    reg  [7:0]      r_preamble[7:0];
    reg  [7:0]      r_eth_head[13:0];
    reg  [31:0]     r_ip_head[6:0];                     
    reg             r0_start_en;
    reg             r1_start_en;
    reg             r2_start_en;
    reg  [15:0]     r_tx_data_num;
    reg  [15:0]     r_total_num;
    reg             r_trig_tx_en;
    reg  [15:0]     r_udp_num;
    reg             r_udpcom_busy;
    reg             r_skip_en;
    reg  [4:0]      r_cnt;
    reg  [31:0]     r_check_buffer;
    reg  [1:0]      r_tx_bit_sel;
    reg  [15:0]     r_data_cnt;
    reg             r_tx_done_t;
    reg  [4:0]      r_real_add_cnt;

    reg             r_tx_done;
    reg             r_tx_req;
    reg  [10:0]     r_udp_txram_rdaddr;
    reg             r_udp_txvld;
    reg  [7:0]      r_udp_txdata;
    reg             r_crc_en;
    reg             r_crc_clr;

    //wire define                       
    wire            w_pos_start_en;//开始发送数据上升沿
    wire [15:0]     w_real_tx_data_num;//实际发送的字节数(以太网最少字节要求)
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    assign  w_pos_start_en      = (~r2_start_en) & r1_start_en;
    assign  w_real_tx_data_num  = (r_tx_data_num >= MIN_DATA_NUM) 
                                  ? r_tx_data_num : MIN_DATA_NUM; 

    //采tx_start_en的上升沿
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r0_start_en <= 1'b0;
            r1_start_en <= 1'b0;
    		r2_start_en <= 1'b0;
        end    
        else begin
            r0_start_en <= i_udp_start_txen;
            r1_start_en <= r0_start_en;
    		r2_start_en <= r1_start_en;
        end
    end 

    //寄存数据有效字节
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_tx_data_num <= 16'd0;
            r_total_num <= 16'd0;
            r_udp_num <= 16'd0;
        end
        else begin
            if(w_pos_start_en && r_cur_state==ST_IDLE) begin
                //数据长度
                r_tx_data_num <= i_udp_txbyte_num;        
                //IP长度：有效数据+IP首部长度            
                r_total_num <= i_udp_txbyte_num + 16'd28;  
                //UDP长度：有效数据+UDP首部长度            
                r_udp_num <= i_udp_txbyte_num + 16'd8;               
            end   
    		else ;
        end
    end

    //触发发送信号
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) 
            r_trig_tx_en <= 1'b0;
        else
            r_trig_tx_en <= w_pos_start_en;

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
            ST_IDLE     : begin                               //wait send data
                if(r_skip_en)                
                    r_next_state = ST_CHECK_SUM;
                else
                    r_next_state = ST_IDLE;
            end  
            ST_CHECK_SUM: begin                               //IP head check
                if(r_skip_en)
                    r_next_state = ST_PREAMBLE;
                else
                    r_next_state = ST_CHECK_SUM;    
            end                             
            ST_PREAMBLE : begin                               //send preamble and fsd
                if(r_skip_en)
                    r_next_state = ST_ETH_HEAD;
                else
                    r_next_state = ST_PREAMBLE;      
            end
            ST_ETH_HEAD : begin                               
                if(r_skip_en)
                    r_next_state = ST_IP_HEAD;
                else
                    r_next_state = ST_ETH_HEAD;      
            end              
            ST_IP_HEAD : begin                                //send ip head and udp head              
                if(r_skip_en)
                    r_next_state = ST_TX_DATA;
                else
                    r_next_state = ST_IP_HEAD;      
            end
            ST_TX_DATA : begin                                //send data                  
                if(r_skip_en)
                    r_next_state = ST_CRC;
                else
                    r_next_state = ST_TX_DATA;      
            end
            ST_CRC: begin                                     //send crc data
                if(r_skip_en)
                    r_next_state = ST_TX_DONE;
                else
                    r_next_state = ST_CRC;      
            end
            ST_TX_DONE: begin
                if(r_skip_en)
                    r_next_state = ST_IDLE;
                else
                    r_next_state = ST_TX_DONE;
            end
            default : r_next_state = ST_IDLE;   
        endcase
    end                      

    // Sequential circuit description status output, send data
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_udpcom_busy <= 1'b0;
            r_skip_en <= 1'b0; 
            r_cnt <= 5'd0;
            r_check_buffer <= 32'd0;
            r_ip_head[1][31:16] <= 16'd0;
            r_tx_bit_sel <= 2'b0;
            r_crc_en <= 1'b0;
            r_udp_txvld <= 1'b0;
            r_udp_txdata <= 8'd0;
            r_tx_req <= 1'b0;
            r_udp_txram_rdaddr  <= 11'd0;
            r_tx_done_t <= 1'b0; 
            r_data_cnt <= 16'd0;
            r_real_add_cnt <= 5'd0;
            //初始化数组    
            //前导码 7个8'h55 + 1个8'hd5
            r_preamble[0] <= 8'h55;                 
            r_preamble[1] <= 8'h55;
            r_preamble[2] <= 8'h55;
            r_preamble[3] <= 8'h55;
            r_preamble[4] <= 8'h55;
            r_preamble[5] <= 8'h55;
            r_preamble[6] <= 8'h55;
            r_preamble[7] <= 8'hd5;
            //目的MAC地址
            r_eth_head[0] <= DES_MAC[47:40];
            r_eth_head[1] <= DES_MAC[39:32];
            r_eth_head[2] <= DES_MAC[31:24];
            r_eth_head[3] <= DES_MAC[23:16];
            r_eth_head[4] <= DES_MAC[15:8];
            r_eth_head[5] <= DES_MAC[7:0];
            //源MAC地址
            r_eth_head[6] <= BOARD_MAC[47:40];
            r_eth_head[7] <= BOARD_MAC[39:32];
            r_eth_head[8] <= BOARD_MAC[31:24];
            r_eth_head[9] <= BOARD_MAC[23:16];
            r_eth_head[10] <= BOARD_MAC[15:8];
            r_eth_head[11] <= BOARD_MAC[7:0];
            //以太网类型
            r_eth_head[12] <= ETH_TYPE[15:8];
            r_eth_head[13] <= ETH_TYPE[7:0];        
        end else begin
            r_skip_en <= 1'b0;
            r_crc_en <= 1'b0;
            r_udp_txvld <= 1'b0;
            r_tx_done_t <= 1'b0;
            case(r_next_state)
                ST_IDLE     : begin
                    if(r_trig_tx_en) begin
                        r_udpcom_busy <= 1'b1;
                        r_skip_en <= 1'b1; 
                        //版本号：4 首部长度：5(单位:32bit,20byte/4=5)
                        r_ip_head[0] <= {8'h45,8'h00,r_total_num};   
                        //16位标识，每次发送累加1      
                        r_ip_head[1][31:16] <= r_ip_head[1][31:16] + 1'b1; 
                        //bit[15:13]: 010表示不分片
                        // r_ip_head[1][15:0] <= 16'h4000;
                        r_ip_head[1][15:0] <= 16'h0000;
                        //协议：17(udp)                  
                        r_ip_head[2] <= {8'h80,8'd17,16'h0};   
                        //源IP地址               
                        r_ip_head[3] <= i_lidar_ip;
                        //目的IP地址    
                        if(i_des_ip != 32'd0)
                            r_ip_head[4] <= i_des_ip;
                        else
                            r_ip_head[4] <= DES_IP;       
                            //16位源端口号：1234  16位目的端口号：1234                      
                        // r_ip_head[5] <= {BOARD_PORT_NUM, BOARD_PORT_NUM};//src, des
                        r_ip_head[5] <= {i_udpsend_srcport, i_udpsend_desport};
                        //16位udp长度，16位udp校验和              
                        r_ip_head[6] <= {r_udp_num,16'h0000};  
                        //更新MAC地址
                        if(i_des_mac != 48'b0) begin
                            //目的MAC地址
                            r_eth_head[0] <= i_des_mac[47:40];
                            r_eth_head[1] <= i_des_mac[39:32];
                            r_eth_head[2] <= i_des_mac[31:24];
                            r_eth_head[3] <= i_des_mac[23:16];
                            r_eth_head[4] <= i_des_mac[15:8];
                            r_eth_head[5] <= i_des_mac[7:0];
                        end else ;
                        r_eth_head[6] <= i_lidar_mac[47:40];
                        r_eth_head[7] <= i_lidar_mac[39:32];
                        r_eth_head[8] <= i_lidar_mac[31:24];
                        r_eth_head[9] <= i_lidar_mac[23:16];
                        r_eth_head[10] <= i_lidar_mac[15:8];
                        r_eth_head[11] <= i_lidar_mac[7:0];
                    end else begin
                        r_udpcom_busy <= 1'b0;
                        r_skip_en <= 1'b0;
                    end
                end                                                       
                ST_CHECK_SUM: begin     //IP首部校验
                    r_cnt <= r_cnt + 5'd1;
                    if(r_cnt == 5'd0) begin                   
                        r_check_buffer <= r_ip_head[0][31:16] + r_ip_head[0][15:0]
                                        + r_ip_head[1][31:16] + r_ip_head[1][15:0]
                                        + r_ip_head[2][31:16] + r_ip_head[2][15:0]
                                        + r_ip_head[3][31:16] + r_ip_head[3][15:0]
                                        + r_ip_head[4][31:16] + r_ip_head[4][15:0];
                    end
                    else if(r_cnt == 5'd1)                      //可能出现进位,累加一次
                        r_check_buffer <= r_check_buffer[31:16] + r_check_buffer[15:0];
                    else if(r_cnt == 5'd2) begin                //可能再次出现进位,累加一次
                        r_check_buffer <= r_check_buffer[31:16] + r_check_buffer[15:0];
                    end                             
                    else if(r_cnt == 5'd3) begin                //按位取反 
                        r_skip_en <= 1'b1;
                        r_cnt <= 5'd0;            
                        r_ip_head[2][15:0] <= ~r_check_buffer[15:0];
                    end 
    				else ;
                end              
                ST_PREAMBLE : begin                           //发送前导码+帧起始界定符
                    r_udp_txvld <= 1'b1;
                    r_udp_txdata <= r_preamble[r_cnt];
                    if(r_cnt == 5'd7) begin                        
                        r_skip_en <= 1'b1;
                        r_cnt <= 5'd0;    
                    end
                    else    
                        r_cnt <= r_cnt + 5'd1;                     
                end
                ST_ETH_HEAD : begin                           //发送以太网首部
                    r_udp_txvld <= 1'b1;
                    r_crc_en <= 1'b1;
                    r_udp_txdata <= r_eth_head[r_cnt];
                    if (r_cnt == 5'd13) begin
                        r_skip_en <= 1'b1;
                        r_cnt <= 5'd0;
                    end    
                    else    
                        r_cnt <= r_cnt + 5'd1;    
                end                    
                ST_IP_HEAD  : begin                           //发送IP首部 + UDP首部
                    r_crc_en <= 1'b1;
                    r_udp_txvld <= 1'b1;
                    r_tx_bit_sel <= r_tx_bit_sel + 2'd1;
                    if(r_tx_bit_sel == 3'd0)
                        r_udp_txdata <= r_ip_head[r_cnt][31:24];
                    else if(r_tx_bit_sel == 3'd1)
                        r_udp_txdata <= r_ip_head[r_cnt][23:16];
                    else if(r_tx_bit_sel == 3'd2) begin
                        r_udp_txdata <= r_ip_head[r_cnt][15:8];
                        if(r_cnt == 5'd6) begin
                            //提前读请求数据，等待数据有效时发送
                            r_tx_req <= 1'b1;                     
                        end
                    end else if(r_tx_bit_sel == 3'd3) begin
                        r_udp_txdata <= r_ip_head[r_cnt][7:0];  
                        if(r_cnt == 5'd6) begin
                            r_skip_en <= 1'b1;   
                            r_udp_txram_rdaddr  <= r_udp_txram_rdaddr + 1'b1;
                            r_cnt <= 5'd0;
                        end else
                            r_cnt <= r_cnt + 5'd1;  
                    end 
    				else ;
                end
                ST_TX_DATA  : begin                           //发送数据
                    r_crc_en <= 1'b1;
                    r_tx_bit_sel <= r_tx_bit_sel + 3'd1;  
                    r_udp_txvld <= 1'b1;
    				r_udp_txdata <= i_udp_txdata;
                    if(r_udp_txram_rdaddr <= r_tx_data_num - 16'd1)
                        r_udp_txram_rdaddr  <= r_udp_txram_rdaddr + 1'b1;
                    else
                        r_udp_txram_rdaddr  <= r_udp_txram_rdaddr;
                        
                    if(r_data_cnt < r_tx_data_num - 16'd1)
                        r_data_cnt <= r_data_cnt + 16'd1;                        
                    else if(r_data_cnt == r_tx_data_num - 16'd1)begin
                        //如果发送的有效数据少于18个字节，在后面填补充位
                        //补充的值为最后一次发送的有效数据
                        if(r_data_cnt + r_real_add_cnt < w_real_tx_data_num - 16'd1)
                            r_real_add_cnt <= r_real_add_cnt + 5'd1;  
                        else begin
                            r_skip_en <= 1'b1;
                            r_data_cnt <= 16'd0;
                            r_real_add_cnt <= 5'd0;
                            r_tx_bit_sel <= 3'd0;  					
                        end    
                    end
    				else ;
    
    				if(r_data_cnt == r_tx_data_num - 16'd2)
    					r_tx_req <= 1'b0; 
    				else ;
    
                end  
                ST_CRC      : begin                          //发送CRC校验值
                    r_udp_txvld <= 1'b1;
                    r_udp_txram_rdaddr  <= 11'd0;
                    r_tx_bit_sel <= r_tx_bit_sel + 3'd1;
    				r_tx_req <= 1'b0;  
                    if(r_tx_bit_sel == 3'd0)
                        r_udp_txdata <= {~i_crc_next[0], ~i_crc_next[1], ~i_crc_next[2],~i_crc_next[3],
                                     ~i_crc_next[4], ~i_crc_next[5], ~i_crc_next[6],~i_crc_next[7]};
                    else if(r_tx_bit_sel == 3'd1)
                        r_udp_txdata <= {~i_crc_data[16], ~i_crc_data[17], ~i_crc_data[18],~i_crc_data[19],
                                     ~i_crc_data[20], ~i_crc_data[21], ~i_crc_data[22],~i_crc_data[23]};
                    else if(r_tx_bit_sel == 3'd2) begin
                        r_udp_txdata <= {~i_crc_data[8], ~i_crc_data[9], ~i_crc_data[10],~i_crc_data[11],
                                     ~i_crc_data[12], ~i_crc_data[13], ~i_crc_data[14],~i_crc_data[15]};                              
                    end
                    else if(r_tx_bit_sel == 3'd3) begin
                        r_udp_txdata <= {~i_crc_data[0], ~i_crc_data[1], ~i_crc_data[2],~i_crc_data[3],
                                     ~i_crc_data[4], ~i_crc_data[5], ~i_crc_data[6],~i_crc_data[7]};  
                        r_tx_done_t <= 1'b1;
                        r_skip_en <= 1'b1;
                    end 
    				else ;
                end
                ST_TX_DONE: begin
                    r_skip_en <= 1'b1; 
                    r_udpcom_busy <= 1'b0;
                end
                default :;  
            endcase                                             
        end
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
    assign o_udpcom_busy        = r_udpcom_busy;
    assign o_tx_done            = r_tx_done;
    assign o_tx_req             = r_tx_req;
    assign o_udp_txram_rdaddr   = r_udp_txram_rdaddr;
    assign o_udp_txvld          = r_udp_txvld;
    assign o_udp_txdata         = r_udp_txdata;
    assign o_crc_en             = r_crc_en;
    assign o_crc_clr            = r_crc_clr;
endmodule

