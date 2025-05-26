cd "D:/FreeWork/df1_second_round/df1_3dprj_dev/src/ip/df1_lidar_ip/divider_34x16/divider_eval/divider_34x16/sim/aldec/rtl"
workspace create divider_rtl
design create divider_rtl .
design open divider_rtl
cd "D:/FreeWork/df1_second_round/df1_3dprj_dev/src/ip/df1_lidar_ip/divider_34x16/divider_eval/divider_34x16/sim/aldec/rtl"
vlog "+incdir+../../../src/params" \
     "../../../src/rtl/top/ecp5u/divider_34x16_top.v" \
     "../../../src/beh_rtl/ecp5u/divider_34x16_beh.v" \
     "../../../../testbench/divider_34x16_tb.v" \
     "../../../../testbench/divider_model.v" 
#----- Start evaluation test -- 
vsim -o5 +access +r -t 1ps divider_rtl.divider_34x16_tb -lib divider_rtl -noglitchmsg -PL pmi_work -L ovi_ecp5u
#----- View the simulation results 
add wave sim:/divider_34x16_tb/rstn 
add wave sim:/divider_34x16_tb/clk 
add wave sim:/divider_34x16_tb/dvalid_in 
add wave -radix hexadecimal sim:/divider_34x16_tb/numer 
add wave -radix hexadecimal sim:/divider_34x16_tb/denom 
add wave sim:/divider_34x16_tb/dvalid_out 
add wave -radix hexadecimal sim:/divider_34x16_tb/quot 
add wave -radix hexadecimal sim:/divider_34x16_tb/remd 
add wave sim:/divider_34x16_tb/comp_error 
run -all 

