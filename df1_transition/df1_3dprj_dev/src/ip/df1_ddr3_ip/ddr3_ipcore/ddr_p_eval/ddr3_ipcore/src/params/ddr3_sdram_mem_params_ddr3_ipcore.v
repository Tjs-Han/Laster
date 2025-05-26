`define ddr3_ipcore_GEAR_MODE "X2"
`define ddr3_ipcore_ECP3_8_0

`define ddr3_ipcore_sg25E

`ifdef ddr3_ipcore_sg187E
 `define ddr3_ipcore_X_FAC 4
`else
 `define ddr3_ipcore_X_FAC 2
`endif 

`define ddr3_ipcore_DATA_WIDTH 16
`define ddr3_ipcore_DATA_SIZE_16
`define ddr3_ipcore_x16
`define ddr3_ipcore_DQS_WIDTH 2
`define ddr3_ipcore_DQS_WIDTH_2
`define ddr3_ipcore_DMSIZE 2

`define ddr3_ipcore_BRST_CNT_EN
`ifdef ddr3_ipcore_X4_GEAR
`define ddr3_ipcore_DATA_X 8
`define ddr3_ipcore_TIME_X 2
`else
`define ddr3_ipcore_DATA_X 4
`define ddr3_ipcore_TIME_X 1
`endif
`define ddr3_ipcore_DSIZE `ddr3_ipcore_DATA_WIDTH*`ddr3_ipcore_DATA_X
`define ddr3_ipcore_USER_DM `ddr3_ipcore_DSIZE/8
`define ddr3_ipcore_DQSW 8
`define ddr3_ipcore_ROW_WIDTH 14
`define ddr3_ipcore_ROW_WIDTH_GT_13

`define ddr3_ipcore_COL_WIDTH 10
`define ddr3_ipcore_COL_WIDTH_EQ_10

`define ddr3_ipcore_CS_WIDTH 1
`define ddr3_ipcore_CS_WIDTH_1

`ifdef ddr3_ipcore_RDIMM
  `define ddr3_ipcore_TSTAB 11'd1200
  `define ddr3_ipcore_DESEL
  `ifdef ddr3_ipcore_CS_WIDTH_1
    `define ddr3_ipcore_CS_WIDTH_BB 2
  `else
    `define ddr3_ipcore_CS_WIDTH_BB `ddr3_ipcore_CS_WIDTH
  `endif
`else
  `define ddr3_ipcore_CS_WIDTH_BB `ddr3_ipcore_CS_WIDTH
`endif
`define ddr3_ipcore_BANK_WIDTH 3
`define ddr3_ipcore_BSIZE 3
`define ddr3_ipcore_ADDR_WIDTH 27

`define ddr3_ipcore_USER_SLOT_SIZE_1
`define ddr3_ipcore_WL_DQS_WIDTH (`ddr3_ipcore_DQS_WIDTH * `ddr3_ipcore_CS_WIDTH)
`define ddr3_ipcore_CLKO_WIDTH 1
`define ddr3_ipcore_CLKO_WIDTH_1
`define ddr3_ipcore_CKE_WIDTH 1

`define ddr3_ipcore_AR_BURST_EN 3'd0
`define ddr3_ipcore_AR_BURST_8

`define ddr3_ipcore_WrRqDDelay 2'd1
`define ddr3_ipcore_MRS0_INIT 16'b0001010100010000
`define ddr3_ipcore_MRS1_INIT 16'b0000000000000100
`define ddr3_ipcore_MRS2_INIT 16'b0000001000000000
`define ddr3_ipcore_MRS3_INIT 16'b0000000000000000

