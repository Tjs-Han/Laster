#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file D:/FreeWork/df1_demo/df1_lidar_top/prj/impl1/launch_synplify.tcl
#-- Written on Tue Dec 17 19:55:23 2024

project -close
set filename "D:/FreeWork/df1_demo/df1_lidar_top/prj/impl1/impl1_syn.prj"
if ([file exists "$filename"]) {
	project -load "$filename"
	project_file -remove *
} else {
	project -new "$filename"
}
set create_new 0

#device options
set_option -technology ECP5U
set_option -part LFE5U_45F
set_option -package BG256C
set_option -speed_grade -7

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
set_option -include_path "D:/FreeWork/df1_demo/df1_lidar_top/prj"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/df1_lidar_top.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/asfifo_256x64/asfifo_256x64.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/asfifo_256x96/asfifo_256x96.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/code_ram128x32/code_ram128x32.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/dataram_1024x8/dataram_1024x8.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/dataram_2048x8/dataram_2048x8.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/dcfifo_rmiirx_36x2/dcfifo_rmiirx_36x2.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/dcfifo_rmiitx_2048x2/dcfifo_rmiitx_2048x2.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/dcfifo_rmiitx_4096x2/dcfifo_rmiitx_4096x2.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/eth_pll/eth_pll.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/fifo_mac_frame_2048x10/fifo_mac_frame_2048x10.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/multiplier/multiplier.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/multiplier2/multiplier2.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/multiplier_in32bit/multiplier_in32bit.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/pll/pll.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/sfifo_128x96/sfifo_128x96.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/sub_ip/sub_ip.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/synfifo_data_2048x8/synfifo_data_2048x8.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_lidar_ip/df1_lidar_ip.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_ddr3_ip/ddr3_ipcore/ddr3_sdram_mem_top_wrapper_ddr3_ipcore.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_ddr3_ip/ddr3_ipcore/ddr3_ipcore_bb.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_ddr3_ip/ddr3_ipcore/ddr_clks_ddr3_ipcore_bb.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/ip/df1_ddr3_ip/df1_ddr3_ip.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/phy_mdio/phy_mdio_ctrl.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/phy_mdio/phy_mdio_drive.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/eth_top.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/eth_ctrl.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/rmii_top/rmii_top.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/rmii_top/rmii_rx.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/rmii_top/rmii_tx.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/mac_top/mac_top.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/mac_top/mac_rx.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/mac_top/mac_tx.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/arp/arp_ctrl.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/arp/arp_rx.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/arp/arp_tx.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/arp/crc32_d8.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/ip_top/ip_top.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/ip_top/icmp/icmp_top.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/ip_top/icmp/icmp_rx.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/ip_top/icmp/icmp_tx.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/ip_top/udp/udp_top.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/ip_top/udp/udp_rx.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/ip_top/udp/udp_tx.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/motor/motor_control.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/motor/motor_drive.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/motor/signal_dejitter.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/rotate/rotate_control.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/rotate/opto_switch_filter.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/rotate/motor_monit.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/rotate/encoder/encoder_control.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/rotate/encoder/sync_control.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/rotate/encoder/opto_switch.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/rotate/encoder/encoder_calculate.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/rotate/encoder/code_cnt.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/rotate/encoder/code_angle.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/laser/laser_control.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/insp/HV_control.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/insp/adc_control.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/insp/adc_to_dac.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/insp/adc_to_temp.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/insp/adc_to_dist_2.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/insp/pluse_average.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/insp/temp_adc_filter.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/insp/division.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/insp/DA_SPI_pwm.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/insp/dac_table.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/insp/AD_SPI.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/gpx2/gpx2_control_wrapper.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/gpx2/gpx2_cfg.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/gpx2/gpx2_spi_master.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/gpx2/data_fill.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/gpx2/gpx2_lvds_ctrl.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/gpx2/gpx2_lvds.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/data_communication/udpcom_datagram_parser.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/data_communication/datagram_cmd_defines.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/data_communication/parameter_ident_define.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/data_communication/udpcom_control.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/data_communication/udpcom_parameter_init.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/eth/data_communication/angle2index.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/data_packet/dist_measure.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/data_packet/loop_packet.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/data_packet/calib_packet.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/ddr/ddr3_init_ctrl.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/ddr/ddr3_rw_ctrl.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/ddr/ddr3_interface.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/ddr/ddr_round_robin.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/flash/flash_control.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/flash/USRMCLK.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/flash/spi flash/spi_flash_cmd.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/flash/spi flash/spi_flash_top.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/flash/spi flash/spi_master.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/data_packet/dist_calculate.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/data_packet/data_pre.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/data_packet/index_cal.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/data_packet/dist_cal.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/data_packet/rssi_cal.v"
add_file -verilog -vlog_std v2001 "D:/FreeWork/df1_demo/df1_lidar_top/src/rtl/data_packet/div_rill.v"
#-- top module name
set_option -top_module {df1_lidar_top}
project -result_file {D:/FreeWork/df1_demo/df1_lidar_top/prj/impl1/impl1.edi}
project -save "$filename"
