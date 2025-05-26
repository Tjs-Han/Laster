// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: divider_32_16bit
// Date Created 	: 2025/05/19 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:divider_32_16bit
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module divider_32_16bit (
    input               i_clk,
    input               i_rst_n,
    input               i_start,
    input  [31:0]       i_dividend,
    input  [15:0]       i_divisor,
    output reg [15:0]   o_quotient,
    output reg          o_done,
    output reg          o_div0      // 新增：除0标志
);
    //----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
    // 状态定义
    localparam ST_IDLE  = 2'd0;
    localparam ST_SHIFT = 2'd1;
    localparam ST_SUB   = 2'd2;
    localparam ST_DONE  = 2'd3;
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
    reg [1:0]   r_state;
    reg [4:0]   r_count;
    reg [47:0]  r_dividend_shift;
    reg [15:0]  r_divisor;
    reg [15:0]  r_quotient;


    // 状态机
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_state           <= ST_IDLE;
            r_count           <= 6'd0;
            r_dividend_shift  <= 48'd0;
            r_divisor         <= 16'd0;
            r_quotient        <= 32'd0;
            o_quotient        <= 32'd0;
            o_done            <= 1'b0;
            o_div0            <= 1'b0;
        end else begin
            case (r_state)
                ST_IDLE: begin
                    o_done    <= 1'b0;
                    o_div0    <= 1'b0;
                    if (i_start) begin
                        if (i_divisor == 16'd0) begin
                            o_div0  <= 1'b1;
                            o_done  <= 1'b1;
                            r_state <= ST_IDLE;
                        end else begin
                            r_dividend_shift <= {16'd0, i_dividend};  // 高位为余数
                            r_divisor        <= i_divisor;
                            r_quotient       <= 32'd0;
                            r_count          <= 6'd0;
                            r_state          <= ST_SHIFT;
                        end
                    end
                end

                // 阶段 1：先左移
                ST_SHIFT: begin
                    r_dividend_shift <= r_dividend_shift << 1;
                    r_state <= ST_SUB;
                end

                // 阶段 2：判断是否可以减去除数并更新商
                ST_SUB: begin
                    if (r_dividend_shift[47:32] >= r_divisor) begin
                        r_dividend_shift[47:32] <= r_dividend_shift[47:32] - r_divisor;
                        r_quotient <= (r_quotient << 1) | 1'b1;
                    end else begin
                        r_quotient <= r_quotient << 1;
                    end

                    if (r_count == 6'd31) begin
                        r_state <= ST_DONE;
                    end else begin
                        r_count <= r_count + 1;
                        r_state <= ST_SHIFT;
                    end
                end

                ST_DONE: begin
                    o_quotient <= r_quotient;
                    o_done     <= 1'b1;
                    r_state    <= ST_IDLE;
                end
            endcase
        end
    end

endmodule

