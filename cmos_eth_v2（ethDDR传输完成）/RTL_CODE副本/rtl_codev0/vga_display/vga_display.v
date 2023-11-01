//`define simulate 
module vga_display(
            input  vga_clk          ,
			input  rstn             ,
			output vga_hs           ,             //行同步信号
			output vga_vs           ,             //列同步信号
			output [4:0] vga_r      ,
			output [5:0] vga_g      ,
			output [4:0] vga_b      ,
            output rfifo_req        ,
            input  [7:0] rfifo_data ,
            input   FIFO_EMPTY      ,
            output  neg_vga_vs      ,            //表征新的一帧图像开始
            output  vga_valid
//          output  vga_rd_done_flag          备用
            
    );
//-----------------------------------------------------------//                    
// 水平扫描参数的设定1280*768 VGA 60FPS_79.5MHz                                    
//-----------------------------------------------------------//                    
parameter LinePeriod =1664;            //行周期数                                 
parameter H_SyncPulse=128;             //行同步脉冲（Sync a）                     
parameter H_BackPorch=192;            //显示后沿（Back porch b）192               
parameter H_ActivePix=1280;            //显示时序段（Display interval c）         
parameter H_FrontPorch=64;            //显示前沿（Front porch d）64               
parameter Hde_start=320;                                                            
parameter Hde_end=1600;                                                             
//-----------------------------------------------------------//                     
// 垂直扫描参数的设定1280*768 VGA 60FPS_79.5MHz                                     
//-----------------------------------------------------------//                     
parameter FramePeriod =798;           //列周期数                                    
parameter V_SyncPulse=7;              //列同步脉冲（Sync o）                        
parameter V_BackPorch=20;             //显示后沿（Back porch p）20                  
parameter V_ActivePix=768;            //显示时序段（Display interval q）            
parameter V_FrontPorch=3;             //显示前沿（Front porch r）3                  
parameter Vde_start=27;               //27                                          
parameter Vde_end=795;                //实际显示798-3                               

//-----------------------------------------------------------//
// 水平扫描参数的设定   1280*800 60hz 83.46MHZ                 
////-----------------------------------------------------------//
//parameter LinePeriod =1680;            //行周期数
//parameter H_SyncPulse=136;             //行同步，VGA显示器所需的行同步脉冲数（Sync a）
//parameter H_BackPorch=200;             //显示后沿（Back porch b）
//parameter H_ActivePix=1280;            //显示时序段（Display interval c）
//parameter H_FrontPorch=64;             //显示前沿（Front porch d）
//parameter Hde_start=336;
//parameter Hde_end=1616;
//
//////-----------------------------------------------------------//
////// 垂直扫描参数的设定  1280*800 60Hz VGA
//////-----------------------------------------------------------//
//parameter FramePeriod =828;           //列周期数
//parameter V_SyncPulse=3;              //列同步，VGA显示器所需的列同步脉冲数（Sync o）
//parameter V_BackPorch=24;             //显示后沿（Back porch p）
//parameter V_ActivePix=800;            //显示时序段（Display interval q）
//parameter V_FrontPorch=1;             //显示前沿（Front porch r）
//parameter Vde_start=27;               //27+16 
//parameter Vde_end=827;                //827-16 811
//-----------------------------------------------------------//
// 水平扫描参数的设定   1280*800 60hz 83.46MHZ                 
////-----------------------------------------------------------//
//parameter LinePeriod =1680;            //行周期数
//parameter H_SyncPulse=136;             //行同步，VGA显示器所需的行同步脉冲数（Sync a）
//parameter H_BackPorch=200;             //显示后沿（Back porch b）
//parameter H_ActivePix=1280;            //显示时序段（Display interval c）
//parameter H_FrontPorch=64;             //显示前沿（Front porch d）
//parameter Hde_start=336;
//parameter Hde_end=1616;
//
//////-----------------------------------------------------------//
////// 垂直扫描参数的设定  1280*800 60Hz VGA
//////-----------------------------------------------------------//
//parameter FramePeriod =828;           //列周期数
//parameter V_SyncPulse=3;              //列同步，VGA显示器所需的列同步脉冲数（Sync o）
//parameter V_BackPorch=24;             //显示后沿（Back porch p）
//parameter V_ActivePix=800;            //显示时序段（Display interval q）
//parameter V_FrontPorch=1;             //显示前沿（Front porch r）
//parameter Vde_start=42;               //27+16 
//parameter Vde_end=811;                //827-16 811
//-----------------------------------------------------------//
// 水平扫描参数的设定        TB    64*48
//-----------------------------------------------------------//
//parameter LinePeriod =75;            //行周期数
//parameter H_SyncPulse=4;             //行同步，VGA显示器所需的行同步脉冲数（Sync a）
//parameter H_BackPorch=5;             //显示后沿（Back porch b）
//parameter H_ActivePix=64;            //显示时序段（Display interval c）
//parameter H_FrontPorch=2;             //显示前沿（Front porch d）
//parameter Hde_start=9;
//parameter Hde_end=73;
//-----------------------------------------------------------//
// 垂直扫描参数的设定       TB  
//-----------------------------------------------------------//
//parameter FramePeriod =59;           //列周期数
//parameter V_SyncPulse=4;             //列同步，VGA显示器所需的列同步脉冲数（Sync o）
//parameter V_BackPorch=5;             //显示后沿（Back porch p）
//parameter V_ActivePix=48;            //显示时序段（Display interval q）
//parameter V_FrontPorch=2;             //显示前沿（Front porch r）
//parameter Vde_start=9;               //27+24 实际显示720
//parameter Vde_end=57;                //51+720个实际显示720
//-----------------------------------------------------------//
//-----------------------------------------------------------//
  reg[10 : 0] x_cnt;
  reg[9 : 0]  y_cnt;
  reg hsync_r;
  reg vsync_r; 
  reg hsync_de;
  reg vsync_de;
  reg vga_vs_d0,vga_vs_d1;
  reg first_word_flag ;
