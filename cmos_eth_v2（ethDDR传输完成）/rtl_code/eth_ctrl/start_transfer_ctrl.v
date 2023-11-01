module start_transfer_ctrl(
    input                 clk                        ,   //时钟信号
    input                 rst_n                      ,   //复位信号，低电平有效
    input                 udp_rec_pkt_done           ,   //UDP单包数据接收完成信号
    input                 udp_rec_en                 ,   //UDP接收的数据使能信号 
    input        [7:0]    udp_rec_data               ,   //UDP接收的数据
    input        [15:0]   udp_rec_byte_num           ,   //UDP接收到的字节数
    output  wire          transfer_all_frame_flag    ,    //图像开始传输标志,1:开始传输 0:停止传输
    output  reg           transfer_signle_frame_flag ,    //图像开始传输标志,1:开始传输 0:停止传输
    output  reg [3:0]     transfer_cmos_sel          , 
    input   wire          frame_transfer_done
    );    
    
//parameter define
localparam  start_all_frame   = 8'h10;  //传输所有帧图像
//parameter  channal = 8'h81;  //开始传输通道1命令
//parameter  channa2 = 8'h82;  //开始传输通道2命令
//parameter  channa3 = 8'h83;  //开始传输通道3命令
//parameter  channa4 = 8'h84;  //开始传输通道4命令
//parameter  channa5 = 8'h85;  //开始传输通道5命令
//parameter  channa6 = 8'h86;  //开始传输通道6命令
//parameter  channa7 = 8'h87;  //开始传输通道7命令
//parameter  channa8 = 8'h88;  //开始传输通道7命令
//*****************************************************
//**                    main code
//*****************************************************
reg transfer_all_frame_flag_d0 ;
reg transfer_all_frame_flag_d1 ;
reg transfer_all_frame_flag_d2 ;
reg transfer_all_frame_flag_d3 ;
//解析接收到的数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin 
        transfer_all_frame_flag_d0     <= 1'b0 ;
        transfer_cmos_sel           <= 4'd1 ;
        transfer_signle_frame_flag  <= 1'b0 ;
    end 
    else if(udp_rec_pkt_done && udp_rec_byte_num == 16'd1) begin
        if(udp_rec_data == start_all_frame) begin                           //停止传输 
            transfer_all_frame_flag_d0 <= 1'b1; 
        end 
        else if(udp_rec_data[7:4] == 4'h8)   begin                //开始传输
            transfer_signle_frame_flag <= 1'b1;
            transfer_cmos_sel          <= udp_rec_data[3:0];      //超出范围，会采用默认摄像头1
        end 
    end
    else begin 
        transfer_signle_frame_flag <= 1'b0 ;
        transfer_all_frame_flag_d0 <= 1'b0 ;
    end 
end 

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin 
        transfer_all_frame_flag_d1  <= 1'b0 ;
        transfer_all_frame_flag_d2  <= 1'b0 ;
        transfer_all_frame_flag_d3  <= 1'b0 ;
    end 
    else begin 
        transfer_all_frame_flag_d1  <= transfer_all_frame_flag_d0 ;
        transfer_all_frame_flag_d2  <= transfer_all_frame_flag_d1 ;
        transfer_all_frame_flag_d3  <= transfer_all_frame_flag_d2 ;
    end 
end 

assign transfer_all_frame_flag =    transfer_all_frame_flag_d0 | transfer_all_frame_flag_d1 | 
                                    transfer_all_frame_flag_d2 | transfer_all_frame_flag_d3 ;


endmodule