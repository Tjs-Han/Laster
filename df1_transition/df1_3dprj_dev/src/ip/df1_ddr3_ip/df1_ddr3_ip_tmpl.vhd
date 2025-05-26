--VHDL instantiation template

component df1_ddr3_ip is
    port (ddr3_ipcore_addr: in std_logic_vector(26 downto 0);
        ddr3_ipcore_cmd: in std_logic_vector(3 downto 0);
        ddr3_ipcore_cmd_burst_cnt: in std_logic_vector(4 downto 0);
        ddr3_ipcore_data_mask: in std_logic_vector(7 downto 0);
        ddr3_ipcore_em_ddr_addr: out std_logic_vector(13 downto 0);
        ddr3_ipcore_em_ddr_ba: out std_logic_vector(2 downto 0);
        ddr3_ipcore_em_ddr_cke: out std_logic_vector(0 downto 0);
        ddr3_ipcore_em_ddr_clk: out std_logic_vector(0 downto 0);
        ddr3_ipcore_em_ddr_cs_n: out std_logic_vector(0 downto 0);
        ddr3_ipcore_em_ddr_data: inout std_logic_vector(15 downto 0);
        ddr3_ipcore_em_ddr_dm: out std_logic_vector(1 downto 0);
        ddr3_ipcore_em_ddr_dqs: inout std_logic_vector(1 downto 0);
        ddr3_ipcore_em_ddr_odt: out std_logic_vector(0 downto 0);
        ddr3_ipcore_read_data: out std_logic_vector(63 downto 0);
        ddr3_ipcore_write_data: in std_logic_vector(63 downto 0);
        ddr3_ipcore_clk_in: in std_logic;
        ddr3_ipcore_clocking_good: out std_logic;
        ddr3_ipcore_cmd_rdy: out std_logic;
        ddr3_ipcore_cmd_valid: in std_logic;
        ddr3_ipcore_datain_rdy: out std_logic;
        ddr3_ipcore_em_ddr_cas_n: out std_logic;
        ddr3_ipcore_em_ddr_ras_n: out std_logic;
        ddr3_ipcore_em_ddr_reset_n: out std_logic;
        ddr3_ipcore_em_ddr_we_n: out std_logic;
        ddr3_ipcore_init_done: out std_logic;
        ddr3_ipcore_init_start: in std_logic;
        ddr3_ipcore_mem_rst_n: in std_logic;
        ddr3_ipcore_ofly_burst_len: in std_logic;
        ddr3_ipcore_read_data_valid: out std_logic;
        ddr3_ipcore_rst_n: in std_logic;
        ddr3_ipcore_rt_err: out std_logic;
        ddr3_ipcore_sclk_out: out std_logic;
        ddr3_ipcore_wl_err: out std_logic
    );
    
end component df1_ddr3_ip; -- sbp_module=true 
_inst: df1_ddr3_ip port map (ddr3_ipcore_addr => __,ddr3_ipcore_cmd => __,
            ddr3_ipcore_cmd_burst_cnt => __,ddr3_ipcore_data_mask => __,ddr3_ipcore_em_ddr_addr => __,
            ddr3_ipcore_em_ddr_ba => __,ddr3_ipcore_em_ddr_cke => __,ddr3_ipcore_em_ddr_clk => __,
            ddr3_ipcore_em_ddr_cs_n => __,ddr3_ipcore_em_ddr_data => __,ddr3_ipcore_em_ddr_dm => __,
            ddr3_ipcore_em_ddr_dqs => __,ddr3_ipcore_em_ddr_odt => __,ddr3_ipcore_read_data => __,
            ddr3_ipcore_write_data => __,ddr3_ipcore_clk_in => __,ddr3_ipcore_clocking_good => __,
            ddr3_ipcore_cmd_rdy => __,ddr3_ipcore_cmd_valid => __,ddr3_ipcore_datain_rdy => __,
            ddr3_ipcore_em_ddr_cas_n => __,ddr3_ipcore_em_ddr_ras_n => __,
            ddr3_ipcore_em_ddr_reset_n => __,ddr3_ipcore_em_ddr_we_n => __,
            ddr3_ipcore_init_done => __,ddr3_ipcore_init_start => __,ddr3_ipcore_mem_rst_n => __,
            ddr3_ipcore_ofly_burst_len => __,ddr3_ipcore_read_data_valid => __,
            ddr3_ipcore_rst_n => __,ddr3_ipcore_rt_err => __,ddr3_ipcore_sclk_out => __,
            ddr3_ipcore_wl_err => __);
