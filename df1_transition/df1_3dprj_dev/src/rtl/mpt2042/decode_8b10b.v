// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: decode_8b10b
// Date Created 	: 2025/04/10
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:decode_8b10b
//          code group    Dx.y or Kx.y
//               
//           MSB|  y  ||    x    |LSB
//           8b: H G F  E D C B A
//
//              |E D C B A|   |H G F|
//          10b：a b c d e i  f g h j
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
`timescale 1ns/1ps

module decode_8b10b (
    input i_decode_reset,                  // Global asynchronous reset (AH)
    input i_decode_clk,                // Master synchronous receive byte clock
    input i_datain_valid,          // Data valid input
    input ai, bi, ci, di, ei, ii, // Encoded input (LS..MS)
    input fi, gi, hi, ji,         // Encoded input (LS..MS)
    output reg o_comma_k,                // Control (K) character indicator (AH)
    // output reg EO, DO, CO, BO, AO, // Decoded output (MS..LS)
    // output reg [2:0] o_decode_3b
    output reg HO, GO, FO, EO, DO, CO, BO, AO // Decoded output (MS..LS)
);

    // Signals to tie things together
    reg  [2:0] r_decode_3b;
    wire ANEB, CNED, EEI, P13, P22, P31;  // Figure 10 Signals
    wire IKA, IKB, IKC;                   // Figure 11 Signals
    wire XA, XB, XC, XD, XE;              // Figure 12 Signals
    wire OR121, OR122, OR123, OR124, OR125, OR126, OR127; // Figure 12 Signals
    wire XF, XG, XH;                      // Figure 13 Signals
    wire OR131, OR132, OR133, OR134, IOR134; // Figure 13 Signals

    // 6b Input Function (Reference: Figure 10)
    assign P13 = (ANEB & (~ci & ~di)) | (CNED & (~ai & ~bi));
    assign P31 = (ANEB & ci & di) | (CNED & ai & bi);
    assign P22 = (ai & bi & (~ci & ~di)) | (ci & di & (~ai & ~bi)) | (ANEB & CNED);

    assign ANEB = ai ^ bi; // Intermediate term for "ai is Not Equal to bi"
    assign CNED = ci ^ di; // Intermediate term for "ci is Not Equal to di"
    assign EEI = ~(ei ^ ii); // Intermediate term for "E is Equal to I"

    // K Decoder - Figure 11
    assign IKA = (ci & di & ei & ii) | (~ci & ~di & ~ei & ~ii);
    assign IKB = P13 & (~ei & ii & gi & hi & ji);
    assign IKC = P31 & (ei & ~ii & ~gi & ~hi & ~ji);

    // Process: KFN; Determine K output
    always @(posedge i_decode_clk or posedge i_decode_reset) begin
        if (i_decode_reset) begin
            o_comma_k <= 0;
        end else if (i_datain_valid) begin
            o_comma_k <= IKA | IKB | IKC;
        end
    end

    // 5b Decoder Figure 12
    assign OR121 = (P22 & (~ai & ~ci & EEI)) | (P13 & ~ei);
    assign OR122 = (ai & bi & ei & ii) | (~ci & ~di & ~ei & ~ii) | (P31 & ii);
    assign OR123 = (P31 & ii) | (P22 & bi & ci & EEI) | (P13 & di & ei & ii);
    assign OR124 = (P22 & ai & ci & EEI) | (P13 & ~ei);
    assign OR125 = (P13 & ~ei) | (~ci & ~di & ~ei & ~ii) | (~ai & ~bi & ~ei & ~ii);
    assign OR126 = (P22 & ~ai & ~ci & EEI) | (P13 & ~ii);
    assign OR127 = (P13 & di & ei & ii) | (P22 & ~bi & ~ci & EEI);

    // Complimenting the A, B, C, D, E inputs
    assign XA = OR127 | OR121 | OR122;
    assign XB = OR122 | OR123 | OR124;
    assign XC = OR121 | OR123 | OR125;
    assign XD = OR122 | OR124 | OR127;
    assign XE = OR125 | OR126 | OR127;

    // Process: DEC5B; Generate and latch LS 5 decoded bits
    always @(posedge i_decode_clk or posedge i_decode_reset) begin
        if (i_decode_reset) begin
            AO <= 0;
            BO <= 0;
            CO <= 0;
            DO <= 0;
            EO <= 0;
        end else if (i_datain_valid) begin
            AO <= XA ^ ai;  // Least significant bit 0
            BO <= XB ^ bi;
            CO <= XC ^ ci;
            DO <= XD ^ di;
            EO <= XE ^ ei;  // Most significant bit 6
        end
    end

/*
    // 修正后的 IOR134 定义，明确逻辑意图
    assign IOR134 = (hi ^ ji) & ~(ci & di & ei & ii);  // 假设异或逻辑更符合需求

    // 优化组合逻辑的可读性
    assign OR131 = (gi & hi & ji) | (fi & hi & ji) | IOR134;
    assign OR132 = (fi & gi & ji) | (~fi & ~gi & ~hi) | (~fi & ~gi & hi & ji);
    assign OR133 = (~fi & ~hi & ~ji) | IOR134 | (~gi & ~hi & ~ji);
    assign OR134 = (~gi & ~hi & ~ji) | (fi & hi & ji) | IOR134;

    // 输出逻辑保持不变
    assign XF = OR131 | OR132;
    assign XG = OR132 | OR133;
    assign XH = OR132 | OR134;

    // 时序逻辑（确保 i_datain_valid 同步）
    always @(posedge i_decode_clk or posedge i_decode_reset) begin
        if (i_decode_reset) begin
            FO <= 1'b0;
            GO <= 1'b0;
            HO <= 1'b0;
        end else if (i_datain_valid) begin
            FO <= XF ^ fi;  // 确认异或逻辑符合解码规则
            GO <= XG ^ gi;
            HO <= XH ^ hi;
        end
    end
*/

    // 3b Decoder - Figure 13
    assign IOR134 = (~(hi & ji)) & (~(~hi & ~ji)) & (~ci & ~di & ~ei & ~ii);
    assign OR131 = (gi & hi & ji) | (fi & hi & ji) | (IOR134);
    assign OR132 = (fi & gi & ji) | (~fi & ~gi & ~hi) | (~fi & ~gi & hi & ji);
    assign OR133 = (~fi & ~hi & ~ji) | (IOR134) | (~gi & ~hi & ~ji);
    assign OR134 = (~gi & ~hi & ~ji) | (fi & hi & ji) | (IOR134);
    
    // Complimenting F, G, H outputs
    assign XF = OR131 | OR132;
    assign XG = OR132 | OR133;
    assign XH = OR132 | OR134;

    // Process: DEC3B; Generate and latch MS 3 decoded bits
    always @(posedge i_decode_clk or posedge i_decode_reset) begin
        if (i_decode_reset) begin
            FO <= 0;
            GO <= 0;
            HO <= 0;
        end else if (i_datain_valid) begin
            FO <= XF ^ fi;  // Least significant bit 7
            GO <= XG ^ gi;
            HO <= XH ^ hi;  // Most significant bit 10
        end
    end

	// //--------------------------------------------------------------------------------------------------
	// // 3b Decoder 
	// //--------------------------------------------------------------------------------------------------
    // always @(*) begin
    //     case({fi, gi, hi, ji})
    //         4'b1011: r_decode_3b    = 3'b000;
    //         4'b0100: r_decode_3b    = 3'b000;
    //         4'b1001: r_decode_3b    = 3'b001;
    //         4'b0110: r_decode_3b    = 3'b001;
    //         4'b0101: r_decode_3b    = 3'b010;
    //         4'b1010: r_decode_3b    = 3'b010;
    //         4'b1100: r_decode_3b    = 3'b011;
    //         4'b0011: r_decode_3b    = 3'b011;
    //         4'b1101: r_decode_3b    = 3'b100;
    //         4'b0010: r_decode_3b    = 3'b100;
    //         4'b1010: r_decode_3b    = 3'b101;
    //         4'b0101: r_decode_3b    = 3'b101;
    //         4'b0110: r_decode_3b    = 3'b110;
    //         4'b0110: r_decode_3b    = 3'b110;
    //         4'b1110: r_decode_3b    = 3'b111;
    //         4'b0001: r_decode_3b    = 3'b111;
    //         4'b0111: r_decode_3b    = 3'b111;
    //         4'b1000: r_decode_3b    = 3'b111;
    //         default: r_decode_3b    = 3'b000;
    //     endcase
    // end

    // // Process: DEC3B; Generate and latch MS 3 decoded bits
    // always @(posedge i_decode_clk or posedge i_decode_reset) begin
    //     if (i_decode_reset) begin
    //         FO <= 0;
    //         GO <= 0;
    //         HO <= 0;
    //     end else if (i_datain_valid) begin
    //         FO <= r_decode_3b[0];
    //         GO <= r_decode_3b[1];
    //         HO <= r_decode_3b[2];
    //     end
    // end
endmodule
