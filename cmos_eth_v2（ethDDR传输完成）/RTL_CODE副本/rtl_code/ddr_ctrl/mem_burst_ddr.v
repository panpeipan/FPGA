module mem_burst_ddr
#(
    parameter MEM_DATA_WIDTH=6'd32,
    parameter ADDR_WIDTH=6'd25,
    parameter LOCAL_SIZE_BITS=3'd3
)(
    input wire MEM_CLK,
    input wire RST_N,

    input wire WR_BURST_REQ,                        //done
    input wire [9:0] WR_BURST_LEN,                  //done
    input wire [ADDR_WIDTH-1:0]WR_BURST_ADDR,
    input wire [MEM_DATA_WIDTH-1:0]WR_BURST_DATA,
    output wire  WR_BURST_DATA_REQ,                 //done
//-----------------------------------//
    input wire RD_BURST_REQ,                        //done
    input wire [9:0] RD_BURST_LEN,                  //done
    input wire [ADDR_WIDTH-1:0] RD_BURST_ADDR,      //done
    output wire [MEM_DATA_WIDTH-1:0] RD_BURST_DATA,//done
    output wire RD_BURST_DATA_VALID,//done
//-----------------------------------//
    output wire  RD_FINISH,//done
    output wire  WR_FINISH,//done
    output wire  BURST_IDLE,//done

//---------------DDR_IP_CORE------------//
    input wire LOCAL_INITIAL_DONE,
    output wire RST_DDR_N,//done
    
    input wire LOCAL_READY,//done
    output wire [MEM_DATA_WIDTH-1:0] LOCAL_WDATA,//done
    output wire LOCAL_WRITE_REQ,//done
    output wire [LOCAL_SIZE_BITS:0]  LOCAL_BE,//done

    output reg [ADDR_WIDTH -1 :0] LOCAL_ADDR,//done
    output wire LOCAL_BURSTBEGIN,//done
    input wire LOCAL_RDATA_VALID,//done
    input wire [MEM_DATA_WIDTH-1:0] LOCAL_RDATA,//done
    output wire LOCAL_READ_REQ,//done
    output reg [LOCAL_SIZE_BITS-1:0] LOCAL_SIZE//done
);
    reg [9:0] rd_remain_len;
    reg [9:0] rd_valid_cnt;
    reg [9:0] rd_addr_cnt;
    reg [ADDR_WIDTH -1 :0] rd_addr_reg;
    parameter burst_param = 10'd2; 

    reg [9:0] wr_burst_len ;
    reg last_wr_burst_data_flag ;
    parameter IDLE = 3'd0;
    parameter BURST_RD_MEM = 3'd1;
    parameter BURST_RD_WAIT = 3'd2;
    parameter BURST_WR_BUFFER_STAGE = 3'd3;
    parameter BURST_WR_FIRST_STAGE = 3'd4;
    parameter BURST_WR_SECOND_STAGE = 3'd5;
    reg [2:0] state , nextstate;
