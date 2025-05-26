cd "D:/FreeWork/df1_second_round/df1_3dprj_dev/src/ip/df1_lidar_ip/divider_32x24/divider_eval/divider_32x24/sim/aldec/timing"
workspace create divider_sdf_synp
design create divider_sdf_synp .
design open divider_sdf_synp
cd "D:/FreeWork/df1_second_round/df1_3dprj_dev/src/ip/df1_lidar_ip/divider_32x24/divider_eval/divider_32x24/sim/aldec/timing"
vlog "+incdir+../../../src/params" \
     +define+POST_SIM \
     ../../../impl/synplify/divider_32x24_top/divider_32x24_top_divider_32x24_top_vo.vo \
     "../../../../testbench/divider_32x24_tb.v" \
     "../../../../testbench/divider_model.v" 
#----- Start evaluation test -- 
vsim -o5 +access +r -t 1ps divider_sdf_synp.divider_32x24_tb -lib divider_sdf_synp -noglitchmsg -PL pmi_work -L ovi_ecp5u
#----- View the simulation results 
add wave sim:/divider_32x24_tb/rstn 
add wave sim:/divider_32x24_tb/clk 
add wave -radix hexadecimal sim:/divider_32x24_tb/numer 
add wave -radix hexadecimal sim:/divider_32x24_tb/denom 
add wave -radix hexadecimal sim:/divider_32x24_tb/quot 
add wave -radix hexadecimal sim:/divider_32x24_tb/remd 
add wave sim:/divider_32x24_tb/comp_error 
run -all 

