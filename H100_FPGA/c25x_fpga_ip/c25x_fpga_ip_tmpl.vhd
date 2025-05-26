--VHDL instantiation template

component c25x_fpga_ip is
    port (cache_opto_ram_Data: in std_logic_vector(15 downto 0);
        cache_opto_ram_Q: out std_logic_vector(15 downto 0);
        cache_opto_ram_RdAddress: in std_logic_vector(7 downto 0);
        cache_opto_ram_WrAddress: in std_logic_vector(7 downto 0);
        distance_ram_Data: in std_logic_vector(63 downto 0);
        distance_ram_Q: out std_logic_vector(63 downto 0);
        distance_ram_RdAddress: in std_logic_vector(7 downto 0);
        distance_ram_WrAddress: in std_logic_vector(7 downto 0);
        eth_data_ram_Data: in std_logic_vector(7 downto 0);
        eth_data_ram_Q: out std_logic_vector(7 downto 0);
        eth_data_ram_RdAddress: in std_logic_vector(9 downto 0);
        eth_data_ram_WrAddress: in std_logic_vector(9 downto 0);
        eth_send_ram_Data: in std_logic_vector(7 downto 0);
        eth_send_ram_Q: out std_logic_vector(7 downto 0);
        eth_send_ram_RdAddress: in std_logic_vector(10 downto 0);
        eth_send_ram_WrAddress: in std_logic_vector(10 downto 0);
        multiplier3_DataA: in std_logic_vector(7 downto 0);
        multiplier3_DataB: in std_logic_vector(7 downto 0);
        multiplier3_Result: out std_logic_vector(15 downto 0);
        multiplier_DataA: in std_logic_vector(15 downto 0);
        multiplier_DataB: in std_logic_vector(15 downto 0);
        multiplier_Result: out std_logic_vector(31 downto 0);
        opto_ram_Data: in std_logic_vector(7 downto 0);
        opto_ram_Q: out std_logic_vector(7 downto 0);
        opto_ram_RdAddress: in std_logic_vector(7 downto 0);
        opto_ram_WrAddress: in std_logic_vector(7 downto 0);
        packet_data_ram_Data: in std_logic_vector(7 downto 0);
        packet_data_ram_Q: out std_logic_vector(7 downto 0);
        packet_data_ram_RdAddress: in std_logic_vector(9 downto 0);
        packet_data_ram_WrAddress: in std_logic_vector(9 downto 0);
        tcp_recv_fifo_Data: in std_logic_vector(7 downto 0);
        tcp_recv_fifo_Q: out std_logic_vector(7 downto 0);
        tcp_recv_fifo_WCNT: out std_logic_vector(11 downto 0);
        c25x_pll_CLKI: in std_logic;
        c25x_pll_CLKOP: out std_logic;
        c25x_pll_CLKOS: out std_logic;
        c25x_pll_CLKOS2: out std_logic;
        cache_opto_ram_RdClock: in std_logic;
        cache_opto_ram_RdClockEn: in std_logic;
        cache_opto_ram_Reset: in std_logic;
        cache_opto_ram_WE: in std_logic;
        cache_opto_ram_WrClock: in std_logic;
        cache_opto_ram_WrClockEn: in std_logic;
        distance_ram_RdClock: in std_logic;
        distance_ram_RdClockEn: in std_logic;
        distance_ram_Reset: in std_logic;
        distance_ram_WE: in std_logic;
        distance_ram_WrClock: in std_logic;
        distance_ram_WrClockEn: in std_logic;
        eth_data_ram_RdClock: in std_logic;
        eth_data_ram_RdClockEn: in std_logic;
        eth_data_ram_Reset: in std_logic;
        eth_data_ram_WE: in std_logic;
        eth_data_ram_WrClock: in std_logic;
        eth_data_ram_WrClockEn: in std_logic;
        eth_send_ram_RdClock: in std_logic;
        eth_send_ram_RdClockEn: in std_logic;
        eth_send_ram_Reset: in std_logic;
        eth_send_ram_WE: in std_logic;
        eth_send_ram_WrClock: in std_logic;
        eth_send_ram_WrClockEn: in std_logic;
        multiplier3_Aclr: in std_logic;
        multiplier3_ClkEn: in std_logic;
        multiplier3_Clock: in std_logic;
        multiplier_Aclr: in std_logic;
        multiplier_ClkEn: in std_logic;
        multiplier_Clock: in std_logic;
        opto_ram_RdClock: in std_logic;
        opto_ram_RdClockEn: in std_logic;
        opto_ram_Reset: in std_logic;
        opto_ram_WE: in std_logic;
        opto_ram_WrClock: in std_logic;
        opto_ram_WrClockEn: in std_logic;
        packet_data_ram_RdClock: in std_logic;
        packet_data_ram_RdClockEn: in std_logic;
        packet_data_ram_Reset: in std_logic;
        packet_data_ram_WE: in std_logic;
        packet_data_ram_WrClock: in std_logic;
        packet_data_ram_WrClockEn: in std_logic;
        tcp_recv_fifo_Clock: in std_logic;
        tcp_recv_fifo_Empty: out std_logic;
        tcp_recv_fifo_Full: out std_logic;
        tcp_recv_fifo_RdEn: in std_logic;
        tcp_recv_fifo_Reset: in std_logic;
        tcp_recv_fifo_WrEn: in std_logic
    );
    