`define ddr3_ipcore_INIT_WR_LAT 5

`define ddr3_ipcore_TRCD 2'd3
`define ddr3_ipcore_TRRD 2'd3
`define ddr3_ipcore_TRP 2'd3
`define ddr3_ipcore_TWR 2'd3
`define ddr3_ipcore_TRAS 4'd8
`define ddr3_ipcore_TRC 4'd10
`define ddr3_ipcore_TRTP 2'd2
`define ddr3_ipcore_TWTR 2'd2
`define ddr3_ipcore_TCKESR 2'd2
`define ddr3_ipcore_TZQOPER 8'd128
`define ddr3_ipcore_TZQS 6'd32
`define ddr3_ipcore_TMRD 2'd2
`define ddr3_ipcore_TPD 2'd2
`define ddr3_ipcore_TXPDLL 3'd5
`define ddr3_ipcore_TCKE 2'd2
`define ddr3_ipcore_TXPR 6'd34
`define ddr3_ipcore_TMOD 3'd6
`define ddr3_ipcore_TZQINIT 9'd256
`define ddr3_ipcore_TRFC 6'd32
`define ddr3_ipcore_TFAW 4'd8
`define ddr3_ipcore_TREFI 16'd1170
`define ddr3_ipcore_TWLMRD 5'd20
`define ddr3_ipcore_TWLDQSEN 4'd13
`define ddr3_ipcore_TODTH4 2'd2
`define ddr3_ipcore_TODTH8 2'd3
`define ddr3_ipcore_TWLO 2'd3
`define ddr3_ipcore_TRCD_WIDTH 2
`define ddr3_ipcore_TRRD_WIDTH 2
`define ddr3_ipcore_TRP_WIDTH 2
`define ddr3_ipcore_TWR_WIDTH 2
`define ddr3_ipcore_TRAS_WIDTH 4
`define ddr3_ipcore_TRC_WIDTH 4
`define ddr3_ipcore_TRTP_WIDTH 2
`define ddr3_ipcore_TWTR_WIDTH 2
`define ddr3_ipcore_TCKESR_WIDTH 2
`define ddr3_ipcore_TZQOPER_WIDTH 8
`define ddr3_ipcore_TZQS_WIDTH 6
`define ddr3_ipcore_TMRD_WIDTH 2
`define ddr3_ipcore_TPD_WIDTH 2
`define ddr3_ipcore_TXPDLL_WIDTH 3
`define ddr3_ipcore_TXPR_WIDTH 6
`define ddr3_ipcore_TMOD_WIDTH 3
`define ddr3_ipcore_TZQINIT_WIDTH 9
`define ddr3_ipcore_TRFC_WIDTH 6
`define ddr3_ipcore_TFAW_WIDTH 4
`define ddr3_ipcore_TCKE_WIDTH 2
`define ddr3_ipcore_TREFI_WIDTH 16
`define ddr3_ipcore_TWLMRD_WIDTH 5
`define ddr3_ipcore_TWLDQSEN_WIDTH 4
`define ddr3_ipcore_TODTH4_WIDTH 2
`define ddr3_ipcore_TODTH8_WIDTH 2
`define ddr3_ipcore_TWLO_WIDTH 2

`define ddr3_ipcore_AL 0
`define ddr3_ipcore_CL 3
`define ddr3_ipcore_CWL 3
`define ddr3_ipcore_CL_WIDTH 4
`define ddr3_ipcore_RL_WIDTH 4
`define ddr3_ipcore_WL_WIDTH 4
`define ddr3_ipcore_AL_WIDTH 2
`define ddr3_ipcore_CWL_WIDTH 3

`define ddr3_ipcore_NO_WRITE_LEVEL
`define ddr3_ipcore_ENB_MEM_RST
`define ddr3_ipcore_REFCLK_PERIOD_BY2 5000
`define ddr3_ipcore_PLL_FIN "100"
`define ddr3_ipcore_PLL_FOUT "300"
`define ddr3_ipcore_PMI_PLL
 `ifdef ddr3_ipcore_x4
`else
  `ifdef ddr3_ipcore_NO_WRITE_LEVEL
     `define ddr3_ipcore_TRC_DQS0 0
     `define ddr3_ipcore_TRC_DQS1 0
     `define ddr3_ipcore_TRC_DQS2 0
     `define ddr3_ipcore_TRC_DQS3 0
     `define ddr3_ipcore_TRC_DQS4 0
     `define ddr3_ipcore_TRC_DQS5 0
     `define ddr3_ipcore_TRC_DQS6 0
     `define ddr3_ipcore_TRC_DQS7 0
     `define ddr3_ipcore_TRC_DQS8 0
     `define ddr3_ipcore_TRC_DQS9 0
     `define ddr3_ipcore_TRC_DQS10 0
     `define ddr3_ipcore_TRC_DQS11 0
     `define ddr3_ipcore_TRC_DQS12 0
     `define ddr3_ipcore_TRC_DQS13 0
     `define ddr3_ipcore_TRC_DQS14 0
     `define ddr3_ipcore_TRC_DQS15 0
     `define ddr3_ipcore_TRC_DQS16 0
     `define ddr3_ipcore_TRC_DQS17 0
  `else
     `define ddr3_ipcore_TRC_DQS0 100
     `define ddr3_ipcore_TRC_DQS1 100
     `define ddr3_ipcore_TRC_DQS2 100
     `define ddr3_ipcore_TRC_DQS3 100
     `define ddr3_ipcore_TRC_DQS4 100
     `define ddr3_ipcore_TRC_DQS5 100
     `define ddr3_ipcore_TRC_DQS6 100
     `define ddr3_ipcore_TRC_DQS7 100
     `define ddr3_ipcore_TRC_DQS8 100
     `define ddr3_ipcore_TRC_DQS9 100
     `define ddr3_ipcore_TRC_DQS10 100
     `define ddr3_ipcore_TRC_DQS11 100
     `define ddr3_ipcore_TRC_DQS12 100
     `define ddr3_ipcore_TRC_DQS13 100
     `define ddr3_ipcore_TRC_DQS14 100
     `define ddr3_ipcore_TRC_DQS15 100
     `define ddr3_ipcore_TRC_DQS16 100
     `define ddr3_ipcore_TRC_DQS17 100
  `endif
`endif

 `define ddr3_ipcore_PHY_REG
 `define ddr3_ipcore_PHY_REG_P2

`define ddr3_ipcore_WL_RTT_NOM 3'b001
`define ddr3_ipcore_WL_RNK0_RTT_NOM 3'b010
`define ddr3_ipcore_WL_RNK1_RTT_NOM 3'b011
`define ddr3_ipcore_DQS_TRC_DEL 0.2
`define ddr3_ipcore_DQ_TRC_DEL 0.2
`define ddr3_ipcore_DM_TRC_DEL 0.2

`define ddr3_ipcore_WL_DQS_PHASE_DLY 0
`define ddr3_ipcore_WL_DQS_PHASE_DLY_CNT 8'd0
`define ddr3_ipcore_DMY_WIDTH 32
`define ddr3_ipcore_DMY_MSK_WIDTH 4
`define ddr3_ipcore_LATTICE_MAC
`define ddr3_ipcore_WL_VAL "1T"
