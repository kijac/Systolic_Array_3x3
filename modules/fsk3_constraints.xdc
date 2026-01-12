## Clock Constraint
## 100MHz System Clock (Y3 Oscillator -> Net CLK_100M)
set_property PACKAGE_PIN R4 [get_ports clk_100m]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100m]

## Clock timing constraint (10ns period = 100MHz)
create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} [get_ports clk_100m]

## Reset Constraint
## Active-Low Reset Button (SYS_RSTB)
set_property PACKAGE_PIN U7 [get_ports sys_rstb]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rstb]

## 7-Segment Display - Digit Select (Active-High)
## Mapping: digit[7]=SEG_DIG1 (leftmost) ~ digit[0]=SEG_DIG8 (rightmost)
## DIGIT[7] - Leftmost digit (SEG_DIG1)
set_property PACKAGE_PIN P14 [get_ports {digit[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit[7]}]

## DIGIT[6] (SEG_DIG2)
set_property PACKAGE_PIN R14 [get_ports {digit[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit[6]}]

## DIGIT[5] (SEG_DIG3)
set_property PACKAGE_PIN P15 [get_ports {digit[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit[5]}]

## DIGIT[4] (SEG_DIG4)
set_property PACKAGE_PIN P16 [get_ports {digit[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit[4]}]

## DIGIT[3] (SEG_DIG5)
set_property PACKAGE_PIN R16 [get_ports {digit[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit[3]}]

## DIGIT[2] (SEG_DIG6)
set_property PACKAGE_PIN N17 [get_ports {digit[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit[2]}]

## DIGIT[1] (SEG_DIG7)
set_property PACKAGE_PIN P17 [get_ports {digit[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit[1]}]

## DIGIT[0] - Rightmost digit (SEG_DIG8)
set_property PACKAGE_PIN R17 [get_ports {digit[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit[0]}]

## 7-Segment Display - Segment Signals (Active-High)
## SEG[6] = Segment A
set_property PACKAGE_PIN U17 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

## SEG[5] = Segment B
set_property PACKAGE_PIN V17 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]

## SEG[4] = Segment C
set_property PACKAGE_PIN W17 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]

## SEG[3] = Segment D
set_property PACKAGE_PIN R18 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]

## SEG[2] = Segment E
set_property PACKAGE_PIN T18 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]

## SEG[1] = Segment F
set_property PACKAGE_PIN U18 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]

## SEG[0] = Segment G
set_property PACKAGE_PIN V18 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]

## Configuration Settings
## Configuration Bank Voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## Bitstream Compression (optional, reduces bitstream size)
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