end component c25x_fpga_ip; -- sbp_module=true 
_inst: c25x_fpga_ip port map (c25x_pll_CLKI => __,c25x_pll_CLKOP => __,c25x_pll_CLKOS => __,
            c25x_pll_CLKOS2 => __,cache_opto_ram_Data => __,cache_opto_ram_Q => __,
            cache_opto_ram_RdAddress => __,cache_opto_ram_WrAddress => __,
            cache_opto_ram_RdClock => __,cache_opto_ram_RdClockEn => __,cache_opto_ram_Reset => __,
            cache_opto_ram_WE => __,cache_opto_ram_WrClock => __,cache_opto_ram_WrClockEn => __,
            distance_ram_Data => __,distance_ram_Q => __,distance_ram_RdAddress => __,
            distance_ram_WrAddress => __,distance_ram_RdClock => __,distance_ram_RdClockEn => __,
            distance_ram_Reset => __,distance_ram_WE => __,distance_ram_WrClock => __,
            distance_ram_WrClockEn => __,eth_data_ram_Data => __,eth_data_ram_Q => __,
            eth_data_ram_RdAddress => __,eth_data_ram_WrAddress => __,eth_data_ram_RdClock => __,
            eth_data_ram_RdClockEn => __,eth_data_ram_Reset => __,eth_data_ram_WE => __,
            eth_data_ram_WrClock => __,eth_data_ram_WrClockEn => __,packet_data_ram_Data => __,
            packet_data_ram_Q => __,packet_data_ram_RdAddress => __,packet_data_ram_WrAddress => __,
            packet_data_ram_RdClock => __,packet_data_ram_RdClockEn => __,
            packet_data_ram_Reset => __,packet_data_ram_WE => __,packet_data_ram_WrClock => __,
            packet_data_ram_WrClockEn => __,eth_send_ram_Data => __,eth_send_ram_Q => __,
            eth_send_ram_RdAddress => __,eth_send_ram_WrAddress => __,eth_send_ram_RdClock => __,
            eth_send_ram_RdClockEn => __,eth_send_ram_Reset => __,eth_send_ram_WE => __,
            eth_send_ram_WrClock => __,eth_send_ram_WrClockEn => __,multiplier_DataA => __,
            multiplier_DataB => __,multiplier_Result => __,multiplier_Aclr => __,
            multiplier_ClkEn => __,multiplier_Clock => __,tcp_recv_fifo_Data => __,
            tcp_recv_fifo_Q => __,tcp_recv_fifo_WCNT => __,tcp_recv_fifo_Clock => __,
            tcp_recv_fifo_Empty => __,tcp_recv_fifo_Full => __,tcp_recv_fifo_RdEn => __,
            tcp_recv_fifo_Reset => __,tcp_recv_fifo_WrEn => __,opto_ram_Data => __,
            opto_ram_Q => __,opto_ram_RdAddress => __,opto_ram_WrAddress => __,
            opto_ram_RdClock => __,opto_ram_RdClockEn => __,opto_ram_Reset => __,
            opto_ram_WE => __,opto_ram_WrClock => __,opto_ram_WrClockEn => __,
            multiplier3_DataA => __,multiplier3_DataB => __,multiplier3_Result => __,
            multiplier3_Aclr => __,multiplier3_ClkEn => __,multiplier3_Clock => __);
