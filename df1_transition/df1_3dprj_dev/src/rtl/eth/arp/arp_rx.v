// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: arp_rx
// Date Created     : 2024/10/08
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:arp_rx
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
module arp_rx
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

    output                      o_arp_rxdone,
    output                      o_arp_rxtype,
    output [47:0]               o_send_desmac,
    output [31:0]               o_send_desip,

    output                      o_rxcrc32_en,
    output [7:0]                o_rxcrc32_dataout,
    output                      o_rxcrc32_clr,
    input  [31:0]               i_rxcrc32_resdata
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	
    localparam DEST_IP  = {8'd192,8'd168,8'd1,8'd1}; 
    //state 
    localparam ST_IDLE         = 5'b0_0000;
    // localparam  ST_PREAMBLE     = 5'b0_0010;
    localparam ST_ETH_HEAD     = 5'b0_0001;
    localparam ST_ARP_DATA     = 5'b0_0010;
    localparam ST_WAIT_EOP     = 5'b0_0100;
    localparam ST_RX_END       = 5'b0_1000;

    localparam ETH_TYPE = 16'h0806;       //Ethernet protocol type ARP
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    //reg define
    reg  [4:0]      r_cur_state     = ST_IDLE;
    reg  [4:0]      r_next_state    = ST_IDLE;

    reg             r_skip_en       = 1'b0;
    reg             r_error_en      = 1'b0;
    reg  [7:0]      r_cnt           = 8'd0;
    reg  [47:0]     r_recv_desmac   = 48'h0;
    reg  [31:0]     r_recv_desip    = 32'h0;
    reg  [47:0]     r_recv_srcmac   = 32'h0;
    reg  [31:0]     r_recv_srcip    = 32'h0;
    reg  [15:0]     r_eth_type      = 16'h0;
    reg  [15:0]     r_op_data       = 16'h0;
    reg  [31:0]     r_fcs_data      = 32'h0;

    reg             r_arp_rxdone;
    reg             r_arp_rxtype;
    reg  [47:0]     r_send_desmac;
    reg  [31:0]     r_send_desip;

    reg             r_crc32_rxen;
    reg  [7:0]      r_crc32_rxdata;
    reg             r_rxcrc32_clr;
    wire [31:0]     w_rxcrc32_resdata;
    reg             r_rxcrc32_true;
    //--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------
    assign w_rxcrc32_resdata = {~i_rxcrc32_resdata[24], ~i_rxcrc32_resdata[25], ~i_rxcrc32_resdata[26], ~i_rxcrc32_resdata[27],
                                ~i_rxcrc32_resdata[28], ~i_rxcrc32_resdata[29], ~i_rxcrc32_resdata[30], ~i_rxcrc32_resdata[31],
                                ~i_rxcrc32_resdata[16], ~i_rxcrc32_resdata[17], ~i_rxcrc32_resdata[18], ~i_rxcrc32_resdata[19],
                                ~i_rxcrc32_resdata[20], ~i_rxcrc32_resdata[21], ~i_rxcrc32_resdata[22], ~i_rxcrc32_resdata[23],
                                ~i_rxcrc32_resdata[8], ~i_rxcrc32_resdata[9], ~i_rxcrc32_resdata[10], ~i_rxcrc32_resdata[11],
                                ~i_rxcrc32_resdata[12], ~i_rxcrc32_resdata[13], ~i_rxcrc32_resdata[14], ~i_rxcrc32_resdata[15],
                                ~i_rxcrc32_resdata[0], ~i_rxcrc32_resdata[1], ~i_rxcrc32_resdata[2], ~i_rxcrc32_resdata[3],
                                ~i_rxcrc32_resdata[4], ~i_rxcrc32_resdata[5], ~i_rxcrc32_resdata[6], ~i_rxcrc32_resdata[7]};
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
                    r_next_state = ST_ARP_DATA;
                else if(r_error_en)
                    r_next_state = ST_RX_END;
                else
                    r_next_state = ST_ETH_HEAD;
            end  
            ST_ARP_DATA : begin                  //receive arp data
                if(r_skip_en)
                    r_next_state = ST_WAIT_EOP;
                else if(r_error_en)
                    r_next_state = ST_RX_END;
                else
                    r_next_state = ST_ARP_DATA;
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
            r_skip_en       <= 1'b0;
            r_error_en      <= 1'b0;
            r_cnt           <= 8'd0;
            r_recv_desmac   <= 48'd0;
            r_recv_desip    <= 32'd0;
            r_recv_srcmac   <= 48'd0;
            r_recv_srcip    <= 32'd0;
            r_eth_type      <= 16'd0;
            r_op_data       <= 16'd0;
            r_arp_rxdone    <= 1'b0;
            r_arp_rxtype    <= 1'b0;
            r_send_desmac   <= 48'd0;
            r_send_desip    <= 32'd0;
            r_fcs_data      <= 32'd0;
            r_crc32_rxen    <= 1'b0;
            r_rxcrc32_clr   <= 1'b0;
            r_crc32_rxdata  <= 8'h0;
        end
        else begin
            r_skip_en       <= 1'b0;
            r_error_en      <= 1'b0;  
            r_arp_rxdone    <= 1'b0;
            r_crc32_rxen    <= 1'b0;
            r_rxcrc32_clr   <= 1'b0;
            case(r_next_state)
                ST_IDLE: begin
                    r_cnt           <= 8'd0;
                    r_recv_desmac   <= 48'h0;
                    r_recv_desip    <= 32'd0;
                    if(i_mac_packet_rxsop) begin
                        r_crc32_rxen    <= 1'b1;
                        r_crc32_rxdata  <= i_mac_packet_rxdata;
                        r_cnt <= r_cnt + 1'b1;
                        r_recv_desmac <= {r_recv_desmac[39:0], i_mac_packet_rxdata};
                    end
                end
                ST_ETH_HEAD: begin
                    if(i_mac_packet_rxvld) begin
                        r_crc32_rxen    <= 1'b1;
                        r_crc32_rxdata  <= i_mac_packet_rxdata;
                        r_cnt <= r_cnt + 1'b1;
                        if(r_cnt < 8'd6) 
                            r_recv_desmac <= {r_recv_desmac[39:0], i_mac_packet_rxdata};
                        else if(r_cnt == 8'd6) begin
                            if((r_recv_desmac != BOARD_MAC)
                                && (r_recv_desmac != 48'hff_ff_ff_ff_ff_ff))           
                                r_error_en <= 1'b1;
                        end else if(r_cnt == 8'd12)
                            r_eth_type[15:8] <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd13) begin
                            r_eth_type[7:0] <= i_mac_packet_rxdata;
                            r_cnt <= 8'd0;
                            if(r_eth_type[15:8] == ETH_TYPE[15:8]
                                && i_mac_packet_rxdata == ETH_TYPE[7:0])
                                r_skip_en <= 1'b1;  // arp req
                            else
                                r_error_en <= 1'b1; // arp ack                      
                        end        
                    end  
                end
                ST_ARP_DATA: begin
                    if(i_mac_packet_rxvld) begin
                        if(r_cnt <= 8'd45) begin
                            r_crc32_rxen    <= 1'b1;
                            r_crc32_rxdata  <= i_mac_packet_rxdata;
                        end else begin
                            r_crc32_rxen    <= 1'b0;
                            r_crc32_rxdata  <= r_crc32_rxdata;
                        end
                        r_cnt <= r_cnt + 1'b1;
                        if(r_cnt == 8'd6)
                            r_op_data[15:8] <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd7)
                            r_op_data[7:0] <= i_mac_packet_rxdata;
                        else if(r_cnt >= 8'd8 && r_cnt < 8'd14)
                            r_recv_srcmac <= {r_recv_srcmac[39:0],i_mac_packet_rxdata};
                        else if(r_cnt >= 8'd14 && r_cnt < 8'd18)
                            r_recv_srcip<= {r_recv_srcip[23:0],i_mac_packet_rxdata};
                        else if(r_cnt >= 8'd24 && r_cnt < 8'd28)
                            r_recv_desip <= {r_recv_desip[23:0],i_mac_packet_rxdata};
                        else if(r_cnt == 8'd28) begin
                            if((r_op_data == 16'd1) || (r_op_data == 16'd2)) begin
                                r_send_desmac <= r_recv_srcmac;
                                r_send_desip <= r_recv_srcip;
                                if(r_op_data == 16'h1)         
                                    r_arp_rxtype <= 1'b0;
                                else
                                    r_arp_rxtype <= 1'b1;
                            end else
                                r_error_en <= 1'b1;
                        end else if(r_cnt == 8'd46)
                            r_fcs_data[31:24]   <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd47)
                            r_fcs_data[23:16]   <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd48)
                            r_fcs_data[15:8]    <= i_mac_packet_rxdata;
                        else if(r_cnt == 8'd49) begin
                            r_fcs_data[7:0] <= i_mac_packet_rxdata;
                            r_skip_en       <= 1'b1;
                            r_arp_rxdone    <= 1'b1;
                        end
                    end                                
                end
                ST_WAIT_EOP: begin
                    r_recv_srcmac   <= 48'h0;
                    r_recv_srcip    <= 32'h0;
                    r_recv_desmac   <= 48'h0;
                    r_recv_desip    <= 32'h0;
                end
                ST_RX_END: begin
                    r_rxcrc32_clr <= 1'b1;
                    r_cnt <= 8'd0;
                    if(i_mac_packet_rxvld == 1'b0 && r_skip_en == 1'b0)// Single packet data is received
                        r_skip_en <= 1'b1; 
                end    
                default : ;
            endcase                                                        
        end
    end

    // //发送完成信号及crc值复位信号
    // always @(posedge i_clk or negedge i_rst_n) begin
    //     if(!i_rst_n)
    //         r_rxcrc32_clr <= 1'b0;
    //     else
    //         r_rxcrc32_clr <= r_arp_rxdone;
    // end

    //r_rxcrc32_true
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)
            r_rxcrc32_true <= 1'b0;
        else if(r_cur_state == ST_WAIT_EOP) begin
            if(r_fcs_data == w_rxcrc32_resdata)
                r_rxcrc32_true <= 1'b1;
            else
                r_rxcrc32_true <= 1'b0;
        end else
            r_rxcrc32_true <= 1'b0;
    end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_arp_rxdone         = r_arp_rxdone;
    assign o_arp_rxtype         = r_arp_rxtype;
    assign o_send_desmac        = r_send_desmac;
    assign o_send_desip         = r_send_desip;
    assign o_rxcrc32_en         = r_crc32_rxen;
    assign o_rxcrc32_dataout    = r_crc32_rxdata;
    assign o_rxcrc32_clr        = r_rxcrc32_clr;
endmodule