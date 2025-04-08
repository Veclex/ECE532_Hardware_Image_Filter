###############################################################################
# This file is a general .xdc for the Nexys4 DDR Rev C board
# Vivado version converted from the original .ucf
# To use it in a project:
#  - Uncomment the lines corresponding to used pins
#  - Rename the used signals to match your top-level RTL
###############################################################################


###############################################################################
# Clock signal
###############################################################################
set_property PACKAGE_PIN E3 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]

# Equivalent of TIMESPEC TS_sys_clk_pin = PERIOD sys_clk_pin 100 MHz HIGH 50%;
# Creates a 10ns (100MHz) clock on port "clk".
create_clock -name sys_clk_pin -period 10.0 [get_ports {clk}]


###############################################################################
# Switches
###############################################################################
# set_property PACKAGE_PIN J15 [get_ports {sw0_test_cmd}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw0_test_cmd}]

set_property PACKAGE_PIN J15 [get_ports {sw0_sel7bits}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw0_sel7bits}]

# set_property PACKAGE_PIN L16 [get_ports {sw13_regs[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw13_regs[0]}]

# set_property PACKAGE_PIN M13 [get_ports {sw13_regs[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw13_regs[1]}]

# set_property PACKAGE_PIN R15 [get_ports {sw13_regs[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw13_regs[2]}]

# set_property PACKAGE_PIN R17 [get_ports {sw4_test_osc}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw4_test_osc}]

# set_property PACKAGE_PIN T18 [get_ports {sw57_rgbfilter[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw57_rgbfilter[0]}]

# set_property PACKAGE_PIN U18 [get_ports {sw57_rgbfilter[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw57_rgbfilter[1]}]

# set_property PACKAGE_PIN R13 [get_ports {sw57_rgbfilter[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw57_rgbfilter[2]}]

# set_property PACKAGE_PIN T8 [get_ports {sw[8]}]
# set_property IOSTANDARD LVCMOS18 [get_ports {sw[8]}]

# set_property PACKAGE_PIN U8 [get_ports {sw[9]}]
# set_property IOSTANDARD LVCMOS18 [get_ports {sw[9]}]

# set_property PACKAGE_PIN R16 [get_ports {sw[10]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]

# set_property PACKAGE_PIN T13 [get_ports {sw[11]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]

# set_property PACKAGE_PIN H6 [get_ports {sw[12]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]

# set_property PACKAGE_PIN U12 [get_ports {sw[13]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]

set_property PACKAGE_PIN U11 [get_ports {sw14}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw14}]

set_property PACKAGE_PIN V10 [get_ports {sw15}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw15}]


# set_property PACKAGE_PIN V10 [get_ports {rst}]
# set_property IOSTANDARD LVCMOS33 [get_ports {rst}]


###############################################################################
# Buttons
###############################################################################
# set_property PACKAGE_PIN C12 [get_ports {cpu_resetn}]
# set_property IOSTANDARD LVCMOS33 [get_ports {cpu_resetn}]

# btn_central:
set_property PACKAGE_PIN N17 [get_ports {rst}]
set_property IOSTANDARD LVCMOS33 [get_ports {rst}]

# set_property PACKAGE_PIN P18 [get_ports {btnd}]
# set_property IOSTANDARD LVCMOS33 [get_ports {btnd}]

# set_property PACKAGE_PIN P17 [get_ports {btnl_oscop}]
# set_property IOSTANDARD LVCMOS33 [get_ports {btnl_oscop}]

# btn_right:
set_property PACKAGE_PIN P17 [get_ports {proc_ctrl}]
set_property IOSTANDARD LVCMOS33 [get_ports {proc_ctrl}]

# set_property PACKAGE_PIN M18 [get_ports {btnu}]
# set_property IOSTANDARD LVCMOS33 [get_ports {btnu}]

set_property PACKAGE_PIN M17 [get_ports {btnr}]
set_property IOSTANDARD LVCMOS33 [get_ports {btnr}]

set_property PACKAGE_PIN D4 [get_ports {tx}]
set_property IOSTANDARD LVCMOS33 [get_ports {tx}]

set_property PACKAGE_PIN C4 [get_ports {rx}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx}]

###############################################################################
# LEDs
###############################################################################
set_property PACKAGE_PIN H17 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN K15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

