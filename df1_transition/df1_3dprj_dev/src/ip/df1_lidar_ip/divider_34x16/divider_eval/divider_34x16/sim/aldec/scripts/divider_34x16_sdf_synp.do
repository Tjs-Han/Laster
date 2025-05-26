cd "D:/FreeWork/df1_second_round/df1_3dprj_dev/src/ip/df1_lidar_ip/divider_34x16/divider_eval/divider_34x16/sim/aldec/timing"
workspace create divider_sdf_synp
design create divider_sdf_synp .
design open divider_sdf_synp
cd "D:/FreeWork/df1_second_round/df1_3dprj_dev/src/ip/df1_lidar_ip/divider_34x16/divider_eval/divider_34x16/sim/aldec/timing"
vlog "+incdir+../../../src/params" \
     +define+POST_SIM \
     ../../../impl/synplify/divider_34x16_top/divider_34x16_top_divider_34x16_top_vo.vo \
     "../../../../testbench/divider_34x16_tb.v" \
     "../../../../testbench/divider_model.v" 
#----- Start evaluation test -- 
vsim -o5 +access +r -t 1ps divider_sdf_synp.divider_34x16_tb -lib divider_sdf_synp -noglitchmsg -PL pmi_work -L ovi_ecp5u
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

