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


set old_mode [set_project_mode -get_mode_value always_show_entity_name] 
set_project_mode -always_show_entity_name on

#**************************************************************
# Time Information
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************

#**************************************************************
# Create Generated Clock
#**************************************************************

#**************************************************************
# Set Clock Latency
#**************************************************************

#**************************************************************
# Set Clock Uncertainty
#**************************************************************

#**************************************************************
# Set Input Delay
#**************************************************************

# Function to constraint non-std_synchronizer path
proc altera_10gbaser_phy_constraint_net_delay {from_reg to_reg max_net_delay {check_exist 0}} {
    
    # Check for instances
    set inst [get_registers -nowarn ${to_reg}]
    
    # Check number of instances
    set inst_num [llength [query_collection -report -all $inst]]
    if {$inst_num > 0} {
        # Uncomment line below for debug purpose
        #puts "${inst_num} ${to_reg} instance(s) found"
    } else {
        # Uncomment line below for debug purpose
        #puts "No ${to_reg} instance found"
    }
    
    if {($check_exist == 0) || ($inst_num > 0)} {
        if { [string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)] } {
            set_max_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] 100ns
            set_min_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -100ns
        } else {
            set_net_delay -from [get_pins -compatibility_mode ${from_reg}|q] -to [get_registers ${to_reg}] -max $max_net_delay
            
            # Relax the fitter effort
            set_max_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] 100ns
            set_min_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -100ns
        }
    }
}

# 1588
altera_10gbaser_phy_constraint_net_delay *altera_10gbaser_phy_rx_fifo*octet_del_en_start_wrclk *altera_10gbaser_phy_rx_fifo*sync_del_en_rdclk*sync_regs[0] 6ns 1
altera_10gbaser_phy_constraint_net_delay *stratixv_10gbaser_1588_ppm_counter*sample_cntr_a *bitsync2_1588*sync_regs[0] 2ns 1
altera_10gbaser_phy_constraint_net_delay *stratixv_10gbaser_1588_ppm_counter*run_cntr_a *bitsync2_1588*sync_regs[1] 2ns 1

# Sync register (externalized from embedded SDC)
altera_10gbaser_phy_constraint_net_delay * *sv_xcvr_10gbaser_nr*sync_block_lock[2]* 6ns 1
altera_10gbaser_phy_constraint_net_delay * *sv_xcvr_10gbaser_nr*sync_hi_ber[2]* 6ns 1
altera_10gbaser_phy_constraint_net_delay * *sv_xcvr_10gbaser_nr*sync_rx_data_ready[2]* 6ns 1

# DCFIFO async reset constraint (externalized from embedded SDC)
set regs [get_pins -compatibility_mode -nowarn *softtxfifos.tx_wr_rstn*|clrn]
if {[llength [query_collection -report -all $regs]] > 0} {
    set_false_path -to $regs
}

set regs [get_pins -compatibility_mode -nowarn *softtxfifos.tx_rd_rstn*|clrn]
if {[llength [query_collection -report -all $regs]] > 0} {
    set_false_path -to $regs
}

set regs [get_pins -compatibility_mode -nowarn *softrxfifos.rx_wr_rstn*|clrn]
if {[llength [query_collection -report -all $regs]] > 0} {
    set_false_path -to $regs
}

set regs [get_pins -compatibility_mode -nowarn *softrxfifos.rx_rd_rstn*|clrn]
if {[llength [query_collection -report -all $regs]] > 0} {
    set_false_path -to $regs
}

set from_regs [get_registers -nowarn *softtxfifos.tx_wr_rstn*]
set to_regs [get_pins -compatibility_mode -nowarn *softtxfifos*dffpipe*rdaclr*|clrn]
if {[llength [query_collection -report -all $from_regs]] > 0 && [llength [query_collection -report -all $to_regs]] > 0} {
    set_false_path -from $from_regs -to $to_regs
}