set_property PACKAGE_PIN J13 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property PACKAGE_PIN N14 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

set_property PACKAGE_PIN R18 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]

set_property PACKAGE_PIN V17 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]

set_property PACKAGE_PIN U17 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]

set_property PACKAGE_PIN U16 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]

set_property PACKAGE_PIN V16 [get_ports {led[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[8]}]

set_property PACKAGE_PIN T15 [get_ports {led[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[9]}]

set_property PACKAGE_PIN U14 [get_ports {led[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]

# set_property PACKAGE_PIN T16 [get_ports {led[11]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]

# set_property PACKAGE_PIN V15 [get_ports {led[12]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]

##set_property PACKAGE_PIN V14 [get_ports {led[13]}]
##set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]

##set_property PACKAGE_PIN V12 [get_ports {led[14]}]
##set_property IOSTANDARD LVCMOS33 [get_ports {led[14]}]

##set_property PACKAGE_PIN V11 [get_ports {led[15]}]
##set_property IOSTANDARD LVCMOS33 [get_ports {led[15]}]


###############################################################################
# RGB LEDs
###############################################################################
# set_property PACKAGE_PIN R12 [get_ports {led16_b}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led16_b}]

# set_property PACKAGE_PIN M16 [get_ports {led16_g}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led16_g}]

# set_property PACKAGE_PIN N15 [get_ports {led16_r}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led16_r}]

# set_property PACKAGE_PIN G14 [get_ports {led17_b}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led17_b}]

# set_property PACKAGE_PIN R11 [get_ports {led17_g}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led17_g}]

# set_property PACKAGE_PIN N16 [get_ports {led17_r}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led17_r}]


###############################################################################
# 7-segment display
###############################################################################
# set_property PACKAGE_PIN T10 [get_ports {seg7[6]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7[6]}]
# ...
# (Repeat similarly for seg7, dp, anode7seg, etc. if needed.)


###############################################################################
# Pmod Header JA (OV7670 signals)
###############################################################################
# set_property PACKAGE_PIN C17 [get_ports {ja[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {ja[1]}]
set_property PACKAGE_PIN C17 [get_ports {ov7670_pwdn}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_pwdn}]

# set_property PACKAGE_PIN D18 [get_ports {ja[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {ja[2]}]
set_property PACKAGE_PIN D18 [get_ports {ov7670_d_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_d_in[0]}]

# set_property PACKAGE_PIN E18 [get_ports {ja[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {ja[3]}]
set_property PACKAGE_PIN E18 [get_ports {ov7670_d_in[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_d_in[2]}]

# set_property PACKAGE_PIN G17 [get_ports {ov7670_d[4]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_d[4]}]
set_property PACKAGE_PIN G17 [get_ports {ov7670_d_msb[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_d_msb[1]}]

# set_property PACKAGE_PIN D17 [get_ports {ja[7]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {ja[7]}]
set_property PACKAGE_PIN D17 [get_ports {ov7670_rst_n}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_rst_n}]

# set_property PACKAGE_PIN E17 [get_ports {ja[8]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {ja[8]}]
set_property PACKAGE_PIN E17 [get_ports {ov7670_d_in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_d_in[1]}]

# set_property PACKAGE_PIN F18 [get_ports {ja[9]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {ja[9]}]
set_property PACKAGE_PIN F18 [get_ports {ov7670_d_msb[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_d_msb[0]}]

# set_property PACKAGE_PIN G18 [get_ports {ja[10]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {ja[10]}]
set_property PACKAGE_PIN G18 [get_ports {ov7670_d_msb[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_d_msb[2]}]


###############################################################################
# Pmod Header JB (OV7670 signals)
###############################################################################
# set_property PACKAGE_PIN D14 [get_ports {jb[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {jb[1]}]
set_property PACKAGE_PIN D14 [get_ports {ov7670_d_msb[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_d_msb[3]}]

# set_property PACKAGE_PIN F16 [get_ports {jb[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {jb[2]}]
set_property PACKAGE_PIN F16 [get_ports {ov7670_xclk}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_xclk}]

# set_property PACKAGE_PIN G16 [get_ports {jb[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {jb[3]}]
set_property PACKAGE_PIN G16 [get_ports {ov7670_href}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_href}]

# set_property PACKAGE_PIN H14 [get_ports {jb[4]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {jb[4]}]
set_property PACKAGE_PIN H14 [get_ports {ov7670_siod}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_siod}]

# set_property PACKAGE_PIN E16 [get_ports {jb[7]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {jb[7]}]
set_property PACKAGE_PIN E16 [get_ports {ov7670_d_msb[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_d_msb[4]}]

# set_property PACKAGE_PIN F13 [get_ports {jb[8]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {jb[8]}]
set_property PACKAGE_PIN F13 [get_ports {ov7670_pclk}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_pclk}]

# set_property PACKAGE_PIN G13 [get_ports {jb[9]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {jb[9]}]
set_property PACKAGE_PIN G13 [get_ports {ov7670_vsync}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_vsync}]

# set_property PACKAGE_PIN H16 [get_ports {jb[10]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {jb[10]}]
set_property PACKAGE_PIN H16 [get_ports {ov7670_sioc}]
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_sioc}]


###############################################################################
# Pmod Header JC, JD, etc.
###############################################################################
# (All these are commented out in the UCF; replicate similarly if needed.)
# set_property PACKAGE_PIN K1 [get_ports {jc[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {jc[1]}]
# ...
# set_property PACKAGE_PIN H4 [get_ports {jd[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {jd[1]}]
# ...
# (And so on. Uncomment if you need them.)


###############################################################################
# VGA Connector
###############################################################################
set_property PACKAGE_PIN A3 [get_ports {vga_red_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_out[0]}]

set_property PACKAGE_PIN B4 [get_ports {vga_red_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_out[1]}]

set_property PACKAGE_PIN C5 [get_ports {vga_red_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_out[2]}]

set_property PACKAGE_PIN A4 [get_ports {vga_red_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_out[3]}]

set_property PACKAGE_PIN C6 [get_ports {vga_green_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green_out[0]}]

set_property PACKAGE_PIN A5 [get_ports {vga_green_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green_out[1]}]

set_property PACKAGE_PIN B6 [get_ports {vga_green_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green_out[2]}]

set_property PACKAGE_PIN A6 [get_ports {vga_green_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green_out[3]}]

set_property PACKAGE_PIN B7 [get_ports {vga_blue_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue_out[0]}]

set_property PACKAGE_PIN C7 [get_ports {vga_blue_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue_out[1]}]

set_property PACKAGE_PIN D7 [get_ports {vga_blue_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue_out[2]}]

set_property PACKAGE_PIN D8 [get_ports {vga_blue_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue_out[3]}]

set_property PACKAGE_PIN B11 [get_ports {vga_hsync}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_hsync}]

