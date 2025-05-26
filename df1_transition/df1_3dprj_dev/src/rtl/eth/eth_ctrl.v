// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: eth_ctrl
// Date Created     : 2024/10/21
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:eth_ctrl
// 	                           
// -------------------------------------------------------------------------------------------------                                 
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module eth_ctrl(
    input                       i_clk,
    input                       i_rst_n,

	//arp
    output						o_arp_tx_en,
    input                      	i_arp_txsop,
    input                      	i_arp_txeop,
    input                      	i_arp_txvld,
    input  [7:0]                i_arp_txdata,
    input						i_arp_rxdone,
	input						i_arp_tx_done,

	//ICMP
   	output						o_icmp_tx_en,
    input                      	i_icmp_txsop,
    input                      	i_icmp_txeop,
    input                      	i_icmp_txvld,
    input  [7:0]                i_icmp_txdata,
    input                      	i_icmp_rxdone,
    input                      	i_icmp_txdone,
	
	//UDP
	output						o_udp_tx_en,
    input                      	i_udp_txsop,
    input                      	i_udp_txeop,
    input                      	i_udp_txvld,
    input  [7:0]                i_udp_txdata,
    input                      	i_udp_rxdone,
    input                      	i_udp_txdone,
    //GMII发送引脚                  	   
    output 						o_mac_packet_tx_sop,
    output 						o_mac_packet_tx_eop,
    output 						o_mac_packet_txvld,
    output [7:0]				o_mac_packet_txdata
    );
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
	//reg define
	reg							r_arp_tx_en;
	reg							r_icmp_tx_en;
	reg							r_udp_tx_en;

	reg [1:0]  					r_protocol_sw; 	//协议切换信号
	reg		   					r_icmp_tx_busy;	//ICMP正在发送数据标志信号	
	reg        					r_udp_tx_busy; 	//UDP正在发送数据标志信号
	reg        					r_arp_rx_flag; 	//接收到ARP请求信号的标志

	reg 						r_mac_packet_tx_sop;
    reg 						r_mac_packet_tx_eop;
	reg							r_mac_packet_txvld;
	reg  [7:0]					r_mac_packet_txdata;
	
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
	always @(posedge i_clk or negedge i_rst_n) begin
	    if(!i_rst_n) begin
	        r_protocol_sw <= 2'b0;
	        r_arp_tx_en		<= 1'b0;
			r_icmp_tx_en	<= 1'b0;
			r_udp_tx_en		<= 1'b0;
	    end else begin
			r_arp_tx_en		<= 1'b0;
			r_icmp_tx_en	<= 1'b0;
			r_udp_tx_en		<= 1'b0;
			if (i_udp_rxdone) begin
				r_udp_tx_en		<= 1'b1;
				r_protocol_sw	<= 2'b01;
			end else if(i_icmp_rxdone) begin
				r_icmp_tx_en	<= 1'b1;
	            r_protocol_sw 	<= 2'b10;
			end else if((r_arp_rx_flag && (r_udp_tx_busy == 1'b0)) || (r_arp_rx_flag && (r_icmp_tx_busy == 1'b0))) begin
	            r_protocol_sw <= 2'b00;
	            r_arp_tx_en <= 1'b1;
	        end    
			else ;
	    end        
	end

	// always @(posedge i_clk or negedge i_rst_n) begin
	//     if(!i_rst_n) begin
	//         r_protocol_sw <= 2'b0;
	//         r_arp_tx_en		<= 1'b0;
	// 		r_icmp_tx_en	<= 1'b0;
	// 		r_udp_tx_en		<= 1'b0;
	//     end else if((r_arp_rx_flag && (r_udp_tx_busy == 1'b0)) || (r_arp_rx_flag && (r_icmp_tx_busy == 1'b0))) begin
	//             r_protocol_sw <= 2'b00;
	//             r_arp_tx_en <= 1'b1;
	//         end    
	// 	else ;          
	// end

	//协议的切换
	always @(posedge i_clk or negedge i_rst_n) begin
	    if(!i_rst_n) begin
			r_mac_packet_txvld <= 1'd0;
			r_mac_packet_txdata   <= 8'd0;
		end
		else begin
			case(r_protocol_sw)
				2'b00:	begin
					r_mac_packet_txvld	<= i_arp_txvld;
					r_mac_packet_txdata	<= i_arp_txdata;
				end
				2'b01: begin
					r_mac_packet_txvld	<= i_udp_txvld;
					r_mac_packet_txdata	<= i_udp_txdata;		
				end
				2'b10: begin
					r_mac_packet_txvld	<= i_icmp_txvld;
					r_mac_packet_txdata	<= i_icmp_txdata;
				end
				default:;
			endcase
		end
	end	
	
	//控制ICMP发送忙信号
	always @(posedge i_clk or negedge i_rst_n) begin
	    if(!i_rst_n)
	        r_icmp_tx_busy <= 1'b0;
	    else if(i_icmp_rxdone)
	        r_icmp_tx_busy <= 1'b1;
	    else if(i_icmp_txdone)
	        r_icmp_tx_busy <= 1'b0;
		else ;	
	end
	
	
	//控制UDP发送忙信号
	always @(posedge i_clk or negedge i_rst_n) begin
	    if(!i_rst_n)
	        r_udp_tx_busy <= 1'b0;
	    else if(i_udp_rxdone)
	        r_udp_tx_busy <= 1'b1;
	    else if(i_udp_txdone)
	        r_udp_tx_busy <= 1'b0;
		else ;
	end
	
	//控制接收到ARP请求信号的标志
	always @(posedge i_clk or negedge i_rst_n) begin
	    if(!i_rst_n)
	        r_arp_rx_flag <= 1'b0;
	    else if(i_arp_rxdone)   
	        r_arp_rx_flag <= 1'b1;
	    else 
	        r_arp_rx_flag <= 1'b0;
	end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_arp_tx_en			= r_arp_tx_en;
    assign o_icmp_tx_en			= r_icmp_tx_en;
	assign o_udp_tx_en			= r_udp_tx_en;
    assign o_mac_packet_tx_sop	= 1'b0;
    assign o_mac_packet_tx_eop	= 1'b0;
    assign o_mac_packet_txvld	= r_mac_packet_txvld;
    assign o_mac_packet_txdata	= r_mac_packet_txdata;
endmodule