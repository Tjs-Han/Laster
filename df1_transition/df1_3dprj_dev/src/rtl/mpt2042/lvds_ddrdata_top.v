// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: lvds_ddrdata_top
// Date Created 	: 2025/04/17
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:lvds_ddrdata_top
//          mpt2042 output idle code is Comma(k28.5)
//          RD-：001111_1010
//          RD+：110000_0101
//          RD- and RD+ interleaved transmission
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
`timescale 1ns/1ps
module lvds_ddrdata_top(
    input                   i_lvds_divclk,
    input                   i_clk_100m,
    input                   i_rst_n,

    //ddr datain
    input  [3:0]            i_lvds_datain,

    //decode signal
    output                  o_decode_done,
    output                  o_cdctdc_ready,
    //fifo
    output                  o_lvdsfifo_empty,
    input                   i_lvdsfifo_ren,
    output [9:0]            o_lvdsfifo_rdata
);
    //--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
    // define localparam
    localparam CMD_COMMA_K285_RDADD         = 20'b001111_1010_110000_0101;
    localparam CMD_COMMA_K285_RDSUB         = 20'b110000_0101_001111_1010;
    localparam FRAME_DATA_NUM               = 8'd6;

    localparam ST_IDLE                      = 8'd0;
    localparam ST_READY                     = 8'd1;
    localparam ST_FRAME_DATA                = 8'd2;
    localparam ST_CRC_JUDGE                 = 8'd3;
    localparam ST_FRAME_END                 = 8'd4;
    //--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    reg  [7:0]  r_tdc_state                 = 8'h0;        
    reg         r_idlesig_k285              = 1'b0;
    reg         r_comma_syncerr             = 1'b0;
    reg  [2:0]  r_comma_clkcnt              = 3'd0;
    reg  [2:0]  r_lvds_clkcnt               = 3'd0;
    reg  [15:0] r_idle_k285_cnt             = 16'd0;
    reg  [19:0] r_lvds_datain_buf           = 20'h0;

    reg         r_decode_reset              = 1'b1;
    reg         r0_decode_en                = 1'b0;
    reg         r1_decode_en                = 1'b0;
    reg  [9:0]  r_decode_datain             = 10'h0;
    wire [7:0]  w_decode_dataout;
    wire        w_comma_k;

    reg         r_crc_rst                   = 1'b1;
    wire        w_data_valid;
    wire        w_frame_end;
    wire [7:0]  w_crc_out;

    reg         r_ready_sig                 = 1'b0;
    reg         r_cdctdc_ready              = 1'b0;
    reg  [47:0] r_frame_data                = 48'h0;
    reg         r_crc_en                    = 1'b0;
    reg  [7:0]  r_crc_datain                = 8'h0;
    reg         r_crc_clr                   = 1'b0;
    reg         r_crc_judsuc                = 1'b0;
    reg         r_lvdsfifo_wen              = 1'b0;
    reg  [9:0]  r_lvdsfifo_wdata            = 10'h0;
    //--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    //r_lvds_datain_buf
    always@(posedge i_lvds_divclk) begin
        if(!i_rst_n) begin
            r_lvds_datain_buf <= 20'h0;
        end else begin
            r_lvds_datain_buf <= {r_lvds_datain_buf[15:0], i_lvds_datain[0], i_lvds_datain[1], i_lvds_datain[2], i_lvds_datain[3]};
        end
    end
    //--------------------------------------------------
	// find idle k28.5
	//--------------------------------------------------
    //r_idlesig_k285
    always@(posedge i_lvds_divclk) begin
        if(!i_rst_n) begin
            r_idlesig_k285  <= 1'b0;
        end else if(r_lvds_datain_buf == CMD_COMMA_K285_RDADD) begin
            r_idlesig_k285  <= 1'b1;
        end else if(r_lvds_datain_buf == CMD_COMMA_K285_RDSUB) begin
            r_idlesig_k285  <= 1'b1;
        end else if(r_comma_syncerr) begin
            r_idlesig_k285  <= 1'b0;
        end
    end

    //r_comma_clkcnt
    always@(posedge i_lvds_divclk) begin
        if(!i_rst_n) begin
            r_comma_syncerr <= 1'b0;
            r_comma_clkcnt  <= 3'd0;
        end else if(r_idle_k285_cnt == 16'hffff)begin
            r_comma_syncerr <= 1'b0;
            r_comma_clkcnt  <= 3'd0;
        end else if(r_comma_clkcnt == 3'd4) begin
            r_comma_clkcnt  <= 3'd0;
            if(r_lvds_datain_buf == CMD_COMMA_K285_RDADD || r_lvds_datain_buf == CMD_COMMA_K285_RDSUB) begin
                r_comma_syncerr <= 1'b0;
            end else begin
                r_comma_syncerr <= 1'b1;
            end
        end else if(r_comma_syncerr) begin
            r_comma_syncerr <= 1'b0;
        end else if(r_idlesig_k285) begin
            r_comma_clkcnt  <= r_comma_clkcnt + 1'b1;
        end else begin
            r_comma_clkcnt  <= 3'd0;
        end
    end
    
    //r_idle_k285_cnt
    always@(posedge i_lvds_divclk) begin
        if(!i_rst_n) begin
            r_idle_k285_cnt <= 16'h0;
        end else if(r_comma_syncerr) begin
            r_idle_k285_cnt <= 16'h0;
        end else if(r_idle_k285_cnt == 16'hffff) begin
            r_idle_k285_cnt <= r_idle_k285_cnt;
        end else if(r_comma_clkcnt == 3'd4) begin
            r_idle_k285_cnt <= r_idle_k285_cnt + 1'b1;
        end
    end

    //r_lvds_clkcnt
    always@(posedge i_lvds_divclk) begin
        if(!i_rst_n) begin
            r_lvds_clkcnt   <= 3'd0;
        end else if(r_lvds_clkcnt == 3'd4) begin
            r_lvds_clkcnt   <= 3'd0;
        end else if(r_idle_k285_cnt == 16'hffff) begin
            r_lvds_clkcnt   <= r_lvds_clkcnt + 1'b1;
        end
    end

    //r0_decode_en
    always@(posedge i_lvds_divclk) begin
        if(!i_rst_n) begin
            r0_decode_en  <= 1'b0;
        end else if(r_lvds_clkcnt == 3'd4 || r_lvds_clkcnt == 3'd2) begin
            r0_decode_en  <= 1'b1;
        end else begin
            r0_decode_en  <= 1'b0;
        end
    end

    //r1_decode_en
    always@(posedge i_lvds_divclk) begin
        if(!i_rst_n) begin
            r1_decode_en  <= 1'b0;
        end else begin
            r1_decode_en  <= r0_decode_en;
        end
    end
    
    //r_decode_datain
    always@(posedge i_lvds_divclk) begin
        if(!i_rst_n) begin
            r_decode_datain <= 10'h0;
        end else if(r_lvds_clkcnt == 3'd2) begin
            r_decode_datain <= r_lvds_datain_buf[11:2];
        end else if(r_lvds_clkcnt == 3'd4) begin
            r_decode_datain <= r_lvds_datain_buf[9:0];
        end else begin
            r_decode_datain <= 10'h0;
        end
    end

    //r_ready_sig
    always@(posedge i_lvds_divclk) begin
        if(!i_rst_n) begin
            r_ready_sig  <= 1'b0;
        end else if(r_idle_k285_cnt == 16'hffff) begin
            r_ready_sig  <= 1'b1;
        end else begin
            r_ready_sig  <= 1'b0;
        end
    end

    //r_cdctdc_ready
    always@(posedge i_clk_100m) begin
        if(!i_rst_n) begin
            r_cdctdc_ready  <= 1'b0;
        end else if(r_ready_sig) begin
            r_cdctdc_ready  <= 1'b1;
        end else begin
            r_cdctdc_ready  <= 1'b0;
        end
    end

    always@(posedge i_lvds_divclk) begin
        r_decode_reset  <= ~i_rst_n;
    end
	//--------------------------------------------------------------------------------------------------
	// instance domain
	//--------------------------------------------------------------------------------------------------
    decode_8b10b u_dec_8b10b(
        .i_decode_reset ( r_decode_reset         ),
        .i_decode_clk   ( i_lvds_divclk          ),
        .i_datain_valid ( r0_decode_en           ),   
 
        .ai             ( r_decode_datain[9]     ),
        .bi             ( r_decode_datain[8]     ),
        .ci             ( r_decode_datain[7]     ),
        .di             ( r_decode_datain[6]     ),
        .ei             ( r_decode_datain[5]     ),
        .ii             ( r_decode_datain[4]     ),
        .fi             ( r_decode_datain[3]     ),
        .gi             ( r_decode_datain[2]     ),
        .hi             ( r_decode_datain[1]     ),
        .ji             ( r_decode_datain[0]     ),
    
        .AO             ( w_decode_dataout[0]    ),
        .BO             ( w_decode_dataout[1]    ),
        .CO             ( w_decode_dataout[2]    ),
        .DO             ( w_decode_dataout[3]    ),
        .EO             ( w_decode_dataout[4]    ),
        .FO             ( w_decode_dataout[5]    ),
        .GO             ( w_decode_dataout[6]    ),
        .HO             ( w_decode_dataout[7]    ),

        .o_comma_k      ( w_comma_k              )
    );
    //--------------------------------------------------
	// 8b10b decode out data 
	//--------------------------------------------------
    assign r_lvds_rst   = !i_rst_n;
    assign w_frame_end  = w_comma_k && w_decode_dataout == 8'h9c;
    assign w_data_valid = r1_decode_en && !w_comma_k;
    //r_tdc_state
    always@(posedge i_lvds_divclk) begin
        if(!i_rst_n) begin
            r_tdc_state     <= ST_IDLE;
            r_lvdsfifo_wen  <= 1'b0;
            r_lvdsfifo_wdata<= 10'h0;
            r_crc_en        <= 1'b0;
            r_crc_datain    <= 8'h0;
            r_crc_clr       <= 1'b0;
        end else begin
            case (r_tdc_state)
                ST_IDLE: begin
                    r_lvdsfifo_wen  <= 1'b0;
                    r_lvdsfifo_wdata<= 10'h0;
                    r_crc_en        <= 1'b0;
                    r_crc_clr       <= 1'b0;
                    if(r_ready_sig) begin
                        r_tdc_state <= ST_READY;
                    end else begin
                        r_tdc_state <= ST_IDLE;
                    end
                end
                ST_READY: begin
                    r_crc_clr       <= 1'b0;
                    if(w_data_valid) begin
                        r_lvdsfifo_wen  <= 1'b1;
                        r_lvdsfifo_wdata<= {2'b01, w_decode_dataout};
                        r_crc_en        <= 1'b1;
                        r_crc_datain    <= w_decode_dataout;
                        r_tdc_state     <= ST_FRAME_DATA;
                    end else begin
                        r_lvdsfifo_wen  <= 1'b0;
                        r_crc_en        <= 1'b0;
                        r_tdc_state     <= ST_READY;
                    end
                end
                ST_FRAME_DATA: begin
                    if(w_frame_end) begin
                        r_lvdsfifo_wen  <= 1'b1;
                        r_lvdsfifo_wdata<= {2'b10, w_decode_dataout};
                        r_crc_en        <= 1'b0;
                        r_tdc_state     <= ST_CRC_JUDGE;
                    end else if(w_data_valid) begin
                        r_lvdsfifo_wen  <= 1'b1;
                        r_lvdsfifo_wdata<= {2'b01, w_decode_dataout};
                        r_crc_en        <= 1'b1;
                        r_crc_datain    <= w_decode_dataout;
                    end else begin
                        r_lvdsfifo_wen  <= 1'b0;
                        r_crc_en        <= 1'b0;
                    end
                end
                ST_CRC_JUDGE: begin
                    r_crc_en    <= 1'b0;
                    r_crc_clr   <= 1'b0;
                    if(w_data_valid) begin
                        r_lvdsfifo_wen  <= 1'b1;
                        r_tdc_state <= ST_FRAME_END;
                        if(w_crc_out == w_decode_dataout) begin
                            r_lvdsfifo_wdata<= 10'h0AA;
                        end else begin
                            r_lvdsfifo_wdata<= 10'h3ff;
                        end
                    end else begin
                        r_lvdsfifo_wen  <= 1'b0;
                        r_tdc_state <= ST_CRC_JUDGE;
                    end
                end
                ST_FRAME_END: begin
                    r_lvdsfifo_wen  <= 1'b0;
                    r_crc_en        <= 1'b0;
                    r_crc_clr       <= 1'b1;
                    r_tdc_state     <= ST_READY;
                end
                default: begin
                    r_lvdsfifo_wen  <= 1'b0;
                    r_crc_en        <= 1'b0;
                    r_crc_clr       <= 1'b0;
                    r_tdc_state     <= ST_READY;
                end
            endcase
        end
    end

    always@(posedge i_lvds_divclk) begin
        r_crc_rst  <= ~i_rst_n;
    end
    crc8_d8 u_crc8_d8
    (
        .i_clk          ( i_lvds_divclk             ),
        .i_rst          ( r_crc_rst                 ),
        .i_crc_en       ( r_crc_en                  ),
        .i_data_in      ( r_crc_datain              ),
        .i_crc_clr      ( r_crc_clr                 ),
        .o_crc_out      ( w_crc_out                 )
    );

    asfifo_decode u_lasfifo_decode
    (
        .Data           ( r_lvdsfifo_wdata          ), //input [9:0]
        .WrClock        ( i_lvds_divclk             ), //input
        .RdClock        ( i_clk_100m                ), //input
        .WrEn           ( r_lvdsfifo_wen            ), //input
        .RdEn           ( i_lvdsfifo_ren            ), //input
        .Reset          ( ~i_rst_n                  ), //input
        .RPReset        ( ~i_rst_n                  ), //input
        .Q              ( o_lvdsfifo_rdata          ), //output [9:0]
        .Empty          ( o_lvdsfifo_empty          ), //output
        .Full           (                           )  //output
    );
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_decode_done    = w_frame_end;
    assign o_cdctdc_ready   = r_cdctdc_ready;
endmodule
