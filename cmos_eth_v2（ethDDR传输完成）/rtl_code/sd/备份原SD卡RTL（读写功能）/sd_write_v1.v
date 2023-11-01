`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    sd_write 
//////////////////////////////////////////////////////////////////////////////////
module sd_write_v1(  
        input                   clk_25m         ,
		output reg              sd_cs           ,
		output reg              sd_mosi         ,
		input                   sd_miso         ,
		input                   init            ,
		input [31:0]            sec             ,            //写SD的sec地址
		input                   wr_start_en     ,             //写SD卡请求
        output reg              wr_busy         ,
		output reg              rx_valid        ,     
        input  wire [15:0]      wr_data         ,
        output reg              wr_req          ,                        
		output reg              sd_block_wdone
    );
	 
wire [3:0] mystate_o;

reg [7:0] rx;
reg [3:0] mystate;
reg en;

reg [5:0] aa;	 
reg [21:0] cnt;

reg [7:0] write_data;

reg [47:0] CMD24={8'h58,8'h00,8'h00,8'h00,8'h00,8'hff};//block写命令CMD24的字节序列
reg [7:0] Sblock_token=8'hfe;                  //令牌字

reg [7:0] CMDX;
reg [7:0] CMDY=8'hff;
reg [2:0] cnta;

parameter idle=4'd0;
parameter write_cmd=4'd1;
parameter wait_8clk=4'd2;
parameter start_taken=4'd3;
parameter writea=4'd4;
parameter write_crc=4'd5;
parameter write_wait=4'd6;
parameter write_done=4'd7;
	 
always @(posedge clk_25m)
begin
	rx[0]<=sd_miso;
	rx[7:1]<=rx[6:0];
end

//接收SD卡的应答数据
always @(posedge clk_25m)
begin
	if(!sd_miso&&!en)begin rx_valid<=1'b0; aa<=1;en<=1'b1;end      //等待SD_dataout为低,SD_dataout为低,开始接收数据
   else if(en)	begin 
		if(aa<7) begin
			aa<=aa+1'b1; 
			rx_valid<=1'b0;
		end
		else begin
			aa<=0;
			en<=1'b0;
			rx_valid<=1'b1;             //接收完第8bit后,rx_valid信号开始有效
		end
	end
	else begin en<=1'b0;aa<=0;rx_valid<=1'b0;end
end
reg [3:0] bit_cnt;
reg [8:0] data_cnt ;
reg [15:0] wr_data_t ;
//SD卡写程序
always @(negedge clk_25m)
if(!init)
	begin
		mystate<=idle;
		CMD24<={8'h58,8'h00,8'h00,8'h00,8'h00,8'hff};
		sd_block_wdone<=1'b0;
	end
else
	begin
    wr_req <= 1'b0 ;
	case(mystate)
		idle:	begin
                wr_busy <= 1'b0 ;
				sd_cs<=1'b1;
				sd_mosi<=1'b1;
				cnt<=22'd0;		
                bit_cnt <= 4'd0 ;                
				if(wr_start_en) begin          //如果有写请求	
                        wr_busy <= 1'b1 ;                
						mystate<=write_cmd;
						CMD24<={8'h58,sec[31:24],sec[23:16],sec[15:8],sec[7:0],8'hff};
						Sblock_token<=8'hfe;
						sd_block_wdone<=1'b0;
					end
				else mystate<=idle;
		end
		write_cmd: begin                    //发送CMD24命令 (single Block write)	
			   if(CMD24!=48'd0) begin
					sd_cs<=1'b0;
					sd_mosi<=CMD24[47];
					CMD24<={CMD24[46:0],1'b0};     //移位输出,高位在先						
				end
				else begin 
				   if(rx_valid) begin         //等待应答信号			
						cnta<=7;
						mystate<=wait_8clk;
						sd_cs<=1'b1;
					   sd_mosi<=1'b1;					
					end
				end
		end
		wait_8clk: begin                     //写数据之前等待8clock
			 if(cnta>0) begin
					 cnta<=cnta-1'b1;
					 sd_cs<=1'b1;
					 sd_mosi<=1'b1;
			 end
			 else begin
					 sd_cs<=1'b1;
					 sd_mosi<=1'b1;
					 mystate<=start_taken;
					 cnta<=7;
			 end
		end		
		start_taken: begin             //发送Start Block Taken
			 if(cnta>0) begin
					 cnta<=cnta-1'b1;
					 sd_cs<=1'b0;
					 sd_mosi<=Sblock_token[cnta];         //高位在先发送
			 end
			 else begin
					 sd_cs<=1'b0;
					 sd_mosi<=Sblock_token[0];
					 mystate<=writea;
                     wr_req <= 1'b1 ;
					 cnta<=15;
					 cnt<=0;
                     bit_cnt <= 4'd0 ;
                     data_cnt <= 9'd0 ;
				end
		end
		writea: begin             //写512个字节(0~255,0~255)到SD卡
                bit_cnt <= bit_cnt + 4'd1;                     
                if(bit_cnt == 4'd0) begin                      
                    sd_mosi <= wr_data[4'd15-bit_cnt];      //先发送数据高位     
                    wr_data_t <= wr_data;                   //寄存数据   
                end                                            
                else                                           
                    sd_mosi <= wr_data_t[4'd15-bit_cnt];    //先发送数据高位
//----------------------------------------------------------------------、、
                if((bit_cnt == 4'd14) && (data_cnt < 9'd255)) 
                    wr_req <= 1'b1;                          
                if(bit_cnt == 4'd15) begin                     
                    data_cnt <= data_cnt + 9'd1;  
                    //写入单个BLOCK共512个字节 = 256 * 16bit             
                    if(data_cnt == 9'd255) begin
                        data_cnt <= 9'd0;            
                        //写入数据完成,控制计数器加1   
                        mystate<=write_crc;                        
                    end                                        
                end      
		end
		write_crc: begin               //写crc:0xff,0xff
				if(cnt<16) begin
					 sd_cs<=1'b0;
					 sd_mosi<=1'b1;
					 cnt<=cnt+1'b1;
				 end
				 else begin
				    if(rx_valid)         //等待Data Response Token
							mystate<=write_wait;
					 else
							mystate<=write_crc;					 
				end
		end
		write_wait: begin               //等待数据写入完成,
				if(rx==8'hff) begin
					mystate<=write_done;	 
				end
				else begin 
					mystate<=write_wait;
				end
		end
		write_done:begin
			  if(cnt<22'd15) begin      //等待15个clock
				sd_cs<=1'b1;
				sd_mosi<=1'b1;
				cnt<=cnt+1'b1;
			  end
			  else begin
				mystate<=idle;
                wr_busy <= 1'b0;
				sd_block_wdone<=1'b1;	
                cnt<=0;
           end					
		end		
		default:mystate<=idle;
		endcase		
	end					
	

endmodule
