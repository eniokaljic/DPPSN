// (C) 2001-2016 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`define CTL_BFL 9 
`define TOTAL_XGMII_LANE 8
`define TOTAL_DATA_PER_LANE 8
`define TOTAL_CONTROL_PER_LANE 1
`define TOTAL_SIGNAL_PER_LANE (`TOTAL_DATA_PER_LANE+`TOTAL_CONTROL_PER_LANE)

`timescale 1ns/10ps

import altera_xcvr_functions::*;

module sv_xcvr_10gbaser_native #(
  parameter operation_mode         = "duplex",
  parameter output_clock_frequency = "5156.25 MHz",
  parameter output_data_rate       = "10312.50 Mbps",
  parameter ref_clk_freq           = "322.265625 Mhz",
  parameter rx_use_coreclk         = 0,
  parameter pll_type               = "AUTO",    // PLL type for each PLL
  parameter pma_mode               = 40,
  parameter high_precision_latadj  = 1,
  parameter latadj_width           = 16,
  parameter RX_LATADJ            = 0,
  parameter TX_LATADJ            = 0
)(
  input wire                                                                                                pll_ref_clk,
  input wire                                                                                                pll_rstn,
  input wire                                                                                                tx_analog_rst,
  input wire                                                                                                tx_digital_rstn,
  input wire                                                                                                rx_analog_rstn,
  input wire                                                                                                rx_digital_rstn,
  input wire [71:0]                                                                                         xgmii_tx_dc,
  output wire [71:0]                                                                                        xgmii_rx_dc,
  input wire                                                                                                xgmii_tx_clk, 
  input  wire        rx_coreclkin,
  output wire                                                                                               xgmii_rx_clk, 
  output wire                                                                                               tx_serial_data,
  input wire                                                                                                rx_serial_data,
  output wire                                                                                               pll_locked,
  output wire                                                                                               rx_recovered_clk,
  output wire                                                                                               rx_is_lockedtodata,
  output wire                                                                                               rx_is_lockedtoref,
  output wire                                                                                               tx_cal_busy,
  output wire                                                                                               rx_cal_busy,

  input wire                                                                                                rx_set_locktodata, //directly connect to rx_pma.ltd
  input wire                                                                                                rx_set_locktoref, //goes thru pcs then to rx_pma.ltr
  input wire                                                                                                rxseriallpbken,
  input wire                                                                                                rxclrerrorblockcount,
  input wire                                                                                                rxclrbercount,
  input wire                                                                                                rxprbserrorclr,
//output wire        pcsstatus,
  output wire                                                                                               rxblocklock,
  output wire                                                                                               rxhighber,
  output wire                                                                                               rx_data_ready,
//output wire [ 5:0] bercount,
//output wire [ 7:0] errorblockcount,
//output wire [15:0] randomerrorcount,
  output wire                                                                                               rxfifoempty,
  output wire                                                                                               rxfifopartialempty,
  output wire                                                                                               rxfifopartialfull,
  output wire                                                                                               rxfifofull,
  output wire                                                                                               rxsyncheadererror,
  output wire                                                                                               rxscramblererror,

  output wire                                                                                               txfifoempty,
  output wire                                                                                               txfifopartialempty,
  output wire                                                                                               txfifopartialfull,
  output wire                                                                                               txfifofull,

  output wire [latadj_width-1:0]                                                                            tx_latency_adj,
  output wire [latadj_width-1:0]                                                                            rx_latency_adj,

  input wire [altera_xcvr_functions::get_custom_reconfig_to_width ("Stratix V",operation_mode,1,1,1)-1:0]   reconfig_to_xcvr,
  output wire [altera_xcvr_functions::get_custom_reconfig_from_width("Stratix V",operation_mode,1,1,1)-1:0] reconfig_from_xcvr 
  
);

  wire               clkout_totx ;
  wire    [ 64-1:0 ] tx_datain, tx_datain_inter;  
  wire    [  8-1:0 ] tx_control, tx_control_inter;
  wire               tx_data_valid;
  wire               txfifofull_inter;
  wire    [ 64-1:0 ] rx_dataout, rx_dataout_inter;  
  wire    [ 10-1:0 ] rx_control, rx_control_inter;   
  wire               rxfifofull_inter, fifo_full;
  wire    in_pld_10g_rx_pld_clk;
  
  localparam INT_TX_ENABLE = (operation_mode=="duplex")?  1'b1:
                             (operation_mode=="tx_only")? 1'b1:
                             (operation_mode=="rx_only")? 1'b0:1'bx;
  localparam INT_RX_ENABLE = (operation_mode=="duplex")?  1'b1:
                             (operation_mode=="tx_only")? 1'b0:
                             (operation_mode=="rx_only")? 1'b1:1'bx;
  localparam RX_POLARITY_INV = "invert_disable"; //valid setting for 10gbaser:invert_disable,invert_enable
  localparam TX_POLARITY_INV = "invert_disable"; //valid setting for 10gbaser:invert_disable,invert_enable
  localparam TX_SH_ERR       = "sh_err_dis";     //valid setting for 10gbaser:sh_err_en,sh_err_dis
  localparam RX_TRUE_B2B     = "b2b";            //valid setting for 10gbaser:b2b,single

  localparam FAWIDTH  = 5;
  localparam TSWIDTH  = 16; // determines the width of latency_adj
  localparam TX_PCS_OFFSET = (pma_mode == 32) ? 16'h256C : 16'h2AC7;
  localparam RX_PCS_OFFSET = (pma_mode == 32) ? 16'h232A : 16'h28FA;

  wire              rx_data_valid;
  wire              tx_div40_clk;
  
  generate
  genvar i;

  for (i=0; i<`TOTAL_XGMII_LANE; i=i+1) 
  begin: bus_assign
    //tx input
    assign tx_datain[`TOTAL_DATA_PER_LANE*i+:`TOTAL_DATA_PER_LANE]      = xgmii_tx_dc[`TOTAL_SIGNAL_PER_LANE*i+:`TOTAL_DATA_PER_LANE];
    assign tx_control[i]                                                = xgmii_tx_dc[(`TOTAL_SIGNAL_PER_LANE*i+`TOTAL_DATA_PER_LANE)+:`TOTAL_CONTROL_PER_LANE];
    //rx output
    assign xgmii_rx_dc[`TOTAL_SIGNAL_PER_LANE*i+:`TOTAL_SIGNAL_PER_LANE]= {rx_control[i], rx_dataout[`TOTAL_DATA_PER_LANE*i+:`TOTAL_DATA_PER_LANE]};
  end 
  endgenerate

  
  sv_xcvr_native #(
    //PMA parameters
    .rx_enable(INT_RX_ENABLE),
    .tx_enable(INT_TX_ENABLE),
    .bonded_lanes(1),
    .channel_number(0),
    .pma_prot_mode("basic"),
    .pma_mode(pma_mode),
    .pma_data_rate(output_data_rate),
    .cdr_reference_clock_frequency(ref_clk_freq),

    //PCS parameters
    .enable_10g_rx(INT_RX_ENABLE ? "true" : "false"),
    .enable_10g_tx(INT_TX_ENABLE ? "true" : "false"),
    .enable_8g_rx("false"),
    .enable_8g_tx("false"),
    .enable_dyn_reconfig("false"),
    .enable_gen12_pipe("false"),
    .enable_gen3_pipe("false"),
    .enable_gen3_rx("false"),
    .enable_gen3_tx("false"),

    //enable parallel loopback for debugging only
    .pcs10g_rx_lpbk_mode("lpbk_dis"), // lpbk_dis|lpbk_en

    //10G_PCS
    .pcs10g_rx_ber_bit_err_total_cnt("bit_err_total_cnt_10g"), //SIV is 15
    .pcs10g_rx_ber_xus_timer_window("xus_timer_window_10g"), //SIV value
    .pcs10g_rx_dis_signal_ok("dis_signal_ok_en"),//to enable signal_ok
    .pcs10g_rx_gb_rx_odwidth("width_66"),
    .pcs10g_rx_gb_rx_idwidth((pma_mode == 32) ? "width_32" : "width_40"),
    .pcs10g_rx_prot_mode(RX_LATADJ?"teng_1588_mode":"teng_baser_mode"),
    .pcs10g_rx_rx_polarity_inv(RX_POLARITY_INV),
    .pcs10g_rx_sup_mode("user_mode"),
    .pcs10g_rx_rxfifo_pempty(RX_LATADJ?2:7),
    .pcs10g_rx_rx_testbus_sel("<auto_any>"),
    .pcs10g_rx_rx_true_b2b(RX_TRUE_B2B),
    .pcs10g_tx_txfifo_pempty(2),
    .pcs10g_tx_gb_tx_idwidth("width_66"),
    .pcs10g_tx_gb_tx_odwidth((pma_mode == 32) ? "width_32" : "width_40"),
    .pcs10g_tx_pmagate_en("pmagate_dis"),//to disable programmable PMA gate value
    .pcs10g_tx_prot_mode(TX_LATADJ?"teng_1588_mode":"teng_baser_mode"),
    .pcs10g_tx_sup_mode("user_mode"),
    .pcs10g_tx_sh_err(TX_SH_ERR),
    .pcs10g_tx_tx_polarity_inv(TX_POLARITY_INV),
    .pcs10g_tx_tx_testbus_sel("<auto_any>"),
    .com_pcs_pma_if_force_freqdet("force_freqdet_dis"),
    .com_pcs_pma_if_func_mode("teng_only"),
    .com_pcs_pma_if_ppmsel("ppmsel_1000"),
    .com_pcs_pma_if_prot_mode("other_protocols"),
    .com_pcs_pma_if_sup_mode("user_mode"),
    .com_pld_pcs_if_testbus_sel("ten_g_pcs"),
    .rx_pcs_pma_if_prot_mode("other_protocols"),
    .rx_pcs_pma_if_selectpcs("ten_g_pcs"),
    .rx_pld_pcs_if_selectpcs("ten_g_pcs"),
    .tx_pcs_pma_if_selectpcs("ten_g_pcs")
  ) native_inst (

    //TX/RX ports
    .seriallpbken(rxseriallpbken),   // 1 = enable serial loopback                    

    //RX Ports                                                                 
    .rx_crurstn(rx_analog_rstn),  
    .rx_datain(rx_serial_data),      // RX serial data input                          
    .rx_cdr_ref_clk(pll_ref_clk), // Reference clock for CDR                       
    .rx_ltd(rx_set_locktodata),         // Force lock-to-data stream                     
    .rx_is_lockedtoref(rx_is_lockedtoref),  // Indicates lock to reference clock         
    .rx_is_lockedtodata(rx_is_lockedtodata),
    .rx_clkdivrx(/*unused*/),
    .tx_cal_busy(tx_cal_busy),
    .rx_cal_busy(rx_cal_busy),

    // TX Ports                                                                 
    .tx_rxdetclk(1'b0),    // Clock for detection of downstream receiver
    .tx_dataout(tx_serial_data),     // TX serial data output
    .tx_rstn(~tx_analog_rst),        // TODO - Examine resets
    .tx_ser_clk(clkout_totx),     // High-speed serial clock from PLL              

    // PCS Ports
    .in_agg_align_status(/*unused*/),
    .in_agg_align_status_sync_0(/*unused*/),
    .in_agg_align_status_sync_0_top_or_bot(/*unused*/),
    .in_agg_align_status_top_or_bot(/*unused*/),
    .in_agg_cg_comp_rd_d_all(/*unused*/),
    .in_agg_cg_comp_rd_d_all_top_or_bot(/*unused*/),
    .in_agg_cg_comp_wr_all(/*unused*/),
    .in_agg_cg_comp_wr_all_top_or_bot(/*unused*/),
    .in_agg_del_cond_met_0(/*unused*/),
    .in_agg_del_cond_met_0_top_or_bot(/*unused*/),
    .in_agg_en_dskw_qd(/*unused*/),
    .in_agg_en_dskw_qd_top_or_bot(/*unused*/),
    .in_agg_en_dskw_rd_ptrs(/*unused*/),
    .in_agg_en_dskw_rd_ptrs_top_or_bot(/*unused*/),
    .in_agg_fifo_ovr_0(/*unused*/),
    .in_agg_fifo_ovr_0_top_or_bot(/*unused*/),
    .in_agg_fifo_rd_in_comp_0(/*unused*/),
    .in_agg_fifo_rd_in_comp_0_top_or_bot(/*unused*/),
    .in_agg_fifo_rst_rd_qd(/*unused*/),
    .in_agg_fifo_rst_rd_qd_top_or_bot(/*unused*/),
    .in_agg_insert_incomplete_0(/*unused*/),
    .in_agg_insert_incomplete_0_top_or_bot(/*unused*/),
    .in_agg_latency_comp_0(/*unused*/),
    .in_agg_latency_comp_0_top_or_bot(/*unused*/),
    .in_agg_rcvd_clk_agg(/*unused*/),
    .in_agg_rcvd_clk_agg_top_or_bot(/*unused*/),
    .in_agg_rx_control_rs(/*unused*/),
    .in_agg_rx_control_rs_top_or_bot(/*unused*/),
    .in_agg_rx_data_rs(/*unused*/),
    .in_agg_rx_data_rs_top_or_bot(/*unused*/),
    .in_agg_test_so_to_pld_in(/*unused*/),
    .in_agg_testbus(/*unused*/),
    .in_agg_tx_ctl_ts(/*unused*/),
    .in_agg_tx_ctl_ts_top_or_bot(/*unused*/),
    .in_agg_tx_data_ts(/*unused*/),
    .in_agg_tx_data_ts_top_or_bot(/*unused*/),
    .in_emsip_com_in(/*unused*/),
    .in_emsip_com_special_in(/*unused*/),
    .in_emsip_rx_clk_in(/*unused*/),
    .in_emsip_rx_in(/*unused*/),
    .in_emsip_rx_special_in(/*unused*/),
    .in_emsip_tx_clk_in(/*unused*/),
    .in_emsip_tx_in(/*unused*/),
    .in_emsip_tx_special_in(/*unused*/),

    .in_pld_10g_refclk_dig(1'b0),
    .in_pld_10g_rx_align_clr(1'b0),
    .in_pld_10g_rx_align_en(1'b0),//was tie to 1 in 2.0
    .in_pld_10g_rx_bitslip(1'b0),
    .in_pld_10g_rx_clr_ber_count(rxclrbercount),
    .in_pld_10g_rx_clr_errblk_cnt(rxclrerrorblockcount),
    .in_pld_10g_rx_disp_clr(1'b0),
    .in_pld_10g_rx_pld_clk(in_pld_10g_rx_pld_clk),
    .in_pld_10g_rx_prbs_err_clr(rxprbserrorclr),
    .in_pld_10g_rx_rd_en(1'b0),//was tie to 1 in 2.0
    .in_pld_10g_rx_rst_n(rx_digital_rstn),

    .in_pld_tx_data(tx_datain_inter[63:0]),
    .in_pld_10g_tx_bitslip(7'b0),
    .in_pld_10g_tx_burst_en(1'b1),
    .in_pld_10g_tx_control({1'b0, tx_control_inter}),
    .in_pld_10g_tx_data_valid(tx_data_valid),
    .in_pld_10g_tx_diag_status(2'b00),
    .in_pld_10g_tx_pld_clk(xgmii_tx_clk),
    .in_pld_10g_tx_rst_n(tx_digital_rstn),
    .in_pld_10g_tx_wordslip(1'b0),

    .in_pld_8g_a1a2_size(/*unused*/),
    .in_pld_8g_bitloc_rev_en(/*unused*/),
    .in_pld_8g_bitslip(/*unused*/),
    .in_pld_8g_byte_rev_en(/*unused*/),
    .in_pld_8g_bytordpld(/*unused*/),
    .in_pld_8g_cmpfifourst_n(/*unused*/),
    .in_pld_8g_encdt(/*unused*/),
    .in_pld_8g_phfifourst_rx_n(/*unused*/),
    .in_pld_8g_phfifourst_tx_n(/*unused*/),
    .in_pld_8g_pld_rx_clk(/*unused*/),
    .in_pld_8g_pld_tx_clk(/*unused*/),
    .in_pld_8g_polinv_rx(/*unused*/),
    .in_pld_8g_polinv_tx(/*unused*/),
    .in_pld_8g_powerdown(/*unused*/),
    .in_pld_8g_prbs_cid_en(/*unused*/),
    .in_pld_8g_rddisable_tx(/*unused*/),
    .in_pld_8g_rdenable_rmf(/*unused*/),
    .in_pld_8g_rdenable_rx(/*unused*/),
    .in_pld_8g_refclk_dig(/*unused*/),
    .in_pld_8g_refclk_dig2(/*unused*/),
    .in_pld_8g_rev_loopbk(/*unused*/),
    .in_pld_8g_rxpolarity(/*unused*/),
    .in_pld_8g_rxurstpcs_n(/*unused*/),
    .in_pld_8g_tx_blk_start(/*unused*/),
    .in_pld_8g_tx_boundary_sel(/*unused*/),
    .in_pld_8g_tx_data_valid(/*unused*/),
    .in_pld_8g_tx_sync_hdr(/*unused*/),
    .in_pld_8g_txdeemph(/*unused*/),
    .in_pld_8g_txdetectrxloopback(/*unused*/),
    .in_pld_8g_txelecidle(/*unused*/),
    .in_pld_8g_txmargin(/*unused*/),
    .in_pld_8g_txswing(/*unused*/),
    .in_pld_8g_txurstpcs_n(/*unused*/),
    .in_pld_8g_wrdisable_rx(/*unused*/),
    .in_pld_8g_wrenable_rmf(/*unused*/),
    .in_pld_8g_wrenable_tx(/*unused*/),
    .in_pld_agg_refclk_dig(/*unused*/),
    .in_pld_eidleinfersel(/*unused*/),
    .in_pld_gen3_current_coeff(/*unused*/),
    .in_pld_gen3_current_rxpreset(/*unused*/),
    .in_pld_gen3_rx_rstn(/*unused*/),
    .in_pld_gen3_tx_rstn(/*unused*/),
    .in_pld_ltr(rx_set_locktoref),
    .in_pld_partial_reconfig_in(1'b1),
    .in_pld_pcs_pma_if_refclk_dig(/*unused*/),
    .in_pld_rate(/*unused*/),
    .in_pld_reserved_in(/*unused*/),
    .in_pld_rx_clk_slip_in(1'b0),
    .in_pld_rxpma_rstb_in(rx_analog_rstn),  
    .in_pld_scan_mode_n(1'b1),
    .in_pld_scan_shift_n(1'b1),
    .in_pld_sync_sm_en(/*unused*/),
    .in_pma_clkdiv33_lc_in(1'b0),
    .in_pma_eye_monitor_in(/*unused*/),
    .in_pma_hclk(/*unused*/),
    .in_pma_reserved_in(/*unused*/),
    .in_pma_rx_freq_tx_cmu_pll_lock_in(1'b0),
    .in_pma_tx_lc_pll_lock_in(1'b0),

    .out_agg_align_det_sync(/*unused*/),                               
    .out_agg_align_status_sync(/*unused*/),
    .out_agg_cg_comp_rd_d_out(/*unused*/),
    .out_agg_cg_comp_wr_out(/*unused*/),
    .out_agg_dec_ctl(/*unused*/),
    .out_agg_dec_data(/*unused*/),
    .out_agg_dec_data_valid(/*unused*/),
    .out_agg_del_cond_met_out(/*unused*/),
    .out_agg_fifo_ovr_out(/*unused*/),
    .out_agg_fifo_rd_out_comp(/*unused*/),
    .out_agg_insert_incomplete_out(/*unused*/),
    .out_agg_latency_comp_out(/*unused*/),
    .out_agg_rd_align(/*unused*/),
    .out_agg_rd_enable_sync(/*unused*/),
    .out_agg_refclk_dig(/*unused*/),
    .out_agg_running_disp(/*unused*/),
    .out_agg_rxpcs_rst(/*unused*/),
    .out_agg_scan_mode_n(/*unused*/),
    .out_agg_scan_shift_n(/*unused*/),
    .out_agg_sync_status(/*unused*/),
    .out_agg_tx_ctl_tc(/*unused*/),
    .out_agg_tx_data_tc(/*unused*/),
    .out_agg_txpcs_rst(/*unused*/),
    .out_emsip_com_clk_out(/*unused*/),
    .out_emsip_com_out(/*unused*/),
    .out_emsip_com_special_out(/*unused*/),
    .out_emsip_rx_clk_out(/*unused*/),
    .out_emsip_rx_out(/*unused*/),
    .out_emsip_rx_special_out(/*unused*/),
    .out_emsip_tx_clk_out(/*unused*/),
    .out_emsip_tx_out(/*unused*/),
    .out_emsip_tx_special_out(/*unused*/),

    .out_pld_rx_data(rx_dataout_inter[63:0]),
    .out_pld_10g_rx_align_val(/*unused*/),
    .out_pld_10g_rx_blk_lock(rxblocklock),
    .out_pld_10g_rx_clk_out(rx_recovered_clk),
    .out_pld_10g_rx_control(rx_control_inter), //also to tap out rx_data_ready later
    .out_pld_10g_rx_crc32_err(/*unused*/),
    .out_pld_10g_rx_data_valid(rx_data_valid),
    .out_pld_10g_rx_diag_err(/*unused*/),
    .out_pld_10g_rx_diag_status(/*unused*/),
    .out_pld_10g_rx_empty(rxfifoempty),
    .out_pld_10g_rx_fifo_del(/*unused*/), //for 10gbaser. do we need it?
    .out_pld_10g_rx_fifo_insert(/*unused*/), //for 10gbaser. do we need it?
    .out_pld_10g_rx_frame_lock(/*unused*/),
    .out_pld_10g_rx_hi_ber(rxhighber),
    .out_pld_10g_rx_mfrm_err(/*unused*/),
    .out_pld_10g_rx_oflw_err(rxfifofull_inter), //??Q?? I don't see rx_fifofull signal now
    .out_pld_10g_rx_pempty(rxfifopartialempty),
    .out_pld_10g_rx_pfull(rxfifopartialfull),
    .out_pld_10g_rx_prbs_err(/*unused*/),
    .out_pld_10g_rx_pyld_ins(/*unused*/),
    .out_pld_10g_rx_rdneg_sts(/*unused*/),
    .out_pld_10g_rx_rdpos_sts(/*unused*/),
    .out_pld_10g_rx_rx_frame(/*unused*/),
    .out_pld_10g_rx_scrm_err(rxscramblererror),
    .out_pld_10g_rx_sh_err(rxsyncheadererror),
    .out_pld_10g_rx_skip_err(/*unused*/),
    .out_pld_10g_rx_skip_ins(/*unused*/),
    .out_pld_10g_rx_sync_err(/*unused*/),

    .out_pld_10g_tx_burst_en_exe(/*unused*/),
    .out_pld_10g_tx_clk_out(tx_div40_clk),
    .out_pld_10g_tx_empty(txfifoempty),
    .out_pld_10g_tx_fifo_del(/*unused*/), //for 10gbaser. do we need it?
    .out_pld_10g_tx_fifo_insert(/*unused*/),//for 10gbaser. do we need it?
    .out_pld_10g_tx_frame(/*unused*/),
    .out_pld_10g_tx_full(txfifofull_inter),
    .out_pld_10g_tx_pempty(txfifopartialempty),
    .out_pld_10g_tx_pfull(txfifopartialfull),
    .out_pld_10g_tx_wordslip_exe(/*unused*/),

    .out_pld_8g_a1a2_k1k2_flag(/*unused*/),
    .out_pld_8g_align_status(/*unused*/),
    .out_pld_8g_bistdone(/*unused*/),
    .out_pld_8g_bisterr(/*unused*/),
    .out_pld_8g_byteord_flag(/*unused*/),
    .out_pld_8g_empty_rmf(/*unused*/),
    .out_pld_8g_empty_rx(/*unused*/),
    .out_pld_8g_empty_tx(/*unused*/),
    .out_pld_8g_full_rmf(/*unused*/),
    .out_pld_8g_full_rx(/*unused*/),
    .out_pld_8g_full_tx(/*unused*/),
    .out_pld_8g_phystatus(/*unused*/),
    .out_pld_8g_rlv_lt(/*unused*/),
    .out_pld_8g_rx_blk_start(/*unused*/),
    .out_pld_8g_rx_clk_out(/*unused*/),
    .out_pld_8g_rx_data_valid(/*unused*/),
    .out_pld_8g_rx_sync_hdr(/*unused*/),
    .out_pld_8g_rxelecidle(/*unused*/),
    .out_pld_8g_rxstatus(/*unused*/),
    .out_pld_8g_rxvalid(/*unused*/),
    .out_pld_8g_signal_detect_out(/*unused*/),
    .out_pld_8g_tx_clk_out(/*unused*/),
    .out_pld_8g_wa_boundary(/*unused*/),

    .out_pld_clkdiv33_lc(/*unused*/),
    .out_pld_clkdiv33_txorrx(/*unused*/),
    .out_pld_clklow(/*unused*/),
    .out_pld_fref(/*unused*/),
    .out_pld_gen3_mask_tx_pll(/*unused*/),
    .out_pld_gen3_rx_eq_ctrl(/*unused*/),
    .out_pld_gen3_rxdeemph(/*unused*/),
    .out_pld_reserved_out(/*unused*/),
    .out_pld_test_data(/*unused*/),
    .out_pld_test_si_to_agg_out(/*unused*/),
    .out_pma_current_rxpreset(/*unused*/),
    .out_pma_eye_monitor_out(/*unused*/),
    .out_pma_lc_cmu_rstb(/*unused*/),
    .out_pma_nfrzdrv(/*unused*/),
    .out_pma_partial_reconfig(/*unused*/),
    .out_pma_reserved_out(/*unused*/),
    .out_pma_rx_clk_out(/*unused*/),
//      .out_pma_rxpma_rstb(/*unused*/),
    .out_pma_tx_clk_out(/*unused*/),
    .out_pma_tx_pma_syncp_fbkp(/*unused*/),

    // sv_xcvr_avmm ports
    .reconfig_to_xcvr    (reconfig_to_xcvr    [0+:W_S5_RECONFIG_BUNDLE_TO_XCVR]  ),
    .reconfig_from_xcvr  (reconfig_from_xcvr  [0+:W_S5_RECONFIG_BUNDLE_FROM_XCVR]) 
    
  );

        wire pll5G_locked;
        wire pll156M_locked;
        assign pll_locked = pll5G_locked & pll156M_locked;
        
        generate
           if(operation_mode != "rx_only")
           begin
                //generic module in altera_xcvr_generic
                        wire fboutclk0;
            sv_xcvr_plls #(
              .plls                     (1                       ),
              .pll_type                 (pll_type                ),
              .reference_clock_frequency(ref_clk_freq            ),
              .output_clock_frequency   (output_clock_frequency  )
            ) altera_pll_5G (
              .refclk            (pll_ref_clk  ),
              .rst               (~pll_rstn    ),
              .fbclk             (fboutclk0    ),
              
              .outclk            (clkout_totx  ),
              .locked            (pll5G_locked ),
              .fboutclk          (fboutclk0    ),
            
              // avalon MM native reconfiguration interfaces
              .reconfig_to_xcvr   (reconfig_to_xcvr  [1*W_S5_RECONFIG_BUNDLE_TO_XCVR+:W_S5_RECONFIG_BUNDLE_TO_XCVR]   ),
              .reconfig_from_xcvr (reconfig_from_xcvr[1*W_S5_RECONFIG_BUNDLE_FROM_XCVR+:W_S5_RECONFIG_BUNDLE_FROM_XCVR] )
            );
           end
           else 
             begin
             assign pll5G_locked = 1'b1;
             assign clkout_totx = 1'b0;
             end
        endgenerate

                wire fboutclk1;
                generate
                        if (rx_use_coreclk==1'b0)
                        begin :g_fpll
              (* altera_attribute = "-name MERGE_TX_PLL_DRIVEN_BY_REGISTERS_WITH_SAME_CLEAR ON" *)
                                generic_pll #(
                                        .reference_clock_frequency  (ref_clk_freq  ),
                                        .output_clock_frequency     ("156.25 MHz"  )
                                ) altera_pll_156M (
                                        .outclk              (xgmii_rx_clk   ),
                                        .fboutclk            (fboutclk1      ),
                                        .rst                 (~pll_rstn      ),
                                        .refclk              (pll_ref_clk    ),
                                        .fbclk               (fboutclk1      ),
                                        .locked              (pll156M_locked ),
                        
                                        .writerefclkdata     (/*unused*/  ),
                                        .writeoutclkdata     (/*unused*/  ),
                                        .writephaseshiftdata (/*unused*/  ),
                                        .writedutycycledata  (/*unused*/  ),
                                        .readrefclkdata      (/*unused*/  ),
                                        .readoutclkdata      (/*unused*/  ),
                                        .readphaseshiftdata  (/*unused*/  ),
                                        .readdutycycledata   (/*unused*/  )
                                );
                        end
                        else
                        begin:no_g_fpll
                                assign xgmii_rx_clk = rx_coreclkin;
                                assign pll156M_locked = 1'b1;
                        end
                endgenerate

   generate
      if (RX_LATADJ == 1) begin : softrxfifos

         // Synchronize the reset of the FIFO
         reg rx_wr_rstn, rx_wr_rstn_m1;
         reg rx_rd_rstn, rx_rd_rstn_m1;
         always @(posedge rx_recovered_clk or negedge rx_digital_rstn)
           if (rx_digital_rstn == 0) begin
              rx_wr_rstn <= 1'b0;
              rx_wr_rstn_m1 <= 1'b0;
           end else begin
              rx_wr_rstn <= rx_wr_rstn_m1;
              rx_wr_rstn_m1 <= 1'b1;
           end
 
         always @(posedge xgmii_rx_clk or negedge rx_digital_rstn)
           if (rx_digital_rstn == 0) begin
              rx_rd_rstn <= 1'b0;
              rx_rd_rstn_m1 <= 1'b0;
           end else begin
              rx_rd_rstn <= rx_rd_rstn_m1;
              rx_rd_rstn_m1 <= 1'b1;
           end
  
        // reg incoming data (from hardfifo) before pass to 1588's softrxfifo
         reg [73:0] fifo_datain;
         reg        fifo_dvalid;
         reg        rxfifofull_reg;
         always @(posedge rx_recovered_clk or negedge rx_wr_rstn)
           if (rx_wr_rstn == 0) begin
              fifo_datain <= 74'b0;
              fifo_dvalid <= 1'b0;
              rxfifofull_reg <= 1'b0;
           end else begin
              fifo_datain <= {rx_control_inter,rx_dataout_inter};
              fifo_dvalid <= rx_data_valid;
              rxfifofull_reg <= fifo_full; // reg fifo_full before passing to CSR
           end
           
         wire [TSWIDTH-1:0] rx_latency_adj_w;
         
         altera_10gbaser_phy_rx_fifo_wrap 
           #(
             .FDWIDTH            (74),        // FIFO Data input width  
             .FAWIDTH            (FAWIDTH),   // FIFO Depth (address width) 
             .FSYNCSTAGE         (5),
             .CC_TX              (0),         // FIFO used in TX path 1, else 0 
             .IDWIDTH            (pma_mode),  // RX Gearbox Input Data Width 
             .ISWIDTH            (7),         // RX Gearbox Selector width
             .ODWIDTH            (66),        // RX Gearbox Output Data Width
             .TSWIDTH            (TSWIDTH),
             .PCS_OFFSET         (RX_PCS_OFFSET)
             )
         rx_clockcomp
           (
            .bypass_cc       (1'b0),                          // Bypass clock compensation
            .wr_rstn         (rx_wr_rstn),                    // Write Domain Active low Reset
            .wr_clk          (rx_recovered_clk),              // Write Domain Clock
            .data_in         (fifo_datain),
            .data_in_valid   (fifo_dvalid),
            .rd_rstn         (rx_rd_rstn),                    // Read Domain Active low Reset
            .rd_clk          (xgmii_rx_clk),                  // Read Domain Clock
            .data_out        ({rx_control,rx_dataout}),       // Read Data Out (Contains CTRL+DATA)
            .data_out_valid  (),                              // Read Data Out Valid 
            .fifo_full       (fifo_full),                     // FIFO Became FULL, Error Condition
            .latency_adj     (rx_latency_adj_w)
            );
            
        // eliminate the last 4 bits of fractional cycle if it is not high_precision_latadj
        assign rx_latency_adj = (high_precision_latadj) ? rx_latency_adj_w : rx_latency_adj_w[15:4];
        assign rx_data_ready = rx_control[`CTL_BFL];
        assign in_pld_10g_rx_pld_clk = rx_recovered_clk;
        assign rxfifofull = rxfifofull_reg;
        
      end else begin : hardrxfifo // block: softrxfifos
         assign rx_data_ready = rx_control[`CTL_BFL];
         assign rx_control = rx_control_inter;
         assign rx_dataout = rx_dataout_inter;
         assign rx_latency_adj = {latadj_width{1'b0}};
         assign rxfifofull = rxfifofull_inter;
         assign in_pld_10g_rx_pld_clk = xgmii_rx_clk;
      end
   endgenerate
   
   generate
      if (TX_LATADJ == 1) begin : softtxfifos

         // Synchronize the reset of the FIFO
         reg               tx_rd_rstn,tx_rd_rstn_m1;
         reg               tx_wr_rstn,tx_wr_rstn_m1;
         
         always @(posedge tx_div40_clk or negedge tx_digital_rstn) begin
            if (tx_digital_rstn == 0) begin
               tx_rd_rstn <= 1'b0;
               tx_rd_rstn_m1 <= 1'b0;
            end else begin
               tx_rd_rstn <= tx_rd_rstn_m1;
               tx_rd_rstn_m1 <= 1'b1;
            end
         end

         always @(posedge xgmii_tx_clk or negedge tx_digital_rstn) begin
            if (tx_digital_rstn == 0) begin
               tx_wr_rstn <= 1'b0;
               tx_wr_rstn_m1 <= 1'b0;
            end else begin
               tx_wr_rstn <= tx_wr_rstn_m1;
               tx_wr_rstn_m1 <= 1'b1;
            end
         end
         
         // reg outgoing data (from 1588's txsoftfifo) before pass to hardfifo
         // Adding the following register because their seems to be a inversion on 3 of every 8 bits of this bus.
         // This inversion is due to the default XGMII word being the reset state of the FIFO.
         // The inversion makes it difficult to meet timing on this bus, because it induces 600ps of difference
         // on the bits.

         wire [ 64-1:0 ]   tx_datain_l;
         wire [  8-1:0 ]   tx_control_l;
         wire              tx_data_valid_l;

         reg [ 64-1:0 ]    tx_datain_r;  
         reg [  8-1:0 ]    tx_control_r;
         reg               tx_data_valid_r;

         
         assign tx_datain_inter = tx_datain_r;
         assign tx_control_inter = tx_control_r;
         assign tx_data_valid = tx_data_valid_r;

         always @(posedge tx_div40_clk or negedge tx_rd_rstn) begin
           if (tx_rd_rstn == 0) begin
            tx_datain_r <= 64'b0;
            tx_control_r <= 8'b0;
            tx_data_valid_r <= 1'b0;
           end else begin
            tx_datain_r <= tx_datain_l;
            tx_control_r <= tx_control_l;
            tx_data_valid_r <= tx_data_valid_l;
           end
         end

         wire [TSWIDTH-1:0] tx_latency_adj_w;
         
         altera_10gbaser_phy_clockcomp
           #(
             .FDWIDTH            (72),         // FIFO Data input width  
             .FAWIDTH            (5),
             .CC_TX              (1),          // FIFO used in TX path 1, else 0 
             .IDWIDTH            (pma_mode),   // RX Gearbox Input Data Width 
             .ISWIDTH            (7),          // RX Gearbox Selector width
             .ODWIDTH            (66),         // RX Gearbox Output Data Width
             .TSWIDTH            (TSWIDTH),
             .PCS_OFFSET         (TX_PCS_OFFSET)
             )
         tx_clockcomp
           (
            // Outputs
            .data_out                   ({tx_control_l,tx_datain_l}),
            .data_out_valid             (tx_data_valid_l),
            .fifo_full                  (txfifofull),
            .latency_adj                (tx_latency_adj_w),
            // Inputs
            .bypass_cc                  (1'b0),
            .wr_rstn                    (tx_wr_rstn),
            .wr_clk                     (xgmii_tx_clk),
            .data_in                    ({tx_control,tx_datain[63:0]}),
            .data_in_valid              (1'b1),
            .rd_rstn                    (tx_rd_rstn),
            .rd_clk                     (tx_div40_clk)
            );
            
        // eliminate the last 4 bits of fractional cycle if it is not high_precision_latadj
        assign tx_latency_adj = (high_precision_latadj) ? tx_latency_adj_w : tx_latency_adj_w[TSWIDTH-1:4];  
        
      end // block: softtxfifos
      else begin : hardtxfifo
         assign tx_datain_inter = tx_datain;
         assign tx_control_inter = tx_control;
         assign tx_data_valid = 1'b1;
         assign tx_latency_adj = {latadj_width{1'b0}};
         assign txfifofull = txfifofull_inter;
      end
   endgenerate
        
endmodule                                                               
