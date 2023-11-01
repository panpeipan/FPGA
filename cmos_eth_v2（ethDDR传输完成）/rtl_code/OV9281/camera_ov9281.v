module camera_ov9281 
(
    input  wire CLK_24M,                //24mhz
    input  wire CLK_20K,
    input  wire CAMERA_RSTN,
    //i2c write ov9281
    output wire [8:0]   o_reg_index      ,
    input  wire [23:0]  i_lut_data       ,
    output wire         reg_conf_done    ,
    output wire         i2c_sclk         ,
    inout  wire         i2c_sdat         ,
    input wire          ddr_initial_done ,
    output wire         camera_pwdn      ,
    output wire         camera_vsync_rst ,
    input  wire [ 7: 0] camera_data      ,
    //ov9281 write fifo32/32
    input  wire         camera_pclk       ,
    input  wire         camera_href       ,
    input  wire         camera_vsync      ,
    //output wire         camera_init_done  ,
    output wire         camera_wfifo_req  ,
    output wire [31: 0] camera_wfifo_data 
//    output wire [ 7: 0] camera_8data      ,
//    output wire         camera_8data_valid
);
    reg bank_valid_d0,bank_valid_d1;
    reg [9:0] r_wait_cnt_20k ;
    reg reg_conf_req ; 
    always @(posedge camera_pclk or negedge CAMERA_RSTN) begin
        if (CAMERA_RSTN == 1'b0) begin
            bank_valid_d0 <= 1'b0;
            bank_valid_d1 <= 1'b0;
        end
        else begin
            bank_valid_d0 <= camera_vsync;
            bank_valid_d1 <= bank_valid_d0;
        end
    end
    assign camera_vsync_rst = (~bank_valid_d1 & bank_valid_d0) ? 1'b1:1'b0; //posedge
    assign camera_pwdn = 1'b1;

    //assign camera_init_done = reg_conf_done ;
    
    always @(posedge CLK_20K or negedge CAMERA_RSTN) begin
        if (!CAMERA_RSTN) begin
            r_wait_cnt_20k <= 10'b0;
        end
        else if(reg_conf_done && ~camera_wfifo_req)begin
            r_wait_cnt_20k <= r_wait_cnt_20k + 10'd1;
        end 
        else begin 
            r_wait_cnt_20k <= 10'b0;
        end 
    end
    
    always @(posedge CLK_20K or negedge CAMERA_RSTN) begin
        if (!CAMERA_RSTN) begin
            reg_conf_req <= 1'b0;
        end
        else if(reg_conf_done && r_wait_cnt_20k[9])begin
            reg_conf_req <= 1'd1;
        end 
        else begin 
            reg_conf_req <= 1'b0;
        end 
    end

    
ov9281_capture camera_capture_m0(
	.rst_n	            (CAMERA_RSTN                   ),
	.init_done          (reg_conf_done&ddr_initial_done),
	.camera_pclk        (camera_pclk                   ),
    .camera_href        (camera_href                   ),             //行同步                               
	.camera_vsync       (camera_vsync                  ),            //Vertical sync垂直同步信号 (帧同步）
	.camera_data	    (camera_data                   ),             //DVP output data[8]-[1]
	.camera_wfifo_req   (camera_wfifo_req              ),        //ddr camera写入信号, 高写
	.camera_wfifo_data  (camera_wfifo_data             )        //ddr camera写入数据
//    .camera_8data       (camera_8data                  ),
//    .camera_8data_valid (camera_8data_valid            ) 
);
ov9281_config ov9281_config_m0(     
   .clk_24M         ( CLK_24M       ) ,          //24.0Mhz
   .clk_20k         ( CLK_20K       ) ,
   .camera_rstn     ( CAMERA_RSTN   ) ,
   .reg_conf_done   ( reg_conf_done ) ,         //寄存器配置完成信号
   .reg_conf_req    (  reg_conf_req ) ,
   .reg_index       ( o_reg_index   ),
   .LUT_DATA        ( i_lut_data    ),
   .i2c_sclk        ( i2c_sclk      ) ,         //iic 时钟
   .i2c_sdat        ( i2c_sdat      )           //iic 数据
);


endmodule