set_property PACKAGE_PIN B12 [get_ports {vga_vsync}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_vsync}]


###############################################################################
# Micro SD, Audio, Accelerometer, etc.
###############################################################################
# (All currently commented in your .ucf; convert similarly if you use them.)
# set_property PACKAGE_PIN B1 [get_ports {sd_sck}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sd_sck}]
# ...
# set_property PACKAGE_PIN A11 [get_ports {aud_pwm}]
# set_property IOSTANDARD LVCMOS33 [get_ports {aud_pwm}]
# ...
# set_property PACKAGE_PIN E15 [get_ports {acl_miso}]
# set_property IOSTANDARD LVCMOS33 [get_ports {acl_miso}]
# ...
# set_property PACKAGE_PIN B13 [get_ports {acl_int[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {acl_int[1]}]
# ...
# And so on for the rest


###############################################################################
# USB-RS232, USB HID, QSPI Flash, Ethernet PHY
###############################################################################
# (Likewise, these lines are commented in the original. Uncomment if needed.)
# set_property PACKAGE_PIN D3 [get_ports {uart_cts}]
# set_property IOSTANDARD LVCMOS33 [get_ports {uart_cts}]
# ...
# set_property PACKAGE_PIN F4 [get_ports {ps2_clk}]
# set_property IOSTANDARD LVCMOS33 [get_ports {ps2_clk}]
# ...
# set_property PACKAGE_PIN L13 [get_ports {qspi_csn}]
# set_property IOSTANDARD LVCMOS33 [get_ports {qspi_csn}]
# ...
# set_property PACKAGE_PIN C11 [get_ports {eth_rxd[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {eth_rxd[0]}]
# ...
# (etc., repeat for all Ethernet lines as needed)