set from_regs [get_registers -nowarn *softtxfifos.tx_rd_rstn*]
set to_regs [get_pins -compatibility_mode -nowarn *softtxfifos*dffpipe*wraclr*|clrn]
if {[llength [query_collection -report -all $from_regs]] > 0 && [llength [query_collection -report -all $to_regs]] > 0} {
    set_false_path -from $from_regs -to $to_regs
}

set from_regs [get_registers -nowarn *softrxfifos.rx_wr_rstn*]
set to_regs [get_pins -compatibility_mode -nowarn *softrxfifos*dffpipe*rdaclr*|clrn]
if {[llength [query_collection -report -all $from_regs]] > 0 && [llength [query_collection -report -all $to_regs]] > 0} {
    set_false_path -from $from_regs -to $to_regs
}

set from_regs [get_registers -nowarn *softrxfifos.rx_rd_rstn*]
set to_regs [get_pins -compatibility_mode -nowarn *softrxfifos*dffpipe*wraclr*|clrn]
if {[llength [query_collection -report -all $from_regs]] > 0 && [llength [query_collection -report -all $to_regs]] > 0} {
    set_false_path -from $from_regs -to $to_regs
}

set regs [get_pins -compatibility_mode -nowarn *stratixv_10gbaser_1588_ppm_counter*sync_rst_b_n*|clrn]
if {[llength [query_collection -report -all $regs]] > 0} {
    set_false_path -to $regs
}


# Clock crosser constraint
set inst [get_registers -nowarn *altera_10gbaser_phy_clock_crosser*]
set inst_num [llength [query_collection -report -all $inst]]
if {$inst_num > 0} {
    # -----------------------------------------------------------------------------
    # Altera timing constraints for Avalon clock domain crossing (CDC) paths.
    # The purpose of these constraints is to remove the false paths and replace with timing bounded 
    # requirements for compilation.
    #
    # ***Important note *** 
    #
    # The clocks involved in this transfer must be kept synchronous and no false path
    # should be set on these paths for these constraints to apply correctly.
    # -----------------------------------------------------------------------------

    set temp_inst "altera_10gbaser_phy_clock_crosser:"
    set_net_delay -from [get_registers *${temp_inst}*|in_data_buffer* ] -to [get_registers *${temp_inst}*|out_data_buffer* ] -max 2
    set_max_delay -from [get_registers *${temp_inst}*|in_data_buffer* ] -to [get_registers *${temp_inst}*|out_data_buffer* ] 100
    set_min_delay -from [get_registers *${temp_inst}*|in_data_buffer* ] -to [get_registers *${temp_inst}*|out_data_buffer* ] -100

    set temp_inst "altera_10gbaser_phy_clock_crosser:*|altera_std_synchronizer_nocut:"
    set_net_delay -from [get_registers * ] -to [get_registers *${temp_inst}*|din_s1 ] -max 2
    set_max_delay -from [get_registers * ] -to [get_registers *${temp_inst}*|din_s1 ] 100
    set_min_delay -from [get_registers * ] -to [get_registers *${temp_inst}*|din_s1 ] -100

    # -----------------------------------------------------------------------------
    # This procedure constrains the skew between the token and data bits, and should
    # be called from the top level SDC, once per instance of the clock crosser.
    #
    # The hierarchy path to the handshake clock crosser instance is required as an 
    # argument.
    #
    # In practice, the token and data bits tend to be placed close together, making
    # excessive skew less of an issue.
    # -----------------------------------------------------------------------------
    proc altera_10gbaser_phy_constrain_clock_crosser_skew { path } {

        set in_regs  [ get_registers $path|*altera_10gbaser_phy_clock_crosser*|in_data_buffer* ] 
        set out_regs [ get_registers $path|*altera_10gbaser_phy_clock_crosser*|out_data_buffer* ] 

        set in_regs [ add_to_collection $in_regs  [ get_registers $path|*altera_10gbaser_phy_clock_crosser*|in_data_toggle ] ]
        set out_regs [ add_to_collection $out_regs [ get_registers $path|*altera_10gbaser_phy_clock_crosser:*|altera_std_synchronizer_nocut:in_to_out_synchronizer|din_s1 ] ]

        set_max_skew -from $in_regs -to $out_regs 3 
    }

}

