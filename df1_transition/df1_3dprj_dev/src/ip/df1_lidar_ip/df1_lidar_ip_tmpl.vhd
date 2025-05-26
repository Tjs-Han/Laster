--VHDL instantiation template

component df1_lidar_ip is
    port (asfifo_256x64_Data: in std_logic_vector(63 downto 0);
        asfifo_256x64_Q: out std_logic_vector(63 downto 0);
        asfifo_256x96_Data: in std_logic_vector(95 downto 0);
        asfifo_256x96_Q: out std_logic_vector(95 downto 0);
        asfifo_decode_Data: in std_logic_vector(9 downto 0);
        asfifo_decode_Q: out std_logic_vector(9 downto 0);
        code_ram128x32_Data: in std_logic_vector(31 downto 0);
        code_ram128x32_Q: out std_logic_vector(7 downto 0);
        code_ram128x32_RdAddress: in std_logic_vector(8 downto 0);
        code_ram128x32_WrAddress: in std_logic_vector(6 downto 0);
        dataram_1024x8_Data: in std_logic_vector(7 downto 0);
        dataram_1024x8_Q: out std_logic_vector(7 downto 0);
        dataram_1024x8_RdAddress: in std_logic_vector(9 downto 0);
        dataram_1024x8_WrAddress: in std_logic_vector(9 downto 0);
        dataram_2048x8_Data: in std_logic_vector(7 downto 0);
        dataram_2048x8_Q: out std_logic_vector(7 downto 0);
        dataram_2048x8_RdAddress: in std_logic_vector(10 downto 0);
        dataram_2048x8_WrAddress: in std_logic_vector(10 downto 0);
        dcfifo_rmiirx_36x2_Data: in std_logic_vector(1 downto 0);
        dcfifo_rmiirx_36x2_Q: out std_logic_vector(1 downto 0);
        dcfifo_rmiitx_2048x2_Data: in std_logic_vector(1 downto 0);
        dcfifo_rmiitx_2048x2_Q: out std_logic_vector(1 downto 0);
        dcfifo_rmiitx_4096x2_Data: in std_logic_vector(1 downto 0);
        dcfifo_rmiitx_4096x2_Q: out std_logic_vector(1 downto 0);
        divider_24bit_denominator: in std_logic_vector(15 downto 0);
        divider_24bit_numerator: in std_logic_vector(23 downto 0);
        divider_24bit_quotient: out std_logic_vector(23 downto 0);
        divider_24bit_remainder: out std_logic_vector(15 downto 0);
        divider_32x24_denominator: in std_logic_vector(23 downto 0);
        divider_32x24_numerator: in std_logic_vector(31 downto 0);
        divider_32x24_quotient: out std_logic_vector(31 downto 0);
        divider_32x24_remainder: out std_logic_vector(23 downto 0);
        divider_34x16_denominator: in std_logic_vector(15 downto 0);
        divider_34x16_numerator: in std_logic_vector(33 downto 0);
        divider_34x16_quotient: out std_logic_vector(33 downto 0);
        divider_34x16_remainder: out std_logic_vector(15 downto 0);
        fifo_mac_frame_2048x10_Data: in std_logic_vector(9 downto 0);
        fifo_mac_frame_2048x10_Q: out std_logic_vector(9 downto 0);
        iddrx2f_datain: in std_logic_vector(0 downto 0);
        iddrx2f_dcntl: out std_logic_vector(7 downto 0);
        iddrx2f_q: out std_logic_vector(3 downto 0);
        mpt2042_rom_Address: in std_logic_vector(6 downto 0);
        mpt2042_rom_Q: out std_logic_vector(7 downto 0);
        multiplier_10x32_DataA: in std_logic_vector(9 downto 0);
        multiplier_10x32_DataB: in std_logic_vector(23 downto 0);
        multiplier_10x32_Result: out std_logic_vector(33 downto 0);
        multiplier_16x8_DataA: in std_logic_vector(15 downto 0);
        multiplier_16x8_DataB: in std_logic_vector(7 downto 0);
        multiplier_16x8_Result: out std_logic_vector(23 downto 0);
        multiplier_DataA: in std_logic_vector(15 downto 0);
        multiplier_DataB: in std_logic_vector(15 downto 0);
        multiplier_Result: out std_logic_vector(31 downto 0);
        multiplier_in32bit_DataA: in std_logic_vector(9 downto 0);
        multiplier_in32bit_DataB: in std_logic_vector(31 downto 0);
        multiplier_in32bit_Result: out std_logic_vector(41 downto 0);
        sfifo128x88_Data: in std_logic_vector(87 downto 0);
        sfifo128x88_Q: out std_logic_vector(87 downto 0);
        sfifo_128x96_Data: in std_logic_vector(95 downto 0);
        sfifo_128x96_Q: out std_logic_vector(95 downto 0);
        sfifo_64x48_Data: in std_logic_vector(47 downto 0);
        sfifo_64x48_Q: out std_logic_vector(47 downto 0);
        sub_ip_DataA: in std_logic_vector(31 downto 0);
        sub_ip_DataB: in std_logic_vector(31 downto 0);
        sub_ip_Result: out std_logic_vector(31 downto 0);
        synfifo_data_2048x8_Data: in std_logic_vector(7 downto 0);
        synfifo_data_2048x8_Q: out std_logic_vector(7 downto 0);
        asfifo_256x64_Empty: out std_logic;
        asfifo_256x64_Full: out std_logic;
        asfifo_256x64_RPReset: in std_logic;
        asfifo_256x64_RdClock: in std_logic;
        asfifo_256x64_RdEn: in std_logic;
        asfifo_256x64_Reset: in std_logic;
        asfifo_256x64_WrClock: in std_logic;
        asfifo_256x64_WrEn: in std_logic;
        asfifo_256x96_Empty: out std_logic;
        asfifo_256x96_Full: out std_logic;
        asfifo_256x96_RPReset: in std_logic;
        asfifo_256x96_RdClock: in std_logic;
        asfifo_256x96_RdEn: in std_logic;
        asfifo_256x96_Reset: in std_logic;
        asfifo_256x96_WrClock: in std_logic;
        asfifo_256x96_WrEn: in std_logic;
        asfifo_decode_Empty: out std_logic;
        asfifo_decode_Full: out std_logic;
        asfifo_decode_RPReset: in std_logic;
        asfifo_decode_RdClock: in std_logic;
        asfifo_decode_RdEn: in std_logic;
        asfifo_decode_Reset: in std_logic;
        asfifo_decode_WrClock: in std_logic;
        asfifo_decode_WrEn: in std_logic;
        code_ram128x32_RdClock: in std_logic;
        code_ram128x32_RdClockEn: in std_logic;
        code_ram128x32_Reset: in std_logic;
        code_ram128x32_WE: in std_logic;
        code_ram128x32_WrClock: in std_logic;
        code_ram128x32_WrClockEn: in std_logic;
        dataram_1024x8_RdClock: in std_logic;
        dataram_1024x8_RdClockEn: in std_logic;
        dataram_1024x8_Reset: in std_logic;
        dataram_1024x8_WE: in std_logic;
        dataram_1024x8_WrClock: in std_logic;
        dataram_1024x8_WrClockEn: in std_logic;
        dataram_2048x8_RdClock: in std_logic;
        dataram_2048x8_RdClockEn: in std_logic;
        dataram_2048x8_Reset: in std_logic;
        dataram_2048x8_WE: in std_logic;
        dataram_2048x8_WrClock: in std_logic;
        dataram_2048x8_WrClockEn: in std_logic;
        dcfifo_rmiirx_36x2_Empty: out std_logic;
        dcfifo_rmiirx_36x2_Full: out std_logic;
        dcfifo_rmiirx_36x2_RPReset: in std_logic;
        dcfifo_rmiirx_36x2_RdClock: in std_logic;
        dcfifo_rmiirx_36x2_RdEn: in std_logic;
        dcfifo_rmiirx_36x2_Reset: in std_logic;
        dcfifo_rmiirx_36x2_WrClock: in std_logic;
        dcfifo_rmiirx_36x2_WrEn: in std_logic;
        dcfifo_rmiitx_2048x2_Empty: out std_logic;
        dcfifo_rmiitx_2048x2_Full: out std_logic;
        dcfifo_rmiitx_2048x2_RPReset: in std_logic;
        dcfifo_rmiitx_2048x2_RdClock: in std_logic;
        dcfifo_rmiitx_2048x2_RdEn: in std_logic;
        dcfifo_rmiitx_2048x2_Reset: in std_logic;
        dcfifo_rmiitx_2048x2_WrClock: in std_logic;
        dcfifo_rmiitx_2048x2_WrEn: in std_logic;
        dcfifo_rmiitx_4096x2_Empty: out std_logic;
        dcfifo_rmiitx_4096x2_Full: out std_logic;
        dcfifo_rmiitx_4096x2_RPReset: in std_logic;
        dcfifo_rmiitx_4096x2_RdClock: in std_logic;
        dcfifo_rmiitx_4096x2_RdEn: in std_logic;
        dcfifo_rmiitx_4096x2_Reset: in std_logic;
        dcfifo_rmiitx_4096x2_WrClock: in std_logic;
        dcfifo_rmiitx_4096x2_WrEn: in std_logic;
        divider_24bit_clk: in std_logic;
        divider_24bit_rstn: in std_logic;
        divider_32x24_clk: in std_logic;
        divider_32x24_rstn: in std_logic;
        divider_34x16_clk: in std_logic;
        divider_34x16_dvalid_in: in std_logic;
        divider_34x16_dvalid_out: out std_logic;
        divider_34x16_rstn: in std_logic;
        eth_pll_CLKI: in std_logic;
        eth_pll_CLKOP: out std_logic;
        fifo_mac_frame_2048x10_Clock: in std_logic;
        fifo_mac_frame_2048x10_Empty: out std_logic;
        fifo_mac_frame_2048x10_Full: out std_logic;
        fifo_mac_frame_2048x10_RdEn: in std_logic;
        fifo_mac_frame_2048x10_Reset: in std_logic;
        fifo_mac_frame_2048x10_WrEn: in std_logic;
        iddrx2f_alignwd: in std_logic;
        iddrx2f_clkin: in std_logic;
        iddrx2f_ready: out std_logic;
        iddrx2f_sclk: out std_logic;
        iddrx2f_sync_clk: in std_logic;
        iddrx2f_sync_reset: in std_logic;
        iddrx2f_update: in std_logic;
        mpt2042_rom_OutClock: in std_logic;
        mpt2042_rom_OutClockEn: in std_logic;
        mpt2042_rom_Reset: in std_logic;
        multiplier_10x32_Aclr: in std_logic;
        multiplier_10x32_ClkEn: in std_logic;
        multiplier_10x32_Clock: in std_logic;
        multiplier_16x8_Aclr: in std_logic;
        multiplier_16x8_ClkEn: in std_logic;
        multiplier_16x8_Clock: in std_logic;
        multiplier_Aclr: in std_logic;
        multiplier_ClkEn: in std_logic;
        multiplier_Clock: in std_logic;
        multiplier_in32bit_Aclr: in std_logic;
        multiplier_in32bit_ClkEn: in std_logic;
        multiplier_in32bit_Clock: in std_logic;
        pll_CLKI: in std_logic;
        pll_CLKOP: out std_logic;
        pll_CLKOS: out std_logic;
        pll_CLKOS2: out std_logic;
        pll_LOCK: out std_logic;
        sfifo128x88_Clock: in std_logic;
        sfifo128x88_Empty: out std_logic;
        sfifo128x88_Full: out std_logic;
        sfifo128x88_RdEn: in std_logic;
        sfifo128x88_Reset: in std_logic;
        sfifo128x88_WrEn: in std_logic;
        sfifo_128x96_Clock: in std_logic;
        sfifo_128x96_Empty: out std_logic;
        sfifo_128x96_Full: out std_logic;
        sfifo_128x96_RdEn: in std_logic;
        sfifo_128x96_Reset: in std_logic;
        sfifo_128x96_WrEn: in std_logic;
        sfifo_64x48_Clock: in std_logic;
        sfifo_64x48_Empty: out std_logic;
        sfifo_64x48_Full: out std_logic;
        sfifo_64x48_RdEn: in std_logic;
        sfifo_64x48_Reset: in std_logic;
        sfifo_64x48_WrEn: in std_logic;
        synfifo_data_2048x8_Clock: in std_logic;
        synfifo_data_2048x8_Empty: out std_logic;
        synfifo_data_2048x8_Full: out std_logic;
        synfifo_data_2048x8_RdEn: in std_logic;
        synfifo_data_2048x8_Reset: in std_logic;
        synfifo_data_2048x8_WrEn: in std_logic
    );
    
