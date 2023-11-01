module vsync_pos_switch (
    input wire     i_ddr_clk     ,
    input wire     i_rst_n       ,
    input wire     i_sd_save_key ,
    input wire     i_sel_vsync   ,
    output reg     o_cmos_sel_channal_sw 
);
reg r_sel_vsync_d0,r_sel_vsync_d1;
reg r_save_req;
wire w_pos_sel_vsync ;

always @(posedge i_ddr_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_sel_vsync_d0 <= 1'b0 ;
        r_sel_vsync_d1 <= 1'b0 ;
    end 
    else begin
        r_sel_vsync_d0 <= i_sel_vsync    ;
        r_sel_vsync_d1 <= r_sel_vsync_d0 ;
    end 
end 

always @(posedge i_ddr_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_save_req <= 1'b0 ;
    end 
    else if (i_sd_save_key)begin 
        r_save_req <= 1'b1 ;
    end 
    else if (w_pos_sel_vsync)begin 
        r_save_req <= 1'b0 ;
    end 
    else  begin
        r_save_req <= r_save_req ;
    end 
end 

always @(posedge i_ddr_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_cmos_sel_channal_sw <= 1'b0 ;
    end 
    else if ( w_pos_sel_vsync )begin 
        o_cmos_sel_channal_sw <= r_save_req ;
    end 
    else if ( w_pos_sel_vsync )begin 
        o_cmos_sel_channal_sw <= r_save_req ;
    end 
    else  begin
        o_cmos_sel_channal_sw <= o_cmos_sel_channal_sw ;
    end 
end 

assign  w_pos_sel_vsync = r_sel_vsync_d0 & !r_sel_vsync_d1 ; 

endmodule 