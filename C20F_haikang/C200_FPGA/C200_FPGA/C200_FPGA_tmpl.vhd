--VHDL instantiation template

component C200_FPGA is
    port (C200_PLL_CLKI: in std_logic;
        C200_PLL_CLKOP: out std_logic;
        C200_PLL_CLKOS: out std_logic
    );
    
end component C200_FPGA; -- sbp_module=true 
_inst: C200_FPGA port map (C200_PLL_CLKI => __,C200_PLL_CLKOP => __,C200_PLL_CLKOS => __);
