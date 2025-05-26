// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: mpt2042_dataprc
// Date Created 	: 2025/04/17
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:mpt2042_dataprc
//          mpt2042 output idle code is Comma(k28.5)
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
`timescale 1ns/1ps
module mpt2042_dataprc(
    input                       i_clk_100m,
    input                       i_rst_n,

    //ctrl signal
    input		                i_cdctdc_ready,
    input						i_tdc_strdy,
    input                       i_laser_sync,
    input [3:0]					i_tdc_chnlmask,

    //iddr data decode fifo
    input                       i_lvdsfifo_empty,
    output                      o_lvdsfifo_ren,
    input  [9:0]                i_lvdsfifo_rdata,

    //tdc data
    output                      o_data_valid,
    output [15:0]               o_rise_data,
    output [15:0]               o_fall_data
);
    //--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
    // define localparam
    localparam FIXED_DELAY_CLKNUM           = 8'd5;
    localparam INIT_DELAY_CLKNUM            = 16'd160;

    localparam ST_IDLE                      = 8'd0;
    localparam ST_READY                     = 8'd1;
    localparam ST_DELAY                     = 8'd2;
    localparam ST_TDC_CHECK                 = 8'd3;
    localparam ST_WAIT_DATA                 = 8'd4;
    localparam ST_DATAOUT_REG               = 8'd5;
    localparam ST_EDGE_DATA                 = 8'd6;
    localparam ST_WAIT_CHECK                = 8'd7;
    localparam ST_CHECK_FEND                = 8'd8;
    localparam ST_DATA_JUDGE                = 8'd9;
    localparam ST_FIFO_DISEN                = 8'd10;
    localparam ST_WAIT_CRC                  = 8'd11;
    localparam ST_CHECK_CRC                 = 8'd12;
    localparam ST_WAIT_EMPTY                = 8'd13;
    localparam ST_DONE                      = 8'd14;
    //--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    reg  [7:0]      r_curr_state            = 8'h0;
    reg  [7:0]      r_next_state            = 8'h0;
    reg  [7:0]      r_delay_clkcnt          = 8'd0;
    reg  [15:0]     r_initdly_clkcnt        = 16'd0;
    reg             r0_tdc_strdy            = 1'b0;
    reg             r1_tdc_strdy            = 1'b0;
    reg             r_measure_fail          = 1'b0;
    
    reg             r_lvdsfifo_ren          = 1'b0;
    reg  [3:0]      r_data_bytecnt          = 4'd0;
    reg             r_rise_valid            = 1'b0;
    reg             r_fall_valid            = 1'b0;
    reg             r_tdcdata_valid         = 1'b0;
    reg  [15:0]     r_rise_data             = 16'h0;
    reg  [15:0]     r_fall_data             = 16'h0;
    reg  [15:0]     r_rise_data_reg         = 16'h0;
    reg  [15:0]     r_fall_data_reg         = 16'h0;

    wire            w_lvdsfifo_ren;
    wire [7:0]      w_lvdsfifo_rdata;
    reg  [23:0]     r_chnl_data             = 24'h0;
    //--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    //r0_tdc_strdy, r1_tdc_strdy
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r0_tdc_strdy    <= 1'b0;
            r1_tdc_strdy    <= 1'b0;
        end else begin
            r0_tdc_strdy    <= i_tdc_strdy;
            r1_tdc_strdy    <= r0_tdc_strdy;
        end
    end

    //r_initdly_clkcnt
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_initdly_clkcnt    <= 16'd0;
        end else if(r_curr_state == ST_READY) begin
            r_initdly_clkcnt    <= 16'd0;
        end else begin
            r_initdly_clkcnt    <= r_initdly_clkcnt + 1'b1;
        end
    end

    //r_measure_fail
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_measure_fail  <= 1'b0;
        end else if(r1_tdc_strdy) begin
            if(r_curr_state == ST_READY)
                r_measure_fail  <= 1'b0;
            else
                r_measure_fail  <= 1'b1;
        end else begin
            r_measure_fail  <= 1'b0;
        end
    end 
    //--------------------------------------------------------------------------------------------------
	// Three-stage state machine
	//--------------------------------------------------------------------------------------------------
    //r_curr_state
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_curr_state <= ST_IDLE;
        end else begin
            r_curr_state <= r_next_state;
        end
    end

    //r_next_state trans comb logic
    always @(*) begin
        if(r_measure_fail) begin
            r_next_state    = ST_DONE;
        end else begin
            case(r_curr_state)
                ST_IDLE: begin
                    if(i_cdctdc_ready)
                        r_next_state    = ST_READY;
                    else
                        r_next_state    = ST_IDLE;
                end
                ST_READY: begin
                    if(i_laser_sync) begin
                        r_next_state    = ST_DELAY;
                    end else begin 
                        r_next_state    = ST_READY;
                    end
                end
                ST_DELAY: begin
                    if(r_delay_clkcnt >= FIXED_DELAY_CLKNUM)
                        r_next_state    = ST_TDC_CHECK;
                    else
                        r_next_state    = ST_DELAY;
                end
                ST_TDC_CHECK: begin
                    if(i_tdc_chnlmask[3:2] == 2'b11)
                        r_next_state    = ST_WAIT_DATA;
                    else
                        r_next_state    = ST_WAIT_EMPTY;
                end
                ST_WAIT_DATA: begin
                    if(r_data_bytecnt >= 4'd2) begin
                        r_next_state    = ST_DATAOUT_REG;
                    end else begin
                        r_next_state    = ST_WAIT_DATA;
                    end
                end
                ST_DATAOUT_REG: begin
                    if(r_data_bytecnt >= 4'd2) begin
                        r_next_state    = ST_EDGE_DATA;
                    end else begin
                        r_next_state    = ST_DATAOUT_REG;
                    end
                end
                ST_EDGE_DATA: r_next_state  = ST_WAIT_CHECK;
                ST_WAIT_CHECK: begin
                    if(r_data_bytecnt >= 4'd1) begin
                        r_next_state    = ST_CHECK_FEND;
                    end else begin
                        r_next_state    = ST_WAIT_CHECK;
                    end
                end
                ST_CHECK_FEND: begin
                    if(i_lvdsfifo_rdata == 10'h29c)
                        r_next_state    = ST_WAIT_DATA;
                    else
                        r_next_state    = ST_DATA_JUDGE;
                end
                ST_DATA_JUDGE: begin
                    if(r_rise_valid && r_fall_valid)
                        r_next_state    = ST_WAIT_CRC;
                    else
                        r_next_state    = ST_FIFO_DISEN;
                end
                ST_FIFO_DISEN: r_next_state    = ST_DATAOUT_REG;
                ST_WAIT_CRC: r_next_state   = ST_CHECK_CRC;
                ST_CHECK_CRC: r_next_state  = ST_WAIT_EMPTY;
                ST_WAIT_EMPTY: begin
                    if(i_tdc_strdy)
                        r_next_state  = ST_DONE;
                    else
                        r_next_state  = ST_WAIT_EMPTY;
                end
                ST_DONE: r_next_state  = ST_READY;
                default : begin
                    r_next_state = ST_IDLE;
                end
            endcase
        end
    end

    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_delay_clkcnt  <= 8'd0;
            r_lvdsfifo_ren  <= 1'b0;
            r_data_bytecnt  <= 4'd0;
            r_chnl_data     <= 24'h0;
            r_rise_valid    <= 1'b0;
            r_fall_valid    <= 1'b0;
            r_rise_data_reg <= 16'h0;
            r_fall_data_reg <= 16'h0;
            r_tdcdata_valid <= 1'b0;
            r_rise_data     <= 16'h0;
            r_fall_data     <= 16'h0;
        end else begin
            case (r_curr_state)
                ST_IDLE: begin
                    r_delay_clkcnt  <= 8'd0;
                    r_lvdsfifo_ren  <= 1'b0;
                    r_data_bytecnt  <= 4'd0;
                    r_chnl_data     <= 24'h0;
                    r_rise_valid    <= 1'b0;
                    r_fall_valid    <= 1'b0;
                    r_rise_data_reg <= 16'h0;
                    r_fall_data_reg <= 16'h0;
                    r_tdcdata_valid <= 1'b0;
                    r_rise_data     <= 16'h0;
                    r_fall_data     <= 16'h0;
                end
                ST_READY: begin
                    r_delay_clkcnt  <= 8'd0;
                    r_data_bytecnt  <= 4'd0;
                    r_chnl_data     <= 24'h0;
                    r_rise_valid    <= 1'b0;
                    r_fall_valid    <= 1'b0;
                    r_tdcdata_valid <= 1'b0;
                    r_rise_data_reg <= 16'h0;
                    r_fall_data_reg <= 16'h0;
                    if(i_lvdsfifo_empty)
                        r_lvdsfifo_ren  <= 1'b0;
                    else
                        r_lvdsfifo_ren  <= 1'b1;
                end
                ST_DELAY: begin //2
                    if(~i_lvdsfifo_empty) begin
                        r_delay_clkcnt  <= r_delay_clkcnt + 1'b1;
                    end else begin
                        r_delay_clkcnt  <= 8'd0;
                    end
                end
                ST_TDC_CHECK: begin //3
                    r_lvdsfifo_ren  <= 1'b0;
                    r_delay_clkcnt  <= 8'd0;
                end
                ST_WAIT_DATA: begin //4
                    if(~i_lvdsfifo_empty) begin
                        r_lvdsfifo_ren  <= 1'b1;
                        r_data_bytecnt  <= r_data_bytecnt + 1'b1;
                    end else begin
                        r_lvdsfifo_ren  <= 1'b0;
                    end

                    if(r_data_bytecnt >= 4'd2)
                        r_data_bytecnt  <= 4'd0;
                end
                ST_DATAOUT_REG: begin //5
                    r_lvdsfifo_ren  <= 1'b0;
                    r_data_bytecnt  <= r_data_bytecnt + 1'b1;
                    r_chnl_data     <= {r_chnl_data[15:0], i_lvdsfifo_rdata[7:0]};
                    if(r_data_bytecnt >= 4'd2)
                        r_data_bytecnt  <= 4'd0;
                end
                ST_EDGE_DATA: begin //6
                    r_lvdsfifo_ren  <= 1'b1;
                    r_data_bytecnt  <= 4'd0;
                    if(r_chnl_data[23:22] == i_tdc_chnlmask[1:0] && r_chnl_data[20] == 1'b1) begin
                        if(r_chnl_data[19] == 1'b1 && r_rise_valid == 1'b0) begin
                            r_rise_valid    <= 1'b1;
                            r_rise_data_reg <= r_chnl_data[15:0];
                        end else if(r_chnl_data[19] == 1'b0 && r_fall_valid == 1'b0) begin
                            r_fall_valid    <= 1'b1;
                            r_fall_data_reg <= r_chnl_data[15:0];
                        end
                    end
                end
                ST_WAIT_CHECK: begin //7
                    r_lvdsfifo_ren  <= 1'b0;
                    if(r_data_bytecnt >= 4'd1)
                        r_data_bytecnt  <= 4'd0;
                    else
                        r_data_bytecnt  <= r_data_bytecnt + 1'b1;
                end
                ST_CHECK_FEND: begin //8
                    r_lvdsfifo_ren      <= 1'b1;
                    if(i_lvdsfifo_rdata == 10'h29c) begin
                        r_data_bytecnt      <= 4'd0;
                    end else begin
                        r_data_bytecnt      <= 4'd1;
                        r_chnl_data[7:0]    <= i_lvdsfifo_rdata;
                    end
                end
                ST_DATA_JUDGE: begin //9
                    r_lvdsfifo_ren  <= 1'b1;
                end
                ST_FIFO_DISEN: begin //10
                    r_lvdsfifo_ren  <= 1'b0;
                end
                ST_WAIT_CRC: begin //11
                    r_lvdsfifo_ren  <= 1'b0;
                end
                ST_CHECK_CRC: begin //12
                    r_lvdsfifo_ren  <= 1'b0;
                    r_data_bytecnt  <= 4'd0;
                    if(i_lvdsfifo_rdata == 10'h3FF) begin
                        r_rise_data_reg <= 16'hFFFF;
                        r_fall_data_reg <= 16'hFFFF;
                    end
                end
                ST_WAIT_EMPTY: begin //13
                    r_lvdsfifo_ren  <= 1'b1;
                end
                ST_DONE: begin //14
                    r_lvdsfifo_ren  <= 1'b0;
                    r_data_bytecnt  <= 4'd0;
                    r_tdcdata_valid <= 1'b1;
                    r_rise_data     <= r_rise_data_reg;
                    r_fall_data     <= r_fall_data_reg;
                end
                default: begin
                    r_lvdsfifo_ren  <= 1'b0;
                    r_data_bytecnt  <= 4'd0;
                    r_chnl_data     <= 24'h0;
                    r_rise_valid    <= 1'b0;
                    r_fall_valid    <= 1'b0;
                    r_rise_data     <= 16'h0;
                    r_fall_data     <= 16'h0;
                end
            endcase
        end
    end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_lvdsfifo_ren   = r_lvdsfifo_ren;
    assign o_data_valid     = r_tdcdata_valid;
    assign o_rise_data      = r_rise_data;
    assign o_fall_data      = r_fall_data;
endmodule
