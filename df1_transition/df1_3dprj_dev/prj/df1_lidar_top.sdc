# ������ʱ�ӣ�����ʱ������Ϊ LVDS ���ͣ�
create_clock -name i_clk_50m -period 20.0 [get_ports {i_clk_50m}]
create_clock -name i_ethphy_refclk -period 20.0 [get_ports {i_ethphy_refclk}]
create_clock -name i_ddrclk_100m -period 10.0 [get_ports {i_ddrclk_100m}]
create_clock -name w_pll_50m -period 20.0 [get_nets {w_pll_50m}]
create_clock -name w_pll_150m -period 6.666666 [get_ports {w_pll_150m}]

#create_clock -name w_sclk -period 6.666 [get_nets {w_sclk}]
# ���/��С�����ӳ٣����� PCB �����ӳٺ��������Ե�����
set_input_delay -clock i_ddrclk_100m -max 0.1 [get_ports {i_ddrclk_100m[*]}]
set_input_delay -clock i_ddrclk_100m -min -0.1 [get_ports {i_ddrclk_100m[*]}]

#set_multicycle_path -setup 1 -from [get_clocks i_ddrclk_100m] -to [get_clocks w_sclk]
#set_multicycle_path -hold 1 -from [get_clocks i_ddrclk_100m] -to [get_clocks w_sclk]

# �첽ʱ����
#set_clock_groups -asynchronous -group {i_clk_50m} -group {i_ddrclk_100m}
set_clock_groups -asynchronous -group {w_pll_100m} -group {w_sclk}

set_clock_uncertainty -setup 0.1 [get_clocks i_ddrclk_100m]
set_clock_uncertainty -hold 0.1 [get_clocks i_ddrclk_100m]

set_clock_uncertainty -setup 0.1 [get_clocks i_ethphy_refclk]
set_clock_uncertainty -hold 0.1 [get_clocks i_ethphy_refclk]


####################################################################
# tdc1
####################################################################
create_clock -name i_tdc1_lvds_serclk -period 3.333333 [get_ports {i_tdc1_lvds_serclk}]
set_clock_groups -asynchronous -group {i_tdc1_lvds_serclk}
create_generated_clock -name w_iddr_sclk1 -source [get_ports i_tdc1_lvds_serclk] \
  -divide_by 2 [get_pins {CLKDIV_inst/CLKOUT}]
  
# ���/��С�����ӳ٣����� PCB �����ӳٺ��������Ե�����
set_input_delay -clock i_tdc1_lvds_serclk -max 0.1 [get_ports {i_tdc1_lvds_serdata[*]}]
set_input_delay -clock i_tdc1_lvds_serclk -min -0.1 [get_ports {i_tdc1_lvds_serdata[*]}]

# ���˫�ز�������Ϊ�½�����Ӷ���Լ��
set_input_delay -clock i_tdc1_lvds_serclk -max 0.1 [get_ports {i_tdc1_lvds_serdata[*]}] -clock_fall -add_delay
set_input_delay -clock i_tdc1_lvds_serclk -min -0.1 [get_ports {i_tdc1_lvds_serdata[*]}] -clock_fall -add_delay

set_multicycle_path -setup 1 -from [get_clocks i_tdc1_lvds_serclk] -to [get_clocks w_iddr_sclk1]
set_multicycle_path -hold 1 -from [get_clocks i_tdc1_lvds_serclk] -to [get_clocks w_iddr_sclk1]

set_clock_uncertainty -setup 0.1 [get_clocks i_tdc1_lvds_serclk]
set_clock_uncertainty -hold 0.1 [get_clocks i_tdc1_lvds_serclk]


####################################################################
# tdc2
####################################################################
create_clock -name i_tdc2_lvds_serclk -period 3.333333 [get_ports {i_tdc2_lvds_serclk}]
set_clock_groups -asynchronous -group {i_tdc2_lvds_serclk}
create_generated_clock -name w_iddr_sclk2 -source [get_ports i_tdc2_lvds_serclk] \
  -divide_by 2 [get_pins {CLKDIV_inst/CLKOUT}]
  
# ���/��С�����ӳ٣����� PCB �����ӳٺ��������Ե�����
set_input_delay -clock i_tdc2_lvds_serclk -max 0.1 [get_ports {i_tdc2_lvds_serdata[*]}]
set_input_delay -clock i_tdc2_lvds_serclk -min -0.1 [get_ports {i_tdc2_lvds_serdata[*]}]

# ���˫�ز�������Ϊ�½�����Ӷ���Լ��
set_input_delay -clock i_tdc2_lvds_serclk -max 0.1 [get_ports {i_tdc2_lvds_serdata[*]}] -clock_fall -add_delay
set_input_delay -clock i_tdc2_lvds_serclk -min -0.1 [get_ports {i_tdc2_lvds_serdata[*]}] -clock_fall -add_delay

set_multicycle_path -setup 1 -from [get_clocks i_tdc2_lvds_serclk] -to [get_clocks w_iddr_sclk2]
set_multicycle_path -hold 1 -from [get_clocks i_tdc2_lvds_serclk] -to [get_clocks w_iddr_sclk2]

set_clock_uncertainty -setup 0.1 [get_clocks i_tdc2_lvds_serclk]
set_clock_uncertainty -hold 0.1 [get_clocks i_tdc2_lvds_serclk]