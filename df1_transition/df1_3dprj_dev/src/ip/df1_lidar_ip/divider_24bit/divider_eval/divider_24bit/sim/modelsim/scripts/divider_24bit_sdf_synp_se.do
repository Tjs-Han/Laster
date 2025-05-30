#=============================================================================
# Eval simulation script generated by IPExpress    05/12/2025    14:41:02 
# Lattice IP Core Simulation Script for Evaluation (Verilog)                  
# Copyright(c) 2012 Lattice Semiconductor Corporation. All rights reserved.   
#=============================================================================

# WARNING - Changes to this file should be performed by re-running IPexpress or
# modifying the .LPC file and regenerating the core. Other changes may lead to 
# inconsistent simulation and/or implementation results.                       

onbreak {resume} 
quit -sim 
cd "D:/FreeWork/df1_second_round/df1_3dprj_dev/src/ip/df1_lidar_ip/divider_24bit/divider_eval/divider_24bit/sim/modelsim/timing"
if [file exists work] { 
   file delete -force work 
} 
#-- Simulation work library creation
if {![file exists work]} { 
     vlib work 
   } 
vlog -novopt -y D:/TOOL/LatticeDiamond/diamond/3.13/cae_library/simulation/verilog/ecp5u +libext+.v \
     +incdir+../../../src/params \
     +define+POST_SIM \
     ../../../impl/synplify/divider_24bit_top/divider_24bit_top_divider_24bit_top_vo.vo \
  ../../../../testbench/divider_24bit_tb.v \
  ../../../../testbench/divider_model.v \
  +libext+.v -y D:/TOOL/LatticeDiamond/diamond/3.13/cae_library/simulation/verilog/pmi 
#-- Start evaluation test
vsim -novopt -t 1ps divider_24bit_tb -l divider_24bit_sdf_synp_se.log
#----- View the simulation results 
view structure 
view signals 
add wave sim:/divider_24bit_tb/rstn 
add wave sim:/divider_24bit_tb/clk 
add wave -radix hexadecimal sim:/divider_24bit_tb/numer 
add wave -radix hexadecimal sim:/divider_24bit_tb/denom 
add wave -radix hexadecimal sim:/divider_24bit_tb/quot 
add wave -radix hexadecimal sim:/divider_24bit_tb/remd 
add wave sim:/divider_24bit_tb/comp_error 
run -all 

