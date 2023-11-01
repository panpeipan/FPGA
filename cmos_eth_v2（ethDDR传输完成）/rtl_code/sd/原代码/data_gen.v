module data_gen(
    input                clk                    ,  //时钟信号
    input                rst_n                  ,  //复位信号,低电平有效
    input                sd_init_done           ,  //SD卡初始化完成信号
    //写SD卡接口   
    input  wire          sys_cmos_image_save_req,
    input                wr_busy                ,  //写数据忙信号
    output  reg          wr_start_en            ,  //开始写SD卡数据信号
    output  reg  [31:0]  wr_sec_addr            ,  //写数据扇区地址 
    output  wire [15:0]  wr_data                ,
    output  wire [1:0]   o_state                ,

    //读SD卡接口 
    input  wire          sys_image_read_req     ,
    input                rd_busy                ,
    input  wire  [15:0]  rd_data                ,
    input  wire          rd_data_valid          ,
    output  reg          rd_start_en            ,  //开始写SD卡数据信号
    output  reg  [31:0]  rd_sec_addr            ,  //读数据扇区地址

    input  wire          fifo_16w32r_full       ,  //rd 
    input  wire          fifo_32w16r_full_flag  ,  //wr 
    input  wire   [9:0]  fifo_32w16r_len        ,
//    output reg          rd_sd_image_done_n_reg ,
    output wire          wr_sd_image_done
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
  
reg [11:0]       rd_sec_number        ;
reg [11:0]       wr_sec_number        ;         //一次写入多少个扇区

reg              first_rd_done        ;
reg              first_rd_sd_req      ;

localparam   RSD_sec_addr  = 32'd0     ;

//parameter sec_length    = 12'd3072 ;     // 1280*800*8 / 8 /512 (一扇区512BYTE ) 
parameter    sec_length    = 12'd2000 ;     // 1280*800*8 / 8 /512 (一扇区512BYTE ) 
//*****************************************************
//**                    状态机
//*****************************************************
localparam  idle_state         = 2'b00;
localparam  first_num_rd_state = 2'b01;
localparam  write_sd_state     = 2'b10;
localparam  write_num_sd_state = 2'b11;

reg  [1:0] state ;
reg        wr_sd_req ;
reg        wr_num_req;
always@(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin 
        state <= idle_state ;
        wr_sd_req <= 1'b0 ;
        first_rd_sd_req <= 1'b0 ;
        wr_num_req <= 1'b0 ;
    end 
    else if (!sd_init_done )begin 
        state <= idle_state ;
        wr_sd_req <= 1'b0 ;
        first_rd_sd_req <= 1'b0 ;
        wr_num_req <= 1'b0 ;
    end 
    else begin 
        first_rd_sd_req <= 1'b0 ;
        case (state)
        idle_state :begin 
            if(sys_cmos_image_save_req&!sd_busy)begin 
                state <= first_num_rd_state ;
                first_rd_sd_req <= 1'b1 ;
            end 
            else begin 
                state <= idle_state ;
            end 
        end 
        first_num_rd_state :begin 
            if(neg_rd_busy)begin 
                state <= write_sd_state ;
                wr_sd_req <= 1'b1 ;
            end 
            else begin 
                state <= first_num_rd_state ;
            end 
        end 
        write_sd_state :begin 
            if(wr_sd_image_done)begin 
                state <= write_num_sd_state ;
                wr_sd_req <= 1'b0 ;
                wr_num_req <= 1'b1 ;
            end 
            else begin 
                state <= write_sd_state ;
            end 
        end 
        write_num_sd_state :begin 
            if(neg_wr_busy)begin 
                state <= idle_state ;
                wr_num_req <= 1'b0 ;
            end 
            else begin 
                state <= write_num_sd_state ;
            end 
        end 
        default:begin 
            state <= idle_state ;
        end 
        endcase 
    end 
end 

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
    else if(first_rd_sd_req&&!sd_busy) begin
        rd_start_en <= 1'b1;
        rd_sec_addr <= RSD_sec_addr;                        //任意指定一块扇区地址
        rd_sec_number <= 12'd1;
    end 
    else begin
        rd_start_en <= 1'b0;          
    end    
end
    
assign sd_image_done = (neg_rd_busy&&(rd_sec_number == sec_length+1)) ? 1'b1:1'b0;

reg  [15:0]  r_rd_data                ;

//SD卡读出信号控制
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0) begin
        r_rd_data <= 'd0;
    end
    else if(rd_data_valid) begin
        r_rd_data <= rd_data ;
    end 
    else begin
        r_rd_data <= r_rd_data;          
    end    
end

//*****************************************************
//**                   sd_image_save_flag
//*****************************************************
//r_transfer_flag
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin 
        sd_image_save_flag <= 1'b0;
    end 
    else if (wr_sd_req)begin 
        sd_image_save_flag <= 1'b1; 
    end   
    else if (wr_sd_image_done)begin
        sd_image_save_flag <= 1'b0; 
    end 
    else begin 
        sd_image_save_flag <= sd_image_save_flag ;
    end 
end
//*****************************************************
//**                   wr_start_en
//*****************************************************
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0) begin
        wr_start_en   <= 1'b0;
    end  
    else if (sd_init_done&& !sd_busy &&sd_image_save_flag &&(wr_sec_number<=sec_length) )begin 
        if(fifo_32w16r_len_flag||fifo_32w16r_full_flag )begin 
            wr_start_en <= 1'b1;
        end         
    end 
    else if (sd_init_done&& !sd_busy &&wr_num_req) begin 
        wr_start_en <= 1'b1;   
    end 
    else begin
        wr_start_en <= 1'b0;          
    end    
end  
//*****************************************************
//**                   pos_wr_start_en
//*****************************************************
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
//*****************************************************
//**                   wr_sec_addr
//*****************************************************
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0) begin
        wr_sec_addr   <= 32'd0;  
        wr_sec_number <= 12'd0;
    end  
    else if(sys_cmos_image_save_req) begin        //此时作为存储的预准备工作
        wr_sec_addr   <= r_rd_data*2000 + 1;            //后续可更改，任意指定一块扇区地址，--------
        wr_sec_number <= 12'd0;                   //后续可更改，任意指定一块扇区地址，--------
    end 
    else if (pos_wr_start_en)begin 
        wr_sec_addr   <= wr_sec_addr + 32'd00001;
        wr_sec_number <= wr_sec_number + 12'd1;    
    end 
    else if (wr_num_req) begin 
        wr_sec_addr   <= RSD_sec_addr ;
    end 
    else begin
        wr_sec_addr   <= wr_sec_addr ;
        wr_sec_number <= wr_sec_number ;      
    end    
end  
//*****************************************************
//**                   neg_wr_busy
//*****************************************************
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

assign  wr_data              = rd_data + 16'd1                                          ;
assign  o_state              = state                                                    ;

endmodule