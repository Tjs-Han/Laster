// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: icmp_tx
// Date Created     : 2024/10/08
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:icmp_tx
// icmp send frame format
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module icmp_tx
#(
    parameter BOARD_MAC = 48'h00_11_22_33_44_55,  
    parameter BOARD_IP  = {8'd192,8'd168,8'd1,8'd10},
    parameter DES_MAC   = 48'hff_ff_ff_ff_ff_ff,
    parameter DES_IP    = {8'd192,8'd168,8'd1,8'd102}
)
(    
    input                           i_clk,
    input                           i_rst_n,

    input  [31:0]                   i_reply_checksum,
    input  [15:0]                   i_icmp_id,
    input  [15:0]                   i_icmp_seq,
    input                           i_start_txen,
    input  [ 7:0]                   i_tx_data,
    input  [15:0]                   i_tx_byte_num,
    input  [47:0]                   i_lidar_mac,
    input  [31:0]                   i_lidar_ip,
    input  [47:0]                   i_des_mac,
    input  [31:0]                   i_des_ip,
    input  [31:0]                   i_crc_data,
    input  [7:0]                    i_crc_next,

    output                          o_tx_done,
    output                          o_tx_req,
    output                          o_icmp_txvld,
    output [7:0]                    o_icmp_txdata,
    output                          o_crc_en,
    output                          o_crc_clr
    );
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	 
    //state
    localparam ST_IDLE              = 8'b0000_0001; //Initial state, waiting to start sending signals
    localparam ST_HEAD_CHECKSUM     = 8'b0000_0010; //IP header checksum
    localparam ST_ICMP_CHECKSUM     = 8'b0000_0100; //ICMP header + data calibration
    localparam ST_PREAMBLE          = 8'b0000_1000; //send preamble and sfd
    localparam ST_ETH_HEAD          = 8'b0001_0000; //The Ethernet frame header is send
    localparam ST_IP_HEAD           = 8'b0010_0000; //Send the IP header +ICMP header
    localparam ST_ICMP_DATA         = 8'b0100_0000; //send icmp data
    localparam ST_CRC               = 8'b1000_0000; //send crc check data
    //以太网类型定义
    localparam ETH_TYPE             = 16'h0800;  //Ethernet protocol type IP
    localparam ICMP_TYPE            = 8'h01;     //ICMP protocol types
    //------------------------------------------------
	/*	
        The minimum Ethernet data contains 46 bytes, 
        the IP header contains 20 bytes and the ICMP header contains 8 bytes 
        So the data must be at least 46-20-8=18 bytes
    */
    //-----------------------------------------------
    localparam MIN_DATA_NUM         = 16'd18;
    //ICMP报文类型:回显应答
    localparam ECHO_REPLY           = 8'h00;
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    //reg define
    reg  [7:0]                  r_cur_state;
    reg  [7:0]                  r_next_state;                                
    reg  [7:0]                  r_preamble[7:0];
    reg  [7:0]                  r_eth_head[13:0];
    reg  [31:0]                 r_ip_head[6:0]; //IP header +ICMP header                            
    reg                         r0_start_en;
    reg                         r1_start_en;
    reg                         r2_start_en;
    reg  [15:0]                 r_txdata_num; //The number of valid data bytes sent
    reg  [15:0]                 r_total_num;
    reg                         r_trig_txen;
    reg                         r_skip_en;
    reg  [7:0]                  r_cnt;
    reg  [31:0]                 r_check_buffer;//IP header checksum
    reg  [31:0]                 r_check_buffer_icmp;
    reg  [1:0]                  r_txbit_sel;
    reg  [15:0]                 r_data_cnt;
    reg                         r_tx_done_t;
    reg  [4:0]                  r_real_add_cnt; //Actual number of extra bytes of Ethernet data

    reg                         r_tx_done; 
    reg                         r_tx_req;
    reg                         r_icmp_txvld;
    reg  [7:0]                  r_icmp_txdata;
    reg                         r_crc_en;
    reg                         r_crc_clr;

    //wire define                       
    wire                        w_pos_start_en;//开始发送数据上升沿
    wire [15:0]                 w_real_txdata_num;//实际发送的字节数(以太网最少字节要求)
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    assign  w_pos_start_en = (~r2_start_en) & r1_start_en;
    assign  w_real_txdata_num = (r_txdata_num >= MIN_DATA_NUM)
                               ? r_txdata_num : MIN_DATA_NUM;

    //采tx_start_en的上升沿
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r0_start_en <= 1'b0;
            r1_start_en <= 1'b0;
    		r2_start_en <= 1'b0;
        end    
        else begin
            r0_start_en <= i_start_txen;
            r1_start_en <= r0_start_en;
    		r2_start_en <= r1_start_en;
        end
    end 

    ////寄存数据有效字节
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_txdata_num <= 16'd0;
            r_total_num <= 16'd0;
        end
        else begin
            if(w_pos_start_en && r_cur_state==ST_IDLE) begin
                //数据长度
                r_txdata_num <= i_tx_byte_num;
                //IP长度：有效数据+IP首部长度(20bytes)+ICMP首部长度(8bytes)
                r_total_num <= i_tx_byte_num + 16'd28;
            end  
    		else;
        end
    end

    //触发发送信号
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) 
            r_trig_txen <= 1'b0;
        else
            r_trig_txen <= w_pos_start_en;

    end

    //--------------------------------------------------------------------------------------------------
	// Three-stage state machine
	//--------------------------------------------------------------------------------------------------
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)
            r_cur_state <= ST_IDLE;
        else
            r_cur_state <= r_next_state;
    end

    always @(*) begin
        r_next_state = ST_IDLE;
        case(r_cur_state)
            ST_IDLE     : begin                               //等待发送数据
                if(r_skip_en)
                    r_next_state = ST_HEAD_CHECKSUM;
                else
                    r_next_state = ST_IDLE;
            end  
            ST_HEAD_CHECKSUM: begin                               //IP首部校验
                if(r_skip_en)
                    r_next_state = ST_ICMP_CHECKSUM;
                else
                    r_next_state = ST_HEAD_CHECKSUM;
            end  
            ST_ICMP_CHECKSUM: begin                              //ICMP首部校验
                if(r_skip_en)
                    r_next_state = ST_PREAMBLE;
                else
                    r_next_state = ST_ICMP_CHECKSUM;
            end  
            ST_PREAMBLE : begin                               //发送前导码+帧起始界定符
                if(r_skip_en)
                    r_next_state = ST_ETH_HEAD;
                else
                    r_next_state = ST_PREAMBLE;
            end
            ST_ETH_HEAD : begin                               //发送以太网首部
                if(r_skip_en)
                    r_next_state = ST_IP_HEAD;
                else
                    r_next_state = ST_ETH_HEAD;
            end              
            ST_IP_HEAD : begin                                //发送IP首部+icmp首部
                if(r_skip_en)
                    r_next_state = ST_ICMP_DATA;
                else
                    r_next_state = ST_IP_HEAD;
            end
            ST_ICMP_DATA : begin                                //发送数据
                if(r_skip_en)
                    r_next_state = ST_CRC;
                else
                    r_next_state = ST_ICMP_DATA;
            end
            ST_CRC: begin                                     //发送CRC校验值
                if(r_skip_en)
                    r_next_state = ST_IDLE;
                else
                    r_next_state = ST_CRC;
            end
            default : r_next_state = ST_IDLE;
        endcase
    end

    //发送数据
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_skip_en           <= 1'b0; 
            r_cnt               <= 8'd0;
            r_check_buffer      <= 32'd0;
            r_check_buffer_icmp <= 32'd0;
            r_ip_head[1][31:16] <= 16'd0;
            r_txbit_sel         <= 2'b0;
            r_crc_en            <= 1'b0;
            r_icmp_txvld        <= 1'b0;
            r_icmp_txdata       <= 8'd0;
            r_tx_req            <= 1'b0;
            r_tx_done_t         <= 1'b0; 
            r_data_cnt          <= 16'd0;
            r_real_add_cnt      <= 5'd0;
            //初始化数组    
            //前导码 7个8'h55 + 1个8'hd5
            r_preamble[0]       <= 8'h55;
            r_preamble[1]       <= 8'h55;
            r_preamble[2]       <= 8'h55;
            r_preamble[3]       <= 8'h55;
            r_preamble[4]       <= 8'h55;
            r_preamble[5]       <= 8'h55;
            r_preamble[6]       <= 8'h55;
            r_preamble[7]       <= 8'hd5;
            //目的MAC地址
            r_eth_head[0]       <= DES_MAC[47:40];
            r_eth_head[1]       <= DES_MAC[39:32];
            r_eth_head[2]       <= DES_MAC[31:24];
            r_eth_head[3]       <= DES_MAC[23:16];
            r_eth_head[4]       <= DES_MAC[15:8];
            r_eth_head[5]       <= DES_MAC[7:0];
            //源MAC地址
            r_eth_head[6]       <= BOARD_MAC[47:40];
            r_eth_head[7]       <= BOARD_MAC[39:32];
            r_eth_head[8]       <= BOARD_MAC[31:24];
            r_eth_head[9]       <= BOARD_MAC[23:16];
            r_eth_head[10]      <= BOARD_MAC[15:8];
            r_eth_head[11]      <= BOARD_MAC[7:0];
            //以太网类型
            r_eth_head[12]      <= ETH_TYPE[15:8];
            r_eth_head[13]      <= ETH_TYPE[7:0];
        end
        else begin
            r_skip_en <= 1'b0;
            r_crc_en <= 1'b0;
            r_icmp_txvld <= 1'b0;
            r_tx_done_t <= 1'b0;
            case(r_next_state)
                ST_IDLE     : begin
                    if(r_trig_txen) begin
                        r_skip_en <= 1'b1; 
                        //版本号：4 首部长度：5(单位:32bit,20byte/4=5)
                        r_ip_head[0] <= {8'h45,8'h00,r_total_num};
                        //16位标识，每次发送累加1      
                        r_ip_head[1][31:16] <= r_ip_head[1][31:16] + 1'b1;
                        //bit[15:13]: 010表示不分片
                        r_ip_head[1][15:0] <= 16'h4000;
                        //8'h80：表示生存时间
                        //8'd01：1代表ICMP，2代表IGMP，6代表TCP，17代表UDP
                        r_ip_head[2] <= {8'h80,8'd01,16'h0000};
                        //源IP地址               
                        r_ip_head[3] <= i_lidar_ip;
                        //目的IP地址    
                        if(i_des_ip != 32'd0)
                            r_ip_head[4] <= i_des_ip;
                        else
                            r_ip_head[4] <= DES_IP;
                        // 8位icmp TYPE ，8位 icmp CODE 
                        r_ip_head[5][31:16] <= {ECHO_REPLY,8'h00};
                        //16位identifier 16位sequence
                        r_ip_head[6] <= {i_icmp_id,i_icmp_seq};
                        //更新MAC地址
    
                        if(i_des_mac != 48'b0) begin
                            //目的MAC地址
                            r_eth_head[0] <= i_des_mac[47:40];
                            r_eth_head[1] <= i_des_mac[39:32];
                            r_eth_head[2] <= i_des_mac[31:24];
                            r_eth_head[3] <= i_des_mac[23:16];
                            r_eth_head[4] <= i_des_mac[15:8];
                            r_eth_head[5] <= i_des_mac[7:0];
                        end else;
                        r_eth_head[6] <= i_lidar_mac[47:40];
                        r_eth_head[7] <= i_lidar_mac[39:32];
                        r_eth_head[8] <= i_lidar_mac[31:24];
                        r_eth_head[9] <= i_lidar_mac[23:16];
                        r_eth_head[10] <= i_lidar_mac[15:8];
                        r_eth_head[11] <= i_lidar_mac[7:0];
                    end
    				else;
                end
                ST_HEAD_CHECKSUM: begin                           //IP首部校验
                    r_cnt <= r_cnt + 1'b1;
                    if(r_cnt == 8'd0) begin
                        r_check_buffer <= r_ip_head[0][31:16] + r_ip_head[0][15:0]
                                        + r_ip_head[1][31:16] + r_ip_head[1][15:0]
                                        + r_ip_head[2][31:16] + r_ip_head[2][15:0]
                                        + r_ip_head[3][31:16] + r_ip_head[3][15:0]
                                        + r_ip_head[4][31:16] + r_ip_head[4][15:0];
                    end
                    else if(r_cnt == 8'd1)                      //可能出现进位,累加一次
                        r_check_buffer <= r_check_buffer[31:16] + r_check_buffer[15:0];
                    else if(r_cnt == 8'd2) begin                //可能再次出现进位,累加一次
                        r_check_buffer <= r_check_buffer[31:16] + r_check_buffer[15:0];
                    end                             
                    else if(r_cnt == 8'd3) begin                //按位取反 
                        r_skip_en <= 1'b1;
                        r_cnt <= 8'd0;            
                        r_ip_head[2][15:0] <= ~r_check_buffer[15:0];
                    end 
    				else;
                end
                ST_ICMP_CHECKSUM: begin                           //ICMP首部+数据校验
                    r_cnt <= r_cnt + 1'b1;
                    if(r_cnt == 8'd0) begin
                        r_check_buffer_icmp <= r_ip_head[5][31:16]
                                        + r_ip_head[6][31:16] + r_ip_head[6][15:0]
                                        + i_reply_checksum;
                    end
                    else if(r_cnt == 8'd1)                      //可能出现进位,累加一次
                        r_check_buffer_icmp <= r_check_buffer_icmp[31:16] + r_check_buffer_icmp[15:0];
                    else if(r_cnt == 8'd2) begin                //可能再次出现进位,累加一次
                        r_check_buffer_icmp <= r_check_buffer_icmp[31:16] + r_check_buffer_icmp[15:0];
                    end                             
                    else if(r_cnt == 8'd3) begin                //按位取反
                        r_skip_en <= 1'b1;
                        r_cnt <= 8'd0;
                        // ICMP:16位校验和
                        r_ip_head[5][15:0] <= ~r_check_buffer_icmp[15:0];
                    end
    				else;
                end
                ST_PREAMBLE : begin                     //发送前导码+帧起始界定符
                    r_icmp_txvld <= 1'b1;
                    r_icmp_txdata <= r_preamble[r_cnt];
                    if(r_cnt == 8'd7) begin
                        r_skip_en <= 1'b1;
                        r_cnt <= 8'd0;
                    end
                    else
                        r_cnt <= r_cnt + 1'b1;
                end
                ST_ETH_HEAD : begin                      //发送以太网首部
                    r_icmp_txvld <= 1'b1;
                    r_crc_en <= 1'b1;
                    r_icmp_txdata <= r_eth_head[r_cnt];
                    if (r_cnt == 8'd13) begin
                        r_skip_en <= 1'b1;
                        r_cnt <= 8'd0;
                    end
                    else
                        r_cnt <= r_cnt + 5'd1;
                end
                ST_IP_HEAD  : begin                        //发送IP首部
                    r_crc_en <= 1'b1;
                    r_icmp_txvld <= 1'b1;
                    r_txbit_sel <= r_txbit_sel + 2'd1;
                    if(r_txbit_sel == 3'd0)
                        r_icmp_txdata <= r_ip_head[r_cnt][31:24];
                    else if(r_txbit_sel == 3'd1)
                        r_icmp_txdata <= r_ip_head[r_cnt][23:16];
                    else if(r_txbit_sel == 3'd2) begin
                        r_icmp_txdata <= r_ip_head[r_cnt][15:8];
                        if(r_cnt == 8'd6) begin
                            //提前读请求数据，等待数据有效时发送
                            r_tx_req <= 1'b1;
                        end
                    end 
                    else if(r_txbit_sel == 3'd3) begin
                        r_icmp_txdata <= r_ip_head[r_cnt][7:0];
                        if(r_cnt == 8'd6) begin
                            r_skip_en <= 1'b1;
                            r_cnt <= 8'd0;
                        end else
                            r_cnt <= r_cnt + 1'b1;
                    end
    				else;
                end  
                ST_ICMP_DATA  : begin                           //发送数据
                    r_crc_en <= 1'b1;
                    r_icmp_txvld <= 1'b1;
    				r_icmp_txdata <= i_tx_data;
                    r_txbit_sel <= 3'd0;   
                    if(r_data_cnt < r_txdata_num - 16'd1)
                        r_data_cnt <= r_data_cnt + 16'd1;  
                    else if(r_data_cnt == r_txdata_num - 16'd1)begin
                        //如果发送的有效数据少于18个字节，在后面填补充位
                        //补充的值为最后一次发送的有效数据
                        if(r_data_cnt + r_real_add_cnt < w_real_txdata_num - 16'd1)
                            r_real_add_cnt <= r_real_add_cnt + 5'd1;  
                        else begin
                            r_skip_en <= 1'b1;
                            r_data_cnt <= 16'd0;
                            r_real_add_cnt <= 5'd0;
                        end    
                    end
    				else;
    
    				if(r_data_cnt == r_txdata_num - 16'd2)
    					r_tx_req <= 1'b0; 
    				else ;
    
                end 
                ST_CRC      : begin                          //发送CRC校验值
                    r_icmp_txvld <= 1'b1;
                    r_txbit_sel <= r_txbit_sel + 3'd1;
    				r_tx_req <= 1'b0; 
                    if(r_txbit_sel == 3'd0)
                        r_icmp_txdata <= {~i_crc_next[0], ~i_crc_next[1], ~i_crc_next[2],~i_crc_next[3],
                                     ~i_crc_next[4], ~i_crc_next[5], ~i_crc_next[6],~i_crc_next[7]};
                    else if(r_txbit_sel == 3'd1)
                        r_icmp_txdata <= {~i_crc_data[16], ~i_crc_data[17], ~i_crc_data[18],~i_crc_data[19],
                                     ~i_crc_data[20], ~i_crc_data[21], ~i_crc_data[22],~i_crc_data[23]};
                    else if(r_txbit_sel == 3'd2) begin
                        r_icmp_txdata <= {~i_crc_data[8], ~i_crc_data[9], ~i_crc_data[10],~i_crc_data[11],
                                     ~i_crc_data[12], ~i_crc_data[13], ~i_crc_data[14],~i_crc_data[15]};
                    end
                    else if(r_txbit_sel == 3'd3) begin
                        r_icmp_txdata <= {~i_crc_data[0], ~i_crc_data[1], ~i_crc_data[2],~i_crc_data[3],
                                     ~i_crc_data[4], ~i_crc_data[5], ~i_crc_data[6],~i_crc_data[7]};
                        r_tx_done_t <= 1'b1;
                        r_skip_en <= 1'b1;
                    end
    				else;
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
    assign o_tx_done        = r_tx_done; 
    assign o_tx_req         = r_tx_req;
    assign o_icmp_txvld     = r_icmp_txvld;
    assign o_icmp_txdata    = r_icmp_txdata;
    assign o_crc_en         = r_crc_en;
    assign o_crc_clr        = r_crc_clr;
endmodule