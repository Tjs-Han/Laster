
// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: lvds_ddrdata_sync
// Date Created 	: 2025/04/08
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:lvds_ddrdata_sync
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
`timescale 1ns/1ps
//-----------------------------------------------------------------------------
// CRC module for data[7:0] ,   crc[7:0]=1+x^1+x^2+x^8;
//-----------------------------------------------------------------------------
module crc8_d8(
	input 					i_clk,
	input 					i_rst,

	input 					i_crc_en,
    input  [7:0] 			i_data_in,
    input 					i_crc_clr,
    output [7:0] 			o_crc_out
    
    
);
    //--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
 	reg [7:0] lfsr_q,lfsr_c;

 	assign o_crc_out = lfsr_q;

 	always @(*) begin
 	  lfsr_c[0] = lfsr_q[0] ^ lfsr_q[6] ^ lfsr_q[7] ^ i_data_in[0] ^ i_data_in[6] ^ i_data_in[7];
 	  lfsr_c[1] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[6] ^ i_data_in[0] ^ i_data_in[1] ^ i_data_in[6];
 	  lfsr_c[2] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[6] ^ i_data_in[0] ^ i_data_in[1] ^ i_data_in[2] ^ i_data_in[6];
 	  lfsr_c[3] = lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[7] ^ i_data_in[1] ^ i_data_in[2] ^ i_data_in[3] ^ i_data_in[7];
 	  lfsr_c[4] = lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ i_data_in[2] ^ i_data_in[3] ^ i_data_in[4];
 	  lfsr_c[5] = lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ i_data_in[3] ^ i_data_in[4] ^ i_data_in[5];
 	  lfsr_c[6] = lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ i_data_in[4] ^ i_data_in[5] ^ i_data_in[6];
 	  lfsr_c[7] = lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ i_data_in[5] ^ i_data_in[6] ^ i_data_in[7];
 	end

 	always @(posedge i_clk or posedge i_rst) begin
 	  if(i_rst) begin
 	    lfsr_q <= {8{1'b0}};
 	  end else if(i_crc_clr) begin
		lfsr_q <= {8{1'b0}};
	  end else if(i_crc_en) begin
 	    lfsr_q <= lfsr_c;
 	  end
 	end // always
endmodule // crc