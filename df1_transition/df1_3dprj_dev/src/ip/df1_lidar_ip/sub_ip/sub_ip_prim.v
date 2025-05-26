// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.13.0.56.2
// Netlist written on Thu Sep 19 20:49:20 2024
//
// Verilog Description of module sub_ip
//

module sub_ip (DataA, DataB, Result) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(8[8:14])
    input [31:0]DataA;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(9[23:28])
    input [31:0]DataB;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(10[23:28])
    output [31:0]Result;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(11[24:30])
    
    
    wire precin, co0, co1, co2, co3, co4, co5, co6, co7, co8, 
        co9, co10, co11, co12, co13, co14, scuba_vhi, scuba_vlo, 
        co15;
    
    CCU2C addsub_0 (.A0(scuba_vhi), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[0]), .B1(DataB[0]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(precin), .COUT(co0), .S1(Result[0])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(45[11] 47[57])
    defparam addsub_0.INIT0 = 16'b1001100110101010;
    defparam addsub_0.INIT1 = 16'b1001100110101010;
    defparam addsub_0.INJECT1_0 = "NO";
    defparam addsub_0.INJECT1_1 = "NO";
    CCU2C addsub_1 (.A0(DataA[1]), .B0(DataB[1]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[2]), .B1(DataB[2]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co0), .COUT(co1), .S0(Result[1]), .S1(Result[2])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(53[11] 55[63])
    defparam addsub_1.INIT0 = 16'b1001100110101010;
    defparam addsub_1.INIT1 = 16'b1001100110101010;
    defparam addsub_1.INJECT1_0 = "NO";
    defparam addsub_1.INJECT1_1 = "NO";
    CCU2C addsub_2 (.A0(DataA[3]), .B0(DataB[3]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[4]), .B1(DataB[4]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co1), .COUT(co2), .S0(Result[3]), .S1(Result[4])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(61[11] 63[63])
    defparam addsub_2.INIT0 = 16'b1001100110101010;
    defparam addsub_2.INIT1 = 16'b1001100110101010;
    defparam addsub_2.INJECT1_0 = "NO";
    defparam addsub_2.INJECT1_1 = "NO";
    CCU2C addsub_3 (.A0(DataA[5]), .B0(DataB[5]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[6]), .B1(DataB[6]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co2), .COUT(co3), .S0(Result[5]), .S1(Result[6])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(69[11] 71[63])
    defparam addsub_3.INIT0 = 16'b1001100110101010;
    defparam addsub_3.INIT1 = 16'b1001100110101010;
    defparam addsub_3.INJECT1_0 = "NO";
    defparam addsub_3.INJECT1_1 = "NO";
    CCU2C addsub_4 (.A0(DataA[7]), .B0(DataB[7]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[8]), .B1(DataB[8]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co3), .COUT(co4), .S0(Result[7]), .S1(Result[8])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(77[11] 79[63])
    defparam addsub_4.INIT0 = 16'b1001100110101010;
    defparam addsub_4.INIT1 = 16'b1001100110101010;
    defparam addsub_4.INJECT1_0 = "NO";
    defparam addsub_4.INJECT1_1 = "NO";
    CCU2C addsub_5 (.A0(DataA[9]), .B0(DataB[9]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[10]), .B1(DataB[10]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co4), .COUT(co5), .S0(Result[9]), .S1(Result[10])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(85[11] 87[64])
    defparam addsub_5.INIT0 = 16'b1001100110101010;
    defparam addsub_5.INIT1 = 16'b1001100110101010;
    defparam addsub_5.INJECT1_0 = "NO";
    defparam addsub_5.INJECT1_1 = "NO";
    CCU2C addsub_6 (.A0(DataA[11]), .B0(DataB[11]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[12]), .B1(DataB[12]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co5), .COUT(co6), .S0(Result[11]), .S1(Result[12])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(93[11] 95[65])
    defparam addsub_6.INIT0 = 16'b1001100110101010;
    defparam addsub_6.INIT1 = 16'b1001100110101010;
    defparam addsub_6.INJECT1_0 = "NO";
    defparam addsub_6.INJECT1_1 = "NO";
    CCU2C addsub_7 (.A0(DataA[13]), .B0(DataB[13]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[14]), .B1(DataB[14]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co6), .COUT(co7), .S0(Result[13]), .S1(Result[14])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(101[11] 103[65])
    defparam addsub_7.INIT0 = 16'b1001100110101010;
    defparam addsub_7.INIT1 = 16'b1001100110101010;
    defparam addsub_7.INJECT1_0 = "NO";
    defparam addsub_7.INJECT1_1 = "NO";
    CCU2C addsub_8 (.A0(DataA[15]), .B0(DataB[15]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[16]), .B1(DataB[16]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co7), .COUT(co8), .S0(Result[15]), .S1(Result[16])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(109[11] 111[65])
    defparam addsub_8.INIT0 = 16'b1001100110101010;
    defparam addsub_8.INIT1 = 16'b1001100110101010;
    defparam addsub_8.INJECT1_0 = "NO";
    defparam addsub_8.INJECT1_1 = "NO";
    CCU2C addsub_9 (.A0(DataA[17]), .B0(DataB[17]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[18]), .B1(DataB[18]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co8), .COUT(co9), .S0(Result[17]), .S1(Result[18])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(117[11] 119[65])
    defparam addsub_9.INIT0 = 16'b1001100110101010;
    defparam addsub_9.INIT1 = 16'b1001100110101010;
    defparam addsub_9.INJECT1_0 = "NO";
    defparam addsub_9.INJECT1_1 = "NO";
    CCU2C addsub_10 (.A0(DataA[19]), .B0(DataB[19]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[20]), .B1(DataB[20]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co9), .COUT(co10), .S0(Result[19]), .S1(Result[20])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(125[11] 127[66])
    defparam addsub_10.INIT0 = 16'b1001100110101010;
    defparam addsub_10.INIT1 = 16'b1001100110101010;
    defparam addsub_10.INJECT1_0 = "NO";
    defparam addsub_10.INJECT1_1 = "NO";
    CCU2C addsub_11 (.A0(DataA[21]), .B0(DataB[21]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[22]), .B1(DataB[22]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co10), .COUT(co11), .S0(Result[21]), .S1(Result[22])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(133[11] 135[67])
    defparam addsub_11.INIT0 = 16'b1001100110101010;
    defparam addsub_11.INIT1 = 16'b1001100110101010;
    defparam addsub_11.INJECT1_0 = "NO";
    defparam addsub_11.INJECT1_1 = "NO";
    CCU2C addsub_12 (.A0(DataA[23]), .B0(DataB[23]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[24]), .B1(DataB[24]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co11), .COUT(co12), .S0(Result[23]), .S1(Result[24])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(141[11] 143[67])
    defparam addsub_12.INIT0 = 16'b1001100110101010;
    defparam addsub_12.INIT1 = 16'b1001100110101010;
    defparam addsub_12.INJECT1_0 = "NO";
    defparam addsub_12.INJECT1_1 = "NO";
    CCU2C addsub_13 (.A0(DataA[25]), .B0(DataB[25]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[26]), .B1(DataB[26]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co12), .COUT(co13), .S0(Result[25]), .S1(Result[26])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(149[11] 151[67])
    defparam addsub_13.INIT0 = 16'b1001100110101010;
    defparam addsub_13.INIT1 = 16'b1001100110101010;
    defparam addsub_13.INJECT1_0 = "NO";
    defparam addsub_13.INJECT1_1 = "NO";
    CCU2C addsub_14 (.A0(DataA[27]), .B0(DataB[27]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[28]), .B1(DataB[28]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co13), .COUT(co14), .S0(Result[27]), .S1(Result[28])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(157[11] 159[67])
    defparam addsub_14.INIT0 = 16'b1001100110101010;
    defparam addsub_14.INIT1 = 16'b1001100110101010;
    defparam addsub_14.INJECT1_0 = "NO";
    defparam addsub_14.INJECT1_1 = "NO";
    CCU2C addsub_15 (.A0(DataA[29]), .B0(DataB[29]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(DataA[30]), .B1(DataB[30]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co14), .COUT(co15), .S0(Result[29]), .S1(Result[30])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(165[11] 167[67])
    defparam addsub_15.INIT0 = 16'b1001100110101010;
    defparam addsub_15.INIT1 = 16'b1001100110101010;
    defparam addsub_15.INJECT1_0 = "NO";
    defparam addsub_15.INJECT1_1 = "NO";
    VHI scuba_vhi_inst (.Z(scuba_vhi));
    VLO scuba_vlo_inst (.Z(scuba_vlo));
    CCU2C addsub_16 (.A0(DataA[31]), .B0(DataB[31]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co15), .S0(Result[31])) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(177[11] 179[53])
    defparam addsub_16.INIT0 = 16'b1001100110101010;
    defparam addsub_16.INIT1 = 16'b1001100110101010;
    defparam addsub_16.INJECT1_0 = "NO";
    defparam addsub_16.INJECT1_1 = "NO";
    GSR GSR_INST (.GSR(scuba_vhi));
    CCU2C precin_inst99 (.A0(scuba_vhi), .B0(scuba_vhi), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(scuba_vhi), .B1(scuba_vhi), .C1(scuba_vhi), 
          .D1(scuba_vhi), .COUT(precin)) /* synthesis syn_instantiated=1 */ ;   // d:/freework/df1_demo/gpx2/src/ip/df1_lidar_ip/sub_ip/sub_ip.v(37[11] 39[61])
    defparam precin_inst99.INIT0 = 16'b0000000000000000;
    defparam precin_inst99.INIT1 = 16'b0000000000000000;
    defparam precin_inst99.INJECT1_0 = "NO";
    defparam precin_inst99.INJECT1_1 = "NO";
    PUR PUR_INST (.PUR(scuba_vhi));
    defparam PUR_INST.RST_PULSE = 1;
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

