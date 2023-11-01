module ddr_wdisplayfifo 
#(
    parameter MAXADDR  = 18'd245_760                  //1280*768      64*48/4=768
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
    output reg  [24 : 0]    rd_addr                         ,
    output wire [9 : 0 ]    rd_len                          ,
    input  wire [3 :0 ]     read_channal                    ,     //后续可加入按键消抖，进行摄像头的跳转
    //
    input  wire             ddr_ready                       ,
    //fifo_32w8r 状态                                           
    input wire  [9: 0]      fifo_len                        ,
    input wire              fifo_full_flag                  ,  
    output reg              fifo_clearn                     ,
    
    input wire              slave_sel_rd_load               ,
    input wire  [1:0]       slave_sel_rd_bank               ,

//    input wire              camera_vsync                    , //for debug
    input wire              neg_vga_vs                      ,
    input wire              frame_wr_done                   ,
    //debug                                                 
    output wire [17: 0]     addr_u1                         
); 

wire [1:0] sellect_rd_bank;

assign rd_len = 10'd256;
//---------------------------------------------//
localparam rd_byte_number = 10'd750;
//localparam wr_byte_number = 256; 
localparam initial_addr = 18'd0;
wire [24:0]             rd_addr_sample        ;

wire                    ready_rd_flag         ; 

reg  [ 1:0]             reg_slave_sel_rd_bank ;

reg                     First_image_done      ;
reg  [1:0]              state                 ;
reg                     frame_wr_done_reg     ;
//reg                     bank_image_done_d0    ;
//reg                     bank_image_done_d1    ;
//wire                    bank_image_done_pos   ;  
wire                    rd_addr_clr             ;

always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        reg_slave_sel_rd_bank <= 2'b0 ;
    end 
    else if (slave_sel_rd_load) begin //keepping until ddr finishes read comd
        reg_slave_sel_rd_bank <= slave_sel_rd_bank ;
    end 
    else begin
        reg_slave_sel_rd_bank <= reg_slave_sel_rd_bank ;
    end
end
//-----------------------------------------------
//   frame_rd_done
//-----------------------------------------------
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (ddr_rstn ==1'b0) begin
        rd_addr <= 25'd0;
        fifo_clearn <= 1'b1;
    end 
    else if (mem_ren_valid) begin
        rd_addr <= rd_addr + 25'd256;
        fifo_clearn <= 1'b1;
    end 
    else if (rd_addr[17:0]==MAXADDR&&rd_addr_clr) begin 
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
    else if((ddr_ready&&ready_rd_flag)&&(rd_addr[17:0]<addr_u1))begin
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
reg neg_vga_vs_d0,neg_vga_vs_d1;
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (ddr_rstn ==1'b0) begin
        neg_vga_vs_d0<=1'b0;
        neg_vga_vs_d1<=1'b0;
    end 
    else begin
        neg_vga_vs_d0<=neg_vga_vs;
        neg_vga_vs_d1<=neg_vga_vs_d0;
    end 
end

assign rd_addr_clr = (!neg_vga_vs_d0&neg_vga_vs_d1);         //for debug
//assign bank_image_done_pos = bank_image_done_d0&~bank_image_done_d1; //for debug
assign ready_rd_flag = (frame_wr_done_reg&&(!fifo_full_flag)&&(fifo_len<rd_byte_number))?1'b1:1'b0;
//assign ready_rd_flag = (First_image_done&&(!fifo_full_flag)&&(fifo_len<rd_byte_number))?1'b1:1'b0;
//---------------------------------------------//  
assign w_fifo_clk   = ddr_clk            ;
assign w_fifo_en    = rd_burst_data_valid;
assign w_fifo_data  = rd_burst_data      ;
//---------------------------------------------//  
//assign First_image_done_n = ~First_image_done;
assign addr_u1 = rd_addr_sample[17:0] + MAXADDR ;          //不关心最高BANK位
assign rd_addr_sample = {reg_slave_sel_rd_bank,1'b0,read_channal,initial_addr};             //initial read_address

//debug 
//assign error_rd_empty  = (rd_addr[22:0]==addr_u1) ? 1'b1:1'b0;

endmodule