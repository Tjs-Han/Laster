// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: crc32_d8
// Date Created     : 2024/10/15
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:crc32_d8
// Ethernet frame data crc32 check
// The high and low bits of the input data are rearranged
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module crc32_d8(
    input                   i_clk,
    input                   i_rst_n,
    input  [7:0]            i_data,
    input                   i_crc_en,
    input                   i_crc_clr,          
    output [31:0]           o_crc_data,
    output [31:0]           o_crc_next
);

	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    reg  [31:0]  r_crc_data;
    wire [31:0]  w_crc_next;
    wire [7:0]   w_data_t;

    //To enter the 8-bit data to be verified, swap the high and low bits first
    assign w_data_t = {i_data[0],i_data[1],i_data[2],i_data[3],i_data[4],i_data[5],i_data[6],i_data[7]};

    //Generating polynomial of CRC32：G(x)= x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 
    //+ x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x^1 + 1

    assign w_crc_next[0] = r_crc_data[24] ^ r_crc_data[30] ^ w_data_t[0] ^ w_data_t[6];
    assign w_crc_next[1] = r_crc_data[24] ^ r_crc_data[25] ^ r_crc_data[30] ^ r_crc_data[31] 
                         ^ w_data_t[0] ^ w_data_t[1] ^ w_data_t[6] ^ w_data_t[7];
    assign w_crc_next[2] = r_crc_data[24] ^ r_crc_data[25] ^ r_crc_data[26] ^ r_crc_data[30] 
                         ^ r_crc_data[31] ^ w_data_t[0] ^ w_data_t[1] ^ w_data_t[2] ^ w_data_t[6] 
                         ^ w_data_t[7];
    assign w_crc_next[3] = r_crc_data[25] ^ r_crc_data[26] ^ r_crc_data[27] ^ r_crc_data[31] 
                         ^ w_data_t[1] ^ w_data_t[2] ^ w_data_t[3] ^ w_data_t[7];
    assign w_crc_next[4] = r_crc_data[24] ^ r_crc_data[26] ^ r_crc_data[27] ^ r_crc_data[28] 
                         ^ r_crc_data[30] ^ w_data_t[0] ^ w_data_t[2] ^ w_data_t[3] ^ w_data_t[4] 
                         ^ w_data_t[6];
    assign w_crc_next[5] = r_crc_data[24] ^ r_crc_data[25] ^ r_crc_data[27] ^ r_crc_data[28] 
                         ^ r_crc_data[29] ^ r_crc_data[30] ^ r_crc_data[31] ^ w_data_t[0] 
                         ^ w_data_t[1] ^ w_data_t[3] ^ w_data_t[4] ^ w_data_t[5] ^ w_data_t[6] 
                         ^ w_data_t[7];
    assign w_crc_next[6] = r_crc_data[25] ^ r_crc_data[26] ^ r_crc_data[28] ^ r_crc_data[29] 
                         ^ r_crc_data[30] ^ r_crc_data[31] ^ w_data_t[1] ^ w_data_t[2] ^ w_data_t[4] 
                         ^ w_data_t[5] ^ w_data_t[6] ^ w_data_t[7];
    assign w_crc_next[7] = r_crc_data[24] ^ r_crc_data[26] ^ r_crc_data[27] ^ r_crc_data[29] 
                         ^ r_crc_data[31] ^ w_data_t[0] ^ w_data_t[2] ^ w_data_t[3] ^ w_data_t[5] 
                         ^ w_data_t[7];
    assign w_crc_next[8] = r_crc_data[0] ^ r_crc_data[24] ^ r_crc_data[25] ^ r_crc_data[27] 
                         ^ r_crc_data[28] ^ w_data_t[0] ^ w_data_t[1] ^ w_data_t[3] ^ w_data_t[4];
    assign w_crc_next[9] = r_crc_data[1] ^ r_crc_data[25] ^ r_crc_data[26] ^ r_crc_data[28] 
                         ^ r_crc_data[29] ^ w_data_t[1] ^ w_data_t[2] ^ w_data_t[4] ^ w_data_t[5];
    assign w_crc_next[10] = r_crc_data[2] ^ r_crc_data[24] ^ r_crc_data[26] ^ r_crc_data[27] 
                         ^ r_crc_data[29] ^ w_data_t[0] ^ w_data_t[2] ^ w_data_t[3] ^ w_data_t[5];
    assign w_crc_next[11] = r_crc_data[3] ^ r_crc_data[24] ^ r_crc_data[25] ^ r_crc_data[27] 
                         ^ r_crc_data[28] ^ w_data_t[0] ^ w_data_t[1] ^ w_data_t[3] ^ w_data_t[4];
    assign w_crc_next[12] = r_crc_data[4] ^ r_crc_data[24] ^ r_crc_data[25] ^ r_crc_data[26] 
                         ^ r_crc_data[28] ^ r_crc_data[29] ^ r_crc_data[30] ^ w_data_t[0] 
                         ^ w_data_t[1] ^ w_data_t[2] ^ w_data_t[4] ^ w_data_t[5] ^ w_data_t[6];
    assign w_crc_next[13] = r_crc_data[5] ^ r_crc_data[25] ^ r_crc_data[26] ^ r_crc_data[27] 
                         ^ r_crc_data[29] ^ r_crc_data[30] ^ r_crc_data[31] ^ w_data_t[1] 
                         ^ w_data_t[2] ^ w_data_t[3] ^ w_data_t[5] ^ w_data_t[6] ^ w_data_t[7];
    assign w_crc_next[14] = r_crc_data[6] ^ r_crc_data[26] ^ r_crc_data[27] ^ r_crc_data[28] 
                         ^ r_crc_data[30] ^ r_crc_data[31] ^ w_data_t[2] ^ w_data_t[3] ^ w_data_t[4]
                         ^ w_data_t[6] ^ w_data_t[7];
    assign w_crc_next[15] =  r_crc_data[7] ^ r_crc_data[27] ^ r_crc_data[28] ^ r_crc_data[29]
                         ^ r_crc_data[31] ^ w_data_t[3] ^ w_data_t[4] ^ w_data_t[5] ^ w_data_t[7];
    assign w_crc_next[16] = r_crc_data[8] ^ r_crc_data[24] ^ r_crc_data[28] ^ r_crc_data[29] 
                         ^ w_data_t[0] ^ w_data_t[4] ^ w_data_t[5];
    assign w_crc_next[17] = r_crc_data[9] ^ r_crc_data[25] ^ r_crc_data[29] ^ r_crc_data[30] 
                         ^ w_data_t[1] ^ w_data_t[5] ^ w_data_t[6];
    assign w_crc_next[18] = r_crc_data[10] ^ r_crc_data[26] ^ r_crc_data[30] ^ r_crc_data[31] 
                         ^ w_data_t[2] ^ w_data_t[6] ^ w_data_t[7];
    assign w_crc_next[19] = r_crc_data[11] ^ r_crc_data[27] ^ r_crc_data[31] ^ w_data_t[3] ^ w_data_t[7];
    assign w_crc_next[20] = r_crc_data[12] ^ r_crc_data[28] ^ w_data_t[4];
    assign w_crc_next[21] = r_crc_data[13] ^ r_crc_data[29] ^ w_data_t[5];
    assign w_crc_next[22] = r_crc_data[14] ^ r_crc_data[24] ^ w_data_t[0];
    assign w_crc_next[23] = r_crc_data[15] ^ r_crc_data[24] ^ r_crc_data[25] ^ r_crc_data[30] 
                          ^ w_data_t[0] ^ w_data_t[1] ^ w_data_t[6];
    assign w_crc_next[24] = r_crc_data[16] ^ r_crc_data[25] ^ r_crc_data[26] ^ r_crc_data[31] 
                          ^ w_data_t[1] ^ w_data_t[2] ^ w_data_t[7];
    assign w_crc_next[25] = r_crc_data[17] ^ r_crc_data[26] ^ r_crc_data[27] ^ w_data_t[2] ^ w_data_t[3];
    assign w_crc_next[26] = r_crc_data[18] ^ r_crc_data[24] ^ r_crc_data[27] ^ r_crc_data[28] 
                          ^ r_crc_data[30] ^ w_data_t[0] ^ w_data_t[3] ^ w_data_t[4] ^ w_data_t[6];
    assign w_crc_next[27] = r_crc_data[19] ^ r_crc_data[25] ^ r_crc_data[28] ^ r_crc_data[29] 
                          ^ r_crc_data[31] ^ w_data_t[1] ^ w_data_t[4] ^ w_data_t[5] ^ w_data_t[7];
    assign w_crc_next[28] = r_crc_data[20] ^ r_crc_data[26] ^ r_crc_data[29] ^ r_crc_data[30] 
                          ^ w_data_t[2] ^ w_data_t[5] ^ w_data_t[6];
    assign w_crc_next[29] = r_crc_data[21] ^ r_crc_data[27] ^ r_crc_data[30] ^ r_crc_data[31] 
                          ^ w_data_t[3] ^ w_data_t[6] ^ w_data_t[7];
    assign w_crc_next[30] = r_crc_data[22] ^ r_crc_data[28] ^ r_crc_data[31] ^ w_data_t[4] ^ w_data_t[7];
    assign w_crc_next[31] = r_crc_data[23] ^ r_crc_data[29] ^ w_data_t[5];

    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)
            r_crc_data <= 32'hff_ff_ff_ff;
        else if(i_crc_clr)
            r_crc_data <= 32'hff_ff_ff_ff;
        else if(i_crc_en)
            r_crc_data <= w_crc_next;
    	else;
    end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_crc_data   = r_crc_data;
    assign o_crc_next   = w_crc_next;
endmodule