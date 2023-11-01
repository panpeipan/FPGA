module bank_switch 
(
    input wire phy_clk,
    input wire sys_rstn,

    input wire camera_valid,      //flag :camera will trans an new image | from camera camera_vsync
    input wire frame_wr_done,     //from ddr ddr2R_fifo.v
    input wire frame_rd_done,     //from ddr ddr2W_fifo.v
    //
    output reg [1:0] wr_bank,           //ddr_width is 25bit,bank bit is [24][23]
    output reg wr_load,           //
    output reg [1:0] rd_bank,           //to ddrw_fifo.v
    output reg rd_load           //to ddrw_fifo.v
);

//reg bank_valid_d0,bank_valid_d1;
//wire bank_switch_flag;
//always @(posedge phy_clk or negedge sys_rstn) begin
//    if (sys_rstn == 1'b0) begin
//        bank_valid_d0 <= 1'b0;
//        bank_valid_d1 <= 1'b0;
//    end
//    else begin
//        bank_valid_d0 <= camera_valid;
//        bank_valid_d1 <= bank_valid_d0;
//    end
//end
//
//assign bank_switch_flag = (~bank_valid_d1 & bank_valid_d0) ? 1'b1:1'b0; //pos 
//-------------------------------------------------------
//  write_pingpong
//-------------------------------------------------------
reg [2:0] state_wr;
always @(posedge phy_clk or negedge sys_rstn) begin
    if (sys_rstn == 1'b0) begin
        wr_bank <= 2'b0;
        wr_load <= 1'b0;
        state_wr <= 3'd0;
    end 
    else begin
        case (state_wr)
            3'd0: begin
                wr_load <= 1'b0;
                state_wr <= 3'd1;
            end
            3'd1: begin
                wr_load <= 1'b1;          //load bank_address
                state_wr <= 3'd2;
            end
            3'd2: begin
                wr_load <= 1'b0;
                state_wr <= 3'd3;
            end 
            //3'd3:begin 
            //    if (bank_switch_flag) begin    //when camera transfers next image , it will switch bank
            //        state_wr <= 3'd4;
            //    end 
            //    else begin
            //        state_wr <= 3'd3;
            //    end
            //end  
            3'd3:begin 
                if (frame_wr_done) begin       //waiting for the last fifo data
                    state_wr <= 3'd0;
                    wr_bank <= wr_bank + 2'd1;
                end 
                else begin
                    state_wr <= 3'd3;
                end
            end 
            default: begin
                wr_bank <= 2'd0;
                wr_load <= 1'b0;
                state_wr <= 3'd0;
            end
        endcase
    end
end
//--------------------------------------------------------//
//read-pingpong
reg [2:0] state_rd;
always @(posedge phy_clk or negedge sys_rstn) begin
    if (sys_rstn==1'b0) begin
        rd_bank <= 2'd0;
        rd_load <= 1'b0;
        state_rd <= 3'd0;
    end 
    else begin
        case (state_rd)
            3'b0: begin
                rd_load <= 1'b1;
                state_rd <= 3'd1;
            end
            3'd1: begin
                rd_load <= 1'b0;
                state_rd <= 3'd2;
            end
           // 3'd2: begin 
           //     if (frame_wr_done) begin    //when camera transfers next image , it will switch bank
           //         state_rd <= 3'd3;
           //         rd_load <= 1'b0;
           //     end 
           //     else begin
           //         state_rd <= 3'd2;
           //     end
           // end  
            3'd2:begin 
                if (frame_rd_done) begin
                    state_rd <= 3'd0;
                    rd_load <= 1'b0;
                    if (wr_bank==2'b00)begin
                        rd_bank <= 2'b11;
                    end
                    else if (wr_bank==2'b01)begin
                        rd_bank <= 2'b00;
                    end
                    else if (wr_bank==2'b10)begin
                        rd_bank <= 2'b01;
                    end
                    else if (wr_bank==2'b11)begin
                        rd_bank <= 2'b10;
                    end 
                end 
                else begin
                    rd_bank <= rd_bank;
                    state_rd <= 3'd2;
                end
            end 
            default: begin
                rd_bank <= 1'b1;
                rd_load <= 1'b0;
                state_rd <= 3'd0;
            end
        endcase
    end
end




endmodule
