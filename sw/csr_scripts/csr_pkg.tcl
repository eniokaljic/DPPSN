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


#==============================================================================
#                       Example Design Address Map                
#==============================================================================
set XAUI_BASE_ADDR 		0x00040000
set MDIO_BASE_ADDR 		0x00010000
set MAC_BASE_ADDR 		0x00000000
set LB_BASE_ADDR 		0x00010200
set RX_SC_FIFO_BASE_ADDR 	0x00010400

#==============================================================================
#                       PCS Address Map                
#==============================================================================

#==============================================================================
#                       XAUI Address Map                
#==============================================================================
set ALT_PMA_CONTROLLER_BASE_ADDR    0x00000080
set ALT_PMA_CH_CONTROLLER_BASE_ADDR 0x00000180
set ALT_XAUI_PCS_BASE_ADDR          0x00000200

#==============================================================================
#                       MAC Address Map                
#==============================================================================
# RX path
set RX_BACKPRESSURE_BASE_ADDR 	0x00000000
set CRC_PAD_REMOVER_BASE_ADDR 	0x00000100
set CRC_CHECKER_BASE_ADDR 	0x00000200 
set RX_FRAME_DECODER_BASE_ADDR 	0x00002000
set OVERFLOW_CTRL_BASE_ADDR 	0x00000300
set RX_STATISTICS_BASE_ADDR 	0x00003000

# TX path
set TX_BACKPRESSURE_BASE_ADDR 	0x00004000
set CRC_INSERTER_BASE_ADDR 	0x00004200
set PAD_INSERTER_BASE_ADDR 	0x00004100
set PAUSE_GEN_CTRL_BASE_ADDR 	0x00004500
set ADDRESS_INSERTER_BASE_ADDR 	0x00004800
set TX_FRAME_DECODER_BASE_ADDR 	0x00006000
set UNDERFLOW_CTRL_BASE_ADDR 	0x00006300
set TX_STATISTICS_BASE_ADDR 	0x00007000

#==============================================================================
#                       APIs              
#==============================================================================

#==============================================================================
#                       APIs for loopback features              
#==============================================================================

# Read line loopback register
proc read_loopback {} {
    global LB_BASE_ADDR
 
    puts "Reading Line Loopback : [rd32 $LB_BASE_ADDR 0x0 0x0]\n"
    puts "Reading Local Loopback : [rd32 $LB_BASE_ADDR 0x8 0x0]\n"
}

# Write to line loopback back register with the given value
# value = 0 or 1
proc write_line_loopback {value} {
    global LB_BASE_ADDR

    puts "Writing $value to Line Loopback\n"
    wr32 $LB_BASE_ADDR 0x0 0x0 $value
}

proc write_local_loopback {value} {
    global LB_BASE_ADDR

    puts "Writing $value to Local Loopback\n"
    wr32 $LB_BASE_ADDR 0x8 0x0 $value
}

#==============================================================================
#                       APIs for PCS              
#==============================================================================

# Accessing XAUI PMA Channel Controller
proc read_xaui_pma_ch_controller {} {
    global XAUI_BASE_ADDR
    global ALT_PMA_CH_CONTROLLER_BASE_ADDR
    
    puts "Reading all registers of PMA Channel Controller\n"
    for {set AddressOffset $ALT_PMA_CH_CONTROLLER_BASE_ADDR} {$AddressOffset <= [expr $ALT_PMA_CH_CONTROLLER_BASE_ADDR + 0x24]} {incr AddressOffset 0x4} {
        set address_hex [format "%#x" $AddressOffset];
        puts "Read Address Offset $address_hex : [rd32 $XAUI_BASE_ADDR $address_hex 0x0]\n"
    }
}

# Accessing XAUI PCS                
proc read_xaui_pcs {} {
    global XAUI_BASE_ADDR
    global ALT_XAUI_PCS_BASE_ADDR

    puts "Reading from XAUI PCS\n"
    for {set AddressOffset $ALT_XAUI_PCS_BASE_ADDR} {$AddressOffset <= [expr $ALT_XAUI_PCS_BASE_ADDR + 0x24]} {incr AddressOffset 0x4} {
        set address_hex [format "%#x" $AddressOffset];
        puts "Read Address Offset $address_hex : [rd32 $XAUI_BASE_ADDR $address_hex 0x0]\n"
    }
}

#==============================================================================
#                       APIs for MDIO              
#==============================================================================

