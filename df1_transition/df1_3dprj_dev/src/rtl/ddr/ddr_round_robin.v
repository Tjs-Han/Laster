//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: ddr_round_robin
// Date Created 	: 2024/11/18 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
// File description	:ddr_round_robin
//				
//--------------------------------------------------------------------------------------------------
// Revision History :V1.0
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------	
module ddr_round_robin
#(  
    parameter ARB_DW        = 96,
    parameter ST_WIDTH      = 8,
    parameter CMD_WIDTH     = 4,
    parameter DDR_DW        = 64,
    parameter DDR_AW        = 27,
    parameter DDR_BLW       = 5,
    parameter DM_WIDTH      = 8,
    parameter USER_RDW      = 16
)
(
    input					    i_clk,
    input                       i_ddr_sclk,
	input					    i_rst_n,

    // udp
    input                       i_udp2ddr_wren,
    input                       i_udp2ddr_rden,
    input  [DDR_AW-1:0]         i_udp2ddr_addr,
    input  [DDR_DW-1:0]         i_udp2ddr_data,
    output                      o_ddr2udp_valid,
    output [DDR_DW-1:0]         o_ddr2udp_data,
    // para
    input                       i_para2ddr_wren,
    input                       i_ddr2para_rden,
    input  [DDR_AW-1:0]         i_para2ddr_addr,
    input  [DDR_DW-1:0]         i_para2ddr_data,
    input                       i_ddr2para_fifo_rden,
    output                      o_ddr2para_fifo_empty,
    output [DDR_DW-1:0]         o_ddr2para_fifo_data,
    // flash
    input                       i_flash2ddr_wren,
    input                       i_ddr2flash_rden,
    input  [DDR_AW-1:0]         i_flash2ddr_addr,
    input  [DDR_DW-1:0]         i_flash2ddr_data,
    input                       i_ddr2flash_fifo_rden,
    output                      o_ddr2flash_fifo_empty,
    output [DDR_DW-1:0]         o_ddr2flash_fifo_data,
    // dist
    input                       i_dist2ddr_wren,
    input                       i_dist2ddr_rden,
    input  [DDR_AW-1:0]         i_dist2ddr_addr,
    input  [DDR_DW-1:0]         i_dist2ddr_data,
    input                       i_ddr2dist_fifo_rden,
    output                      o_ddr2dist_fifo_empty,
    output [DDR_DW-1:0]         o_ddr2dist_fifo_data,
    // ddr interface
    input  [CMD_WIDTH-1:0]      i_req_type,
    input                       i_rdata_valid,
    input  [DDR_DW-1:0]         i_ddr_rdata,
    input                       i_arbfifo_rden,
    output [ARB_DW-1:0]         o_arbfifo_rddata,
    output                      o_arbfifo_empty
);
    //----------------------------------------------------------------------------------------------
    // parameter adn localparam define 
    //----------------------------------------------------------------------------------------------
    localparam RR_NUM           = 4'd4;

    localparam REQ_TYPE1        = 4'h1;
    localparam REQ_TYPE2        = 4'h2;
    localparam REQ_TYPE3        = 4'h3;
    localparam REQ_TYPE4        = 4'h4;

    localparam ST_SEL_IDLE      = 8'b0000_0000;
    localparam ST_SEL_MSG0      = 8'b0000_0001;
    localparam ST_SEL_MSG1      = 8'b0000_0010;
    localparam ST_SEL_MSG2      = 8'b0000_0100;
    localparam ST_SEL_MSG3      = 8'b0000_1000;
    //----------------------------------------------------------------------------------------------
    // reg and wire define 
    //----------------------------------------------------------------------------------------------
    // sel0
    reg                         r_wfifo_en0;
    reg  [ARB_DW-1:0]           r_wfifo_data0;
    wire                        w_cmd0;
    wire                        w_fifo_full0;
    wire                        w_fifo_empty0;
    wire                        w_rfifo_en0;
    wire [ARB_DW-1:0]           w_rfifo_data0;

    // sel1
    reg                         r_wfifo_en1;
    reg  [ARB_DW-1:0]           r_wfifo_data1;
    wire                        w_cmd1;
    wire                        w_fifo_full1;
    wire                        w_fifo_empty1;
    wire                        w_rfifo_en1;
    wire [ARB_DW-1:0]           w_rfifo_data1;

    // sel2
    reg                         r_wfifo_en2;
    reg  [ARB_DW-1:0]           r_wfifo_data2;
    wire                        w_cmd2;
    wire                        w_fifo_full2;
    wire                        w_fifo_empty2;
    wire                        w_rfifo_en2;
    wire [ARB_DW-1:0]           w_rfifo_data2;

    // sel3
    reg                         r_wfifo_en3;
    reg  [ARB_DW-1:0]           r_wfifo_data3;
    wire                        w_cmd3;
    wire                        w_fifo_full3;
    wire                        w_fifo_empty3;
    wire                        w_rfifo_en3;
    wire [ARB_DW-1:0]           w_rfifo_data3;

    wire [RR_NUM-1:0]           r_req;
    reg  [RR_NUM-1:0]           r_rfifo_flag;
    reg  [ST_WIDTH-1:0]         r_curr_state;
    reg  [ST_WIDTH-1:0]         r_next_state;
    reg                         r_rfifo_en0;
    reg                         r_rfifo_en1;
    reg                         r_rfifo_en2;
    reg                         r_rfifo_en3;
    reg  [ARB_DW-1:0]           r_rfifo_data0;
    reg  [ARB_DW-1:0]           r_rfifo_data1;
    reg  [ARB_DW-1:0]           r_rfifo_data2;
    reg  [ARB_DW-1:0]           r_rfifo_data3;

    reg                         r_maskfifo_wren;
    reg  [2:0]                  r_maskfifo_wrdata;
    wire                        w_maskfifo_rden;
    wire [2:0]                  w_maskfifo_rddata;
    wire                        w_maskfifo_full;
    wire                        w_maskfifo_empty;

    reg                         r_arbfifo_wren;
    reg  [ARB_DW-1:0]           r_arbfifo_wrdata;
    wire                        w_arbfifo_rden;
    wire [ARB_DW-1:0]           w_arbfifo_rddata;
    wire                        w_arbfifo_full;
    wire                        w_arbfifo_empty;
    reg                         r_arbfifo_rden;
    reg  [ARB_DW-1:0]           r_arbfifo_rddata;

    // ddr interface
    reg                         r_cmd_flag;
    reg  [DDR_AW-1:0]           r_addr;
    reg  [DDR_DW-1:0]           r_ddr3_wdata;
    wire                        w_ddr2fifo_rden;
    wire [DDR_DW-1:0]           w_ddr2fifo_rddata;
    wire                        w_ddr2fifo_empty;
    reg                         r_rddr_valid;
    reg                         r0_rddr_valid;
    reg  [DDR_DW-1:0]           r_rddr_data;

    //output rd data
    reg                         r_ddr2udp_valid;
    reg  [DDR_DW-1:0]           r_ddr2udp_data;
    reg                         r_ddr2para_valid;
    reg  [DDR_DW-1:0]           r_ddr2para_data;
    reg                         r_ddr2flash_valid;
    reg  [DDR_DW-1:0]           r_ddr2flash_data;
    reg                         r_ddr2dist_valid;
    reg  [DDR_DW-1:0]           r_ddr2dist_data;

    //read ddr data fifo
    reg                         r_wren_para; 
    wire                        w_ddr2para_empty;
    reg                         r_wren_flash; 
    wire                        w_ddr2flash_empty;
    reg                         r_wren_dist; 
    wire                        w_ddr2dist_empty;
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    //0 udp
    always @(posedge i_clk)begin
        if(~i_rst_n)begin
            r_wfifo_en0 <=  1'b0;
        end else begin
            r_wfifo_en0 <= i_udp2ddr_wren || i_udp2ddr_rden;  
        end
    end
    assign w_cmd0 = i_udp2ddr_wren ? 1'b0:1'b1;

    always @(posedge i_clk)begin
        if(~i_rst_n)begin
            r_wfifo_data0 <=  {ARB_DW{1'b0}};
        end else if(i_udp2ddr_wren || i_udp2ddr_rden)begin
            r_wfifo_data0 <= {w_cmd0, REQ_TYPE1, i_udp2ddr_addr, i_udp2ddr_data};  
        end
    end

    sfifo_128x96 u0_udp2ddr(
        .Data           ( r_wfifo_data0         ), //input [ARB_DW-1:0]
        .Clock          ( i_clk                 ), 
        .WrEn           ( r_wfifo_en0           ), 
        .RdEn           ( w_rfifo_en0           ), 
        .Reset          ( ~i_rst_n              ), 
        .Q              ( w_rfifo_data0         ), 
        .Empty          ( w_fifo_empty0         ), 
        .Full           ( w_fifo_full0          )
    );

    //1 para
    always @(posedge i_clk)begin
        if(~i_rst_n)begin
            r_wfifo_en1 <=  1'b0;
        end else begin
            r_wfifo_en1 <= i_para2ddr_wren || i_ddr2para_rden;  
        end
    end
    assign w_cmd1 = i_para2ddr_wren ? 1'b0:1'b1;

    always @(posedge i_clk)begin
        if(~i_rst_n)begin
            r_wfifo_data1 <= {ARB_DW{1'b0}};
        end else if(i_para2ddr_wren || i_ddr2para_rden)begin
            r_wfifo_data1 <= {w_cmd1, REQ_TYPE2, i_para2ddr_addr, i_para2ddr_data};  
        end
    end

    sfifo_128x96 u1_para2ddr(
        .Data           ( r_wfifo_data1         ), //input [ARB_DW-1:0]
        .Clock          ( i_clk                 ), 
        .WrEn           ( r_wfifo_en1           ), 
        .RdEn           ( w_rfifo_en1           ), 
        .Reset          ( ~i_rst_n              ), 
        .Q              ( w_rfifo_data1         ), 
        .Empty          ( w_fifo_empty1         ), 
        .Full           ( w_fifo_full1          )
    );

    //2 flash
    always @(posedge i_clk)begin
        if(~i_rst_n)begin
            r_wfifo_en2 <=  1'b0;
        end else begin
            r_wfifo_en2 <= i_flash2ddr_wren || i_ddr2flash_rden;  
        end
    end
    assign w_cmd2 = i_flash2ddr_wren ? 1'b0:1'b1;

    always @(posedge i_clk)begin
        if(~i_rst_n)begin
            r_wfifo_data2 <= {ARB_DW{1'b0}};
        end else if(i_flash2ddr_wren || i_ddr2flash_rden)begin
            r_wfifo_data2 <= {w_cmd2, REQ_TYPE3, i_flash2ddr_addr, i_flash2ddr_data};  
        end
    end

    sfifo_128x96 u2_flash2ddr(
        .Data           ( r_wfifo_data2         ), //input [ARB_DW-1:0]
        .Clock          ( i_clk                 ), 
        .WrEn           ( r_wfifo_en2           ), 
        .RdEn           ( w_rfifo_en2           ), 
        .Reset          ( ~i_rst_n              ), 
        .Q              ( w_rfifo_data2         ), 
        .Empty          ( w_fifo_empty2         ), 
        .Full           ( w_fifo_full2          )
    );

    //3 dist
    always @(posedge i_clk)begin
        if(~i_rst_n)begin
            r_wfifo_en3 <=  1'b0;
        end else begin
            r_wfifo_en3 <= i_dist2ddr_wren || i_dist2ddr_rden;  
        end
    end
    assign w_cmd3 = i_udp2ddr_wren ? 1'b0:1'b1;

    always @(posedge i_clk)begin
        if(~i_rst_n)begin
            r_wfifo_data3 <= {ARB_DW{1'b0}};
        end else if(i_dist2ddr_wren || i_dist2ddr_rden)begin
            r_wfifo_data3 <= {w_cmd3, REQ_TYPE4, i_dist2ddr_addr, i_dist2ddr_data};  
        end
    end

    sfifo_128x96 u3_dist2ddr(
        .Data           ( r_wfifo_data3         ), //input [ARB_DW-1:0]
        .Clock          ( i_clk                 ), 
        .WrEn           ( r_wfifo_en3           ), 
        .RdEn           ( w_rfifo_en3           ), 
        .Reset          ( ~i_rst_n              ), 
        .Q              ( w_rfifo_data3         ), 
        .Empty          ( w_fifo_empty3         ), 
        .Full           ( w_fifo_full3          )
    );
	//--------------------------------------------------------------------------------------------------
	// Arbiter
	//--------------------------------------------------------------------------------------------------
    assign r_req = {~w_fifo_empty3, ~w_fifo_empty2, ~w_fifo_empty1, ~w_fifo_empty0};
    always @(posedge i_clk) begin
        if(!i_rst_n)
        	r_curr_state	<= ST_SEL_IDLE;
        else
        	r_curr_state	<= r_next_state;
    end

    always @(*) begin
        r_next_state    = r_curr_state;
        r_rfifo_flag   = {RR_NUM{1'b0}};
        case(r_curr_state)
        	ST_SEL_IDLE: begin
        		if(r_req[0])begin
        			r_rfifo_flag[0] = 1'b1;
        			r_next_state    = ST_SEL_MSG0;
        		end else if(r_req[1])begin
        			r_rfifo_flag[1] = 1'b1;
        			r_next_state    = ST_SEL_MSG1;
        		end else if(r_req[2])begin
        			r_rfifo_flag[2] = 1'b1;
        			r_next_state    = ST_SEL_MSG2;
        		end else if(r_req[3])begin
        			r_rfifo_flag[3] = 1'b1;
        			r_next_state    = ST_SEL_MSG3;                          
        		end else begin
        			r_next_state    = ST_SEL_IDLE;
        		end
        	end
        	ST_SEL_MSG0: begin
                if(r_rfifo_en0)begin
                    if(r_req[1])begin
                        r_rfifo_flag[1] = 1'b1;
                        r_next_state    = ST_SEL_MSG1;
                    end else if(r_req[2])begin
                        r_rfifo_flag[2] = 1'b1;
                        r_next_state    = ST_SEL_MSG2;
                    end else if(r_req[3])begin
                        r_rfifo_flag[3] = 1'b1;
                        r_next_state    = ST_SEL_MSG3;                                      
                    end else if(r_req[0])begin
                        r_rfifo_flag[0] = 1'b1;
                        r_next_state    = ST_SEL_MSG0;  
                    end else begin
                        r_next_state    = ST_SEL_IDLE;                                 
                    end
                end
        	end
        	ST_SEL_MSG1: begin
                if(r_rfifo_en1)begin
                    if(r_req[2])begin
                        r_rfifo_flag[2] = 1'b1;
                        r_next_state    = ST_SEL_MSG2;
                    end else if(r_req[3])begin
                        r_rfifo_flag[3] = 1'b1;
                        r_next_state    = ST_SEL_MSG3;                                      
                    end else if(r_req[0])begin
                        r_rfifo_flag[0] = 1'b1;
                        r_next_state    = ST_SEL_MSG0;
                    end else if(r_req[1])begin
                        r_rfifo_flag[1] = 1'b1;
                        r_next_state    = ST_SEL_MSG1;
                    end else begin
                        r_next_state    = ST_SEL_IDLE;                   
                    end
                end
        	end
        	ST_SEL_MSG2: begin
                if(r_rfifo_en2)begin
                    if(r_req[3])begin
                        r_rfifo_flag[3] = 1'b1;
                        r_next_state    = ST_SEL_MSG3;                                      
                    end else if(r_req[0])begin
                        r_rfifo_flag[0] = 1'b1;
                        r_next_state    = ST_SEL_MSG0;
                    end else if(r_req[1])begin
                        r_rfifo_flag[1] = 1'b1;
                        r_next_state    = ST_SEL_MSG1;
                    end else if(r_req[2])begin
                        r_rfifo_flag[2] = 1'b1;
                        r_next_state    = ST_SEL_MSG2;
                    end else begin
                        r_next_state    = ST_SEL_IDLE;                   
                    end
                end
        	end   
        	ST_SEL_MSG3: begin
                if(r_rfifo_en3)begin
                    if(r_req[0])begin
                        r_rfifo_flag[0] = 1'b1;
                        r_next_state    = ST_SEL_MSG0;                    
                    end else if(r_req[1])begin
                        r_rfifo_flag[1] = 1'b1;
                        r_next_state    = ST_SEL_MSG1;
                    end else if(r_req[2])begin
                        r_rfifo_flag[2] = 1'b1;
                        r_next_state    = ST_SEL_MSG2;
                    end else if(r_req[3])begin
                        r_rfifo_flag[3] = 1'b1;
                        r_next_state    = ST_SEL_MSG3;
                    end else begin
                        r_next_state    = ST_SEL_IDLE;                
                    end
                end
        	end
            default: r_next_state = ST_SEL_IDLE;
        endcase
    end

    assign w_rfifo_en0 = ~w_fifo_empty0 && r_rfifo_flag[0];
    assign w_rfifo_en1 = ~w_fifo_empty1 && r_rfifo_flag[1];
    assign w_rfifo_en2 = ~w_fifo_empty2 && r_rfifo_flag[2];
    assign w_rfifo_en3 = ~w_fifo_empty3 && r_rfifo_flag[3];

    always @(posedge i_clk)begin
        if(~i_rst_n)begin
            r_rfifo_en0 <=  1'b0;
            r_rfifo_en1 <=  1'b0;
            r_rfifo_en2 <=  1'b0;
            r_rfifo_en3 <=  1'b0;
        end else begin
            r_rfifo_en0 <=  w_rfifo_en0;
            r_rfifo_en1 <=  w_rfifo_en1;
            r_rfifo_en2 <=  w_rfifo_en2;
            r_rfifo_en3 <=  w_rfifo_en3;
        end
    end

    always @(posedge i_clk)begin
        if(~i_rst_n)begin
            r_rfifo_data0 <=  {ARB_DW{1'b0}};
            r_rfifo_data1 <=  {ARB_DW{1'b0}};
            r_rfifo_data2 <=  {ARB_DW{1'b0}};
            r_rfifo_data3 <=  {ARB_DW{1'b0}};
        end else begin
            r_rfifo_data0 <=  w_rfifo_data0;
            r_rfifo_data1 <=  w_rfifo_data1;  
            r_rfifo_data2 <=  w_rfifo_data2;  
            r_rfifo_data3 <=  w_rfifo_data3;            
        end
    end
    //--------------------------------------------------------------------------------------------------
	// data is processed across clock domains
	//--------------------------------------------------------------------------------------------------
    always @(posedge i_clk)begin
        if(~i_rst_n)begin
            r_arbfifo_wren  <=  1'b0; 
        end else begin
            r_arbfifo_wren  <= r_rfifo_en0 || r_rfifo_en1 || r_rfifo_en2 || r_rfifo_en3;  
        end
    end

    always @(posedge i_clk)begin
        if(~i_rst_n)begin
            r_arbfifo_wrdata    <=  {ARB_DW{1'b0}};
        end else if(r_rfifo_en0)begin
            r_arbfifo_wrdata    <= w_rfifo_data0;
        end else if(r_rfifo_en1)begin
            r_arbfifo_wrdata    <= w_rfifo_data1;
        end else if(r_rfifo_en2)begin
            r_arbfifo_wrdata    <= w_rfifo_data2;
        end else if(r_rfifo_en3)begin
            r_arbfifo_wrdata    <= w_rfifo_data3;
        end
    end

    asfifo_256x96 u_asfifo_256x96
    (
        .Data           ( r_arbfifo_wrdata      ), //input [ARB_DW-1:0]
        .WrClock        ( i_clk                 ), //input
        .RdClock        ( i_ddr_sclk            ), //input
        .WrEn           ( r_arbfifo_wren        ), //input
        .RdEn           ( i_arbfifo_rden        ), //input
        .Reset          ( ~i_rst_n              ), //input
        .RPReset        ( ~i_rst_n              ), //input
        .Q              ( o_arbfifo_rddata      ), //output [ARB_DW-1:0]
        .Empty          ( o_arbfifo_empty       ), //output
        .Full           (           )  //output
    );
    //----------------------------------------------------
	/* 
        read ddr data to fifo
    */
	//----------------------------------------------------
    //read ddr to para
    always @(posedge i_ddr_sclk)begin
        if(~i_rst_n)begin
            r_wren_para     <= 1'b0;
            r_ddr2para_data <= {DDR_DW{1'b0}};
        end else if(i_req_type == REQ_TYPE2) begin
            r_wren_para     <= i_rdata_valid;
            r_ddr2para_data <= i_ddr_rdata;
        end else begin
            r_wren_para     <= 1'b0;
            r_ddr2para_data <= {DDR_DW{1'b0}};
        end
    end
    asfifo_256x64 u_ddr2para
    (
        .Data           ( r_ddr2para_data       ), //input [DDR_DW-1:0]
        .WrClock        ( i_ddr_sclk            ), //input
        .RdClock        ( i_clk                 ), //input
        .WrEn           ( r_wren_para           ), //input
        .RdEn           ( i_ddr2para_fifo_rden  ), //input
        .Reset          ( ~i_rst_n              ), //input
        .RPReset        ( ~i_rst_n              ), //input
        .Q              ( o_ddr2para_fifo_data  ), //output [DDR_DW-1:0]
        .Empty          ( o_ddr2para_fifo_empty ), //output
        .Full           (                       )  //output
    );

    //read ddr to flash
    always @(posedge i_ddr_sclk)begin
        if(~i_rst_n)begin
            r_wren_flash        <= 1'b0;
            r_ddr2flash_data    <= {DDR_DW{1'b0}};
        end else if(i_req_type == REQ_TYPE3) begin
            r_wren_flash        <= i_rdata_valid;
            r_ddr2flash_data    <= i_ddr_rdata;
        end else begin
            r_wren_flash        <= 1'b0;
            r_ddr2flash_data    <= {DDR_DW{1'b0}};
        end
    end
    asfifo_256x64 u_ddr2flash
    (
        .Data           ( r_ddr2flash_data      ), //input [DDR_DW-1:0]
        .WrClock        ( i_ddr_sclk            ), //input
        .RdClock        ( i_clk                 ), //input
        .WrEn           ( r_wren_flash          ), //input
        .RdEn           ( i_ddr2flash_fifo_rden ), //input
        .Reset          ( ~i_rst_n              ), //input
        .RPReset        ( ~i_rst_n              ), //input
        .Q              ( o_ddr2flash_fifo_data ), //output [DDR_DW-1:0]
        .Empty          ( o_ddr2flash_fifo_empty), //output
        .Full           (                       )  //output
    );

    //read ddr to dist cal
    always @(posedge i_ddr_sclk)begin
        if(~i_rst_n)begin
            r_wren_dist        <= 1'b0;
            r_ddr2dist_data    <= {DDR_DW{1'b0}};
        end else if(i_req_type == REQ_TYPE4) begin
            r_wren_dist        <= i_rdata_valid;
            r_ddr2dist_data    <= i_ddr_rdata;
        end else begin
            r_wren_dist        <= 1'b0;
            r_ddr2dist_data    <= {DDR_DW{1'b0}};
        end
    end
    asfifo_256x64 u_ddr2dist
    (
        .Data           ( r_ddr2dist_data       ), //input [DDR_DW-1:0]
        .WrClock        ( i_ddr_sclk            ), //input
        .RdClock        ( i_clk                 ), //input
        .WrEn           ( r_wren_dist           ), //input
        .RdEn           ( i_ddr2dist_fifo_rden  ), //input
        .Reset          ( ~i_rst_n              ), //input
        .RPReset        ( ~i_rst_n              ), //input
        .Q              ( o_ddr2dist_fifo_data  ), //output [DDR_DW-1:0]
        .Empty          ( o_ddr2dist_fifo_empty ), //output
        .Full           (                       )  //output
    );
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------

endmodule