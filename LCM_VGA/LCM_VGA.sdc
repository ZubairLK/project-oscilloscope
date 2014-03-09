create_clock -name CLOCK_50 -period 20.000 [get_ports CLOCK_50]
create_clock -name CLOCK_27 -period 37.037 [get_ports CLOCK_27]

derive_pll_clocks
derive_clock_uncertainty