# Example: Accessing PHY XS control register as specified in Clause45
proc access_mdio {} {
    global MDIO_BASE_ADDR

    # Clause45 = csr_address[5] 
    set mdio_rw_addr 0x80
    set mdio_csr_addr_cl45 0x84

    #==============================================================================
    # Writing to dev_prt_phy_address register (16 bits) of address 0x84 (0x21 on the slave)
    #    Bit [4:0] : phydev_address = clause 22 PHYAD / clause 45 DEVAD (device address)
    #    Bit [12:8] : prt_address = clause 45 PRTAD (for HSMC X2 daughter card, the value is define by the dip switch on the board) 
    #    Bit [31:16] : c1ause 45 register address (refer to IEEE 802.1 clause 45 for description)
    #==============================================================================

    # Example : Read from PHY XS control register (device address 4, cl45 register address 0) 
    set mdio_reg_value 0x00000004 
    puts "Read dev_prt_phy_add register $mdio_csr_addr_cl45 = [rd32 $MDIO_BASE_ADDR $mdio_csr_addr_cl45 0x0]\n"
    puts "Writing $mdio_reg_value to $mdio_csr_addr_cl45\n"
    wr32 $MDIO_BASE_ADDR $mdio_csr_addr_cl45 0x0 $mdio_reg_value
    puts "Read dev_prt_phy_add register $mdio_csr_addr_cl45 = [rd32 $MDIO_BASE_ADDR $mdio_csr_addr_cl45 0x0]\n"
    puts "Read PHY XS control register $mdio_rw_addr = [rd32 $MDIO_BASE_ADDR $mdio_rw_addr 0x0]\n"
}

#==============================================================================
#                       APIs for RX FIFO              
#==============================================================================
proc set_fifo_drop_on_error {value} {
    global RX_SC_FIFO_BASE_ADDR

    puts "Writing $value to drop on error register of RX FIFO\n"
    wr32 $RX_SC_FIFO_BASE_ADDR 0x14 0x0 $value
}

#==============================================================================
#                       APIs for MAC              
#==============================================================================
# Read all registers of address inserter
proc read_address_inserter {} {
    global MAC_BASE_ADDR
    global ADDRESS_INSERTER_BASE_ADDR
    global add_inserter

    puts "=============================================================================="
    puts "                      Reading Address Inserter CSR			        "
    puts "==============================================================================\n\n"
    puts "control status : [rd32 $MAC_BASE_ADDR $ADDRESS_INSERTER_BASE_ADDR 0x0]\n"
    puts "MAC src addr 0 : [rd32 $MAC_BASE_ADDR $ADDRESS_INSERTER_BASE_ADDR 0x4]\n"
    puts "MAC src addr 1 : [rd32 $MAC_BASE_ADDR $ADDRESS_INSERTER_BASE_ADDR 0x8]\n"
}

# Write to MAC source address register with the given value
proc write_MAC_src_address {value} {
    global MAC_BASE_ADDR
    global ADDRESS_INSERTER_BASE_ADDR

    puts "=============================================================================="
    puts "                      Write MAC Source Address to Address Inserter 		"
    puts "==============================================================================\n\n"
    set offset 0x4
    set lowerMAC 0x[string range $value 6 13]
    puts "Write to offset $offset of Address Inserter with value of $lowerMAC\n"
    wr32 $MAC_BASE_ADDR $ADDRESS_INSERTER_BASE_ADDR $offset $lowerMAC

    set offset 0x8
    set higherMAC [string range $value 0 5]
    puts "Write to offset $offset of Address Inserter with value of $higherMAC\n"
    wr32 $MAC_BASE_ADDR $ADDRESS_INSERTER_BASE_ADDR $offset $higherMAC
}

proc set_address_inserter {value} {
    global MAC_BASE_ADDR
    global ADDRESS_INSERTER_BASE_ADDR
    set offset 0x0

    puts "=============================================================================="
    puts "                      Write to Control register of Address Inserter  	        "
    puts "==============================================================================\n\n"
    puts "Write to offset $offset of Address inserter with value of $value\n"
    wr32 $MAC_BASE_ADDR $ADDRESS_INSERTER_BASE_ADDR $offset $value
}