# Function to constraint pointers
proc altera_10gbaser_phy_constraint_ptr {from_path from_reg to_path to_reg max_skew max_net_delay} {
    
    if { [string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)] } {
        # Check for instances
        set inst [get_registers -nowarn *${from_path}|${from_reg}*]
        
        # Check number of instances
        set inst_num [llength [query_collection -report -all $inst]]
        if {$inst_num > 0} {
            # Uncomment line below for debug purpose
            #puts "${inst_num} ${from_path}|${from_reg} instance(s) found"
        } else {
            # Uncomment line below for debug purpose
            #puts "No ${from_path}|${from_reg} instance found"
        }
        
        set inst_list [query_collection -list -all $inst]
        foreach each_inst $inst_list {
            # Get the path to instance
            regexp "(.*${from_path})(.*|)(${from_reg})" $each_inst reg_path inst_path inst_name reg_name
            
            set_max_skew -from [get_registers ${inst_path}${inst_name}${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] $max_skew
            
            set_max_delay -from [get_registers ${inst_path}${inst_name}${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] 100ns
            set_min_delay -from [get_registers ${inst_path}${inst_name}${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] -100ns
        }
        
    } else {
        set_net_delay -from [get_pins -compatibility_mode *${from_path}|${from_reg}*|q] -to [get_registers *${to_path}|${to_reg}*] -max $max_net_delay
        
        # Relax the fitter effort
        set_max_delay -from [get_registers *${from_path}|${from_reg}*] -to [get_registers *${to_path}|${to_reg}*] 100ns
        set_min_delay -from [get_registers *${from_path}|${from_reg}*] -to [get_registers *${to_path}|${to_reg}*] -100ns
        
    }
    
}

# DCFIFO pointer constraint
set inst [get_registers -nowarn *async_fifo*dcfifo_componenet*]
set inst_num [llength [query_collection -report -all $inst]]
if {$inst_num > 0} {
    altera_10gbaser_phy_constraint_ptr  altera_10gbaser_phy_async_fifo:altera_10gbaser_phy_async_fifo|dcfifo:dcfifo_componenet|dcfifo_*:auto_generated  delayed_wrptr_g  altera_10gbaser_phy_async_fifo:altera_10gbaser_phy_async_fifo|dcfifo:dcfifo_componenet|dcfifo_*:auto_generated|alt_synch_pipe_*:rs_dgwp*|*  *dffe*  6ns  5ns
    altera_10gbaser_phy_constraint_ptr  altera_10gbaser_phy_async_fifo:altera_10gbaser_phy_async_fifo|dcfifo:dcfifo_componenet|dcfifo_*:auto_generated  rdptr_g          altera_10gbaser_phy_async_fifo:altera_10gbaser_phy_async_fifo|dcfifo:dcfifo_componenet|dcfifo_*:auto_generated|alt_synch_pipe_*:ws_dgrp*|*  *dffe*  3ns  2ns
    altera_10gbaser_phy_constraint_ptr  altera_10gbaser_phy_async_fifo_fpga:async_fifo|dcfifo:dcfifo_componenet|dcfifo_*:auto_generated  delayed_wrptr_g    altera_10gbaser_phy_async_fifo_fpga:async_fifo|dcfifo:dcfifo_componenet|dcfifo_*:auto_generated|alt_synch_pipe_*:rs_dgwp*|*  *dffe*  3ns  2ns
    altera_10gbaser_phy_constraint_ptr  altera_10gbaser_phy_async_fifo_fpga:async_fifo|dcfifo:dcfifo_componenet|dcfifo_*:auto_generated  rdptr_g            altera_10gbaser_phy_async_fifo_fpga:async_fifo|dcfifo:dcfifo_componenet|dcfifo_*:auto_generated|alt_synch_pipe_*:ws_dgrp*|*  *dffe*  6ns  5ns
}

set_project_mode -always_show_entity_name $old_mode
