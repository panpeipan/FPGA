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
    output wire [1:0]    slave3_rd_bank       ,
    //slave4_bank_switch
    input wire           slave4_valid         ,
    input wire           slave4_frame_wr_done ,
    input wire           slave4_frame_rd_done ,
    output wire          slave4_wr_load       ,
    output wire [1:0]    slave4_wr_bank       ,
    output wire          slave4_rd_load       ,
    output wire [1:0]    slave4_rd_bank       ,
    //slave5_bank_switch
    input wire           slave5_valid         ,
    input wire           slave5_frame_wr_done ,
    input wire           slave5_frame_rd_done ,
    output wire          slave5_wr_load       ,
    output wire [1:0]    slave5_wr_bank       ,
    output wire          slave5_rd_load       ,
    output wire [1:0]    slave5_rd_bank       ,
    //slave3_bank_switch
    input wire           slave6_valid         ,
    input wire           slave6_frame_wr_done ,
    input wire           slave6_frame_rd_done ,
    output wire          slave6_wr_load       ,
    output wire [1:0]    slave6_wr_bank       ,
    output wire          slave6_rd_load       ,
    output wire [1:0]    slave6_rd_bank       ,
    //slave4_bank_switch
    input wire           slave7_valid         ,
    input wire           slave7_frame_wr_done ,
    input wire           slave7_frame_rd_done ,
    output wire          slave7_wr_load       ,
    output wire [1:0]    slave7_wr_bank       ,
    output wire          slave7_rd_load       ,
    output wire [1:0]    slave7_rd_bank       ,
    //slave5_bank_switch
    input wire           slave8_valid         ,
    input wire           slave8_frame_wr_done ,
    input wire           slave8_frame_rd_done ,
    output wire          slave8_wr_load       ,
    output wire [1:0]    slave8_wr_bank       ,
    output wire          slave8_rd_load       ,
    output wire [1:0]    slave8_rd_bank       
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
//-----------------------------------------------------
// bank_switch m4
//-----------------------------------------------------
 bank_switch bank_switch4
(
    .phy_clk                   ( ddr_clk               ),
    .sys_rstn                  ( sys_rstn              ),
    .camera_valid              (slave4_valid           ),//flag :camera will trans an new image | from camera camera_vsync
    .frame_wr_done             (slave4_frame_wr_done   ),//from ddr ddr2R_fifo.v
    .frame_rd_done             (slave4_frame_rd_done   ),//from ddr ddr2W_fifo.v
    .wr_bank                   (slave4_wr_bank         ),//ddr_width is 25bit,bank bit is [24][23]
    .wr_load                   (slave4_wr_load         ),//
    .rd_bank                   (slave4_rd_bank         ),//to ddrw_fifo.v
    .rd_load                   (slave4_rd_load         ) //to ddrw_fifo.v
);
//-----------------------------------------------------
// bank_switch m5
//-----------------------------------------------------
 bank_switch bank_switch5
(
    .phy_clk                   ( ddr_clk               ),
    .sys_rstn                  ( sys_rstn              ),
    .camera_valid              (slave5_valid           ),//flag :camera will trans an new image | from camera camera_vsync
    .frame_wr_done             (slave5_frame_wr_done   ),//from ddr ddr2R_fifo.v
    .frame_rd_done             (slave5_frame_rd_done   ),//from ddr ddr2W_fifo.v
    .wr_bank                   (slave5_wr_bank         ),//ddr_width is 25bit,bank bit is [24][23]
    .wr_load                   (slave5_wr_load         ),//
    .rd_bank                   (slave5_rd_bank         ),//to ddrw_fifo.v
    .rd_load                   (slave5_rd_load         ) //to ddrw_fifo.v
);
//-----------------------------------------------------
// bank_switch m6
//-----------------------------------------------------
 bank_switch bank_switch6
(
    .phy_clk                   ( ddr_clk               ),
    .sys_rstn                  ( sys_rstn              ),
    .camera_valid              (slave6_valid           ),//flag :camera will trans an new image | from camera camera_vsync
    .frame_wr_done             (slave6_frame_wr_done   ),//from ddr ddr2R_fifo.v
    .frame_rd_done             (slave6_frame_rd_done   ),//from ddr ddr2W_fifo.v
    .wr_bank                   (slave6_wr_bank         ),//ddr_width is 25bit,bank bit is [24][23]
    .wr_load                   (slave6_wr_load         ),//
    .rd_bank                   (slave6_rd_bank         ),//to ddrw_fifo.v
    .rd_load                   (slave6_rd_load         ) //to ddrw_fifo.v
);
//-----------------------------------------------------
// bank_switch m7
//-----------------------------------------------------
 bank_switch bank_switch7
(
    .phy_clk                   ( ddr_clk               ),
    .sys_rstn                  ( sys_rstn              ),
    .camera_valid              (slave7_valid           ),//flag :camera will trans an new image | from camera camera_vsync
    .frame_wr_done             (slave7_frame_wr_done   ),//from ddr ddr2R_fifo.v
    .frame_rd_done             (slave7_frame_rd_done   ),//from ddr ddr2W_fifo.v
    .wr_bank                   (slave7_wr_bank         ),//ddr_width is 25bit,bank bit is [24][23]
    .wr_load                   (slave7_wr_load         ),//
    .rd_bank                   (slave7_rd_bank         ),//to ddrw_fifo.v
    .rd_load                   (slave7_rd_load         ) //to ddrw_fifo.v
);
//-----------------------------------------------------
// bank_switch m8
//-----------------------------------------------------
 bank_switch bank_switch8
(
    .phy_clk                   ( ddr_clk               ),
    .sys_rstn                  ( sys_rstn              ),
    .camera_valid              (slave8_valid           ),//flag :camera will trans an new image | from camera camera_vsync
    .frame_wr_done             (slave8_frame_wr_done   ),//from ddr ddr2R_fifo.v
    .frame_rd_done             (slave8_frame_rd_done   ),//from ddr ddr2W_fifo.v
    .wr_bank                   (slave8_wr_bank         ),//ddr_width is 25bit,bank bit is [24][23]
    .wr_load                   (slave8_wr_load         ),//
    .rd_bank                   (slave8_rd_bank         ),//to ddrw_fifo.v
    .rd_load                   (slave8_rd_load         ) //to ddrw_fifo.v
);

endmodule