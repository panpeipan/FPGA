module ddr_wdisplayfifo 
#(
    parameter MAXADDR  = 25'd245_760                  //1280*768      64*48/4=768
)  
(    
    //ddr_wr_ctrl                                        
    input wire              ddr_clk                         ,
    input wire              ddr_rstn                        ,
    input wire              rd_burst_data_valid             ,
    input wire  [31 : 0]    rd_burst_data                   ,
    //w_fifo                                                
    output wire             w_fifo_clk                      ,
    output wire             w_fifo_en                       ,
    output wire [31 :0 ]    w_fifo_data                     ,
    //ddr_wr_ctrl
    output reg              mem_ren                         ,
    input  wire             mem_ren_valid                   ,
    output reg  [22 : 0]    rd_addr                         ,
    output wire [9 : 0 ]    rd_len                          ,
    input  wire [1 :0 ]     read_channal                    ,     //后续可加入按键消抖，进行摄像头的跳转
    //
    input  wire             ddr_ready                       ,
    //fifo_32w8r 状态                                           
    input wire  [9: 0]      fifo_len                        ,
    input wire              fifo_full_flag                  ,  
    output reg              fifo_clearn                     ,

//    input wire              camera_vsync                    , //for debug
    input wire              vga_vs                          ,
    input wire              frame_wr_done                   ,
    //debug                                                 
    output wire [20: 0]     addr_u1                         
); 

parameter          slave0_rd_bank   =    2'b00;
parameter          slave1_rd_bank   =    2'b01;
parameter          slave2_rd_bank   =    2'b10;
parameter          slave3_rd_bank   =    2'b11;

wire [1:0] sellect_rd_bank;

assign rd_len = 10'd256;
//---------------------------------------------//
parameter rd_byte_number = 750;
parameter wr_byte_number = 256; 
parameter initial_addr = 21'd0;
wire [22:0]             rd_addr_sample        ;

wire                    ready_rd_flag         ; 
reg                     First_image_done      ;
reg  [1:0]              state                 ;
reg                     frame_wr_done_reg     ;
//reg                     bank_image_done_d0    ;
//reg                     bank_image_done_d1    ;
//wire                    bank_image_done_pos   ;  
wire                    vga_vs_neg             ;
//-----------------------------------------------
//   frame_rd_done
//-----------------------------------------------
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (ddr_rstn ==1'b0) begin
        rd_addr <= 23'd0;
        fifo_clearn <= 1'b1;
    end 
    else if (mem_ren_valid) begin
        rd_addr <= rd_addr + 23'd256;
        fifo_clearn <= 1'b1;
    end 
    else if (rd_addr[20:0]==MAXADDR&&vga_vs_neg) begin 
        rd_addr <= rd_addr_sample;
        fifo_clearn <= 1'b0;
    end
    else begin
        rd_addr <= rd_addr;
        fifo_clearn <= 1'b1;
    end
end 
//-----------------------------------------------
//  bank_switch --- mem_ren/mem_wen
//-----------------------------------------------
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (ddr_rstn ==1'b0) begin
        mem_ren <= 1'b0;
    end 
    else if((ddr_ready&&ready_rd_flag)&&(rd_addr[20:0]<addr_u1))begin
        mem_ren <= 1'b1;
    end 
    else if(mem_ren_valid)begin
        mem_ren <= 1'b0;
    end 
    else begin
        mem_ren <= mem_ren;
    end
end  

always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (ddr_rstn ==1'b0) begin
        frame_wr_done_reg <= 1'b0;
    end 
    else if(frame_wr_done)begin
        frame_wr_done_reg <= 1'b1;
    end 
    else begin
        frame_wr_done_reg <= frame_wr_done_reg;
    end
end 
//-----------------------------------------------
//  bank_image_done_pos  for debug
//-----------------------------------------------
//always @(posedge ddr_clk or negedge ddr_rstn) begin
//    if (ddr_rstn ==1'b0) begin
//        bank_image_done_d0<=1'b1;
//        bank_image_done_d1<=1'b1;
//    end 
//    else begin
//        bank_image_done_d0<=camera_vsync;
//        bank_image_done_d1<=bank_image_done_d0;
//    end 
//end  
//-----------------------------------------------
//  vga_vs neg 高         for debug
//-----------------------------------------------
reg vga_vs_d0,vga_vs_d1;
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (ddr_rstn ==1'b0) begin
        vga_vs_d0<=1'b0;
        vga_vs_d1<=1'b0;
    end 
    else begin
        vga_vs_d0<=vga_vs;
        vga_vs_d1<=vga_vs_d0;
    end 
end

assign vga_vs_neg = (!vga_vs_d0&vga_vs_d1) ? 1'b1:1'b0;         //for debug
//assign bank_image_done_pos = bank_image_done_d0&~bank_image_done_d1; //for debug
assign ready_rd_flag = (frame_wr_done_reg&&(!fifo_full_flag)&&(fifo_len<rd_byte_number))?1'b1:1'b0;
//assign ready_rd_flag = (First_image_done&&(!fifo_full_flag)&&(fifo_len<rd_byte_number))?1'b1:1'b0;
//---------------------------------------------//  
assign w_fifo_clk   = ddr_clk            ;
assign w_fifo_en    = rd_burst_data_valid;
assign w_fifo_data  = rd_burst_data      ;
//---------------------------------------------//  
//assign First_image_done_n = ~First_image_done;
assign addr_u1 = rd_addr_sample[20:0] + MAXADDR ;          //不关心最高BANK位
assign rd_addr_sample = {read_channal,initial_addr};             //initial read_address

//debug 
//assign error_rd_empty  = (rd_addr[22:0]==addr_u1) ? 1'b1:1'b0;

endmodule