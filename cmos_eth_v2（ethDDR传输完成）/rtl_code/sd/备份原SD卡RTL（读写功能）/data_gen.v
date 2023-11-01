module data_gen(
    input                clk                    ,  //时钟信号
    input                rst_n                  ,  //复位信号,低电平有效
    input                sd_init_done           ,  //SD卡初始化完成信号
    //写SD卡接口   
    input  wire          sys_cmos_image_save_req,
    input                wr_busy                ,  //写数据忙信号
    output  reg          wr_start_en            ,  //开始写SD卡数据信号
    output  reg  [31:0]  wr_sec_addr            ,  //写数据扇区地址

    //读SD卡接口 
    input  wire          sys_image_read_req     ,
    input                rd_busy                ,
    output  reg          rd_start_en            ,  //开始写SD卡数据信号
    output  reg  [31:0]  rd_sec_addr            ,  //读数据扇区地址

    input  wire          fifo_16w32r_full       ,  //rd 
    input  wire          fifo_32w16r_full_flag  ,  //wr 
    input  wire   [9:0]  fifo_32w16r_len        ,
//    output reg          rd_sd_image_done_n_reg ,
    output wire          wr_sd_image_done       ,
    input wire           wr_block_wdone
    );
//localparamter 
localparam sec_depth = 10'd256 ;
//reg define
reg              sd_init_done_d0      ;       //sd_init_done信号延时打拍
reg              sd_init_done_d1      ;       
reg   		     rd_busy_d0	          ;
reg   		     rd_busy_d1	          ;
reg              sd_image_save_flag   ;
reg              r_pos_edge_transfer_flag ; 

reg   		     wr_busy_d0	          ;
reg   		     wr_busy_d1	          ;

reg  wr_start_en_d0 , wr_start_en_d1 ;
wire pos_wr_start_en ;
//wire define
wire             pos_init_done        ;       //sd_init_done信号的上升沿,用于启动写入信号
wire             sd_image_done        ; 
wire             neg_rd_busy          ;
wire             neg_wr_busy          ;
wire             fifo_32w16r_len_flag ;
wire             sd_busy              ;
  
reg [11:0]       rd_sec_number     ;
reg [11:0]       wr_sec_number     ;         //一次写入多少个扇区
parameter WSD_sec_addr  = 32'd10   ;
parameter RSD_sec_addr1 = 32'd33472;
parameter RSD_sec_addr2 = 32'd33088;
parameter RSD_sec_addr3 = 32'd33280;
//parameter sec_length    = 12'd3072 ;     // 1280*800*8 / 8 /512 (一扇区512BYTE ) 
parameter sec_length    = 12'd2000 ;     // 1280*800*8 / 8 /512 (一扇区512BYTE ) 
//parameter sec_length = 12'd1;
//*****************************************************
//**                    main code
//*****************************************************
//SD卡读-----------------------------------------------
assign  pos_init_done = (~sd_init_done_d1) & sd_init_done_d0;
assign  neg_rd_busy   = rd_busy_d1 & (~rd_busy_d0);

//sd_init_done信号延时打拍
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sd_init_done_d0 <= 1'b0;
        sd_init_done_d1 <= 1'b0;
    end
    else begin
        sd_init_done_d0 <= sd_init_done;
        sd_init_done_d1 <= sd_init_done_d0;
    end        
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_busy_d0 <= 1'b0;
        rd_busy_d1 <= 1'b0;
    end    
    else begin
        rd_busy_d0 <= rd_busy;
        rd_busy_d1 <= rd_busy_d0;
    end
end 
//SD卡读出信号控制
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0) begin
        rd_start_en <= 1'b0;
        rd_sec_addr <= 32'd0;  
        rd_sec_number <= 12'd0;
    end
    else if(sd_init_done&&sys_image_read_req&&!sd_busy) begin
            rd_start_en <= 1'b1;
            rd_sec_addr <= RSD_sec_addr1;        //任意指定一块扇区地址
            rd_sec_number <= 12'd1;
    end 
	else if (sd_init_done && neg_rd_busy &&!fifo_16w32r_full&&(rd_sec_number<=sec_length))begin
            rd_start_en <= 1'b1;
            rd_sec_addr <= rd_sec_addr + 32'd00001;
            rd_sec_number <= rd_sec_number + 12'd1;
	end
    else begin
            rd_start_en <= 1'b0;          
    end    
end    

assign sd_image_done = (neg_rd_busy&&(rd_sec_number == sec_length+1)) ? 1'b1:1'b0;
//此always语句块，是为了保持RD——SD一直记录
//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n) begin
//        rd_sd_image_done_n_reg <= 1'b1;
//
//    end    
//    else if(sd_image_done_n==1'b0)begin
//        rd_sd_image_done_n_reg <= 1'b0;
//    end
//    else begin 
//        rd_sd_image_done_n_reg <= rd_sd_image_done_n_reg;
//    end
//end
//SD卡写-----------------------------------------------
//SD卡写入数据 - 信号控制s 

//r_transfer_flag
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin 
        sd_image_save_flag <= 1'b0;
    end 
    else if (sys_cmos_image_save_req)begin 
        sd_image_save_flag <= 1'b1; 
    end   
    else if (wr_sd_image_done)begin
        sd_image_save_flag <= 1'b0; 
    end 
    else begin 
        sd_image_save_flag <= sd_image_save_flag ;
    end 
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0) begin
        wr_start_en   <= 1'b0;
    end  
    else if (sd_init_done&& !sd_busy &&sd_image_save_flag &&(wr_sec_number<=sec_length) )begin 
        if(fifo_32w16r_len_flag||fifo_32w16r_full_flag)begin 
            wr_start_en <= 1'b1;
        end         
    end 
    else begin
        wr_start_en <= 1'b0;          
    end    
end  

always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0) begin
        wr_start_en_d0   <= 1'b0;
        wr_start_en_d1   <= 1'd0;  
    end  
    else begin
        wr_start_en_d0 <= wr_start_en ;
        wr_start_en_d1 <= wr_start_en_d0 ;      
    end    
end  

always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0) begin
        wr_sec_addr   <= 32'd0;  
        wr_sec_number <= 12'd0;
    end  
    else if(sys_cmos_image_save_req) begin        //此时作为存储的预准备工作
        wr_sec_addr   <= WSD_sec_addr;            //后续可更改，任意指定一块扇区地址，--------
        wr_sec_number <= 12'd0;                   //后续可更改，任意指定一块扇区地址，--------
    end 
    else if (pos_wr_start_en)begin 
        wr_sec_addr   <= wr_sec_addr + 32'd00001;
        wr_sec_number <= wr_sec_number + 12'd1;    
    end 
    else begin
        wr_sec_addr   <= wr_sec_addr ;
        wr_sec_number <= wr_sec_number ;      
    end    
end  


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_busy_d0 <= 1'b0;
        wr_busy_d1 <= 1'b0;
    end    
    else begin
        wr_busy_d0 <= wr_busy;
        wr_busy_d1 <= wr_busy_d0;
    end
end 

assign  neg_wr_busy          = wr_busy_d1 & (~wr_busy_d0)                               ;
assign  fifo_32w16r_len_flag = (fifo_32w16r_len >= sec_depth) ? 1'b1 : 1'b0             ;
assign  sd_busy              = rd_busy | wr_busy                                        ;
assign  wr_sd_image_done     = (neg_wr_busy&&(wr_sec_number == sec_length + 1)) ? 1'b1:1'b0 ;
assign  pos_wr_start_en      = ( wr_start_en_d0 ) & (!wr_start_en_d1)                   ;

endmodule