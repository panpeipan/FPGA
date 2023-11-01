//-----------------------FSM---------------------//
module ddr_wr_ctrl#(
    parameter MAX_ADDR   = 21'd245_760   //256760 - 256 =245_504
)
(   
//----------------------------------------  
//DDR2_port
    output  [ 12: 0]               mem_addr          ,
    output  [  2: 0]               mem_ba            ,
    output                         mem_cas_n         ,
    output  [  0: 0]               mem_cke           ,
    inout   [  0: 0]               mem_clk           ,
    inout   [  0: 0]               mem_clk_n         ,
    output  [  0: 0]               mem_cs_n          ,
    output  [  1: 0]               mem_dm            ,
    inout   [ 15: 0]               mem_dq            ,
    inout   [  1: 0]               mem_dqs           ,
    output  [  0: 0]               mem_odt           ,
    output                         mem_ras_n         ,
    output                         mem_we_n          ,
//
//----------------------------------------  
//slave port
    input wire                     source_clk               ,
    output wire                    ddr_clk                  ,
    input wire                     rst_n                    ,
    output wire                    ddr_initial_done         ,
    output reg                     slave0_frame_wr_done     ,
    output reg                     slave0_frame_rd_done     ,
    output reg                     slave1_frame_wr_done     ,
    output reg                     slave1_frame_rd_done     ,
    output reg                     slave2_frame_wr_done     ,
    output reg                     slave2_frame_rd_done     ,
    output reg                     slave3_frame_wr_done     ,
    output reg                     slave3_frame_rd_done     ,
    output reg                     slave4_frame_wr_done     ,
    output reg                     slave4_frame_rd_done     ,
    output reg                     slave5_frame_wr_done     ,
    output reg                     slave5_frame_rd_done     ,
    output reg                     slave6_frame_wr_done     ,
    output reg                     slave6_frame_rd_done     ,
    output reg                     slave7_frame_wr_done     ,
    output reg                     slave7_frame_rd_done     ,
    output reg                     slave8_frame_wr_done     ,
    output reg                     slave8_frame_rd_done     ,
//----------------------------------------   
//state 
    output wire                    ready                    ,

    //from arbitrate 
    input  wire [24:0]             wr_addr                  ,
    input  wire [9: 0]             w_len                    ,
    input  wire                    mem_wen                  ,
    output reg                     mem_wen_valid            ,
    output  wire                   wr_burst_data_req        ,
    input   wire [31:0]            wr_burst_data            ,
    output wire                    wr_burst_finish          ,
    
    input wire [24:0]              rd_addr                  ,
    input wire [9 :0]              r_len                    ,
    output reg                     mem_ren_valid            ,    
    input wire                     mem_ren                  ,
    output  wire                   rd_burst_data_valid      ,
    output  wire [31:0]            rd_burst_data            ,
    output wire                    rd_burst_finish          ,
    
//    output reg                     mem_ren_fail             ,  //for ddrwfifo
    output reg                     frame_wr_done            
);
//---------------------------------------------------------
// mem_ddr define 
localparam DATA_WIDTH = 32;           //总线数据宽度
localparam ADDR_WIDTH = 25;           //总线地址宽度
reg  [24:0]                     wr_burst_addr       ;
reg  [24:0]                     rd_burst_addr       ;
reg  [9:0]                      wr_burst_len        ;
reg  [9:0]                      rd_burst_len        ;
reg                             wr_burst_req        ;
reg                             rd_burst_req        ; 
//----------------------------------------------------------
//local_mem define 
wire                            phy_clk             ;
wire	[ADDR_WIDTH - 1:0]	    local_address       ;
wire		                    local_write_req     ;
wire		                    local_read_req      ;
wire	[DATA_WIDTH - 1:0]	    local_wdata         ;
wire	[DATA_WIDTH/8 - 1:0]	local_be            ;
wire	[2:0]	                local_size          ;
wire		                    local_ready         ;
wire	[DATA_WIDTH - 1:0]	    local_rdata         ;
wire	                       	local_rdata_valid   ;
wire	                       	local_init_done     ;
wire                            local_burstbegin    ;
wire                            burst_idle          ;
//                                                  
//wire	                       	aux_full_rate_clk   ;        ..NULL
//wire	                       	aux_half_rate_clk   ;        ..NULL

