--VHDL instantiation template

component tdc_data is
    port (tdc_data_ram_Data: in std_logic_vector(15 downto 0);
        tdc_data_ram_Q: out std_logic_vector(15 downto 0);
        tdc_data_ram_RdAddress: in std_logic_vector(10 downto 0);
        tdc_data_ram_WrAddress: in std_logic_vector(10 downto 0);
        tdc_data_ram_RdClock: in std_logic;
        tdc_data_ram_RdClockEn: in std_logic;
        tdc_data_ram_Reset: in std_logic;
        tdc_data_ram_WE: in std_logic;
        tdc_data_ram_WrClock: in std_logic;
        tdc_data_ram_WrClockEn: in std_logic
    );
    
end component tdc_data; -- sbp_module=true 
_inst: tdc_data port map (tdc_data_ram_Data => __,tdc_data_ram_Q => __,tdc_data_ram_RdAddress => __,
            tdc_data_ram_WrAddress => __,tdc_data_ram_RdClock => __,tdc_data_ram_RdClockEn => __,
            tdc_data_ram_Reset => __,tdc_data_ram_WE => __,tdc_data_ram_WrClock => __,
            tdc_data_ram_WrClockEn => __);
