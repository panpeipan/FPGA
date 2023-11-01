module bank_switch_ctrl (
    input wire           ddr_clk              ,
    input wire           sys_rstn             ,
    //slave0_bank_switch
    input wire           slave0_valid         ,
    input wire           slave0_frame_wr_done ,
    input wire           slave0_frame_rd_done ,
    output wire          slave0_wr_load       ,
    output wire [1:0]    slave0_wr_bank       ,
    output wire          slave0_rd_load       ,
    output wire [1:0]    slave0_rd_bank       ,
    //slave1_bank_switch
    input wire           slave1_valid         ,
    input wire           slave1_frame_wr_done ,
    input wire           slave1_frame_rd_done ,
    output wire          slave1_wr_load       ,
    output wire [1:0]    slave1_wr_bank       ,
    output wire          slave1_rd_load       ,
    output wire [1:0]    slave1_rd_bank       ,
    //slave2_bank_switch
    input wire           slave2_valid         ,
    input wire           slave2_frame_wr_done ,
    input wire           slave2_frame_rd_done ,
    output wire          slave2_wr_load       ,
    output wire [1:0]    slave2_wr_bank       ,
    output wire          slave2_rd_load       ,
    output wire [1:0]    slave2_rd_bank       ,
    //slave3_bank_switch
    input wire           slave3_valid         ,
    input wire           slave3_frame_wr_done ,
    input wire           slave3_frame_rd_done ,
    output wire          slave3_wr_load       ,
    output wire [1:0]    slave3_wr_bank       ,
    output wire          slave3_rd_load       ,
    output wire [1:0]    slave3_rd_bank        
);

//-----------------------------------------------------
// bank_switch m0
//-----------------------------------------------------
 bank_switch bank_switch0
(
    .phy_clk                   ( ddr_clk               ),
    .sys_rstn                  ( sys_rstn              ),

    .camera_valid              (slave0_valid           ),//flag :camera will trans an new image | from camera camera_vsync
    .frame_wr_done             (slave0_frame_wr_done   ),//from ddr ddr2R_fifo.v
    .frame_rd_done             (slave0_frame_rd_done   ),//from ddr ddr2W_fifo.v

    .wr_bank                   (slave0_wr_bank         ),//ddr_width is 25bit,bank bit is [24][23]
    .wr_load                   (slave0_wr_load         ),//
    .rd_bank                   (slave0_rd_bank         ),//to ddrw_fifo.v
    .rd_load                   (slave0_rd_load         )//to ddrw_fifo.v
);
//-----------------------------------------------------
// bank_switch m1
//-----------------------------------------------------
 bank_switch bank_switch1
(
    .phy_clk                   ( ddr_clk               ),
    .sys_rstn                  ( sys_rstn              ),

    .camera_valid              (slave1_valid           ),//flag :camera will trans an new image | from camera camera_vsync
    .frame_wr_done             (slave1_frame_wr_done   ),//from ddr ddr2R_fifo.v
    .frame_rd_done             (slave1_frame_rd_done   ),//from ddr ddr2W_fifo.v

    .wr_bank                   (slave1_wr_bank         ),//ddr_width is 25bit,bank bit is [24][23]
    .wr_load                   (slave1_wr_load         ),//
    .rd_bank                   (slave1_rd_bank         ),//to ddrw_fifo.v
    .rd_load                   (slave1_rd_load         )//to ddrw_fifo.v
);
//-----------------------------------------------------
// bank_switch m2
//-----------------------------------------------------
 bank_switch bank_switch2
(
    .phy_clk                   ( ddr_clk               ),
    .sys_rstn                  ( sys_rstn              ),

    .camera_valid              (slave2_valid           ),//flag :camera will trans an new image | from camera camera_vsync
    .frame_wr_done             (slave2_frame_wr_done   ),//from ddr ddr2R_fifo.v
    .frame_rd_done             (slave2_frame_rd_done   ),//from ddr ddr2W_fifo.v

    .wr_bank                   (slave2_wr_bank         ),//ddr_width is 25bit,bank bit is [24][23]
    .wr_load                   (slave2_wr_load         ),//
    .rd_bank                   (slave2_rd_bank         ),//to ddrw_fifo.v
    .rd_load                   (slave2_rd_load         )//to ddrw_fifo.v
);
//-----------------------------------------------------
// bank_switch m3
//-----------------------------------------------------
 bank_switch bank_switch3
(
    .phy_clk                   ( ddr_clk               ),
    .sys_rstn                  ( sys_rstn              ),

    .camera_valid              (slave3_valid           ),//flag :camera will trans an new image | from camera camera_vsync
    .frame_wr_done             (slave3_frame_wr_done   ),//from ddr ddr2R_fifo.v
    .frame_rd_done             (slave3_frame_rd_done   ),//from ddr ddr2W_fifo.v

    .wr_bank                   (slave3_wr_bank         ),//ddr_width is 25bit,bank bit is [24][23]
    .wr_load                   (slave3_wr_load         ),//
    .rd_bank                   (slave3_rd_bank         ),//to ddrw_fifo.v
    .rd_load                   (slave3_rd_load         ) //to ddrw_fifo.v
);
endmodule