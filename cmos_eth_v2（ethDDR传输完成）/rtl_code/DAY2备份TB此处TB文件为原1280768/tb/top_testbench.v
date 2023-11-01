`timescale 1ns/1ns 
module top_testbench;
//测试接口连线
//mem
wire  [ 12: 0] wire_mem_addr     ;
wire  [  2: 0] wire_mem_ba       ;
wire           wire_mem_cas_n    ;
wire  [  0: 0] wire_mem_cke      ;
wire  [  0: 0] wire_mem_clk      ;
wire  [  0: 0] wire_mem_clk_n    ;
wire  [  0: 0] wire_mem_cs_n     ;
wire  [  1: 0] wire_mem_dm       ;
wire  [ 15: 0] wire_mem_dq       ;
wire  [  1: 0] wire_mem_dqs      ;
wire  [  0: 0] wire_mem_odt      ;
wire           wire_mem_ras_n    ;
wire           wire_mem_we_n     ;
//disp
wire           vga_hs            ;
wire           vga_vs            ;
wire [4:0]     vga_r             ;
wire [5:0]     vga_g             ;
wire [4:0]     vga_b             ;
 
integer iBmpFileId;                 //输入BMP图片
//integer oBmpFileId;               //输出BMP图片
//integer oTxtFileId;               //输入TXT文本
        
integer iIndex = 0;                 //输出BMP数据索引
integer pixel_index = 0;            //输出像素数据索引 
        
integer iCode;      
        
integer iBmpWidth;                  //输入BMP 宽度
integer iBmpHight;                  //输入BMP 高度
integer iBmpSize;                   //输入BMP 字节数
integer iDataStartIndex;            //输入BMP 像素数据偏移量
    
reg [ 7:0] rBmpData [0:3000000];    //用于寄存输入BMP图片中的字节数据（包括54字节的文件头）
reg [ 7:0] Vip_BmpData [0:3000000]; //用于寄存视频图像处理之后 的BMP图片 数据 


reg [ 7:0] pixel_data;              //输出视频流时的像素数据

reg clk;
reg rst_n;

reg [ 7:0] vip_pixel_data [0:2949120];   //320x240x3=230400 1024*768*3=2359296 1280*768*3=2949120

wire ddr_initial_done ;             //等DDR初始化完成后，再进行图像的传输。
reg  ddr_initial_done_d0,ddr_initial_done_d1;
wire ddr_initial_done_pos;
always@(posedge clk or negedge rst_n )begin 
    if(~rst_n)begin 
        ddr_initial_done_d0 <= 1'b0;
        ddr_initial_done_d1 <= 1'b0;
    end 
    else begin 
        ddr_initial_done_d0 <= ddr_initial_done;
        ddr_initial_done_d1 <= ddr_initial_done_d0;
    end 
end 
assign ddr_initial_done_pos = !ddr_initial_done_d1&ddr_initial_done_d0;
initial begin

    //分别打开 输入/输出BMP图片，以及输出的Txt文本 F:\\modelsim_file\\bmp_sim_test\\PIC
	iBmpFileId = $fopen("F:\\modelsim_file\\1280_768_bmp_sim_test\\input\\1.bmp","rb");
    //将输入BMP图片加载到数组中
	iCode = $fread(rBmpData,iBmpFileId);
 
    //根据BMP图片文件头的格式，分别计算出图片的 宽度 /高度 /像素数据偏移量 /图片字节数
	iBmpWidth       = {rBmpData[21],rBmpData[20],rBmpData[19],rBmpData[18]};
	iBmpHight       = {rBmpData[25],rBmpData[24],rBmpData[23],rBmpData[22]};
	iBmpSize        = {rBmpData[ 5],rBmpData[ 4],rBmpData[ 3],rBmpData[ 2]};
	iDataStartIndex = {rBmpData[13],rBmpData[12],rBmpData[11],rBmpData[10]};
    
    //关闭输入BMP图片
	$fclose(iBmpFileId);
    
    //延迟2ms，等待第一帧VIP处理结束
    #53250000   
    $stop;
    
end
 
//初始化时钟和复位信号
initial begin
    clk     = 1'b1;
    rst_n   = 1'b0;
    #110
    rst_n   = 1'b1;
end 

//产生50MHz时钟
always #10 clk = ~clk;
 
//在时钟驱动下，从数组中读出像素数据
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        pixel_data  <=  8'd0;
        pixel_index <=  0;
    end
    else begin
        pixel_data  <=  rBmpData[pixel_index];
        pixel_index <=  pixel_index+1;
    end
end

////////////////////////////////////////////产生摄像头时序 

wire		cmos_vsync ;
reg			cmos_href;
wire        cmos_clken;
reg	[23:0]	cmos_data;			 
reg [31:0]  cmos_index;
//-----------------------------摄像头参数
parameter  IMG_HDISP = 11'd1280;
parameter  IMG_VDISP = 11'd768;

localparam H_SYNC = 11'd5;		
localparam H_BACK = 11'd5;		
localparam H_DISP = IMG_HDISP;	
localparam H_FRONT = 11'd5;		
localparam H_TOTAL = H_SYNC + H_BACK + H_DISP + H_FRONT;	//1280+129+192+64=

localparam V_SYNC = 11'd2;		
localparam V_BACK = 11'd3;		
localparam V_DISP = IMG_VDISP;	
localparam V_FRONT = 11'd4;		
localparam V_TOTAL = V_SYNC + V_BACK + V_DISP + V_FRONT;     //798

//---------------------------------------------
//水平计数器
reg	[10:0]	hcnt;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		hcnt <= 11'd0;
    else if (ddr_initial_done_pos)
        hcnt <= 11'd0;
	else
		hcnt <= (hcnt < H_TOTAL - 1'b1) ? hcnt + 1'b1 : 11'd0;
end

//---------------------------------------------
//竖直计数器
reg	[10:0]	vcnt;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		vcnt <= 11'd0;	
    else if (ddr_initial_done_pos)
        vcnt <= 11'd0;      
	else begin
		if(hcnt == H_TOTAL - 1'b1)
			vcnt <= (vcnt < V_TOTAL - 1'b1) ? vcnt + 1'b1 : 11'd0;
		else
			vcnt <= vcnt;
    end
end

//---------------------------------------------
//场同步
reg	cmos_vsync_r,cmos_vsync_d0,cmos_vsync_d1;
wire coms_vsync_pos;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_vsync_r <= 1'b0;	    //H: Vaild, L: inVaild
    else if (ddr_initial_done_pos)
        cmos_vsync_r <= 1'b0;
	else begin
		if(vcnt <= V_SYNC - 1'b1)
			cmos_vsync_r <= 1'b0; 	//H: Vaild, L: inVaild
		else
			cmos_vsync_r <= 1'b1; 	//H: Vaild, L: inVaild
    end
end
assign	cmos_vsync	= cmos_vsync_r;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin 
		cmos_vsync_d0 <= 1'b0;	    
        cmos_vsync_d1 <= 1'b0;
    end 
	else begin
		cmos_vsync_d0 <= cmos_vsync_r;	    
        cmos_vsync_d1 <= cmos_vsync_d0;
    end
end
assign coms_vsync_pos = ~cmos_vsync_d1&cmos_vsync_d0;
//---------------------------------------------
//Image data href vaild  signal
wire	frame_valid_ahead =  ( vcnt >= V_SYNC + V_BACK  && vcnt < V_SYNC + V_BACK + V_DISP
                            && hcnt >= H_SYNC + H_BACK  && hcnt < H_SYNC + H_BACK + H_DISP ) 
						? 1'b1 : 1'b0;
      
reg			cmos_href_r;      
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href_r <= 0;
	else begin
		if(frame_valid_ahead)
			cmos_href_r <= 1;
		else
			cmos_href_r <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href <= 0;
	else
        cmos_href <= cmos_href_r;
end

assign cmos_clken = cmos_href;

//-------------------------------------
//从数组中以视频格式输出像素数据
wire [10:0] x_pos;
wire [10:0] y_pos;

assign x_pos = frame_valid_ahead ? (hcnt - (H_SYNC + H_BACK )) : 0;
assign y_pos = frame_valid_ahead ? (vcnt - (V_SYNC + V_BACK )) : 0;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        cmos_index   <=  0;
        cmos_data    <=  24'd0;
    end
    else if (ddr_initial_done_pos)begin 
        cmos_index   <=  0;
        cmos_data    <=  24'd0;
    end 
    else if (coms_vsync_pos)begin 
        cmos_index   <=  0;
        cmos_data    <=  24'd0;
    end 
    else begin
        cmos_index   <=  y_pos * 3840  + x_pos*3 + 54;        //  3*(y*1024 + x) + 54
        cmos_data    <=  {rBmpData[cmos_index], rBmpData[cmos_index+1] , rBmpData[cmos_index+2]};
    end
end
 
//-------------------------------------
//VIP算法——彩色转灰度

wire 		per_frame_vsync	=	cmos_vsync ;	
wire 		per_frame_href	=	cmos_href;	
wire 		per_frame_clken	=	cmos_clken;	
wire [7:0]	per_img_red		=	cmos_data[23:16];	   	
wire [7:0]	per_img_green	=	cmos_data[15: 8];   	            
wire [7:0]	per_img_blue	=	cmos_data[ 7: 0];   	            

wire 		post0_frame_vsync;   
wire 		post0_frame_href ;   
wire 		post0_frame_clken;    
wire [7:0]	post0_img_Y      ;   
wire [7:0]	post0_img_Cb     ;   
wire [7:0]	post0_img_Cr     ;   

rgb888_ycrcb888	u_VIP_RGB888_YCbCr444
(
	//global clock
	.clk				(clk),					//cmos video pixel clock
	.rst_n				(rst_n),				//system reset

	//Image data prepred to be processd
	.per_frame_vsync	(per_frame_vsync),		//Prepared Image data vsync valid signal
	.per_frame_href		(per_frame_href),		//Prepared Image data href vaild  signal
	.per_frame_clken	(per_frame_clken),		//Prepared Image data output/capture enable clock
	.per_img_red		(per_img_red),			//Prepared Image red data input
	.per_img_green		(per_img_green),		//Prepared Image green data input
	.per_img_blue		(per_img_blue),			//Prepared Image blue data input
	
	//Image data has been processd
	.post_frame_vsync	(post0_frame_vsync),	//Processed Image frame data valid signal
	.post_frame_href	(post0_frame_href),		//Processed Image hsync data valid signal
	.post_frame_clken	(post0_frame_clken),	//Processed Image data output/capture enable clock
	.post_img_Y			(post0_img_Y),			//Processed Image brightness output
	.post_img_Cb		(post0_img_Cb),			//Processed Image blue shading output
	.post_img_Cr		(post0_img_Cr)			//Processed Image red shading output
);
//---------------------------------------------------------------
//测试模块
wire [7:0] camera_frame_data ;
assign camera_clk         = clk                ;
assign camera_frame_vsync = ~post0_frame_vsync ; 
assign camera_frame_href  = post0_frame_href   ;
assign camera_frame_data  = post0_img_Y        ;

top_sdv top
(
	.source_clk        (clk),             //输入系统时钟50Mhz
	.sys_rst_n         (rst_n),
//----------------------------------------  
//DDR2_port
    .mem_addr          (wire_mem_addr  ) ,
    .mem_ba            (wire_mem_ba    ) ,
    .mem_cas_n         (wire_mem_cas_n ) ,
    .mem_cke           (wire_mem_cke   ) ,
    .mem_clk           (wire_mem_clk   ) ,
    .mem_clk_n         (wire_mem_clk_n ) ,
    .mem_cs_n          (wire_mem_cs_n  ) ,
    .mem_dm            (wire_mem_dm    ) ,
    .mem_dq            (wire_mem_dq    ) ,
    .mem_dqs           (wire_mem_dqs   ) ,
    .mem_odt           (wire_mem_odt   ) ,
    .mem_ras_n         (wire_mem_ras_n ) ,
    .mem_we_n          (wire_mem_we_n  ) ,
//----------------------------------------  
//SD_port 
//    input  wire      sd_miso         ,
//    output wire      sd_clk          ,
//    output wire      sd_cs           ,
//    output wire      sd_mosi         ,
//----------------------------------------  
//VGA_port 
    .vga_hs           (vga_hs ),             //行同步信号
	.vga_vs           (vga_vs ),             //列同步信号
	.vga_r            (vga_r  ),
	.vga_g            (vga_g  ),
	.vga_b            (vga_b  ),
//---------------------------------------- 
//debug led
//    output wire       camera_init_done_n    ,             //LED0 for sd
//    output wire       led_first_image_done_n,
//    output wire       local_init_done_n     ,
    
//----------------------------------------
//OV9281_port m0
    .m0_i2c_sclk         (),
    .m0_i2c_sdat         (),
    .m0_camera_pwdn      (),
    .m0_camera_xclk      (),    
    .m0_camera_pclk      (camera_clk        ),
    .m0_camera_href      (camera_frame_href ),
    .m0_camera_vsync     (camera_frame_vsync),
    .m0_camera_data      (camera_frame_data ),
//----------------------------------------  
//OV9281_port m0
    .m1_i2c_sclk         (),
    .m1_i2c_sdat         (),
    .m1_camera_pwdn      (),
    .m1_camera_xclk      (),    
    .m1_camera_pclk      (camera_clk        ),
    .m1_camera_href      (camera_frame_href ),
    .m1_camera_vsync     (camera_frame_vsync),
    .m1_camera_data      (camera_frame_data ),
//----------------------------------------  
//OV9281_port m0
    .m2_i2c_sclk         (),
    .m2_i2c_sdat         (),
    .m2_camera_pwdn      (),
    .m2_camera_xclk      (),    
    .m2_camera_pclk      (camera_clk        ),
    .m2_camera_href      (camera_frame_href ),
    .m2_camera_vsync     (camera_frame_vsync),
    .m2_camera_data      (camera_frame_data ),
//----------------------------------------  
//OV9281_port m0
    .m3_i2c_sclk         (),
    .m3_i2c_sdat         (),
    .m3_camera_pwdn      (),
    .m3_camera_xclk      (),    
    .m3_camera_pclk      (camera_clk        ),
    .m3_camera_href      (camera_frame_href ),
    .m3_camera_vsync     (camera_frame_vsync),
    .m3_camera_data      (camera_frame_data ),
//---------------------------------------- 
    .ddr_initial_done    (ddr_initial_done  )
);

ddr2_full_mem_model mem (
    .mem_dq      (wire_mem_dq),
    .mem_dqs     (wire_mem_dqs[0]),
    .mem_dqs_n   (wire_mem_dqs[1]),
    .mem_addr    (wire_mem_addr),
    .mem_ba      (wire_mem_ba),
    .mem_clk     (wire_mem_clk),
    .mem_clk_n   (wire_mem_clk_n),
    .mem_cke     (wire_mem_cke),
    .mem_cs_n    (wire_mem_cs_n),
    .mem_ras_n   (wire_mem_ras_n),
    .mem_cas_n   (wire_mem_cas_n),
    .mem_we_n    (wire_mem_we_n),
    .mem_dm      (wire_mem_dm),
    .mem_odt     (wire_mem_odt)
);
//    ddr2_mem_model mem (
//    	.mem_dq      (wire_mem_dq),
//        .mem_dqs     (wire_mem_dqs[0]),
//        .mem_dqs_n   (wire_mem_dqs[1]),
//        .mem_addr    (wire_mem_addr),
//        .mem_ba      (wire_mem_ba),
//        .mem_clk     (wire_mem_clk),
//        .mem_clk_n   (wire_mem_clk_n),
//        .mem_cke     (wire_mem_cke),
//        .mem_cs_n    (wire_mem_cs_n),
//        .mem_ras_n   (wire_mem_ras_n),
//        .mem_cas_n   (wire_mem_cas_n),
//        .mem_we_n    (wire_mem_we_n),
//        .mem_dm      (wire_mem_dm),
//        .mem_odt     (wire_mem_odt)
//    );
endmodule 