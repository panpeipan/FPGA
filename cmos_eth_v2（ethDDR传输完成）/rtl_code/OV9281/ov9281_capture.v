module ov9281_capture(
	input rst_n,	
	input init_done,
	input camera_pclk,
    input camera_href,                               //行同步                               
	input camera_vsync,                              //Vertical sync垂直同步信号 (帧同步）
    //它在每一帧图像的开始和结束位置分别产生一个脉冲，用来告诉显示设备和摄像头当前正在传输的是一帧图像的哪一部分
	input [7:0]       camera_data        ,	          //DVP output data[8]-[1]
	output wire       camera_wfifo_req   ,            //ddr camera写入信号, 高写
	output reg [31:0] camera_wfifo_data               //ddr camera写入数据
//    output reg [24:0] num_cnt            ,
//    output wire [7:0] camera_8data       ,
//    output wire       camera_8data_valid 

);

//reg [10:0] camera_h_count;            
//reg [9:0]  camera_v_count;       

reg [31:0] camera_data_reg;
reg [3:0] counter;

reg cmos_wren;
reg first_flag;
//    reg camera_vsync_d0,camera_vsync_d1;
//    wire neg_camera_vsync;

//产生camera行计数  
//always @(posedge camera_pclk)
//begin
//	 if (~rst_n) 
//       camera_h_count<=1;
//	 else if(camera_h_count==1280)
//		 camera_h_count<=1;
//	 else if((camera_href==1'b1) & (camera_vsync==1'b0))  
//       camera_h_count<=camera_h_count+1'b1;	  
//	 else 
//	 	 camera_h_count<=camera_h_count;
// 
//end

//产生camera列计数
//always @(posedge camera_pclk)
//begin
//	 if (~rst_n | camera_vsync) 
//       camera_v_count<=1;
//	 else if((camera_href==1'b1)&&(camera_v_count==800))   
//       camera_v_count<=1;
//	 else if(camera_h_count==1280)   
//       camera_v_count<=camera_v_count+1'b1;	  
//	 else 
//	 	 camera_v_count<=camera_v_count;
//end
	
//产生camera数据存储到DDR中的请求信号 
always @(posedge camera_pclk)
begin
    if (~rst_n) begin 
        camera_data_reg<=0;
        cmos_wren<=1'b0;
        counter<=0;
    end	
    else if((camera_href==1'b1) & (camera_vsync==1'b0)) begin   //cmos数据有效
        if(counter<3) begin                              //读取前3个camera数据	  
        camera_data_reg<={camera_data,camera_data_reg[31:8]};
        counter<=counter+1'b1;
        camera_wfifo_data<=camera_wfifo_data;	
        cmos_wren<=1'b0;
        end
        else begin                                       //读取第4个camera数据		  
            camera_wfifo_data<={camera_data,camera_data_reg[31:8]};
            camera_data_reg<=0;		
            counter<=0; 
            cmos_wren<=1'b1;                              //接收到4个bytes数据,产生ddr写信号				 
        end
    end
    else begin
        camera_data_reg<=0;
        camera_wfifo_data<=0;
        cmos_wren<=1'b0;
        counter<=0;
    end
end

always @(negedge camera_pclk or negedge rst_n)begin
    if(rst_n==1'b0) begin
        first_flag<=1'b0;
    end  
    else if(init_done && camera_vsync) begin
        first_flag<=1'b1;
    end
    else begin 
        first_flag<=first_flag;
    end
end
	
	assign camera_wfifo_req = first_flag ? cmos_wren:1'b0;
//    assign camera_8data_valid = first_flag ? ((camera_href==1'b1)&(camera_vsync==1'b0)):1'b0;
//    assign camera_8data = camera_data ; 
//always @(negedge camera_pclk or negedge rst_n)begin
//    if(rst_n==1'b0) begin
//        num_cnt<=0;
//    end  
//    else if(camera_8data_valid) begin
//        num_cnt<= num_cnt + 1;
//    end
//    //else if(camera_wfifo_req) begin
//    //    num_cnt<= num_cnt + 1;
//    //end
//    else if(neg_camera_vsync) begin
//        num_cnt<= 0;
//    end
//    else begin 
//        num_cnt<=num_cnt;
//    end
//end

//always @(negedge camera_pclk or negedge rst_n)begin
//    if(rst_n==1'b0) begin
//        camera_vsync_d0 <= 0;
//        camera_vsync_d1 <= 0;
//    end  
//    else begin
//        camera_vsync_d0 <= camera_vsync;
//        camera_vsync_d1 <= camera_vsync_d0;
//    end
//end
//    assign neg_camera_vsync = ~camera_vsync_d0&camera_vsync_d1;
    
endmodule