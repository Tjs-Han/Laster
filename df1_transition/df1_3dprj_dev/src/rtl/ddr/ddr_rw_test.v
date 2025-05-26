//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: ddr3_hmic_ctrl
// Date Created 	: 2023/12/8 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
// File description	:ddr3_hmic_ctrl module
//				1G bit ddr3 NT5CC64M16GP-DII
//--------------------------------------------------------------------------------------------------
// Revision History :			
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module ddr_rw_test
#(
    parameter USER_DW           = 16,
	parameter AXI_AW 		    = 27,
	parameter AXI_DW 		    = 32
) 
(
    input                       i_clk,
    input                       i_rst_n,    
                   
    //user          
    output                      o_wrfifo_en,
    output  [USER_DW-1:0]       o_wrfifo_data,
    output                      o_ddr_csen,
    output  [AXI_AW-1:0]        o_wrddr_addr_base,
    output                      o_ddr_rden,
    output  [AXI_AW-1:0]        o_rdddr_addr_base
);
    //----------------------------------------------------------------------------------------------
	// reg define
	//----------------------------------------------------------------------------------------------
    reg                         r_test_rst_n;
    reg [31:0]                  r_test_rst_delay;

    reg [USER_DW-1:0]           r_count;
    reg [AXI_DW-1:0]            r_delay_cnt;
    reg                         r_wrfifo_en;
    reg [USER_DW-1:0]           r_wrfifo_data;
    reg                         r_ddr_csen;
    reg [AXI_AW-1:0]            r_wrddr_addr_base;

    reg                         r_ddr_rden;
    reg [AXI_AW-1:0]            r_rdddr_addr_base;
    //----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
    localparam  MAX_DATA    = 32'd63;
    //----------------------------------------------------------------------------------------------
	// test rst signal
	//----------------------------------------------------------------------------------------------
    //r_wrfifo_en
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_test_rst_delay    <= 32'd0;
            r_test_rst_n        <= 1'b0;
        end else if(r_test_rst_delay < 32'd1000_000_000)begin
            r_test_rst_delay     <= r_test_rst_delay + 1'b1;
            r_test_rst_n <= 1'b0;
        end else begin
            r_test_rst_delay    <= r_test_rst_delay;
            r_test_rst_n        <= 1'b1;
        end
    end
    //----------------------------------------------------------------------------------------------
	// always domain
	//----------------------------------------------------------------------------------------------
    //r_wrfifo_en
    always @(posedge i_clk or negedge r_test_rst_n) begin
        if(!r_test_rst_n) begin
            r_count     <= 32'd0;
            r_wrfifo_en <= 1'b0;
        end else if(r_count <= MAX_DATA)begin
            r_count     <= r_count + 1'b1;
            r_wrfifo_en <= 1'b1;
        end else begin
            r_count     <= r_count;
            r_wrfifo_en <= 1'b0;
        end
    end

    //r_ddr_csen
    always @(posedge i_clk or negedge r_test_rst_n) begin
        if(!r_test_rst_n)
            r_ddr_csen <= 1'b0;
        else if(r_count>= 32'd64 && r_count <= MAX_DATA + 32'd128)
            r_ddr_csen <= 1'b1;
        else if(r_delay_cnt >= 32'd50_000_000)
            r_ddr_csen <= 1'b1;
        else
            r_ddr_csen <= 1'b0;
    end

    //r_delay_cnt
    always @(posedge i_clk or negedge r_test_rst_n) begin
        if(!r_test_rst_n)
            r_delay_cnt <= 32'd0;
        else if(r_count >= MAX_DATA) begin
            // if(r_delay_cnt <= 32'd150_000_000)
            if(r_delay_cnt <= 32'd15000)
                r_delay_cnt <= r_delay_cnt +  1'b1;
            else
                r_delay_cnt <= r_delay_cnt;
        end
    end

    //r_ddr_rden
    always @(posedge i_clk or negedge r_test_rst_n) begin
        if(!r_test_rst_n)
            r_ddr_rden <= 1'b0;
        else if(r_count >= MAX_DATA) begin
            if(r_delay_cnt >= 32'd400 && r_delay_cnt <= 32'd1500)
                r_ddr_rden <= 1'b1;
            else
                r_ddr_rden <= 1'b0;
        end
    end
    //----------------------------------------------------------------------------------------------
	// output assign
	//----------------------------------------------------------------------------------------------
    assign o_wrfifo_en      = r_wrfifo_en;
    assign o_wrfifo_data    = r_count;
    assign o_ddr_csen       = r_ddr_csen;
    assign o_ddr_rden       = r_ddr_rden;
    assign o_wrddr_addr_base= 32'd0;
    assign o_rdddr_addr_base= 32'd0;
endmodule