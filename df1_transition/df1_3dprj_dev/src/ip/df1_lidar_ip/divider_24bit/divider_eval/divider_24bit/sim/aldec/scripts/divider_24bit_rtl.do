cd "D:/FreeWork/df1_second_round/df1_3dprj_dev/src/ip/df1_lidar_ip/divider_24bit/divider_eval/divider_24bit/sim/aldec/rtl"
workspace create divider_rtl
design create divider_rtl .
design open divider_rtl
cd "D:/FreeWork/df1_second_round/df1_3dprj_dev/src/ip/df1_lidar_ip/divider_24bit/divider_eval/divider_24bit/sim/aldec/rtl"
vlog "+incdir+../../../src/params" \
     "../../../src/rtl/top/ecp5u/divider_24bit_top.v" \
     "../../../src/beh_rtl/ecp5u/divider_24bit_beh.v" \
     "../../../../testbench/divider_24bit_tb.v" \
     "../../../../testbench/divider_model.v" 
#----- Start evaluation test -- 
vsim -o5 +access +r -t 1ps divider_rtl.divider_24bit_tb -lib divider_rtl -noglitchmsg -PL pmi_work -L ovi_ecp5u
#----- View the simulation results 
add wave sim:/divider_24bit_tb/rstn 
add wave sim:/divider_24bit_tb/clk 
add wave -radix hexadecimal sim:/divider_24bit_tb/numer 
add wave -radix hexadecimal sim:/divider_24bit_tb/denom 
add wave -radix hexadecimal sim:/divider_24bit_tb/quot 
add wave -radix hexadecimal sim:/divider_24bit_tb/remd 
add wave sim:/divider_24bit_tb/comp_error 
run -all 

