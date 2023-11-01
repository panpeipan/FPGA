module arbitrate_ctrl 
#(
    parameter slave_num = 4'd4
)
(
    input wire            ddr_clk          ,
    input wire            sys_rstn         ,
    output reg  [9: 0]    slave_valid      ,
//slave0
    input  wire           slave0_req       ,
    input  wire [24: 0]   slave0_Waddr     ,
    input  wire [9: 0]    slave0_Wlen      ,
    input  wire [31: 0]   slave0_data      ,
    output wire           slave0_ren       ,
//slave1
    input  wire           slave1_req       ,
    input  wire [24: 0]   slave1_Waddr     ,
    input  wire [9: 0]    slave1_Wlen      ,
    input  wire [31: 0]   slave1_data      ,
    output wire           slave1_ren       ,
//slave2
    input  wire           slave2_req       ,
    input  wire [24: 0]   slave2_Waddr     ,
    input  wire [9: 0]    slave2_Wlen      ,
    input  wire [31: 0]   slave2_data      ,
    output wire           slave2_ren       ,
//slave3
    input  wire           slave3_req       ,
    input  wire [24: 0]   slave3_Waddr     ,
    input  wire [9: 0]    slave3_Wlen      ,
    input  wire [31: 0]   slave3_data      ,
    output wire           slave3_ren       ,
//slave4
    input  wire           slave4_req       ,
    input  wire [24: 0]   slave4_Waddr     ,
    input  wire [9: 0]    slave4_Wlen      ,
    input  wire [31: 0]   slave4_data      ,
    output wire           slave4_ren       ,
//slave5
    input  wire           slave5_req       ,
    input  wire [24: 0]   slave5_Waddr     ,
    input  wire [9: 0]    slave5_Wlen      ,
    input  wire [31: 0]   slave5_data      ,
    output wire           slave5_ren       ,
//slave6
    input  wire           slave6_req       ,
    input  wire [24: 0]   slave6_Waddr     ,
    input  wire [9: 0]    slave6_Wlen      ,
    input  wire [31: 0]   slave6_data      ,
    output wire           slave6_ren       ,
//slave7
    input  wire           slave7_req       ,
    input  wire [24: 0]   slave7_Waddr     ,
    input  wire [9: 0]    slave7_Wlen      ,
    input  wire [31: 0]   slave7_data      ,
    output wire           slave7_ren       ,
//slave8
    input  wire           slave8_req       ,
    input  wire [24: 0]   slave8_Waddr     ,
    input  wire [9: 0]    slave8_Wlen      ,
    input  wire [31: 0]   slave8_data      ,
    output wire           slave8_ren       ,
//slave_Sd
    input  wire           slave_sd_req     ,
    input  wire [24: 0]   slave_sd_Waddr   ,
    input  wire [9: 0]    slave_sd_Wlen    ,
    input  wire [31: 0]   slave_sd_data    ,
    output wire           slave_sd_ren     ,
//from ddr_wr_crtl       
    input wire            ready            ,
    input wire            ddr_write_finish ,
//to ddr_wrctrl
    output reg  [24: 0]   arb_wddr_addr    ,
    output reg  [9: 0]    arb_wddr_len     ,
    input  wire           ddr_Rfifo_en     ,
    output wire [31: 0]   ddr_Rfifo_data   ,
    output reg            mem_wen          ,
    input  wire           mem_wen_valid    
);
    
reg  [9:0]    sellect_num    ;
reg           arbitrate_ready;                           //arbitrate is ready for request from slave 0-3
reg           mem_wen_exact  ; 
wire [9:0]    primary_num    ;
wire          slave_req_flag ; 

always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
        sellect_num <= 'd0;
    end 
    else if (slave_req_flag && arbitrate_ready) begin
        sellect_num <= primary_num ;
    end
end 
always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn ) begin
        arbitrate_ready <= 1'b1;
    end 
    else if (ddr_write_finish) begin
        arbitrate_ready <= 1'b1;
    end 
    else if (slave_req_flag) begin
        arbitrate_ready <= 1'b0;
    end 
    else begin
        arbitrate_ready <= arbitrate_ready ;
    end
end 
always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
        slave_valid <= 'd0 ;
    end 
    else if (ddr_write_finish) begin
        slave_valid <= 'd0 ;
    end
    else if (slave_req_flag && arbitrate_ready) begin
        slave_valid <= primary_num ;
    end 
end 
// arb_wddr_addr
always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn ) begin
        arb_wddr_addr <= 25'd0;
    end 
    else if (ddr_write_finish) begin
        arb_wddr_addr <= 25'd0;
    end 
    else if (slave_req_flag && arbitrate_ready) begin
        case (primary_num)
            10'd1: begin
                arb_wddr_addr <= slave0_Waddr[24:0] ;
            end 
            10'd2:begin 
                arb_wddr_addr <= slave1_Waddr[24:0] ;
            end 
            10'd4:begin 
                arb_wddr_addr <= slave2_Waddr[24:0] ;
            end 
            10'd8:begin 
                arb_wddr_addr <= slave3_Waddr[24:0] ;
            end 
            10'd16:begin 
                arb_wddr_addr <= slave4_Waddr[24:0] ;
            end 
            10'd32:begin 
                arb_wddr_addr <= slave5_Waddr[24:0] ;
            end 
            10'd64:begin 
                arb_wddr_addr <= slave6_Waddr[24:0] ;
            end 
            10'd128:begin 
                arb_wddr_addr <= slave7_Waddr[24:0] ;
            end 
            10'd256:begin 
                arb_wddr_addr <= slave8_Waddr[24:0] ;
            end 
            10'd512:begin 
                arb_wddr_addr <= slave_sd_Waddr[24:0] ;
            end 
            default: begin
                arb_wddr_addr <= 25'd0;
            end
        endcase
    end
