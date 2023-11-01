module camera_config_sel (
//-camera_slave 0 
    input  wire [8:0]   slave0_reg_index         ,
    output wire [23:0]  slave0_lut_data          ,
    input  wire         slave0_config_done       ,
//-camera_slave 1
    input  wire [8:0]   slave1_reg_index         ,
    output wire [23:0]  slave1_lut_data          ,
    input  wire         slave1_config_done       ,
//-camera_slave 2 
    input  wire [8:0]   slave2_reg_index         ,
    output wire [23:0]  slave2_lut_data          ,
    input  wire         slave2_config_done       ,
//-camera_slave 3
    input  wire [8:0]   slave3_reg_index         ,
    output wire [23:0]  slave3_lut_data          ,
    input  wire         slave3_config_done       ,
//-camera_slave 4
    input  wire [8:0]   slave4_reg_index         ,
    output wire [23:0]  slave4_lut_data          ,
    input  wire         slave4_config_done       ,
//-camera_slave 5
    input  wire [8:0]   slave5_reg_index         ,
    output wire [23:0]  slave5_lut_data          ,
    input  wire         slave5_config_done       ,
//-camera_slave 6
    input  wire [8:0]   slave6_reg_index         ,
    output wire [23:0]  slave6_lut_data          ,
    input  wire         slave6_config_done       ,
//-camera_slave 7
    input  wire [8:0]   slave7_reg_index         ,
    output wire [23:0]  slave7_lut_data          ,
    input  wire         slave7_config_done       ,
//-camera_slave 8
    input  wire [8:0]   slave8_reg_index         ,
    output wire [23:0]  slave8_lut_data          ,
    input  wire         slave8_config_done       
);

wire [8:0]   camera_index     ;
wire [23:0]  camera_lut_data  ;  
wire [8:0]   slave_config_flag;
assign slave0_lut_data = (slave_config_flag[0:0] == 1'd0   ) ? camera_lut_data:24'b0 ;
assign slave1_lut_data = (slave_config_flag[1:0] == 2'b1   ) ? camera_lut_data:24'b0 ;
assign slave2_lut_data = (slave_config_flag[2:0] == 3'd3   ) ? camera_lut_data:24'b0 ;
assign slave3_lut_data = (slave_config_flag[3:0] == 4'd7   ) ? camera_lut_data:24'b0 ;
assign slave4_lut_data = (slave_config_flag[4:0] == 5'd15  ) ? camera_lut_data:24'b0 ;
assign slave5_lut_data = (slave_config_flag[5:0] == 6'd31  ) ? camera_lut_data:24'b0 ;
assign slave6_lut_data = (slave_config_flag[6:0] == 7'd63  ) ? camera_lut_data:24'b0 ;
assign slave7_lut_data = (slave_config_flag[7:0] == 8'd127 ) ? camera_lut_data:24'b0 ;
assign slave8_lut_data = (slave_config_flag[8:0] == 9'd255 ) ? camera_lut_data:24'b0 ;

assign camera_index =   (~slave0_config_done) ? slave0_reg_index : (
                        (~slave1_config_done) ? slave1_reg_index : (
                        (~slave2_config_done) ? slave2_reg_index : (
                        (~slave3_config_done) ? slave3_reg_index : (
                        (~slave4_config_done) ? slave4_reg_index : (
                        (~slave5_config_done) ? slave5_reg_index : (
                        (~slave6_config_done) ? slave6_reg_index : (
                        (~slave7_config_done) ? slave7_reg_index : (
                        (~slave8_config_done) ? slave8_reg_index : 
                        9'd0))))))));
camera_config_index  camera_config_index_lab
(
    .reg_index        (camera_index   ),
    .LUT_DATA         (camera_lut_data)
);

assign slave_config_flag = {slave8_config_done,slave7_config_done,slave6_config_done,slave5_config_done,slave4_config_done,slave3_config_done,slave2_config_done,slave1_config_done,slave0_config_done };

endmodule 