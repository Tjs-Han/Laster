// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: iddr_init
// Date Created 	: 2025/04/03
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:iddr_init

// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
`timescale 1ns/1ps
module iddr_init(
    input                   i_clk,
    input                   i_rst_n,

    input                   i_module_en,
    input                   i_iddr_ready,
    output                  o_iddr_synrst,
    output                  o_iddr_update,
    output                  o_iddr_alignwd
);
    //--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    reg         r_module_en         = 1'b0;
    reg         r_iddr_synrst       = 1'b1;
    reg         r_iddr_update       = 1'b0;
    reg         r_iddr_alignwd      = 1'b0;

    reg  [15:0] r_init_cnt          = 16'd0;
    reg         r_init_srvcd        = 1'b0;
    reg         r_rst_srvcd         = 1'b0;
    reg         r0_init_start_hit   = 1'b0;
    reg         r1_init_start_hit   = 1'b0;
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
        end else if(i_module_en) begin
            r_init_cnt    <=  r_init_cnt + 1;
            if (r_init_cnt[6] == 1'b1) begin    // takes the first hit
                r_rst_srvcd   <=  1'b1;
                if (!r_rst_srvcd)
                    r0_init_start_hit  <=  1'b1;
                else
                    r0_init_start_hit  <=  1'b0;
            end if (r_init_cnt[7] && r_rst_srvcd == 1'b1)  begin// takes the second hit after 200 us
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
            r_iddr_alignwd  <= 1'b0;
            r_iddr_update   <= 1'b0;
            r_iddr_synrst   <= 1'b1;
        end else if(i_module_en) begin
            if (r0_init_start_hit) begin
                r_iddr_synrst   <=  1'b0;
            end else if (r1_init_start_hit) begin
                r_iddr_update   <=  1'b1;
                r_iddr_alignwd  <=  1'b1;
            end else if (i_iddr_ready) begin
                r_iddr_update   <=  1'b0;
            end
        end else begin
            r_iddr_alignwd  <= 1'b0;
            r_iddr_update   <= 1'b0;
            r_iddr_synrst   <= 1'b1;
        end
    end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_iddr_synrst    = r_iddr_synrst;
    assign o_iddr_update    = r_iddr_update;
    assign o_iddr_alignwd   = r_iddr_alignwd;
endmodule