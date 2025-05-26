/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module df1_ddr3_ip
//
module df1_ddr3_ip (ddr3_ipcore_addr, ddr3_ipcore_cmd, ddr3_ipcore_cmd_burst_cnt, 
            ddr3_ipcore_data_mask, ddr3_ipcore_em_ddr_addr, ddr3_ipcore_em_ddr_ba, 
            ddr3_ipcore_em_ddr_cke, ddr3_ipcore_em_ddr_clk, ddr3_ipcore_em_ddr_cs_n, 
            ddr3_ipcore_em_ddr_data, ddr3_ipcore_em_ddr_dm, ddr3_ipcore_em_ddr_dqs, 
            ddr3_ipcore_em_ddr_odt, ddr3_ipcore_read_data, ddr3_ipcore_write_data, 
            ddr3_ipcore_clk_in, ddr3_ipcore_clocking_good, ddr3_ipcore_cmd_rdy, 
            ddr3_ipcore_cmd_valid, ddr3_ipcore_datain_rdy, ddr3_ipcore_em_ddr_cas_n, 
            ddr3_ipcore_em_ddr_ras_n, ddr3_ipcore_em_ddr_reset_n, ddr3_ipcore_em_ddr_we_n, 
            ddr3_ipcore_init_done, ddr3_ipcore_init_start, ddr3_ipcore_mem_rst_n, 
            ddr3_ipcore_ofly_burst_len, ddr3_ipcore_read_data_valid, ddr3_ipcore_rst_n, 
            ddr3_ipcore_rt_err, ddr3_ipcore_sclk_out, ddr3_ipcore_wl_err) /* synthesis sbp_module=true */ ;
    input [26:0]ddr3_ipcore_addr;
    input [3:0]ddr3_ipcore_cmd;
    input [4:0]ddr3_ipcore_cmd_burst_cnt;
    input [7:0]ddr3_ipcore_data_mask;
    output [13:0]ddr3_ipcore_em_ddr_addr;
    output [2:0]ddr3_ipcore_em_ddr_ba;
    output [0:0]ddr3_ipcore_em_ddr_cke;
    output [0:0]ddr3_ipcore_em_ddr_clk;
    output [0:0]ddr3_ipcore_em_ddr_cs_n;
    inout [15:0]ddr3_ipcore_em_ddr_data;
    output [1:0]ddr3_ipcore_em_ddr_dm;
    inout [1:0]ddr3_ipcore_em_ddr_dqs;
    output [0:0]ddr3_ipcore_em_ddr_odt;
    output [63:0]ddr3_ipcore_read_data;
    input [63:0]ddr3_ipcore_write_data;
    input ddr3_ipcore_clk_in;
    output ddr3_ipcore_clocking_good;
    output ddr3_ipcore_cmd_rdy;
    input ddr3_ipcore_cmd_valid;
    output ddr3_ipcore_datain_rdy;
    output ddr3_ipcore_em_ddr_cas_n;
    output ddr3_ipcore_em_ddr_ras_n;
    output ddr3_ipcore_em_ddr_reset_n;
    output ddr3_ipcore_em_ddr_we_n;
    output ddr3_ipcore_init_done;
    input ddr3_ipcore_init_start;
    input ddr3_ipcore_mem_rst_n;
    input ddr3_ipcore_ofly_burst_len;
    output ddr3_ipcore_read_data_valid;
    input ddr3_ipcore_rst_n;
    output ddr3_ipcore_rt_err;
    output ddr3_ipcore_sclk_out;
    output ddr3_ipcore_wl_err;
    
    
    ddr3_sdram_mem_top_ddr3_ipcore ddr3_ipcore_inst (.addr({ddr3_ipcore_addr}), 
            .cmd({ddr3_ipcore_cmd}), .cmd_burst_cnt({ddr3_ipcore_cmd_burst_cnt}), 
            .data_mask({ddr3_ipcore_data_mask}), .em_ddr_addr({ddr3_ipcore_em_ddr_addr}), 
            .em_ddr_ba({ddr3_ipcore_em_ddr_ba}), .em_ddr_cke({ddr3_ipcore_em_ddr_cke}), 
            .em_ddr_clk({ddr3_ipcore_em_ddr_clk}), .em_ddr_cs_n({ddr3_ipcore_em_ddr_cs_n}), 
            .em_ddr_data({ddr3_ipcore_em_ddr_data}), .em_ddr_dm({ddr3_ipcore_em_ddr_dm}), 
            .em_ddr_dqs({ddr3_ipcore_em_ddr_dqs}), .em_ddr_odt({ddr3_ipcore_em_ddr_odt}), 
            .read_data({ddr3_ipcore_read_data}), .write_data({ddr3_ipcore_write_data}), 
            .clk_in(ddr3_ipcore_clk_in), .clocking_good(ddr3_ipcore_clocking_good), 
            .cmd_rdy(ddr3_ipcore_cmd_rdy), .cmd_valid(ddr3_ipcore_cmd_valid), 
            .datain_rdy(ddr3_ipcore_datain_rdy), .em_ddr_cas_n(ddr3_ipcore_em_ddr_cas_n), 
            .em_ddr_ras_n(ddr3_ipcore_em_ddr_ras_n), .em_ddr_reset_n(ddr3_ipcore_em_ddr_reset_n), 
            .em_ddr_we_n(ddr3_ipcore_em_ddr_we_n), .init_done(ddr3_ipcore_init_done), 
            .init_start(ddr3_ipcore_init_start), .mem_rst_n(ddr3_ipcore_mem_rst_n), 
            .ofly_burst_len(ddr3_ipcore_ofly_burst_len), .read_data_valid(ddr3_ipcore_read_data_valid), 
            .rst_n(ddr3_ipcore_rst_n), .rt_err(ddr3_ipcore_rt_err), .sclk_out(ddr3_ipcore_sclk_out), 
            .wl_err(ddr3_ipcore_wl_err));
    
endmodule

