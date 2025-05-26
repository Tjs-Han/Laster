cd "D:/FreeWork/df1_second_round/df1_3dprj_dev/src/ip/df1_lidar_ip/divider_24bit/divider_eval/divider_24bit/sim/aldec/timing"
workspace create divider_sdf_synp
design create divider_sdf_synp .
design open divider_sdf_synp
cd "D:/FreeWork/df1_second_round/df1_3dprj_dev/src/ip/df1_lidar_ip/divider_24bit/divider_eval/divider_24bit/sim/aldec/timing"
vlog "+incdir+../../../src/params" \
     +define+POST_SIM \
     ../../../impl/synplify/divider_24bit_top/divider_24bit_top_divider_24bit_top_vo.vo \
     "../../../../testbench/divider_24bit_tb.v" \
     "../../../../testbench/divider_model.v" 
#----- Start evaluation test -- 
vsim -o5 +access +r -t 1ps divider_sdf_synp.divider_24bit_tb -lib divider_sdf_synp -noglitchmsg -PL pmi_work -L ovi_ecp5u
#----- View the simulation results 
add wave sim:/divider_24bit_tb/rstn 
add wave sim:/divider_24bit_tb/clk 
add wave -radix hexadecimal sim:/divider_24bit_tb/numer 
add wave -radix hexadecimal sim:/divider_24bit_tb/denom 
add wave -radix hexadecimal sim:/divider_24bit_tb/quot 
add wave -radix hexadecimal sim:/divider_24bit_tb/remd 
add wave sim:/divider_24bit_tb/comp_error 
run -all 