//----------------------------------------------------------------
////////// 水平扫描计数
//----------------------------------------------------------------
always @ (posedge vga_clk)
       if(~rstn)    x_cnt <= 11'd1;             
       else if(x_cnt == LinePeriod) x_cnt <= 11'd1;
       else x_cnt <= x_cnt+ 11'd1;
		 
//----------------------------------------------------------------
////////// 水平扫描信号hsync,hsync_de产生
//----------------------------------------------------------------
always @ (posedge vga_clk)
   begin
       if(~rstn) hsync_r <= 1'b1;                      //低电平有效
       else if(x_cnt == 1) hsync_r <= 1'b0;            //产生hsync信号 136
       else if(x_cnt == H_SyncPulse) hsync_r <= 1'b1;  
		
	    if(~rstn) hsync_de <= 1'b0;
       else if(x_cnt == Hde_start) hsync_de <= 1'b1;   //产生hsync_de信号
       else if(x_cnt == Hde_end) hsync_de <= 1'b0;	
	end

//----------------------------------------------------------------
////////// 垂直扫描计数
//----------------------------------------------------------------
always @ (posedge vga_clk)
       if(~rstn) y_cnt <= 10'd1;
       else if((y_cnt == FramePeriod)&&(x_cnt == LinePeriod)) y_cnt <= 10'd1;
       else if(x_cnt == LinePeriod) y_cnt <= y_cnt+10'd1;

//----------------------------------------------------------------
////////// 垂直扫描信号vsync, vsync_de产生
//----------------------------------------------------------------
always @ (posedge vga_clk)
  begin
       if(~rstn) vsync_r <= 1'b1;
       else if(y_cnt == 1) vsync_r <= 1'b0;    //产生vsync信号
       else if(y_cnt == V_SyncPulse) vsync_r <= 1'b1;
		
	    if(~rstn) vsync_de <= 1'b0;
       else if(y_cnt == Vde_start) vsync_de <= 1'b1;    //产生vsync_de信号
       else if(y_cnt == Vde_end) vsync_de <= 1'b0;	 
  end
//----------------------------------------------------------------
////////// 一帧图像之前提前产生一个ddr读数据
//---------------------------------------------------------------- 
reg first_read ;
always @(posedge vga_clk)
begin
   if (rstn==1'b0) begin
	    first_read<=1'b0;
     end
   else begin
       if ((x_cnt==Hde_start-1'b1) && (y_cnt==Vde_start-1'b1)) //一帧提前产生一个VGA显示数据
	        first_read<=1'b1;
	   else
		    first_read<=1'b0;
	   end
end
//----------------------------------------------------------------
////////// ddr读请求信号产生程序, 8bit 1像素的DDR数据转成2个像素输出
//---------------------------------------------------------------- 
always @(posedge vga_clk)
begin
    if (rstn==1'b0) begin
	    first_word_flag<=1'b0;
     end
    else begin
        if ((x_cnt==Hde_start-3'd5)&&(y_cnt==Vde_start-1'b1)&&~FIFO_EMPTY) //表示在第一页开始前，FIFO是否已经存到了数据，可以读写。
	        first_word_flag <= 1'b1;
	    else if ( neg_vga_vs ) begin
		    first_word_flag <= 1'b0;
	    end
        else begin
		    first_word_flag <= first_word_flag;
	    end
    end
end
reg ddr_rden;
 always @(negedge vga_clk) begin
    if (rstn==1'b0) begin
	 	ddr_rden<=1'b0;
    end
    else begin
	if (first_read) begin                    //如果vga输出有效的图像数据
	    ddr_rden<=1'b1;
    end
	else if (hsync_de && vsync_de) begin                    //如果vga输出有效的图像数据
	    ddr_rden<=1'b1;
    end
	else begin
	    ddr_rden<=1'b0;
	end
	end
end
    //- neg_vga_vs -------------------------------
    always@(posedge	vga_clk or negedge rstn)
    if(rstn == 1'b0)begin
        vga_vs_d0 <= 1'b0;
        vga_vs_d1 <= 1'b0;
    end
    else begin
        vga_vs_d0 <= vsync_r;               //帧图像结束
        vga_vs_d1 <= vga_vs_d0;
	end 
    

    assign neg_vga_vs = (!vga_vs_d0 && vga_vs_d1);
    assign rfifo_req = ddr_rden&&(~FIFO_EMPTY)&&first_word_flag;
    //assign rfifo_req = ddr_rden&&(~FIFO_EMPTY);
    assign vga_hs = hsync_r;
    assign vga_vs = vsync_r; 
    assign vga_valid = hsync_de && vsync_de ;    
    assign vga_r = vga_valid?rfifo_data[7:3]:5'b00000 ;
    assign vga_g = vga_valid?rfifo_data[7:2]:6'b000000;
    assign vga_b = vga_valid?rfifo_data[7:3]:5'b00000 ;

    //assign vga_rd_done_flag = (y_cnt >= 795)? 1'b1:1'b0; 备用 

    //assign rfifo_req = ~FIFO_EMPTY;
    //assign neg_vga_vs = FIFO_EMPTY;
endmodule