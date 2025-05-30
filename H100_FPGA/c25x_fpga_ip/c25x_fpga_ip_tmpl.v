//Verilog instantiation template

c25x_fpga_ip _inst (.c25x_pll_CLKI(), .c25x_pll_CLKOP(), .c25x_pll_CLKOS(), 
            .c25x_pll_CLKOS2(), .cache_opto_ram_Data(), .cache_opto_ram_Q(), 
            .cache_opto_ram_RdAddress(), .cache_opto_ram_WrAddress(), .cache_opto_ram_RdClock(), 
            .cache_opto_ram_RdClockEn(), .cache_opto_ram_Reset(), .cache_opto_ram_WE(), 
            .cache_opto_ram_WrClock(), .cache_opto_ram_WrClockEn(), .distance_ram_Data(), 
            .distance_ram_Q(), .distance_ram_RdAddress(), .distance_ram_WrAddress(), 
            .distance_ram_RdClock(), .distance_ram_RdClockEn(), .distance_ram_Reset(), 
            .distance_ram_WE(), .distance_ram_WrClock(), .distance_ram_WrClockEn(), 
            .eth_data_ram_Data(), .eth_data_ram_Q(), .eth_data_ram_RdAddress(), 
            .eth_data_ram_WrAddress(), .eth_data_ram_RdClock(), .eth_data_ram_RdClockEn(), 
            .eth_data_ram_Reset(), .eth_data_ram_WE(), .eth_data_ram_WrClock(), 
            .eth_data_ram_WrClockEn(), .packet_data_ram_Data(), .packet_data_ram_Q(), 
            .packet_data_ram_RdAddress(), .packet_data_ram_WrAddress(), 
            .packet_data_ram_RdClock(), .packet_data_ram_RdClockEn(), .packet_data_ram_Reset(), 
            .packet_data_ram_WE(), .packet_data_ram_WrClock(), .packet_data_ram_WrClockEn(), 
            .eth_send_ram_Data(), .eth_send_ram_Q(), .eth_send_ram_RdAddress(), 
            .eth_send_ram_WrAddress(), .eth_send_ram_RdClock(), .eth_send_ram_RdClockEn(), 
            .eth_send_ram_Reset(), .eth_send_ram_WE(), .eth_send_ram_WrClock(), 
            .eth_send_ram_WrClockEn(), .multiplier_DataA(), .multiplier_DataB(), 
            .multiplier_Result(), .multiplier_Aclr(), .multiplier_ClkEn(), 
            .multiplier_Clock(), .tcp_recv_fifo_Data(), .tcp_recv_fifo_Q(), 
            .tcp_recv_fifo_WCNT(), .tcp_recv_fifo_Clock(), .tcp_recv_fifo_Empty(), 
            .tcp_recv_fifo_Full(), .tcp_recv_fifo_RdEn(), .tcp_recv_fifo_Reset(), 
            .tcp_recv_fifo_WrEn(), .opto_ram_Data(), .opto_ram_Q(), .opto_ram_RdAddress(), 
            .opto_ram_WrAddress(), .opto_ram_RdClock(), .opto_ram_RdClockEn(), 
            .opto_ram_Reset(), .opto_ram_WE(), .opto_ram_WrClock(), .opto_ram_WrClockEn(), 
            .multiplier3_DataA(), .multiplier3_DataB(), .multiplier3_Result(), 
            .multiplier3_Aclr(), .multiplier3_ClkEn(), .multiplier3_Clock());