end component df1_lidar_ip; -- sbp_module=true 
_inst: df1_lidar_ip port map (code_ram128x32_Data => __,code_ram128x32_Q => __,
            code_ram128x32_RdAddress => __,code_ram128x32_WrAddress => __,
            code_ram128x32_RdClock => __,code_ram128x32_RdClockEn => __,code_ram128x32_Reset => __,
            code_ram128x32_WE => __,code_ram128x32_WrClock => __,code_ram128x32_WrClockEn => __,
            dataram_1024x8_Data => __,dataram_1024x8_Q => __,dataram_1024x8_RdAddress => __,
            dataram_1024x8_WrAddress => __,dataram_1024x8_RdClock => __,dataram_1024x8_RdClockEn => __,
            dataram_1024x8_Reset => __,dataram_1024x8_WE => __,dataram_1024x8_WrClock => __,
            dataram_1024x8_WrClockEn => __,dataram_2048x8_Data => __,dataram_2048x8_Q => __,
            dataram_2048x8_RdAddress => __,dataram_2048x8_WrAddress => __,
            dataram_2048x8_RdClock => __,dataram_2048x8_RdClockEn => __,dataram_2048x8_Reset => __,
            dataram_2048x8_WE => __,dataram_2048x8_WrClock => __,dataram_2048x8_WrClockEn => __,
            dcfifo_rmiirx_36x2_Data => __,dcfifo_rmiirx_36x2_Q => __,dcfifo_rmiirx_36x2_Empty => __,
            dcfifo_rmiirx_36x2_Full => __,dcfifo_rmiirx_36x2_RPReset => __,
            dcfifo_rmiirx_36x2_RdClock => __,dcfifo_rmiirx_36x2_RdEn => __,
            dcfifo_rmiirx_36x2_Reset => __,dcfifo_rmiirx_36x2_WrClock => __,
            dcfifo_rmiirx_36x2_WrEn => __,dcfifo_rmiitx_2048x2_Data => __,
            dcfifo_rmiitx_2048x2_Q => __,dcfifo_rmiitx_2048x2_Empty => __,
            dcfifo_rmiitx_2048x2_Full => __,dcfifo_rmiitx_2048x2_RPReset => __,
            dcfifo_rmiitx_2048x2_RdClock => __,dcfifo_rmiitx_2048x2_RdEn => __,
            dcfifo_rmiitx_2048x2_Reset => __,dcfifo_rmiitx_2048x2_WrClock => __,
            dcfifo_rmiitx_2048x2_WrEn => __,dcfifo_rmiitx_4096x2_Data => __,
            dcfifo_rmiitx_4096x2_Q => __,dcfifo_rmiitx_4096x2_Empty => __,
            dcfifo_rmiitx_4096x2_Full => __,dcfifo_rmiitx_4096x2_RPReset => __,
            dcfifo_rmiitx_4096x2_RdClock => __,dcfifo_rmiitx_4096x2_RdEn => __,
            dcfifo_rmiitx_4096x2_Reset => __,dcfifo_rmiitx_4096x2_WrClock => __,
            dcfifo_rmiitx_4096x2_WrEn => __,divider_24bit_denominator => __,
            divider_24bit_numerator => __,divider_24bit_quotient => __,divider_24bit_remainder => __,
            divider_24bit_clk => __,divider_24bit_rstn => __,divider_32x24_denominator => __,
            divider_32x24_numerator => __,divider_32x24_quotient => __,divider_32x24_remainder => __,
            divider_32x24_clk => __,divider_32x24_rstn => __,divider_34x16_denominator => __,
            divider_34x16_numerator => __,divider_34x16_quotient => __,divider_34x16_remainder => __,
            divider_34x16_clk => __,divider_34x16_dvalid_in => __,divider_34x16_dvalid_out => __,
            divider_34x16_rstn => __,asfifo_decode_Data => __,asfifo_decode_Q => __,
            asfifo_decode_Empty => __,asfifo_decode_Full => __,asfifo_decode_RPReset => __,
            asfifo_decode_RdClock => __,asfifo_decode_RdEn => __,asfifo_decode_Reset => __,
            asfifo_decode_WrClock => __,asfifo_decode_WrEn => __,asfifo_256x64_Data => __,
            asfifo_256x64_Q => __,asfifo_256x64_Empty => __,asfifo_256x64_Full => __,
            asfifo_256x64_RPReset => __,asfifo_256x64_RdClock => __,asfifo_256x64_RdEn => __,
            asfifo_256x64_Reset => __,asfifo_256x64_WrClock => __,asfifo_256x64_WrEn => __,
            asfifo_256x96_Data => __,asfifo_256x96_Q => __,asfifo_256x96_Empty => __,
            asfifo_256x96_Full => __,asfifo_256x96_RPReset => __,asfifo_256x96_RdClock => __,
            asfifo_256x96_RdEn => __,asfifo_256x96_Reset => __,asfifo_256x96_WrClock => __,
            asfifo_256x96_WrEn => __,pll_CLKI => __,pll_CLKOP => __,pll_CLKOS => __,
            pll_CLKOS2 => __,pll_LOCK => __,fifo_mac_frame_2048x10_Data => __,
            fifo_mac_frame_2048x10_Q => __,fifo_mac_frame_2048x10_Clock => __,
            fifo_mac_frame_2048x10_Empty => __,fifo_mac_frame_2048x10_Full => __,
            fifo_mac_frame_2048x10_RdEn => __,fifo_mac_frame_2048x10_Reset => __,
            fifo_mac_frame_2048x10_WrEn => __,multiplier_10x32_DataA => __,
            multiplier_10x32_DataB => __,multiplier_10x32_Result => __,multiplier_10x32_Aclr => __,
            multiplier_10x32_ClkEn => __,multiplier_10x32_Clock => __,multiplier_16x8_DataA => __,
            multiplier_16x8_DataB => __,multiplier_16x8_Result => __,multiplier_16x8_Aclr => __,
            multiplier_16x8_ClkEn => __,multiplier_16x8_Clock => __,multiplier_in32bit_DataA => __,
            multiplier_in32bit_DataB => __,multiplier_in32bit_Result => __,
            multiplier_in32bit_Aclr => __,multiplier_in32bit_ClkEn => __,multiplier_in32bit_Clock => __,
            sfifo_64x48_Data => __,sfifo_64x48_Q => __,sfifo_64x48_Clock => __,
            sfifo_64x48_Empty => __,sfifo_64x48_Full => __,sfifo_64x48_RdEn => __,
            sfifo_64x48_Reset => __,sfifo_64x48_WrEn => __,eth_pll_CLKI => __,
            eth_pll_CLKOP => __,sub_ip_DataA => __,sub_ip_DataB => __,sub_ip_Result => __,
            synfifo_data_2048x8_Data => __,synfifo_data_2048x8_Q => __,synfifo_data_2048x8_Clock => __,
            synfifo_data_2048x8_Empty => __,synfifo_data_2048x8_Full => __,
            synfifo_data_2048x8_RdEn => __,synfifo_data_2048x8_Reset => __,
            synfifo_data_2048x8_WrEn => __,sfifo_128x96_Data => __,sfifo_128x96_Q => __,
            sfifo_128x96_Clock => __,sfifo_128x96_Empty => __,sfifo_128x96_Full => __,
            sfifo_128x96_RdEn => __,sfifo_128x96_Reset => __,sfifo_128x96_WrEn => __,
            sfifo128x88_Data => __,sfifo128x88_Q => __,sfifo128x88_Clock => __,
            sfifo128x88_Empty => __,sfifo128x88_Full => __,sfifo128x88_RdEn => __,
            sfifo128x88_Reset => __,sfifo128x88_WrEn => __,multiplier_DataA => __,
            multiplier_DataB => __,multiplier_Result => __,multiplier_Aclr => __,
            multiplier_ClkEn => __,multiplier_Clock => __,iddrx2f_datain => __,
            iddrx2f_dcntl => __,iddrx2f_q => __,iddrx2f_alignwd => __,iddrx2f_clkin => __,
            iddrx2f_ready => __,iddrx2f_sclk => __,iddrx2f_sync_clk => __,
            iddrx2f_sync_reset => __,iddrx2f_update => __,mpt2042_rom_Address => __,
            mpt2042_rom_Q => __,mpt2042_rom_OutClock => __,mpt2042_rom_OutClockEn => __,
            mpt2042_rom_Reset => __);