end 
always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn ) begin
        arb_wddr_len <= 10'd0;
    end 
    else if (ddr_write_finish) begin
        arb_wddr_len <= 10'd0;
    end 
    else if (slave_req_flag && arbitrate_ready) begin
        case (primary_num)
            10'd1: begin
                arb_wddr_len <= slave0_Wlen ;
            end 
            10'd2:begin 
                arb_wddr_len <= slave1_Wlen ;
            end 
            10'd4:begin 
                arb_wddr_len <= slave2_Wlen ;
            end 
            10'd8:begin 
                arb_wddr_len <= slave3_Wlen ;
            end 
            10'd16:begin 
                arb_wddr_len <= slave4_Wlen ;
            end 
            10'd32:begin 
                arb_wddr_len <= slave5_Wlen ;
            end 
            10'd64:begin 
                arb_wddr_len <= slave6_Wlen ;
            end 
            10'd128:begin 
                arb_wddr_len <= slave7_Wlen;
            end 
            10'd256:begin 
                arb_wddr_len <= slave8_Wlen;
            end 
            10'd512:begin 
                arb_wddr_len <= slave_sd_Wlen;
            end 
            default: begin
                arb_wddr_len <= 10'd0;
            end
        endcase
    end
end 

//w_ddr unity
always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
        mem_wen_exact <= 1'b0;
    end 
    else if (slave_req_flag&&arbitrate_ready) begin
        mem_wen_exact <= 1'b1;
    end 
    else if(mem_wen)begin
        mem_wen_exact <= 1'b0;
    end 
    else begin 
        mem_wen_exact <= mem_wen_exact ;
    end
end

always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
        mem_wen <= 1'b0;
    end 
    else if (mem_wen_exact && ready) begin
        mem_wen <= 1'b1;
    end 
    else if (mem_wen_valid)begin 
        mem_wen <= 1'b0 ;
    end
    else begin 
        mem_wen <= mem_wen ;
    end 
end

assign slave_req_flag = slave0_req || slave1_req || slave2_req || slave3_req || slave4_req || slave5_req || slave6_req || slave7_req || slave8_req ||slave_sd_req ;
//assign primary_num = slave0_req ? 4'd1:(slave1_req ? 4'd2:(slave2_req ? 4'd4 : (slave3_req ? 4'd8:4'd0)));
assign primary_num  = slave_sd_req ? 10'd512 :
                       (slave0_req ? 10'd1   :
                       (slave1_req ? 10'd2   : 
                       (slave2_req ? 10'd4   :
                       (slave3_req ? 10'd8   :
                       (slave4_req ? 10'd16  :
                       (slave5_req ? 10'd32  :
                       (slave6_req ? 10'd64  :
                       (slave7_req ? 10'd128 :
                       (slave8_req ? 10'd256 :10'd0)))))))));


assign slave0_ren   = (sellect_num == 10'd1  )  ? ddr_Rfifo_en :1'b0;
assign slave1_ren   = (sellect_num == 10'd2  )  ? ddr_Rfifo_en :1'b0;
assign slave2_ren   = (sellect_num == 10'd4  )  ? ddr_Rfifo_en :1'b0;
assign slave3_ren   = (sellect_num == 10'd8  )  ? ddr_Rfifo_en :1'b0;
assign slave4_ren   = (sellect_num == 10'd16 )  ? ddr_Rfifo_en :1'b0;
assign slave5_ren   = (sellect_num == 10'd32 )  ? ddr_Rfifo_en :1'b0;
assign slave6_ren   = (sellect_num == 10'd64 )  ? ddr_Rfifo_en :1'b0;
assign slave7_ren   = (sellect_num == 10'd128)  ? ddr_Rfifo_en :1'b0;
assign slave8_ren   = (sellect_num == 10'd256)  ? ddr_Rfifo_en :1'b0;
assign slave_sd_ren = (sellect_num == 10'd512)  ? ddr_Rfifo_en :1'b0;

assign ddr_Rfifo_data = (sellect_num == 10'd1  ) ? slave0_data :(
                        (sellect_num == 10'd2  ) ? slave1_data :(
                        (sellect_num == 10'd4  ) ? slave2_data :(
                        (sellect_num == 10'd8  ) ? slave3_data :(
                        (sellect_num == 10'd16 ) ? slave4_data :(
                        (sellect_num == 10'd32 ) ? slave5_data :(
                        (sellect_num == 10'd64 ) ? slave6_data :(
                        (sellect_num == 10'd128) ? slave7_data :(
                        (sellect_num == 10'd256) ? slave8_data :(
                        (sellect_num == 10'd512) ? slave_sd_data : 32'b0
                        )))))))));

endmodule
