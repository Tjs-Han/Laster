#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file D:/programs/fpga/C251/C25X_21090810/c25x_fpga/launch_synplify.tcl
#-- Written on Wed Sep  8 13:56:01 2021

project -close
set filename "D:/programs/fpga/C251/C25X_21090810/c25x_fpga/c25x_fpga_syn.prj"
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
set_option -package BG256I
set_option -speed_grade -6

if {$create_new == 1} {
#-- add synthesis options
	set_option -symbolic_fsm_compiler true
	set_option -resource_sharing true
	set_option -vlog_std v2001
	set_option -frequency 200
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
set_option -include_path "D:/programs/fpga/C251/C25X_21090810"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/c25x_fpga.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/dist/calib_packet.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/dist/dist_calculate.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/dist/dist_filter.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/dist/dist_measure.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/dist/dist_packet.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/dist/measure_para.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/dist/tail_filter.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/dist/ms1004/ms1004_control_fall.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/dist/ms1004/ms1004_control_rise.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/dist/ms1004/TDC_SPI_ms1004_2.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/datagram_cmd_defines.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/datagram_parser.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/division.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/index_calculate.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/parameter_ident_define.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/parameter_init.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/spi_w5500_cmd.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/spi_w5500_top.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/time_stamp.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/w5500_cmd_defines.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/w5500_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/w5500_reg_defines.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/flash/flash_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/flash/USRMCLK.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/flash/spi flash/spi_master.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/flash/spi flash/spi_flash_top.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/flash/spi flash/spi_flash_cmd.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/insp/adc_to_dac.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/insp/adc_to_temp.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/insp/pluse_average.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/insp/self_inspection.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/insp/adda/AD_SPI.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/insp/adda/adc_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/insp/adda/DA_SPI.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/laser/laser_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/rotate/encoder_generate.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/rotate/motor_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/rotate/opto_switch_filter.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/rotate/rotate_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/sram/sram_control.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/c25x_fpga_ip/c25x_pll/c25x_pll.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/c25x_fpga_ip/eth_data_ram/eth_data_ram.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/c25x_fpga_ip/eth_send_ram/eth_send_ram.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/c25x_fpga_ip/multiplier/multiplier.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/c25x_fpga_ip/multiplier2/multiplier2.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/c25x_fpga_ip/multiplier3/multiplier3.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/c25x_fpga_ip/packet_data_ram/packet_data_ram.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/c25x_fpga_ip/tcp_recv_fifo/tcp_recv_fifo.v"
add_file -verilog -vlog_std v2001 "D:/programs/fpga/C251/C25X_21090810/source/eth/spi_master_eth.v"
#-- top module name
set_option -top_module {}
project -result_file {D:/programs/fpga/C251/C25X_21090810/c25x_fpga/c25x_fpga.edi}
project -save "$filename"
