/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module tdc_data
//
module tdc_data (tdc_data_ram_Data, tdc_data_ram_Q, tdc_data_ram_RdAddress, 
            tdc_data_ram_WrAddress, tdc_data_ram_RdClock, tdc_data_ram_RdClockEn, 
            tdc_data_ram_Reset, tdc_data_ram_WE, tdc_data_ram_WrClock, 
            tdc_data_ram_WrClockEn) /* synthesis sbp_module=true */ ;
    input [15:0]tdc_data_ram_Data;
    output [15:0]tdc_data_ram_Q;
    input [10:0]tdc_data_ram_RdAddress;
    input [10:0]tdc_data_ram_WrAddress;
    input tdc_data_ram_RdClock;
    input tdc_data_ram_RdClockEn;
    input tdc_data_ram_Reset;
    input tdc_data_ram_WE;
    input tdc_data_ram_WrClock;
    input tdc_data_ram_WrClockEn;
    
    
    tdc_data_ram tdc_data_ram_inst (.Data({tdc_data_ram_Data}), .Q({tdc_data_ram_Q}), 
            .RdAddress({tdc_data_ram_RdAddress}), .WrAddress({tdc_data_ram_WrAddress}), 
            .RdClock(tdc_data_ram_RdClock), .RdClockEn(tdc_data_ram_RdClockEn), 
            .Reset(tdc_data_ram_Reset), .WE(tdc_data_ram_WE), .WrClock(tdc_data_ram_WrClock), 
            .WrClockEn(tdc_data_ram_WrClockEn));
    
endmodule

