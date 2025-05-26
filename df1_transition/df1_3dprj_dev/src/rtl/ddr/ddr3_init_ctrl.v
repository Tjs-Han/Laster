//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: ddr3_init_ctrl
// Date Created 	: 2024/8/26 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
// File description	:ddr3_init_ctrl
//      DDR3 memory devices must be initialized before the memory controller can access them.
//      The memory controller startsthe memory initialization sequence when the r_init_start 
//      signal is asserted by the user interface.
//--------------------------------------------------------------------------------------------------
// Revision History :V1.0
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------	
module ddr3_init_ctrl
(
    input               i_clk,
	input               i_rst_n,

    input               i_ddr_init_done,

    output              o_mem_rst_n,
    output              o_init_start
);
    //--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    reg         r_init_start;
    reg         r_mem_rst_n;
    reg [15:0]  r_init_cnt;
    reg         r_init_srvcd;
    reg         r_rst_srvcd;
    reg         r0_init_start_hit;
    reg         r1_init_start_hit;
    //--------------------------------------------------------------------------------------------------
    // Init_start generation
    // in synthesis mode, wait for +200us for memory reset requirement
    //--------------------------------------------------------------------------------------------------
    always@(posedge i_clk or negedge i_rst_n) begin
        if (i_rst_n == 1'b0) begin
            r_init_cnt          <=  16'h0;
            r_init_srvcd        <=  1'b0;
            r_rst_srvcd         <=  1'b0; 
            r0_init_start_hit   <=  1'b0;
            r1_init_start_hit   <=  1'b0;       
        end else begin
            r_init_cnt    <=  r_init_cnt + 1;
            if (r_init_cnt[7] == 1'b1) begin    // takes the first hit
                r_rst_srvcd   <=  1'b1;
                if (!r_rst_srvcd)
                    r0_init_start_hit  <=  1'b1;
                else
                    r0_init_start_hit  <=  1'b0;
            end if (r_init_cnt[15] && r_init_cnt[13] && r_rst_srvcd == 1'b1)  begin// takes the second hit after 200 us
                r_init_srvcd  <=  1'b1;
                if (!r_init_srvcd)
                    r1_init_start_hit    <=  1'b1;
                else
                    r1_init_start_hit    <=  1'b0;
            end
        end
    end

    always @(posedge i_clk or negedge i_rst_n) begin
        if (i_rst_n == 1'b0) begin
            r_init_start      <=  1'b0;
            r_mem_rst_n   <=  1'b0;
        end else begin
            if (r0_init_start_hit) begin
                r_mem_rst_n   <=  1'b0;
            end else if (r1_init_start_hit) begin
                r_mem_rst_n   <=  1'b1;
                r_init_start      <=  1'b1;
            end else if (i_ddr_init_done) begin
                r_init_start      <=  1'b0;
            end
        end
    end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_mem_rst_n  = r_mem_rst_n;
    assign o_init_start = r_init_start;
endmodule