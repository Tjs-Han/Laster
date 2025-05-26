#create_clock -period 20 [get_pins i_clk_50m];
#create_clock -period 10 [get_pins i_ddrclk_100m];
create_clock -period 20 [get_nets w_pll_50m];
create_clock -period 10 [get_nets w_pll_100m];
set_clock_groups -asynchronous -group [get_clocks w_pll_100m] -group [get_clocks w_sclk]