//-------------FSM--------------//
    always @(posedge MEM_CLK or negedge RST_N) begin
        if (RST_N == 1'b0) begin
            state <= IDLE;
        end 
        else if (LOCAL_INITIAL_DONE == 1'b0) begin
            state <= IDLE;
        end 
        else begin
            state <= nextstate ;
        end
    end
    always @(*) begin
        case (state)
            IDLE: begin
                if (WR_BURST_REQ) begin
                    nextstate <= BURST_WR_BUFFER_STAGE;
                end 
                else if (RD_BURST_REQ) begin
                    nextstate <= BURST_RD_MEM;
                end 
                else begin
                    nextstate <= IDLE;
                end
            end 
            BURST_RD_MEM:begin 
                if (((rd_addr_cnt + burst_param)>=rd_remain_len)&&LOCAL_READY) begin
                    nextstate <= BURST_RD_WAIT;
                end 
                else begin
                    nextstate <= BURST_RD_MEM;
                end
            end 
            BURST_RD_WAIT :begin
                if ((rd_valid_cnt >= rd_remain_len - 10'd1)&&LOCAL_RDATA_VALID) begin
                    nextstate <= IDLE;
                end 
                else begin
                    nextstate <= BURST_RD_WAIT;
                end
            end 
            BURST_WR_BUFFER_STAGE :begin
                nextstate <= BURST_WR_FIRST_STAGE ;
            end 
            BURST_WR_FIRST_STAGE:begin
                if (LOCAL_READY&& wr_burst_len == 10'd1) begin
                    nextstate <= IDLE ;
                end 
                else if (LOCAL_READY) begin
                    nextstate <= BURST_WR_SECOND_STAGE;
                end 
                else begin
                    nextstate <= BURST_WR_FIRST_STAGE;
                end
            end 
            BURST_WR_SECOND_STAGE :begin
                if (LOCAL_READY && wr_burst_len== 10'd1) begin
                    nextstate <= IDLE;
                end 
                else if (LOCAL_READY) begin
                    nextstate <= BURST_WR_FIRST_STAGE;
                end 
                else begin
                    nextstate <= BURST_WR_SECOND_STAGE;
                end 
            end 
            default: begin
                nextstate <= IDLE ;    
            end
        endcase
    end 
    //-------------------LOCAL_ADDR-rd_addr_cnt-------------------//done
    always @(posedge MEM_CLK) begin
        case (state)
            IDLE:
            begin
                if (WR_BURST_REQ) begin
                    LOCAL_ADDR <= WR_BURST_ADDR;
                end 
                else if (RD_BURST_REQ) begin
                    LOCAL_ADDR <= RD_BURST_ADDR;
                    rd_addr_cnt <= 10'd0;
                end 
                else begin
                    LOCAL_ADDR <= 25'hffff_ff;
                    rd_addr_cnt <= 10'd0;
                end
            end 
            BURST_RD_MEM :
            begin
                if (LOCAL_READY) begin
                    LOCAL_ADDR <= LOCAL_ADDR + {14'd0,burst_param};
                    rd_addr_cnt <= rd_addr_cnt + burst_param;
                end 
                else begin
                    LOCAL_ADDR <= LOCAL_ADDR ;
                    rd_addr_cnt <= rd_addr_cnt ;
                end
            end 
            BURST_WR_SECOND_STAGE:
            begin 
                if (LOCAL_READY && (nextstate == BURST_WR_FIRST_STAGE)) begin
                    LOCAL_ADDR <= LOCAL_ADDR  +  {14'd0,burst_param};
                end 
                else begin
                    LOCAL_ADDR <= LOCAL_ADDR ;
                end
            end
            default: begin
                LOCAL_ADDR <= LOCAL_ADDR;
                rd_addr_cnt <= rd_addr_cnt;
            end
        endcase
    end 
    
    //-------------------rd_remain_len------------------//done
    always @(posedge MEM_CLK or negedge RST_N) begin
        if (RST_N == 1'b0) begin
            rd_remain_len <= 10'd0;
        end 
        else if (RD_BURST_REQ==1'b1&&(state==IDLE)) begin
            rd_remain_len <= RD_BURST_LEN;
        end 
        else begin
            rd_remain_len <= rd_remain_len;
        end
    end 
    //--------------------rd_valid_cnt------------------//done
    always @(posedge MEM_CLK or negedge RST_N ) begin
        if (RST_N == 1'b0) begin
            rd_valid_cnt<= 10'd0;
        end 
        else if ((LOCAL_RDATA_VALID==1'b1)&&(state == BURST_RD_MEM || state == BURST_RD_WAIT)) begin
            rd_valid_cnt <= rd_valid_cnt + 10'd1;
        end 
        else if (state == IDLE ) begin
            rd_valid_cnt <= 10'd0;
        end 
        else begin
            rd_valid_cnt <= rd_valid_cnt;
        end
    end 
    //--------------------wr_burst_len------------------//done
    always @(posedge MEM_CLK or negedge RST_N) begin
        if (RST_N == 1'b0) begin
            wr_burst_len <= 10'd0;
        end 
        else if (state == IDLE && WR_BURST_REQ) begin
            wr_burst_len <= WR_BURST_LEN;
        end 
        else if ((state == BURST_WR_FIRST_STAGE ||state == BURST_WR_SECOND_STAGE)&& LOCAL_READY) begin
            wr_burst_len <= wr_burst_len - 10'd1;
        end 
        else begin
            wr_burst_len <= wr_burst_len;
        end
    end 
    //----------------------------------LOCAL_SIZE----------------------------------//
    always @(posedge MEM_CLK) begin
        if ((state == IDLE)&&WR_BURST_REQ) begin
            LOCAL_SIZE <= (WR_BURST_LEN >= burst_param) ? burst_param : WR_BURST_LEN ;
        end 
        else if ((state == IDLE) && RD_BURST_REQ) begin
            LOCAL_SIZE <= (RD_BURST_LEN >= burst_param) ? burst_param : RD_BURST_LEN ;
        end 
        else if (state == BURST_RD_MEM && LOCAL_READY) begin
            LOCAL_SIZE <= ((rd_addr_cnt + burst_param)>= rd_remain_len ) ? 1 : burst_param;
        end 
        else if ((state == BURST_WR_FIRST_STAGE)&&(nextstate == BURST_WR_SECOND_STAGE))begin
            if (wr_burst_len - 1 >= burst_param) begin
                LOCAL_SIZE <= burst_param ;
            end 
            else begin
                LOCAL_SIZE <= wr_burst_len - 1;
            end
        end 
        else if ((state == BURST_WR_SECOND_STAGE)&&(nextstate == BURST_WR_FIRST_STAGE))begin
            if (wr_burst_len - 1 >= burst_param) begin
                LOCAL_SIZE <= burst_param;  
            end 
            else begin
                LOCAL_SIZE <= wr_burst_len - 1;
            end
        end 
        else begin
            LOCAL_SIZE <= LOCAL_SIZE ;
        end
    end 
    //----------------------------------last_wr_burst_data_flag----------------------------------//
    always @(posedge MEM_CLK or negedge RST_N) begin
        if (RST_N == 1'b0) begin
            last_wr_burst_data_flag <= 1'd0;
        end 
        else if ((state == BURST_WR_FIRST_STAGE ||state == BURST_WR_SECOND_STAGE)&& LOCAL_READY) begin
            if(wr_burst_len == 10'd2) begin
                last_wr_burst_data_flag <= 1'd1;
            end 
            else begin 
                last_wr_burst_data_flag <= last_wr_burst_data_flag;
            end
        end 
        else begin
            last_wr_burst_data_flag <= 1'd0;
        end
    end 
    
    //--------assign------------------------------------------------------
    assign RST_DDR_N = RST_N ; 
    assign WR_BURST_DATA_REQ = (((state == BURST_WR_BUFFER_STAGE)||(state == BURST_WR_FIRST_STAGE))||(state == BURST_WR_SECOND_STAGE))&& LOCAL_READY && ~last_wr_burst_data_flag;
    assign LOCAL_WDATA = WR_BURST_DATA ;
    assign LOCAL_WRITE_REQ = ((state == BURST_WR_FIRST_STAGE)||(state == BURST_WR_SECOND_STAGE));
    assign LOCAL_READ_REQ = (state == BURST_RD_MEM);
    assign LOCAL_BE = 4'b1111;

    assign RD_BURST_DATA_VALID = LOCAL_RDATA_VALID;
    assign RD_BURST_DATA = LOCAL_RDATA;

    assign LOCAL_BURSTBEGIN = ((state == BURST_WR_FIRST_STAGE ) || (state == BURST_RD_MEM ));
    assign RD_FINISH = (state == BURST_RD_WAIT)&&(nextstate == IDLE );
    assign WR_FINISH = (state == BURST_WR_FIRST_STAGE || state == BURST_WR_SECOND_STAGE ) && (nextstate == IDLE ) ;
    assign BURST_IDLE = (state == IDLE && nextstate == IDLE && LOCAL_INITIAL_DONE )? 1'b1:1'b0 ;  
    //-------------------------------------------------------------------
endmodule