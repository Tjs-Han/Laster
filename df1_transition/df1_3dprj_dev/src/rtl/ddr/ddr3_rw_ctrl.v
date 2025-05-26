//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: ddr3_rw_ctrl
// Date Created 	: 2024/8/27 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
// File description	:ddr3_rw_ctrl module
//				
//--------------------------------------------------------------------------------------------------
// Revision History :			
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module ddr3_rw_ctrl 
#(  
    parameter ARB_DW        = 96,
    parameter ST_WIDTH      = 8,
    parameter CMD_WIDTH     = 4,
    parameter DDR_DW        = 64,
    parameter DDR_AW        = 27,
    parameter DDR_BLW       = 5,
    parameter DM_WIDTH      = 8
)
(
    //----------------------------------------------------------------------------------------------
    // system siganl
    //----------------------------------------------------------------------------------------------
    input                       i_ddr_sclk,
    input                       i_rst_n,

    output                      o_arbfifo_rden,
    input  [ARB_DW-1:0]         i_arbfifo_rddata,
    input                       i_arbfifo_empty,
    output [CMD_WIDTH-1:0]      o_req_type,

    input                       i_init_done,
    input                       i_cmd_rdy,
    input                       i_datain_rdy,
    input                       i_rt_err,
    input                       i_wl_err,
    input                       i_rdata_valid,
    output [CMD_WIDTH-1:0]      o_cmd,
    output [DDR_AW-1:0]         o_addr,
    output [DDR_BLW-1:0]        o_cmd_burst_cnt,
    output                      o_cmd_valid,
    output                      o_ofly_burst_len,
    output [DDR_DW-1:0]         o_ddr3_wdata,
    output [DM_WIDTH-1:0]       o_data_mask
);
    //----------------------------------------------------------------------------------------------
    // reg and wire define 
    //----------------------------------------------------------------------------------------------
    reg  [ST_WIDTH-1:0]         r_curr_state;
    reg  [ST_WIDTH-1:0]         r_next_state;
    reg                         r_arbfifo_rden;
    reg  [CMD_WIDTH-1:0]        r_req_type;
    reg  [CMD_WIDTH-1:0]        r_delay_cnt;
    reg  [CMD_WIDTH-1:0]        r_cmd;
    reg  [DDR_AW-1:0]           r_addr;
    reg  [DDR_AW-1:0]           r_wddr_addr;
    reg  [DDR_AW-1:0]           r_rddr_addr;
    reg  [DDR_BLW-1:0]          r_cmd_burst_cnt;
    reg                         r_cmd_valid;
    reg                         r_ofly_burst_len;
    reg  [DDR_DW-1:0]           r_ddr3_wdata;
    reg  [DM_WIDTH-1:0]         r_data_mask;
    wire                        w_cmd_gone;
    //----------------------------------------------------------------------------------------------
    // localparam define 
    //----------------------------------------------------------------------------------------------
    localparam READ_CMD         = 4'h1;
    localparam WRITE_CMD        = 4'h2;
    localparam WRITEA_CMD       = 4'h4;
    localparam PDOWN_ENT_CMD    = 4'h5;
    localparam LOAD_MR_CMD      = 4'h6;
    localparam SEL_REF_ENT_CMD  = 4'h8;
    localparam SEL_REF_EXIT_CMD = 4'h9;
    localparam PDOWN_EXIT_CMD   = 4'hB;
    localparam ZQ_LNG_CMD       = 4'hC;
    localparam ZQ_SHRT_CMD      = 4'hD;

    localparam CMD_BURST_NUM    = 5'd1;
    // localparam MR0_DATA         = 16'h1410; //BL8
    // localparam MR1_DATA         = 16'h0004;
    // localparam MR2_DATA         = 16'h0200;
    // localparam MR3_DATA         = 16'h0000;
    // localparam MR0_DATA         = 16'b0001_0100_0001_0000; //BL8
    localparam MR0_DATA         = 16'b0001_0100_0001_0001; //BC4
    localparam MR1_DATA         = 16'b0000_0000_0000_0100;
    localparam MR2_DATA         = 16'b0000_0010_0000_0000;
    localparam MR3_DATA         = 16'b0000_0000_0000_0000;

    localparam ST_IDLE          = 8'd0;
    localparam ST_CFG_MR0       = 8'd1;
    localparam ST_CFG_MR1       = 8'd2;
    localparam ST_CFG_MR2       = 8'd3;
    localparam ST_CFG_MR3       = 8'd4;
    localparam ST_READY         = 8'd5;
    localparam ST_WAIT_FIFO     = 8'd6;
    localparam ST_RDFIFO        = 8'd7;
	localparam ST_WDDR  	    = 8'd8;
    localparam ST_WAIT_RDY      = 8'd9;
    localparam ST_WAIT_WRDONE   = 8'd10;
	localparam ST_RDDR 	        = 8'd11;
    localparam ST_WAIT_VALID    = 8'd12;
    localparam ST_WAIT_RDONE    = 8'd13;
	localparam ST_DONE   	    = 8'd14;
    //--------------------------------------------------------------------------------------------------
	// Three-stage state machine
	//--------------------------------------------------------------------------------------------------
	always @(posedge i_ddr_sclk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_curr_state <= ST_IDLE;
		else 
            r_curr_state <= r_next_state;
    end

    always@(*) begin
        case(r_curr_state)
            ST_IDLE: begin
                if(i_init_done)
                    r_next_state = ST_CFG_MR0;
                else
                    r_next_state = ST_IDLE;
            end
            ST_CFG_MR0: begin
                if(w_cmd_gone)
                    r_next_state = ST_CFG_MR1;
                else
                    r_next_state = ST_CFG_MR0;  
            end
            ST_CFG_MR1: begin
                if(w_cmd_gone)
                    r_next_state = ST_CFG_MR2;
                else
                    r_next_state = ST_CFG_MR1;  
            end
            ST_CFG_MR2: begin
                if(w_cmd_gone)
                    r_next_state = ST_CFG_MR3;
                else
                    r_next_state = ST_CFG_MR2;  
            end
            ST_CFG_MR3: begin
                if(w_cmd_gone)
                    r_next_state = ST_READY;
                else
                    r_next_state = ST_CFG_MR3;  
            end
            ST_READY: begin
                if(~i_arbfifo_empty)
                    r_next_state = ST_WAIT_FIFO;
                else
                    r_next_state = ST_READY;
            end
            ST_WAIT_FIFO: begin
                if(r_delay_cnt  >= 4'd2)
                    r_next_state = ST_RDFIFO;
                else
                    r_next_state = ST_WAIT_FIFO;
            end
            ST_RDFIFO: begin
                if(i_arbfifo_rddata[ARB_DW-1])
                    r_next_state = ST_RDDR;
                else
                    r_next_state = ST_WDDR;
            end
			ST_WDDR: begin
                if(w_cmd_gone)
                    r_next_state = ST_WAIT_RDY;
                    // r_next_state = ST_DONE;
                else
                    r_next_state = ST_WDDR;  
            end
            ST_WAIT_RDY: begin
                if(i_datain_rdy)
                    r_next_state = ST_WAIT_WRDONE;
                else
                    r_next_state = ST_WAIT_RDY;  
            end
            ST_WAIT_WRDONE: begin
                if(~i_datain_rdy)
                    r_next_state = ST_DONE;
                else
                    r_next_state = ST_WAIT_WRDONE;  
            end
            ST_RDDR: begin
                if(w_cmd_gone)
                    r_next_state = ST_WAIT_VALID;
                    // r_next_state = ST_DONE;
                else
                    r_next_state = ST_RDDR;
            end
            ST_WAIT_VALID: begin
                if(i_rdata_valid)
                    r_next_state = ST_WAIT_RDONE; 
                else
                    r_next_state = ST_WAIT_VALID;
            end
            ST_WAIT_RDONE: begin
                if(~i_rdata_valid)
                    r_next_state = ST_DONE; 
                else
                    r_next_state = ST_WAIT_RDONE;
            end
            ST_DONE: r_next_state = ST_READY;
            default: r_next_state = ST_IDLE;
        endcase
    end
	
	
    
    always @(posedge i_ddr_sclk or negedge i_rst_n) begin
        if (i_rst_n == 1'b0) begin
            r_cmd           <= {CMD_WIDTH{1'b0}};
            r_addr          <= {DDR_AW{1'b0}};
            r_cmd_valid     <= 1'b0;
            r_arbfifo_rden  <= 1'b0;
            r_delay_cnt     <= {CMD_WIDTH{1'b0}};
            r_req_type      <= {CMD_WIDTH{1'b0}};
        end else begin
            case (r_curr_state)
                ST_IDLE: begin
                    r_req_type      <= {CMD_WIDTH{1'b0}};
                    r_arbfifo_rden  <= 1'b0;
                    r_cmd           <= {CMD_WIDTH{1'b0}};
                    r_addr          <= {DDR_AW{1'b0}};
                    r_cmd_valid     <= 1'b0;
                end
                ST_CFG_MR0: begin
                    r_cmd       <= LOAD_MR_CMD;
                    r_addr      <= {{DDR_AW-18{1'b0}}, 2'b00, MR0_DATA};
                    r_cmd_valid <= 1'b1;
                    if(w_cmd_gone)
                        r_cmd_valid <= 1'b0;
                end
                ST_CFG_MR1: begin
                    r_cmd       <= LOAD_MR_CMD;
                    r_addr      <= {{DDR_AW-18{1'b0}}, 2'b01, MR1_DATA};
                    r_cmd_valid <= 1'b1;
                    if(w_cmd_gone)
                        r_cmd_valid <= 1'b0;
                end
                ST_CFG_MR2: begin
                    r_cmd       <= LOAD_MR_CMD;
                    r_addr      <= {{DDR_AW-18{1'b0}}, 2'b10, MR2_DATA};
                    r_cmd_valid <= 1'b1;
                    if(w_cmd_gone)
                        r_cmd_valid <= 1'b0;
                end
                ST_CFG_MR3: begin
                    r_cmd       <= LOAD_MR_CMD;
                    r_addr      <= {{DDR_AW-18{1'b0}}, 2'b11, MR3_DATA};
                    r_cmd_valid <= 1'b1;
                    if(w_cmd_gone)
                        r_cmd_valid <= 1'b0;
                end
                ST_READY: begin
                    r_req_type  <= {CMD_WIDTH{1'b0}};
                    r_addr      <= {DDR_AW{1'b0}};
                    r_cmd_valid <= 1'b0;
                    r_delay_cnt <= {CMD_WIDTH{1'b0}};
                    if(~i_arbfifo_empty)
                        r_arbfifo_rden  <= 1'b1;
                    else
                        r_arbfifo_rden  <= 1'b0;
                end
                ST_WAIT_FIFO: begin
                    r_arbfifo_rden  <= 1'b0;
                    if(r_delay_cnt >= 4'd2)
                        r_delay_cnt <= {CMD_WIDTH{1'b0}};
                    else
                        r_delay_cnt <= r_delay_cnt + 1'b1;
                end
                ST_RDFIFO: begin
                    r_req_type  <= i_arbfifo_rddata[94:91];
                end
                ST_WDDR: begin
                    r_cmd       <= WRITE_CMD;
                    r_addr      <= i_arbfifo_rddata[90:64];
                    r_cmd_valid <= 1'b1;
                    if(w_cmd_gone)
                        r_cmd_valid <= 1'b0;
                end
                ST_WAIT_RDY: begin
                    r_ddr3_wdata    <= i_arbfifo_rddata[63:0];
                end
                ST_RDDR: begin
                    r_cmd       <= READ_CMD;
                    r_addr      <= i_arbfifo_rddata[90:64];
                    r_cmd_valid <= 1'b1;
                    if(w_cmd_gone)
                        r_cmd_valid <= 1'b0;
                end
                ST_DONE: begin
                    r_arbfifo_rden  <= 1'b0;
                    r_cmd_valid     <= 1'b0;
                end
                default: r_arbfifo_rden  <= 1'b0;
            endcase
        end
    end
   assign w_cmd_gone = i_cmd_rdy && r_cmd_valid;
    //----------------------------------------------------------------------------------------------
    // write ddr data
    // Write data insertion timing
    // with WrRqDDelay_1 defined: 1 clock delay. Otherwise, two clocks.
    //----------------------------------------------------------------------------------------------

    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_cmd            = r_cmd;
    assign o_addr           = r_addr;
    assign o_cmd_burst_cnt  = CMD_BURST_NUM;
    assign o_cmd_valid      = r_cmd_valid;
    assign o_ofly_burst_len = 1'b0;
    assign o_ddr3_wdata     = r_ddr3_wdata;
    assign o_data_mask      = 8'h0;
    assign o_arbfifo_rden   = r_arbfifo_rden;
    assign o_req_type       = r_req_type;
endmodule