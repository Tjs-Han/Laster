
#Begin clock constraint
define_clock -name {clk} -period 20.0 -clockgroup Autoconstr_clkgroup_1 -rise 0.000 -fall 10.0 -route 0.000 [get_ports {i_clk_50m}]
#End clock constraint

#Begin clock constraint
define_clock -name {C200_PLL|CLKOP_inferred_clock} {n:C200_PLL|CLKOP_inferred_clock} -period 40.0 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 20.0 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {C200_PLL|CLKOS_inferred_clock} {n:C200_PLL|CLKOS_inferred_clock} -period 5.0 -clockgroup Autoconstr_clkgroup_1 -rise 0.000 -fall 2.5 -route 0.000 
#End clock constraint
