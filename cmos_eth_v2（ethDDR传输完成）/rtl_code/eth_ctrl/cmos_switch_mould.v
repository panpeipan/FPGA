module cmos_switch_mould 
#(
    parameter cmos_num = 4'd3 )
(
    input  wire          i_sel_channal_sw ,
    input  wire [3:0]    i_eth_cmos_sel   ,
    //----------------------------------------------------//
    // cmos_port_0
    //----------------------------------------------------//
    input  wire          i_cmos0_pclk     ,
    input  wire [31: 0]  i_cmos0_data     ,
    input  wire          i_cmos0_dreq     ,
    input  wire          i_cmos0_vsync    ,
    //----------------------------------------------------//
    // cmos_port_1
    //----------------------------------------------------//
    input  wire          i_cmos1_pclk     ,
    input  wire [31: 0]  i_cmos1_data     ,
    input  wire          i_cmos1_dreq     ,
    input  wire          i_cmos1_vsync    ,
    //----------------------------------------------------//
    // cmos_port_2
    //----------------------------------------------------//
    input  wire          i_cmos2_pclk     ,
    input  wire [31: 0]  i_cmos2_data     ,
    input  wire          i_cmos2_dreq     ,
    input  wire          i_cmos2_vsync    ,
    //----------------------------------------------------//
    // cmos_port_3
    //----------------------------------------------------//
    input  wire          i_cmos3_pclk     ,
    input  wire [31: 0]  i_cmos3_data     ,
    input  wire          i_cmos3_dreq     ,
    input  wire          i_cmos3_vsync    ,
    //----------------------------------------------------//
    // cmos_port_4
    //----------------------------------------------------//
    input  wire          i_cmos4_pclk     ,
    input  wire [31: 0]  i_cmos4_data     ,
    input  wire          i_cmos4_dreq     ,
    input  wire          i_cmos4_vsync    ,
    //----------------------------------------------------//
    // cmos_port_5
    //----------------------------------------------------//
    input  wire          i_cmos5_pclk     ,
    input  wire [31: 0]  i_cmos5_data     ,
    input  wire          i_cmos5_dreq     ,
    input  wire          i_cmos5_vsync    ,
    //----------------------------------------------------//
    // cmos_port_6
    //----------------------------------------------------//
    input  wire          i_cmos6_pclk     ,
    input  wire [31: 0]  i_cmos6_data     ,
    input  wire          i_cmos6_dreq     ,
    input  wire          i_cmos6_vsync    ,
    //----------------------------------------------------//
    // cmos_port_7
    //----------------------------------------------------//
    input  wire          i_cmos7_pclk     ,
    input  wire [31: 0]  i_cmos7_data     ,
    input  wire          i_cmos7_dreq     ,
    input  wire          i_cmos7_vsync    ,
    //----------------------------------------------------//
    // cmos_port_8
    //----------------------------------------------------//
    input  wire          i_cmos8_pclk     ,
    input  wire [31: 0]  i_cmos8_data     ,
    input  wire          i_cmos8_dreq     ,
    input  wire          i_cmos8_vsync    ,
    //----------------------------------------------------//
    // cmos_port_sel
    //----------------------------------------------------//
    output wire          o_cmos_sel_pclk  ,
    output wire [31: 0]  o_cmos_sel_data  ,
    output wire          o_cmos_sel_dreq  ,
    output wire          o_cmos_sel_vsync 
);

//----------------------------------------------------//
// assign
//----------------------------------------------------//
assign o_cmos_sel_data = i_sel_channal_sw ? ((i_eth_cmos_sel == 4'd0) ? (i_cmos0_data):(
                                             (i_eth_cmos_sel == 4'd1) ? (i_cmos1_data):(
                                             (i_eth_cmos_sel == 4'd2) ? (i_cmos2_data):(
                                             (i_eth_cmos_sel == 4'd3) ? (i_cmos3_data):(
                                             (i_eth_cmos_sel == 4'd4) ? (i_cmos4_data):(
                                             (i_eth_cmos_sel == 4'd5) ? (i_cmos5_data):(
                                             (i_eth_cmos_sel == 4'd6) ? (i_cmos6_data):(
                                             (i_eth_cmos_sel == 4'd7) ? (i_cmos7_data):(
                                             (i_eth_cmos_sel == 4'd8) ? (i_cmos8_data): 
                                             i_cmos0_data ))))))))):1'b0; 
assign o_cmos_sel_dreq = i_sel_channal_sw ? ((i_eth_cmos_sel == 4'd0) ? (i_cmos0_dreq):(
                                             (i_eth_cmos_sel == 4'd1) ? (i_cmos1_dreq):(
                                             (i_eth_cmos_sel == 4'd2) ? (i_cmos2_dreq):(
                                             (i_eth_cmos_sel == 4'd3) ? (i_cmos3_dreq):(
                                             (i_eth_cmos_sel == 4'd4) ? (i_cmos4_dreq):(
                                             (i_eth_cmos_sel == 4'd5) ? (i_cmos5_dreq):(
                                             (i_eth_cmos_sel == 4'd6) ? (i_cmos6_dreq):(
                                             (i_eth_cmos_sel == 4'd7) ? (i_cmos7_dreq):(
                                             (i_eth_cmos_sel == 4'd8) ? (i_cmos8_dreq): 
                                             i_cmos0_dreq ))))))))):1'b0; 
assign o_cmos_sel_vsync = 1'b1 ? ((i_eth_cmos_sel == 4'd0) ? (i_cmos0_vsync):(
                                  (i_eth_cmos_sel == 4'd1) ? (i_cmos1_vsync):(
                                  (i_eth_cmos_sel == 4'd2) ? (i_cmos2_vsync):(
                                  (i_eth_cmos_sel == 4'd3) ? (i_cmos3_vsync):(
                                  (i_eth_cmos_sel == 4'd4) ? (i_cmos4_vsync):(
                                  (i_eth_cmos_sel == 4'd5) ? (i_cmos5_vsync):(
                                  (i_eth_cmos_sel == 4'd6) ? (i_cmos6_vsync):(
                                  (i_eth_cmos_sel == 4'd7) ? (i_cmos7_vsync):(
                                  (i_eth_cmos_sel == 4'd8) ? (i_cmos8_vsync): 
                                  i_cmos0_vsync ))))))))) : 1'b0; 
assign o_cmos_sel_pclk = i_sel_channal_sw ? ((i_eth_cmos_sel == 4'd0) ? (i_cmos0_pclk):(
                                             (i_eth_cmos_sel == 4'd1) ? (i_cmos1_pclk):(
                                             (i_eth_cmos_sel == 4'd2) ? (i_cmos2_pclk):(
                                             (i_eth_cmos_sel == 4'd3) ? (i_cmos3_pclk):(
                                             (i_eth_cmos_sel == 4'd4) ? (i_cmos4_pclk):(
                                             (i_eth_cmos_sel == 4'd5) ? (i_cmos5_pclk):(
                                             (i_eth_cmos_sel == 4'd6) ? (i_cmos6_pclk):(
                                             (i_eth_cmos_sel == 4'd7) ? (i_cmos7_pclk):(
                                             (i_eth_cmos_sel == 4'd8) ? (i_cmos8_pclk): 
                                             i_cmos0_pclk ))))))))) : 1'b0; 
endmodule 
