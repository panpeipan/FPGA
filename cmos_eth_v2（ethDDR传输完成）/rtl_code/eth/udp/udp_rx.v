`timescale  1ns/1ns                     //定义仿真时间单位1ns和仿真时间精度为1ns
module  udp_rx
#(
	parameter   BOARD_MAC = 48'h001122334455,
	parameter   BOARD_IP  = {8'd192,8'd168,8'd1,8'd10},
	parameter   DES_MAC   = 48'hffffffffffff,
	parameter   DES_IP    = {8'd192,8'd168,8'd1,8'd102},
	parameter   BOARD_PORTNUM = 16'd1010
)(
    input   wire          i_sys_rstn    ,
    input   wire          i_gmii_rx_clk ,
    input   wire          i_gmii_rx_dv  ,
    input   wire  [7:0]   i_gmii_rx_data,
	output  reg           o_udp_rec_done,
	output  reg           o_rec_dvalid  ,
	output  reg   [7:0]   o_rec_data    ,
	output  reg   [15:0]  o_rec_data_num
);

reg   [ 2:0]   state            ; 
reg   [ 9:0]   r_cnt            ;
//reg            r_error          ;
reg   [47:0]   r_desmac_addr    ;
reg   [47:0]   r_srcmac_addr    ;
reg   [15:0]   r_eth_length     ;
reg   [15:0]   r_total_len      ;  
//reg   [ 7:0]   r_type_service   ;
reg   [15:0]   r_identification ;
//reg   [ 3:0]   r_flags          ;
//reg   [11:0]   r_fragment_offset;
//reg   [ 7:0]   r_time2live      ;
//reg   [ 7:0]   r_protcol        ;
reg   [15:0]   r_headr_checksum ;
reg   [31:0]   r_srcip_addr     ;
reg   [31:0]   r_desip_addr     ;
reg   [15:0]   r_src_portnum    ;
reg   [15:0]   r_des_portnum    ;
reg   [15:0]   r_udp_len        ;
//reg   [15:0]   r_udp_checksum   ;
reg   [15:0]   r_data_cnt       ;
reg   [1: 0]   r_rec_sel        ;
//reg   [ 3:0]   r_fcs            ;

//---------------------------------------------
//参数
localparam     TYPE_IPV4      =   16'h0800;
localparam     VERSION_IPV4   =   4'b0100 ;
localparam     INF_HEAD_LEN   =   4'd5    ;
localparam     PROTCOL_UDP    =   8'd17   ;

//状态机
localparam     ST_IDLE        =   3'd0;
localparam     ST_PREA        =   3'd1;
localparam     ST_ETH_HEAD    =   3'd2;
localparam     ST_IP_HEAD     =   3'd3;
localparam     ST_UDP_HEAD    =   3'd4;
localparam     ST_UDP_DATA    =   3'd5;
localparam     ST_RX_DONE     =   3'd6;

always@(posedge i_gmii_rx_clk or negedge i_sys_rstn)begin 
    if(!i_sys_rstn)begin 
	    state            <= ST_IDLE ;
		r_cnt            <= 'd0     ;
        //r_error          <= 'd0     ;
        r_desmac_addr    <= 'd0     ;
        r_srcmac_addr    <= 'd0     ;
        r_eth_length     <= 'd0     ;
        //r_total_len      <= 'd0     ;
        //r_type_service   <= 'd0     ;
        r_identification <= 'd0     ;
        //r_flags          <= 'd0     ;
        //r_fragment_offset<= 'd0     ;
        //r_time2live      <= 'd0     ;
        //r_protcol        <= 'd0     ;
        r_headr_checksum <= 'd0     ;
        r_srcip_addr     <= 'd0     ;
        r_desip_addr     <= 'd0     ;
        r_src_portnum    <= 'd0     ;
        r_des_portnum    <= 'd0     ;
        //r_udp_checksum   <= 'd0     ;
		o_udp_rec_done   <= 'd0     ;
		o_rec_dvalid     <= 'd0     ;
		o_rec_data       <= 'd0     ;
		o_rec_data_num   <= 'd0     ;
	end 
	else begin 
	    //r_error <= 1'b0 ;
	    case (state) 
		ST_IDLE: begin 
		    if(i_gmii_rx_dv&&i_gmii_rx_data==8'h55)begin 
			    state <= ST_PREA ;
				r_cnt <= 'd0     ;
            end 
            else begin  
			    state <= ST_IDLE ;
            end 
		end  
		ST_PREA: begin 
		    if(r_cnt <= 10'd5)begin 
		        if(i_gmii_rx_dv && i_gmii_rx_data == 8'h55)begin
				    state <= ST_PREA ;
					r_cnt <= r_cnt + 10'd1;
                end 				 
				else begin 
				    state <= ST_RX_DONE ;
					r_cnt <= 'd0;
					//r_error <= 1'b1     ;
				end 
		    end 
			else if (r_cnt == 10'd6) begin 
			    if(i_gmii_rx_dv && i_gmii_rx_data == 8'hd5)begin 
				    state <= ST_ETH_HEAD ;
					r_cnt <= 'd0;
				end 
				else begin 
				    state <= ST_RX_DONE ;
					//r_error <= 1'b1 ;
				end 
			end 
		end 
		ST_ETH_HEAD: begin 
		    if(i_gmii_rx_dv)begin 
		        if(r_cnt<10'd5)begin 
			        r_desmac_addr <= {r_desmac_addr[39:0],i_gmii_rx_data};
			    	r_cnt <= r_cnt + 10'd1 ;
			    end 
			    else if(r_cnt == 10'd5)begin 
			    	if(({r_desmac_addr[39:0],i_gmii_rx_data}==BOARD_MAC)||({r_desmac_addr[39:0],i_gmii_rx_data}==48'hffff_ffff_ffff))begin 
			            r_cnt <= r_cnt + 10'd1 ;
			            r_desmac_addr <= {r_desmac_addr[39:0],i_gmii_rx_data};
			    	end 
                    else begin
			    	    state <= ST_RX_DONE ;
			    		r_cnt <= 'd0;
                    end
			    end 
			    else if (r_cnt > 10'd5 && r_cnt <= 10'd11)begin 
			        r_cnt <= r_cnt + 10'd1 ;
			    	r_srcmac_addr <= {r_srcmac_addr[39:0],i_gmii_rx_data};
			    end 
                else if (r_cnt == 10'd12) begin
                    r_eth_length[15:8] <= i_gmii_rx_data ;
                    r_cnt <= r_cnt + 10'd1 ;
                end 
                else if (r_cnt == 10'd13) begin
                    r_eth_length[7:0] <= i_gmii_rx_data ;
                    if ({r_eth_length[15:8],i_gmii_rx_data} != 16'h0800) begin
                        state <= ST_RX_DONE ;
                        r_cnt <= 'd0;
                    end 
                    else begin
                        state <= ST_IP_HEAD ;
                        r_cnt <= 'd0;
                    end
                end
			    else begin 
			        state <= ST_RX_DONE ;
			    	//r_error <= 1'b1 ;
                    r_cnt <= 'd0;
			    end 
		    end 
		end 
		ST_IP_HEAD: begin 
		    if(i_gmii_rx_dv)begin 
		        if(r_cnt == 10'd0)begin 
			        r_cnt <= r_cnt + 10'd1 ; 
			        if(i_gmii_rx_data[7:4]!=VERSION_IPV4)begin 
			    	    state <= ST_RX_DONE ;
			    		//r_error <= 1'b1 ;
			    	end 
			    	if(i_gmii_rx_data[3:0]!=INF_HEAD_LEN)begin 
			    	    state <= ST_RX_DONE;
			    		//r_error <= 1'b1 ;
			    	end 
			    end 
			    else if(r_cnt == 10'd1)begin 
			        r_cnt <= r_cnt + 10'd1 ;
			    	//r_type_service <= i_gmii_rx_data;
			    end 
			    else if(r_cnt > 10'd1 && r_cnt <= 10'd3)begin 
			        r_cnt <= r_cnt + 10'd1 ;
			        //r_total_len <= {//r_total_len[7:0],i_gmii_rx_data};
			    end 
			    else if(r_cnt > 10'd3 && r_cnt <= 10'd5)begin 
                    r_cnt <= r_cnt + 10'd1 ;
			    	r_identification <= {r_identification[7:0],i_gmii_rx_data};
                end
                else if(r_cnt == 10'd6)begin 
                    r_cnt <= r_cnt + 10'd1 ;
			    	//r_flags <= i_gmii_rx_data[7:4];
			    	//r_fragment_offset[11:8] <= i_gmii_rx_data[3:0]; 
                end  	
                else if(r_cnt == 10'd7)begin 
                    r_cnt <= r_cnt + 10'd1 ;
			    	//r_fragment_offset[7:0] <= i_gmii_rx_data;
                end  
                else if(r_cnt == 10'd8)begin 
                    r_cnt <= r_cnt + 10'd1 ;
			    	//r_time2live <= i_gmii_rx_data ;
			    	if(i_gmii_rx_data == 0)begin 
			    	    state <= ST_RX_DONE ;
			    		//r_error <= 1'b1 ;
			    	end 
                end  
                else if(r_cnt == 10'd9)begin 
                    r_cnt <= r_cnt + 10'd1 ;
			    	//r_protcol <= i_gmii_rx_data;
			    	if(i_gmii_rx_data != PROTCOL_UDP) begin 
			    	    state <= ST_RX_DONE ;
			    		//r_error <= 1'b1 ;
			    	end 
                end  
                else if(r_cnt > 10'd9 && r_cnt <= 10'd11 )begin 
			        r_cnt <= r_cnt + 10'd1 ;
                    r_headr_checksum <= {r_headr_checksum[7:0],i_gmii_rx_data};
                end  
                else if(r_cnt > 10'd11 && r_cnt <= 10'd15 )begin
                    r_cnt <= r_cnt + 10'd1 ;				
                    r_srcip_addr <= {r_srcip_addr[23:0],i_gmii_rx_data};
                end 
                else if(r_cnt > 10'd15 && r_cnt <= 10'd18 )begin 
                    r_cnt <= r_cnt + 10'd1 ;
			    	r_desip_addr <= {r_desip_addr[23:0],i_gmii_rx_data};
                end 
			    else if(r_cnt == 10'd19)begin 
			        r_cnt <= 10'd0;
			    	r_desip_addr <= {r_desip_addr[23:0],i_gmii_rx_data};
			        if({r_desip_addr[23:0],i_gmii_rx_data}!=BOARD_IP)begin 
			    	    state <= ST_RX_DONE ;
			    	    //r_error <= 1'b1 ;
			    	end 
			    	else begin 
			    	    state <= ST_UDP_HEAD ;
			    	end 
			    end 
			    else begin 
			        state <= ST_RX_DONE ;
			    	//r_error <= 1'b1 ;
			    end 
			end 
		end  
		ST_UDP_HEAD: begin 
			if(i_gmii_rx_dv)begin 
		        if(r_cnt == 10'd0 || r_cnt == 10'd1)begin 
			        r_cnt <= r_cnt + 10'd1 ;
			    	r_src_portnum<={r_src_portnum[7:0], i_gmii_rx_data };
			    end 
			    else if (r_cnt == 10'd2)begin 
			    	r_cnt <= r_cnt + 10'd1 ;
			        r_des_portnum[15:8] <= i_gmii_rx_data ;
                end 
                else if (r_cnt == 10'd3) begin
                    if ({r_des_portnum[15:8],i_gmii_rx_data}!= BOARD_PORTNUM) begin
                        r_cnt <= 'd0;
                        state <= ST_RX_DONE ;
                        //r_error <= 1'b1 ;
                    end 
                    else begin
                        r_des_portnum[7:0] <= i_gmii_rx_data ;
                        r_cnt <= r_cnt + 10'd1 ;
                    end
			    end 
			    else if (r_cnt == 10'd4||r_cnt == 10'd5)begin 
			    	r_cnt <= r_cnt + 10'd1 ;
			    end 
			    else if (r_cnt == 10'd6)begin 
                    r_cnt <= r_cnt + 10'd1 ;
					o_rec_data_num <= r_udp_len - 10'd8;
			        //r_udp_checksum[15:8] <= i_gmii_rx_data ;
			    end 
                else if (r_cnt == 10'd7) begin
                    r_cnt <= 10'd0;
                    //r_udp_checksum[7:0] <= i_gmii_rx_data ;
                    state <= ST_UDP_DATA ;
                end
			    else begin 
			        state <= ST_RX_DONE ; 
			    	//r_error <= 1'b1 ;
			    end 
			end 
		end 
		ST_UDP_DATA: begin 
		    if(i_gmii_rx_dv)begin 
		        if(r_data_cnt>0)begin 
			        o_rec_data   <= i_gmii_rx_data     ;
			        o_rec_dvalid <= 1'b1               ;
			    end  
                else if (r_udp_len>0) begin
                    o_rec_dvalid <= 1'b0               ;
                end 
                else begin 
                    o_rec_dvalid   <= 1'b0       ;
			    end 
			end 
			else begin 
			    state          <= ST_RX_DONE ; 
				o_udp_rec_done <= 1'b1       ;
			end 
		end 
		ST_RX_DONE: begin 
            if(i_gmii_rx_dv)begin 
			    state <= ST_RX_DONE ;
			end 
			else begin 
	            state            <= ST_IDLE ;
		        r_cnt            <= 'd0     ;
                //r_error          <= 'd0     ;
                r_desmac_addr    <= 'd0     ;
                r_srcmac_addr    <= 'd0     ;
                r_eth_length     <= 'd0     ;
                //r_total_len      <= 'd0     ;
                //r_type_service   <= 'd0     ;
                r_identification <= 'd0     ;
                //r_flags          <= 'd0     ;
                //r_fragment_offset<= 'd0     ;
                //r_time2live      <= 'd0     ;
                //r_protcol        <= 'd0     ;
                r_headr_checksum <= 'd0     ;
                r_srcip_addr     <= 'd0     ;
                r_desip_addr     <= 'd0     ;
                r_src_portnum    <= 'd0     ;
                r_des_portnum    <= 'd0     ;							
                //r_udp_checksum   <= 'd0     ;							
		        o_udp_rec_done   <= 'd0     ;				
		        o_rec_dvalid     <= 'd0     ;				
		        o_rec_data       <= 'd0     ;				
		        o_rec_data_num   <= 'd0     ;				
			end 
		end  
		default: begin 
		    state <= ST_IDLE;
		end 
    endcase 
	end 
end 
	
always@(posedge i_gmii_rx_clk or negedge i_sys_rstn)begin 
    if(!i_sys_rstn)begin 
        r_udp_len <= 16'd0 ;
    end 
    else if (state == ST_UDP_HEAD && (r_cnt == 10'd4||r_cnt == 10'd5))begin 
        r_udp_len <= {r_udp_len [7:0] ,i_gmii_rx_data};
    end 
    else if (state == ST_UDP_DATA && r_udp_len > 16'd0)begin 
        r_udp_len <= r_udp_len - 16'd1;
    end
    else if (state == ST_RX_DONE && !i_gmii_rx_dv )begin 
        r_udp_len <= 16'd0 ;
    end 
    else begin
        r_udp_len <= r_udp_len ;
    end 
end     
 
always@(posedge i_gmii_rx_clk or negedge i_sys_rstn)begin 
    if(!i_sys_rstn)begin 
        r_data_cnt <= 16'd0 ;
    end 
    else if (state == ST_UDP_HEAD && r_cnt == 10'd6)begin 
        r_data_cnt <= r_udp_len - 10'd8 ;
    end 
    else if (state == ST_UDP_DATA && r_data_cnt > 16'd0) begin
        r_data_cnt <= r_data_cnt - 16'd1 ;
    end 
    else if (state == ST_RX_DONE && !i_gmii_rx_dv )begin 
        r_data_cnt <= 16'd0 ;
    end  
    else begin 
        r_data_cnt <= r_data_cnt ;
    end 
end 
endmodule 
