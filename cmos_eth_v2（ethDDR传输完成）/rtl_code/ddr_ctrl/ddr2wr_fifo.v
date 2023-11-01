module ddr2wr_fifo 
#(
    parameter WRITE_ADDRMAX = 25'd245_760 , //测试用1536，显示用245_760 64*48*8/32
    parameter READ_ADDRMAX  = 25'd245_760
)  
(                                         
    input wire              DDR_CLK                         ,
    input wire              DDR_RST                         ,
    //ddr_r                                                 
    input wire [31 : 0]     rd_burst_data                   ,
    input wire              rd_burst_data_valid             ,
    output reg              mem_ren                         ,
    output reg [24 : 0]     rd_addr                         ,
    input wire              rd_burst_finish                 ,
    //ddr_w                                                 
    output wire [31: 0]     wr_burst_data                   ,
    input  wire             wr_burst_data_req               ,
    output reg              mem_wen                         ,
    output reg  [24: 0]     wr_addr                         ,
    input  wire             wr_burst_finish                 ,
    //                                                      
    input  wire             ready                           ,
    input  wire             state_ready                     ,
    //fifo_w                                                
    output wire             W_CLK                           ,
    output wire             W_RST_N                         ,
    output wire             W_EN                            ,
    output wire [31 :0 ]    W_DATA                          ,
    //fifo_r                                                
    output wire             R_CLK                           ,
    output wire             R_RST_N                         ,
    output wire             R_EN                            ,
    input  wire [31: 0]     R_DATA                          ,
    //fifo_32w8r                                            
    input wire  [9: 0]      FIFO_LEN_1                      ,
    input wire              FIFO_FULL_1                     ,   
    //fifo_32w32r                                           
    input  wire             FIFO_EMPTY_0                    ,
    input  wire             FIFO_FULL_0                     ,
    input  wire [10: 0]     FIFO_LEN_0                      ,
    output reg  [9 : 0]     wr_burst_len                    ,
    output reg              fifo_32w8r_rst                  ,
    //                                                      
    input wire              camera_vsync                    ,
    input wire              vga_vs                          ,
    //bank_switch                                           
    input  wire  [1 : 0]    wr_bank                         ,
    input  wire             wr_load                         ,
    input  wire  [1 : 0]    rd_bank                         ,
    input  wire             rd_load                         ,
    output reg              frame_rd_done                   ,
    output reg              frame_wr_done                   ,
    //led                                                   
    output wire             First_image_done_n              ,
    //debug                                                 
    output wire [22: 0]     addr_u0                         ,
    output wire [22: 0]     addr_u1                         ,
    output wire             error                           ,
    output wire             error_e1                        ,
    output wire             error_rd_empty    

); 

    //---------------------------------------------//
    localparam rd_byte_number = 10'd750;
    localparam wr_byte_number = 11'd256; 
    localparam initial_addr = 23'd0;
    wire [24:0]             rd_addr_sample        ;
    wire [24:0]             wr_addr_sample        ;
    reg                     load_rd_addr          ;
    reg                     load_wr_addr          ;
    reg  [1 : 0]            rd_bank_reg           ;
    reg  [1 : 0]            wr_bank_reg           ;
    wire                    ready_wr_flag         ;
    wire                    ready_rd_flag         ; 
    
    reg                     First_image_done      ;
    reg  [1:0]              state                 ;
    wire [24:0]             addr_len              ;
    reg                     bank_image_done_d0    ;
    reg                     bank_image_done_d1    ;
    wire                    bank_image_done_pos   ;  
    reg                     mem_busy_flag         ;
    wire                    NEG_VGAHS             ;
    //-----------------------------------------------
    //  load_rd_addr
    //-----------------------------------------------
    always @(posedge DDR_CLK or negedge DDR_RST) begin
        if (DDR_RST ==1'b0) begin
            load_rd_addr <= 1'b0;
        end 
        else if (rd_load) begin
            load_rd_addr <= 1'b1;
        end
        else begin
            load_rd_addr <= 1'b0;
        end
    end 
    //-----------------------------------------------
    //  bank_switch
    //-----------------------------------------------
    always @(posedge DDR_CLK or negedge DDR_RST) begin
        if (DDR_RST ==1'b0) begin
            rd_bank_reg <= 1'b1;
        end 
        else if (rd_load) begin
            rd_bank_reg <= rd_bank;
        end 
        else begin
            rd_bank_reg <= rd_bank_reg;
        end
    end 
    //-----------------------------------------------
    //  bank_switch --- frame_rd_done
    //-----------------------------------------------
    always @(posedge DDR_CLK or negedge DDR_RST) begin
        if (DDR_RST ==1'b0) begin
            frame_rd_done <= 1'b0;
        end 
        else if (rd_addr[22:0]==addr_u1&&~vga_vs) begin
            frame_rd_done <= 1'b1;
        end 
        else begin
            frame_rd_done <= 1'b0;
        end
    end 
    //-----------------------------------------------
    //  bank_switch --- frame_rd_done
    //-----------------------------------------------
    always @(posedge DDR_CLK or negedge DDR_RST) begin
        if (DDR_RST ==1'b0) begin
            rd_addr <= 25'd0;
            fifo_32w8r_rst <= 1'b1;
        end 
        else if (rd_burst_finish && rd_addr[22:0] < addr_u1) begin
            rd_addr <= rd_addr + 25'd256;
            fifo_32w8r_rst <= 1'b1;
        end 
        else if (load_rd_addr) begin 
            rd_addr <= rd_addr_sample;
            fifo_32w8r_rst <= 1'b0;
        end
        else begin
            rd_addr <= rd_addr;
            fifo_32w8r_rst <= 1'b1;
        end
    end 
    //-----------------------------------------------
    //  bank_switch --- mem_ren/mem_wen
    //-----------------------------------------------
    always @(posedge DDR_CLK or negedge DDR_RST) begin
        if (DDR_RST ==1'b0) begin
            mem_ren <= 1'b0;
            mem_wen <= 1'b0;
            wr_burst_len <= 10'd0;
            mem_busy_flag <= 1'b0;
        end 
        else if(!frame_wr_done&&ready && ready_wr_flag&&state_ready&&~mem_busy_flag)begin     
            mem_wen <= 1'b1;                      
            wr_burst_len <= 10'd256;
            mem_ren <= 1'b0;
            mem_busy_flag <= 1'b1;
        end 
        else if((state_ready&&ready&&ready_rd_flag)&&(rd_addr[22:0]<addr_u1)&&~mem_busy_flag)begin
            mem_wen <= 1'b0;                      
            wr_burst_len <= 10'd256;
            mem_ren <= 1'b1;
            mem_busy_flag <= 1'b1;
        end 
        else if(wr_burst_finish||rd_burst_finish)begin
            mem_busy_flag <= 1'b0;
        end 
        else begin
            mem_ren <= 1'b0;
            mem_wen <= 1'b0;
            wr_burst_len <= wr_burst_len;
            mem_busy_flag <= mem_busy_flag;
        end
    end  
    
    //-----------------------------------------------
    //  bank_switch --- frame_wr_done
    //-----------------------------------------------
    always @(posedge DDR_CLK or negedge DDR_RST)begin
        if(DDR_RST==1'b0)begin
            First_image_done <= 1'b0;
        end 
        else if(frame_wr_done)begin 
            First_image_done <= 1'b1;
        end
        else begin
            First_image_done <= First_image_done;
        end 
    end
    
    //-----------------------------------------------
    //  bank_switch
    //-----------------------------------------------
    always @(posedge DDR_CLK or negedge DDR_RST) begin
        if (DDR_RST ==1'b0) begin
            wr_bank_reg <= 1'b0;
        end 
        else if (wr_load) begin
            wr_bank_reg <= wr_bank;
        end 
        else begin
            wr_bank_reg <= wr_bank_reg;
        end
    end 
    
    //-----------------------------------------------
    //  bank_switch --- frame_wr_done
    //-----------------------------------------------
    always @(posedge DDR_CLK or negedge DDR_RST)begin
        if (DDR_RST ==1'b0) begin
            state <= 25'd0;  
        end 
        else  begin
            case(state) 
            0:begin
                if(wr_addr[22:0]==WRITE_ADDRMAX)begin
                    frame_wr_done <= 1'b1;
                    load_wr_addr <= 1'b0;
                    state <= 1;
                end
                else begin
                    frame_wr_done <= 1'b0;
                    load_wr_addr <= 1'b0;
                    state <= 0;
                end
            end
            1: begin
                if (wr_load) begin
                    load_wr_addr <= 1;
                    frame_wr_done <= frame_wr_done;
                    state <= 2;
                end
                else begin
                    load_wr_addr <= load_wr_addr;
                    frame_wr_done <= frame_wr_done;
                    state <= 1;
                end
            end
            2: begin
                    load_wr_addr <= 0;
                    frame_wr_done <= 0;
                    state <= 0;
                end
            default : state <= 0;
            endcase  
        end
    end
    
    always @(posedge DDR_CLK or negedge DDR_RST) begin
        if (DDR_RST ==1'b0) begin
            wr_addr <= 25'd0;  
        end 
        else if (wr_burst_finish && wr_addr[22:0] <= addr_u0) begin
            wr_addr <= wr_addr + 25'd256;
        end 
        else if (load_wr_addr) begin
            wr_addr <= wr_addr_sample;
        end  
        else begin
            wr_addr <= wr_addr;
        end
    end  
    //-----------------------------------------------
    //  bank_image_done_pos
    //-----------------------------------------------
    always @(posedge DDR_CLK or negedge DDR_RST) begin
        if (DDR_RST ==1'b0) begin
            bank_image_done_d0<=1'b1;
            bank_image_done_d1<=1'b1;
        end 
        else begin
            bank_image_done_d0<=camera_vsync;
            bank_image_done_d1<=bank_image_done_d0;
        end 
    end  
    //-----------------------------------------------
    //  vga_vs neg 高
    //-----------------------------------------------
    reg NEG_VGAHS_d0,NEG_VGAHS_d1;
    always @(posedge DDR_CLK or negedge DDR_RST) begin
        if (DDR_RST ==1'b0) begin
            NEG_VGAHS_d0<=1'b0;
            NEG_VGAHS_d1<=1'b0;
        end 
        else begin
            NEG_VGAHS_d0<=vga_vs;
            NEG_VGAHS_d1<=NEG_VGAHS_d0;
        end 
    end

    assign NEG_VGAHS = (!NEG_VGAHS_d0&NEG_VGAHS_d1) ? 1'b1:1'b0;
    assign bank_image_done_pos = bank_image_done_d0&~bank_image_done_d1;
    assign ready_wr_flag = FIFO_FULL_0 ? 1'b1:((FIFO_LEN_0 >= wr_byte_number)? 1'b1:1'b0);
    assign addr_len = (FIFO_LEN_0 >= 12'd2000) ? 25'd1000:{13'b0,FIFO_LEN_0};    
    assign error = (rd_bank==wr_bank) ? ((rd_addr[23:0]<=wr_addr[23:0])? 1'b1:1'b0):1'b0;
    assign error_e1 = (rd_addr[24]==wr_addr[24]) ? ((rd_addr[23:0]<=wr_addr[23:0])? 1'b1:1'b0):1'b0;
    assign ready_rd_flag = (First_image_done&&(!FIFO_FULL_1)&&(FIFO_LEN_1<rd_byte_number))?1'b1:1'b0;
    //---------------------------------------------//
    assign R_CLK = DDR_CLK;
    assign R_RST_N = DDR_RST;
    assign R_EN = wr_burst_data_req;
    assign wr_burst_data = R_DATA ;
    //---------------------------------------------//  
    assign W_CLK = DDR_CLK ;
    assign W_RST_N = DDR_RST;
    assign W_EN = rd_burst_data_valid;
    assign W_DATA = rd_burst_data ;
    //---------------------------------------------//  
    assign First_image_done_n = ~First_image_done;
    assign addr_u0 = wr_addr_sample[22:0] + WRITE_ADDRMAX - 23'd256 ;
    assign addr_u1 = rd_addr_sample[22:0] + READ_ADDRMAX ;          //不关心最高BANK位
    assign rd_addr_sample = {rd_bank_reg,initial_addr};             //initial read_address
    assign wr_addr_sample = {wr_bank_reg,initial_addr};             //initial read_address

    //debug 
    assign error_rd_empty  = (rd_addr[22:0]==addr_u1) ? 1'b1:1'b0;

endmodule
