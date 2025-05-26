lappend auto_path "C:/lscc/diamond/3.12/data/script"
package require simulation_generation
set ::bali::simulation::Para(DEVICEFAMILYNAME) {ECP5U}
set ::bali::simulation::Para(PROJECT) {tb_tdc_process}
set ::bali::simulation::Para(PROJECTPATH) {D:/programs/fpga/C200/C200/C200_FPGA/sim}
set ::bali::simulation::Para(FILELIST) {"D:/programs/fpga/C200/C200/C200_FPGA/tdc_data/tdc_data_ram/tdc_data_ram.v" "D:/programs/fpga/C200/C200/C200_FPGA/tdc_data/tdc_data.v" "D:/programs/fpga/C200/C200/C200_FPGA/dist/dist_packet.v" "D:/programs/fpga/C200/C200/C200_FPGA/dist/dist_filter.v" "D:/programs/fpga/C200/C200/C200_FPGA/C200_FPGA/multiplier/multiplier.v" "D:/programs/fpga/C200/C200/C200_FPGA/cal_process.v" "D:/programs/fpga/C200/C200/C200_FPGA/div_rill.v" "D:/programs/fpga/C200/C200/C200_FPGA/tdc_para.v" "D:/programs/fpga/C200/C200/C200_FPGA/tdc_process.v" "D:/programs/fpga/C200/C200/C200_FPGA/tb_tdc_process.v" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"work" "work" "work" "work" "work" "work" "work" "work" "work" "work" }
set ::bali::simulation::Para(COMPLIST) {"VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_ecp5u}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {tb_tdc_process}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VERILOG}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(INSTALLATIONPATH) {C:/lscc/diamond/3.12}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(HDLPARAMETERS) {}
set ::bali::simulation::Para(POJO2LIBREFRESH)    {}
set ::bali::simulation::Para(POJO2MODELSIMLIB)   {}
::bali::simulation::ModelSim_Run
