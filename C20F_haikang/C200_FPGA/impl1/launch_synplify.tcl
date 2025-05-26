#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file D:/programs/fpga/C200_FPGA/impl1/launch_synplify.tcl
#-- Written on Thu Jun  3 11:41:33 2021

project -close
set filename "D:/programs/fpga/C200_FPGA/impl1/impl1_syn.prj"
if ([file exists "$filename"]) {
	project -load "$filename"
	project_file -remove *
} else {
	project -new "$filename"
}
set create_new 0

#device options
set_option -technology ECP5U
set_option -part LFE5U_25F
set_option -package BG256C
set_option -speed_grade -6

if {$create_new == 1} {
#-- add synthesis options
	set_option -symbolic_fsm_compiler true
	set_option -resource_sharing true
	set_option -vlog_std v2001
	set_option -frequency 25
	set_option -maxfan 1000
	set_option -auto_constrain_io 0
	set_option -disable_io_insertion false
	set_option -retiming false; set_option -pipe true
	set_option -force_gsr false
	set_option -compiler_compatible 0
	set_option -dup false
	
	set_option -default_enum_encoding default
	
	
	
	set_option -write_apr_constraint 1
	set_option -fix_gated_and_generated_clocks 1
	set_option -update_models_cp 0
	set_option -resolve_multiple_driver 0
	
	
	set_option -seqshift_no_replicate 0
	
}
#-- add_file options
set_option -hdl_define -set SBP_SYNTHESIS
set_option -include_path "D:/programs/fpga/C200_FPGA"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/C200_FPGA.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/C200_FPGA/C200_PLL/C200_PLL.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/C200_FPGA/eth_data_fifo/eth_data_fifo.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/C200_FPGA/multiplier/multiplier.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/C200_FPGA/packet_data_fifo/packet_data_fifo.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/rotating_module.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/opto_switch_filter.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/motor_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/encoder_generate.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/laser_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/dist_measure.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/tdc_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/dist_calculate.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/sram_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/spi flash/spi_master.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/spi flash/spi_flash_top.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/spi flash/spi_flash_cmd.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/flash_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/eth/datagram_parser.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/eth/spi_w5500_cmd.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/eth/spi_w5500_top.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/eth/datagram_cmd_defines.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/eth/w5500_cmd_defines.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/eth/w5500_reg_defines.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/eth/tcp_recv_fifo.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/eth/tcp_send_fifo.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/w5500_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/parameter_init.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/data_packet.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/mcp4726a0_top.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/tla2024_cmd_defines.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/tla2024_top.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/i2c_master.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/self_inspection.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/parameter_ident_define.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/test.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/adc_to_dac.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/adc_to_temp.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/encoder_generate_2.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/adc_to_dac_2.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/adc_to_temp_2.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/division.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/TDC_SPI_ms1004.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/gp22/gp22_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/gp22/gp22_spi.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C200_FPGA/encoder_generate_3.v"
#-- top module name
set_option -top_module {C200_FPGA}
project -result_file {D:/programs/fpga/C200_FPGA/impl1/impl1.edi}
project -save "$filename"
