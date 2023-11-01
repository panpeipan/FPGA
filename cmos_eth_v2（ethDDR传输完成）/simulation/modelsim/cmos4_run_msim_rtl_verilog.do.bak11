transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {d:/fpga/altera/quartusii/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/lpm_ver
vmap lpm_ver ./verilog_libs/lpm_ver
vlog -vlog01compat -work lpm_ver {d:/fpga/altera/quartusii/quartus/eda/sim_lib/220model.v}

vlib verilog_libs/sgate_ver
vmap sgate_ver ./verilog_libs/sgate_ver
vlog -vlog01compat -work sgate_ver {d:/fpga/altera/quartusii/quartus/eda/sim_lib/sgate.v}

vlib verilog_libs/altera_mf_ver
vmap altera_mf_ver ./verilog_libs/altera_mf_ver
vlog -vlog01compat -work altera_mf_ver {d:/fpga/altera/quartusii/quartus/eda/sim_lib/altera_mf.v}

vlib verilog_libs/altera_lnsim_ver
vmap altera_lnsim_ver ./verilog_libs/altera_lnsim_ver
vlog -sv -work altera_lnsim_ver {d:/fpga/altera/quartusii/quartus/eda/sim_lib/altera_lnsim.sv}

vlib verilog_libs/cycloneive_ver
vmap cycloneive_ver ./verilog_libs/cycloneive_ver
vlog -vlog01compat -work cycloneive_ver {d:/fpga/altera/quartusii/quartus/eda/sim_lib/cycloneive_atoms.v}

vlib verilog_libs/cycloneiii_ver
vmap cycloneiii_ver ./verilog_libs/cycloneiii_ver
vlog -vlog01compat -work cycloneiii_ver {d:/fpga/altera/quartusii/quartus/eda/sim_lib/cycloneiii_atoms.v}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/ddr2_alt_mem_ddrx_controller_top.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_controller.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_addr_cmd.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_addr_cmd_wrap.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_controller_st_top.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ddr2_odt_gen.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ddr3_odt_gen.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_lpddr2_addr_cmd.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_odt_gen.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_rdwr_data_tmg.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_arbiter.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_burst_gen.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_cmd_gen.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_csr.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_buffer.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_buffer_manager.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_burst_tracking.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_dataid_manager.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_fifo.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_list.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_rdata_path.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_wdata_path.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ecc_decoder.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ecc_decoder_32_syn.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ecc_decoder_64_syn.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ecc_encoder.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ecc_encoder_32_syn.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ecc_encoder_64_syn.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ecc_encoder_decoder_wrapper.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_input_if.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_mm_st_converter.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_rank_timer.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_sideband.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_tbp.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_timing_param.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/ddr2.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/ddr2_phy_alt_mem_phy_seq_wrapper.vo}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/ddr2_phy.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth_ctrl/gmii_tx_ctrl.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp/crc32_d8.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp/arp_tx.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp/arp_top.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp/arp_rx.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp/arp_ctrl.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp/arp.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/udp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/udp/udp_tx.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/udp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/udp/udp_rx.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/udp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/udp/udp.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/ethernet_top.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth_ctrl/start_transfer_ctrl.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth_ctrl/img_data_pkt.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/include {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/include/myparam.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/function_rtl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/function_rtl/switch_show.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/key_sw {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/key_sw/key_bank_switch.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/key_sw {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/key_sw/debounce.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/bank_switch {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/bank_switch/bank_switch_ctrl.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/bank_switch {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/bank_switch/bank_switch.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl/mem_burst_ddr.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl/ddr_wr_ctrl.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl/ddr_wdisplayfifo.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281 {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281/ov9281_capture.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281 {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281/i2c_com.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281 {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281/camera_ov9281.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/Slave_arbitrate {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/Slave_arbitrate/slave_arbitrate_interface.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/Slave_arbitrate {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/Slave_arbitrate/arbitrate_ctrl.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_controller.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ddr2_odt_gen.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ddr3_odt_gen.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_rdwr_data_tmg.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_arbiter.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_buffer.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_burst_tracking.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_dataid_manager.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_fifo.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_list.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_wdata_path.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ecc_decoder.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ecc_decoder_32_syn.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ecc_encoder.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ecc_encoder_32_syn.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_ecc_encoder_decoder_wrapper.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_input_if.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_mm_st_converter.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_rank_timer.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/ddr2_phy_alt_mem_phy_pll.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/fifo_32w32r.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/fifo_32w8r.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/pll_u0.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/fifo_eth_8w32r.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_phy_defines.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/ddr2_controller_phy.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/db {F:/old_Quartus_File/cmos_eth_v0.1/db/pll_u0_altpll.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281 {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281/ov9281_config.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/vga_display {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/vga_display/vga_display.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/top {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/top/top_sdv.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/ddr2_alt_mem_ddrx_controller_top.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_addr_cmd.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_addr_cmd_wrap.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_controller_st_top.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_odt_gen.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_burst_gen.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_cmd_gen.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_rdata_path.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_sideband.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_tbp.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/alt_mem_ddrx_timing_param.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/ddr2_phy_alt_mem_phy.v}

vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/bank_switch {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/bank_switch/bank_switch.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/bank_switch {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/bank_switch/bank_switch_ctrl.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl/ddr_wdisplayfifo.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl/ddr_wr_ctrl.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl/ddr2wr_fifo.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/ddr_ctrl/mem_burst_ddr.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281 {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281/ov9281_config.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281 {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281/ov9281_capture.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281 {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281/i2c_com.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281 {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/OV9281/camera_ov9281.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/Slave_arbitrate {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/Slave_arbitrate/arbitrate_ctrl.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/Slave_arbitrate {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/Slave_arbitrate/slave_arbitrate_interface.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/tb {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/tb/top_testbench.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/tb {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/tb/rgb888_ycrcb888.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/top {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/top/top_sdv.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/vga_display {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/vga_display/vga_display.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/testbench {F:/old_Quartus_File/cmos_eth_v0.1/testbench/ddr2_full_mem_model.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/testbench {F:/old_Quartus_File/cmos_eth_v0.1/testbench/ddr2_mem_model.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/key_sw {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/key_sw/key_bank_switch.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/key_sw {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/key_sw/debounce.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth_ctrl/gmii_tx_ctrl.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth_ctrl/img_data_pkt.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth_ctrl {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth_ctrl/start_transfer_ctrl.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/ethernet_top.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/udp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/udp/udp.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/udp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/udp/udp_rx.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/udp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/udp/udp_tx.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp/arp.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp/arp_ctrl.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp/arp_rx.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp/arp_top.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp/arp_tx.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/eth/arp/crc32_d8.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1 {F:/old_Quartus_File/cmos_eth_v0.1/fifo_eth_8w32r.v}
vlog -vlog01compat -work work +incdir+F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/include {F:/old_Quartus_File/cmos_eth_v0.1/rtl_code/include/myparam.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L cycloneiii_ver -L rtl_work -L work -voptargs="+acc"  top_testbench

add wave *
view structure
view signals
run -all