//-save bank
// reg [1:0] slave0_wr_bank_reg , slave1_wr_bank_reg , slave2_wr_bank_reg , slave3_wr_bank_reg;
// reg [1:0] slave0_rd_bank_reg , slave1_rd_bank_reg , slave2_rd_bank_reg , slave3_rd_bank_reg;

assign ddr_clk = phy_clk ; 
//-FSM-------------------------------------------------------
localparam IDLE = 3'd0;
localparam MEM_READ = 3'd1;
localparam MEM_WRITE  = 3'd2; 

reg[2:0] state;
reg[2:0] next_state;


reg      mem_wen_fail;
always@(posedge	phy_clk or negedge rst_n)
    if ( rst_n == 1'b0) begin
        state <= IDLE;
    end
    else 
	begin
		if(~local_init_done)          //等待初始化成功
			state <= IDLE;
		else	
			state <= next_state;
	end
	
//////循环产生DDR Burst读,Burst写状态///////////
always@(posedge	phy_clk)
	begin 
		case(state)
			IDLE:
                if ( mem_wen && next_state == IDLE) begin
                    next_state <= MEM_WRITE;  
                end
                else if ( mem_ren && next_state == IDLE) begin
				    next_state <= MEM_READ;  
                end
                else begin
                    next_state <= next_state ;
                end
			MEM_READ:                    //读出数据从DDR2
				if(rd_burst_finish)
					next_state <= IDLE;
				else
					next_state <= next_state;
			MEM_WRITE:                    //写入数据到DDR2
				if(wr_burst_finish)          
					next_state <= IDLE;
				else
					next_state <= next_state;
			default:
				next_state <= IDLE;
		endcase
end

//DDR的读写地址和DDR测试数据//
always@(posedge phy_clk or negedge rst_n)
    if ( rst_n == 1'b0) begin
        wr_burst_addr <= {ADDR_WIDTH{1'b0}};
    end
    else 
	begin
		if(state == IDLE && next_state == MEM_WRITE)
			wr_burst_addr <= wr_addr;     //地址清零     
		else
			wr_burst_addr <= wr_burst_addr;                //锁存地址
    end
always@(posedge phy_clk or negedge rst_n)
    if ( rst_n == 1'b0) begin
        rd_burst_addr <= {ADDR_WIDTH{1'b0}};
    end
    else 
	begin
		if(state == IDLE && next_state == MEM_READ)
			rd_burst_addr <= rd_addr;     //地址清零     
		else
			rd_burst_addr <= rd_burst_addr;                //锁存地址
	end

//产生burst写请求信号
always@(posedge phy_clk or negedge rst_n)
    if ( rst_n == 1'b0) begin
        mem_wen_valid <= 1'b0;
		wr_burst_req <= 1'b0;      //产生ddr burst写请求       
		wr_burst_len <= 10'd0;
    end
    else 
	begin 
		if(next_state == MEM_WRITE && state == IDLE)
			begin
                mem_wen_valid <= 1'b1;
				wr_burst_req <= 1'b1;    //产生ddr burst写请求       
				wr_burst_len <= w_len;
			end
		else if(wr_burst_data_req)       //写入burst数据请求 
			begin
                mem_wen_valid <= 1'b0;
				wr_burst_req <= 1'b0;
				wr_burst_len <= wr_burst_len;
			end
		else
			begin
                mem_wen_valid <= 1'b0;
				wr_burst_req <= wr_burst_req;
				wr_burst_len <= wr_burst_len;
			end
	end

//产生burst读请求信号	
always@(posedge phy_clk or negedge rst_n)
    if ( rst_n == 1'b0) begin
        mem_ren_valid <= 1'b0;
		rd_burst_req <= 1'b0;      //产生ddr burst写请求       
		rd_burst_len <= 10'd0;
    end
    else 
	begin
		if(next_state == MEM_READ && state == IDLE)
			begin
                mem_ren_valid <= 1'b1;
				rd_burst_req <= 1'b1;      //产生ddr burst读请求  
				rd_burst_len <= r_len;
			end
		else if(rd_burst_data_valid)     //检测到data_valid信号,burst读请求变0
			begin
                mem_ren_valid <= 1'b0;
				rd_burst_req <= 1'b0;
				rd_burst_len <= rd_burst_len;
			end
		else
			begin
                mem_ren_valid <= 1'b0;
				rd_burst_req <= rd_burst_req;
				rd_burst_len <= rd_burst_len;
			end
	end
//-----------------------------------------------------------
//frame_wr_done
//-----------------------------------------------------------
always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_wr_done <= 1'b0;
    end 
    else if (wr_burst_finish && wr_burst_addr[17:0]==(MAX_ADDR-18'd256)) begin  
        frame_wr_done <= 1'b1;
    end 
    else begin
        frame_wr_done <= 1'b0;
    end
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave0_frame_wr_done <= 1'b0;
    end 
    else if (wr_burst_finish && wr_burst_addr[17:0]==(MAX_ADDR-18'd256)&&wr_burst_addr[21:18]==4'd0) begin  
        slave0_frame_wr_done <= 1'b1;
    end 
    else begin
        slave0_frame_wr_done <= 1'b0;
    end
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave1_frame_wr_done <= 1'b0;
    end 
    else if (wr_burst_finish && wr_burst_addr[17:0]==(MAX_ADDR-18'd256)&&wr_burst_addr[21:18]==4'd1) begin  
        slave1_frame_wr_done <= 1'b1;
    end 
    else begin
        slave1_frame_wr_done <= 1'b0;
    end
end
always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave2_frame_wr_done <= 1'b0;
    end 
    else if (wr_burst_finish && wr_burst_addr[17:0]==(MAX_ADDR-18'd256)&&wr_burst_addr[21:18]==4'd2) begin  
        slave2_frame_wr_done <= 1'b1;
    end 
    else begin
        slave2_frame_wr_done <= 1'b0;
    end
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave3_frame_wr_done <= 1'b0;
    end 
    else if (wr_burst_finish && wr_burst_addr[17:0]==(MAX_ADDR-18'd256)&&wr_burst_addr[21:18]==4'd3) begin  
        slave3_frame_wr_done <= 1'b1;
    end 
    else begin
        slave3_frame_wr_done <= 1'b0;
    end
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave4_frame_wr_done <= 1'b0;
    end 
    else if (wr_burst_finish && wr_burst_addr[17:0]==(MAX_ADDR-18'd256)&&wr_burst_addr[21:18]==4'd4) begin  
        slave4_frame_wr_done <= 1'b1;
    end 
    else begin
        slave4_frame_wr_done <= 1'b0;
    end
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave5_frame_wr_done <= 1'b0;
    end 
    else if (wr_burst_finish && wr_burst_addr[17:0]==(MAX_ADDR-18'd256)&&wr_burst_addr[21:18]==4'd5) begin  
        slave5_frame_wr_done <= 1'b1;
    end 
    else begin
        slave5_frame_wr_done <= 1'b0;
    end
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave6_frame_wr_done <= 1'b0;
    end 
    else if (wr_burst_finish && wr_burst_addr[17:0]==(MAX_ADDR-18'd256)&&wr_burst_addr[21:18]==4'd6) begin  
        slave6_frame_wr_done <= 1'b1;
    end 
    else begin
        slave6_frame_wr_done <= 1'b0;
    end
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave7_frame_wr_done <= 1'b0;
    end 
    else if (wr_burst_finish && wr_burst_addr[17:0]==(MAX_ADDR-18'd256)&&wr_burst_addr[21:18]==4'd7) begin  
        slave7_frame_wr_done <= 1'b1;
    end 
    else begin
        slave7_frame_wr_done <= 1'b0;
    end
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave8_frame_wr_done <= 1'b0;
    end 
    else if (wr_burst_finish && wr_burst_addr[17:0]==(MAX_ADDR-18'd256)&&wr_burst_addr[21:18]==4'd8) begin  
        slave8_frame_wr_done <= 1'b1;
    end 
    else begin
        slave8_frame_wr_done <= 1'b0;
    end
end


//-----------------------------------------------------------
//frame_rd_done
//-----------------------------------------------------------
always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave0_frame_rd_done <= 1'b0;
    end 
    else if (rd_burst_finish && rd_burst_addr[17:0]==(MAX_ADDR-18'd256)&&rd_burst_addr[21:18]==4'd0) begin  
        slave0_frame_rd_done <= 1'b1;
    end 
    else begin
        slave0_frame_rd_done <= 1'b0;
    end
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave1_frame_rd_done <= 1'b0;
    end 
    else if (rd_burst_finish && rd_burst_addr[17:0]==(MAX_ADDR-18'd256)&&rd_burst_addr[21:18]==4'd1) begin  
        slave1_frame_rd_done <= 1'b1;
    end 
    else begin
        slave1_frame_rd_done <= 1'b0;
    end
end
always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave2_frame_rd_done <= 1'b0;
    end 
    else if (rd_burst_finish && rd_burst_addr[17:0]==(MAX_ADDR-18'd256)&&rd_burst_addr[21:18]==4'd2) begin  
        slave2_frame_rd_done <= 1'b1;
    end 
    else begin
        slave2_frame_rd_done <= 1'b0;
    end
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave3_frame_rd_done <= 1'b0;
    end 
    else if (rd_burst_finish && rd_burst_addr[17:0]==(MAX_ADDR-18'd256)&&rd_burst_addr[21:18]==4'd3) begin  
        slave3_frame_rd_done <= 1'b1;
    end 
    else begin
        slave3_frame_rd_done <= 1'b0;
    end 
end 

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave4_frame_rd_done <= 1'b0;
    end 
    else if (rd_burst_finish && rd_burst_addr[17:0]==(MAX_ADDR-18'd256)&&rd_burst_addr[21:18]==4'd4) begin  
        slave4_frame_rd_done <= 1'b1;
    end 
    else begin
        slave4_frame_rd_done <= 1'b0;
    end 
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave5_frame_rd_done <= 1'b0;
    end 
    else if (rd_burst_finish && rd_burst_addr[17:0]==(MAX_ADDR-18'd256)&&rd_burst_addr[21:18]==4'd5) begin  
        slave5_frame_rd_done <= 1'b1;
    end 
    else begin
        slave5_frame_rd_done <= 1'b0;
    end 
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave6_frame_rd_done <= 1'b0;
    end 
    else if (rd_burst_finish && rd_burst_addr[17:0]==(MAX_ADDR-18'd256)&&rd_burst_addr[21:18]==4'd6) begin  
        slave6_frame_rd_done <= 1'b1;
    end 
    else begin
        slave6_frame_rd_done <= 1'b0;
    end 
end 

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave7_frame_rd_done <= 1'b0;
    end 
    else if (rd_burst_finish && rd_burst_addr[17:0]==(MAX_ADDR-18'd256)&&rd_burst_addr[21:18]==4'd7) begin  
        slave7_frame_rd_done <= 1'b1;
    end 
    else begin
        slave7_frame_rd_done <= 1'b0;
    end 
end

always @(posedge phy_clk or negedge rst_n) begin
    if (!rst_n) begin
        slave8_frame_rd_done <= 1'b0;
    end 
    else if (rd_burst_finish && rd_burst_addr[17:0]==(MAX_ADDR-18'd256)&&rd_burst_addr[21:18]==4'd8) begin  
        slave8_frame_rd_done <= 1'b1;
    end 
    else begin
        slave8_frame_rd_done <= 1'b0;
    end 
end

//assign state_ready =(state==IDLE)&&(next_state==IDLE);

//-----------------------------------------------------  
// DDR2 ctrl
//-----------------------------------------------------
   mem_burst_ddr    
   #(
    .MEM_DATA_WIDTH                     (  6'd32                ),
    .ADDR_WIDTH                         (  6'd25                ),
    .LOCAL_SIZE_BITS                    (  3'd3                 )
   )
   mem_burst_m1(
    .MEM_CLK                            (  phy_clk              ),
    .RST_N                              (  rst_n                ),
    .WR_BURST_REQ                       (  wr_burst_req         ),//done
    .WR_BURST_LEN                       (  wr_burst_len         ),//done
    .WR_BURST_ADDR                      (  wr_burst_addr        ),
    .WR_BURST_DATA                      (  wr_burst_data        ),
    .WR_BURST_DATA_REQ                  (  wr_burst_data_req    ),//done
   //--.----------------------//          
    .RD_BURST_REQ                       (  rd_burst_req         ),//done
    .RD_BURST_LEN                       (  rd_burst_len         ),//done
    .RD_BURST_ADDR                      (  rd_burst_addr        ),//done
    .RD_BURST_DATA                      (  rd_burst_data        ),//done
    .RD_BURST_DATA_VALID                (  rd_burst_data_valid  ),//done
   //--.----------------------//           
    .RD_FINISH                          (  rd_burst_finish      ),//done
    .WR_FINISH                          (  wr_burst_finish      ),//done
    .BURST_IDLE                         (  burst_idle           ),//done
   //--.--DDR_IP_CORE------------//        
    .LOCAL_INITIAL_DONE                 (  local_init_done      ),
    .RST_DDR_N                          (                       ),//done
    
    .LOCAL_READY                        (  local_ready          ),//done
    .LOCAL_WDATA                        (  local_wdata          ),//done 
    .LOCAL_WRITE_REQ                    (  local_write_req      ),//done
    .LOCAL_BE                           (  local_be             ),//done
    
    .LOCAL_ADDR                         (  local_address        ),//done
    .LOCAL_BURSTBEGIN                   (  local_burstbegin     ),//done   
    .LOCAL_RDATA_VALID                  (  local_rdata_valid    ),//done
    .LOCAL_RDATA                        (  local_rdata          ),//done
    .LOCAL_READ_REQ                     (  local_read_req       ),//done
    .LOCAL_SIZE                         (  local_size           )
);
assign ddr_initial_done = local_init_done ; 
//实例化ddr2.v
ddr2 ddr_m0(
	.local_address(local_address),
	.local_write_req(local_write_req),
	.local_read_req(local_read_req),
	.local_wdata(local_wdata),
	.local_be(local_be),
	.local_size(local_size),
	.global_reset_n(rst_n),
	//.local_refresh_req(1'b0), 
	//.local_self_rfsh_req(1'b0),
	.pll_ref_clk(source_clk),
	.soft_reset_n(1'b1),
	.local_ready(local_ready),
	.local_rdata(local_rdata),
	.local_rdata_valid(local_rdata_valid),
	.reset_request_n(),
	.mem_cs_n(mem_cs_n),
	.mem_cke(mem_cke),
	.mem_addr(mem_addr),
	.mem_ba(mem_ba),
	.mem_ras_n(mem_ras_n),
	.mem_cas_n(mem_cas_n),
	.mem_we_n(mem_we_n),
	.mem_dm(mem_dm),
	.local_refresh_ack(),
	.local_burstbegin(local_burstbegin),
	.local_init_done(local_init_done),
	.reset_phy_clk_n(),
	.phy_clk(phy_clk),
	.aux_full_rate_clk(),
	.aux_half_rate_clk(),
	.mem_clk(mem_clk),
	.mem_clk_n(mem_clk_n),
	.mem_dq(mem_dq),
	.mem_dqs(mem_dqs),
	.mem_odt(mem_odt)
	);
    
assign ready = local_init_done && (state==IDLE) && (next_state == IDLE) && burst_idle;
endmodule 