# Read all statistics registers of the given path (rx or tx)
proc read_stats {path} {
    global MAC_BASE_ADDR
    global TX_STATISTICS_BASE_ADDR
    global RX_STATISTICS_BASE_ADDR

    set base_address 0x0
    set read_error 0x0
    
    if {$path ==  "tx"} {
        puts "=============================================================================="
        puts "                      Reading TX Statistics			            "
        puts "==============================================================================\n\n"
        set base_address $TX_STATISTICS_BASE_ADDR
    } elseif {$path == "rx"} {
        puts "=============================================================================="
        puts "                      Reading RX Statistics			            "
        puts "==============================================================================\n\n"
        set base_address $RX_STATISTICS_BASE_ADDR
    } else {
        puts "Wrong argument for read_stats\n"
        set read_error 0x1
    }

    if {$read_error == 0x0} {
        puts "clr : [rd32 $MAC_BASE_ADDR $base_address 0x00]\n"
        puts "framesOK : [rd64 $MAC_BASE_ADDR $base_address 0x08]\n"
        puts "framesErr : [rd64 $MAC_BASE_ADDR $base_address 0x10]\n"
        puts "framesCRCErr : [rd64 $MAC_BASE_ADDR $base_address 0x18]\n"
        puts "octetsOK : [rd64 $MAC_BASE_ADDR $base_address 0x20]\n"
        puts "pauseMACCtrlFrames : [rd64 $MAC_BASE_ADDR $base_address 0x28]\n"
        puts "ifErrors : [rd64 $MAC_BASE_ADDR $base_address 0x30]\n"
        puts "unicastFramesOK : [rd64 $MAC_BASE_ADDR $base_address 0x38]\n"
        puts "unicastFramesErr : [rd64 $MAC_BASE_ADDR $base_address 0x40]\n"
        puts "multicastFramesOK : [rd64 $MAC_BASE_ADDR $base_address 0x48]\n"
        puts "multicastFramesErr : [rd64 $MAC_BASE_ADDR $base_address 0x50]\n"
        puts "broadcastFramesOK : [rd64 $MAC_BASE_ADDR $base_address 0x58]\n"
        puts "broadcastFramesErr : [rd64 $MAC_BASE_ADDR $base_address 0x60]\n"
        puts "etherStatsOctets : [rd64 $MAC_BASE_ADDR $base_address 0x68]\n"
        puts "etherStatsPkts : [rd64 $MAC_BASE_ADDR $base_address 0x70]\n"
        puts "etherStatsUnderSizePkts : [rd64 $MAC_BASE_ADDR $base_address 0x78]\n"
        puts "etherStatsOversizePkts : [rd64 $MAC_BASE_ADDR $base_address 0x80]\n"
        puts "etherStatsPkts64Octets : [rd64 $MAC_BASE_ADDR $base_address 0x88]\n"
        puts "etherStatsPkts65to127Octets : [rd64 $MAC_BASE_ADDR $base_address 0x90]\n"
        puts "etherStatsPkts128to255Octets : [rd64 $MAC_BASE_ADDR $base_address 0x98]\n"
        puts "etherStatsPkts256to511Octet : [rd64 $MAC_BASE_ADDR $base_address 0xA0]\n"
        puts "etherStatsPkts512to1023Octets : [rd64 $MAC_BASE_ADDR $base_address 0xA8]\n"
        puts "etherStatsPkts1024to1518Octets : [rd64 $MAC_BASE_ADDR $base_address 0xB0]\n"
        puts "etherStatsPkts1518toXOctets : [rd64 $MAC_BASE_ADDR $base_address 0xB8]\n"
        puts "etherStatsFragments : [rd64 $MAC_BASE_ADDR $base_address 0xC0]\n"
        puts "etherStatsJabbers : [rd64 $MAC_BASE_ADDR $base_address 0xC8]\n"
        puts "etherStatsCRCErr : [rd64 $MAC_BASE_ADDR $base_address 0xD0]\n"
        puts "unicastMACCtrlFrames : [rd64 $MAC_BASE_ADDR $base_address 0xD8]\n"
        puts "multicastMACCtrlFrames : [rd64 $MAC_BASE_ADDR $base_address 0xE0]\n"
        puts "broadcastMACCtrlFrames : [rd64 $MAC_BASE_ADDR $base_address 0xE8]\n" 
   }      
}

# Clear all statistics registers both on the TX and on the RX path
proc clear_stats {} {
    global MAC_BASE_ADDR
    global MacStatistics
    global RX_STATISTICS_BASE_ADDR
    global TX_STATISTICS_BASE_ADDR

    puts "Clear RX statistics registers\n"
    wr32 $MAC_BASE_ADDR $RX_STATISTICS_BASE_ADDR 0x0 0x1
    
    puts "Clear TX statistics registers\n"
    wr32 $MAC_BASE_ADDR $TX_STATISTICS_BASE_ADDR 0x0 0x1

}
    






