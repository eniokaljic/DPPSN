# (C) 2001-2016 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


source common.tcl
source csr_pkg.tcl

open_jtag

puts "=============================================================================="
puts "                      Accessing Ethernet 10G MAC CSR			    "
puts "==============================================================================\n\n"

#==============================================================================
#                       Configuring RX fifo to                
#============================================================================
set_fifo_drop_on_error 1

#==============================================================================
#                       Configuring MAC Source Address               
#==============================================================================
read_address_inserter
set_address_inserter 1
write_MAC_src_address 0xEECC88CCAAEE
read_address_inserter

close_jtag
