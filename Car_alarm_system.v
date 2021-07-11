`timescale 10ps/1ps
module Debouncer(in,brk,hids,ign,dd,pd,clk);
 output reg brk,hids,ign,dd,pd;
 input [4:0]in;
 input clk;
 always@(posedge clk)
 begin
   #1 brk<=in[4];
   #1 hids<=in[3];
   #1 ign<=in[2];
   #1 dd<=in[1];
   #1 pd<=in[0];
 end
endmodule

module fuel_pump(ign,hids,brk,clk,power,reset);
 input ign,hids,clk,brk,reset;
 output reg power;
 `define on 1'b1;
 `define off 1'b0;
 reg state;
 always@(posedge clk)
 begin
   if(reset==1'b1)
   begin
     power=`off;
     state=`off;
   end
   if(state == 1'b0)
   begin
     if((ign & hids & brk) == 1'b1) 
     begin
       power=`on;
       state=`on;
     end
   end
   else if (state== 1'b1)
   begin
     if(ign==1'b0)
     begin
       power=`off;
       state=`off;
     end
   end
 end
endmodule

module anti_theft_fsm(ign,dd,pd,st,exp,stat,siren,clk,start,ck,reset);
 input ign,dd,pd,exp,clk,ck,reset;
 output reg siren,stat,start;
 output reg [1:0]st;
 reg [2:0]p_state;
 reg[2:0] star;
 reg [1:0] k=2'd0;
 always@(negedge clk)
 begin
   if(reset==1'b1)
     k=2'd0;
   if(star==1'b1)
   begin
     k=k+2'd1;
     if(k==2'd2)
     begin
       k=2'd0;
       start=1'b1;     
     end
   end 
   else if(star==1'b0)
   begin
     k=1'd0;
     start=1'b0;   
   end
   if(p_state==3'd0)
   begin
    stat<=ck;
   end 
   if(reset==1'b1)
   begin
     p_state<=3'd0;
     st<=2'dz;
     siren<=1'b0;
   end
   if(p_state==3'd0)
    begin
     if((dd==1'b1 | pd==1'b1) & ign==1'b0)
     begin
       star<=1'b1;
       siren<=1'b0;
       if(dd==1'b1 & pd==1'b0)
       st<=2'd1;
       else if(pd==1'b1)
       st<=2'd2;
       p_state<= 3'd4;
     end
     else if(ign==1'b1)
     begin
       star<=1'b0;
       st<=2'dz;
       stat<=1'b0;
       siren<=1'b0;
       p_state<=3'd2;
     end
    end
    else if(p_state==3'd1) 
    begin
      if(dd==1'b0 & pd==1'b0 & ign==1'b0 & siren==1'b1 & exp==1'b1)
      begin
       star<=1'b0;
       st<=2'dz;
       siren<=1'b0;
       stat<=ck;
       p_state<=3'd0;
      end
      else if(ign==1'b1)
      begin
       star<=1'b0;
       st<=2'bz;
       stat<=1'b0;
       siren<=1'b0;
       p_state<=3'd2;
      end
      else if((dd==1'b1 | pd==1'b1) & ign==1'b0 & siren==1'b1)
      begin
       star<=1'b0;
       st<=2'bz;
       stat<=1'b1;
       siren<=1'b1;
       p_state<=3'd5;
      end 
    end
    else if(p_state==3'd2) 
    begin
      if(dd==1'b0 & pd==1'b0 & ign==1'b0 & siren==1'b0)
      begin
       star<=1'b1;
       st<=2'd0;
       stat<=1'b1;
       siren<=1'b0;
       p_state<=3'd7; 
      end
      else if((dd==1'b1 | pd==1'b1) & ign==1'b0 & siren==1'b0)
      begin
       star<=1'b0;
       st<=2'dz;
       stat<=1'b0;
       siren<=1'b0;
       p_state<=3'd4;
     end
    end
    else if(p_state==3'd4) 
    begin
      if(ign==1'b1)
      begin   
       star<=1'b0;
       st<=2'dz;
       stat<=1'b0;
       siren<=1'b0;
       p_state<=3'd2;
      end
      else if((dd==1'b1 | pd==1'b1) & ign==1'b0 & siren==1'b0 & exp==1'b1)
      begin
       star<=1'b0;
       st<=1'bz;
       stat<=1'b1;
       siren<=1'b1;
       p_state<=3'd5;
      end
      else if(dd==1'b0 & pd==1'b0 & ign==1'b0 & siren==1'b0  & start==1'b0)
      begin
       star<=1'b1;
       st<=2'd0;
       stat<=1'b1;
       siren<=1'b0;
       p_state<=3'd7;
      end
      else if(dd==1'b0 & pd==1'b0 & ign==1'b0 & siren==1'b0 & start==1'b1)
      begin
        star<=1'b0;
        siren<=1'b0;
        st<=2'dz;
        stat<=ck;
        p_state<=3'd0;
      end
    end
    else if(p_state==3'd5) 
    begin
     if(ign==1'b1)
     begin
       star<=1'b0;
       st<=2'bz;
       stat<=1'b0;
       siren<=1'b0;
       p_state<=3'd2;
     end
      else if(dd==1'b0 & pd==1'b0 & ign==1'b0  & siren==1'b1)
      begin
       star<=1'b1;
       st<=2'd3;
       stat<=1'b1;
       siren<=1'b1;
       p_state<=3'd1;
      end
    end
    else if(p_state==3'd7) 
    begin
      if(dd==1'b0 & pd==1'b0 & ign==1'b0 & siren==1'b0 & exp==1'b1)
      begin
       star<=1'b0;
       siren<=1'b0;
       st<=2'dz;
       stat<=ck;
       p_state<=3'd0;
      end
      else if((dd==1'b1 | pd==1'b1) & ign==1'b0 & siren==1'b0)
      begin
       star=1'b0;
       stat<=1'b0;
       st<=2'dz;
       siren<=1'b0;
       p_state<=3'd4;
      end
      else if(ign==1'b1)
      begin
       star<=1'b0;
       stat<=1'b0;
       st<=2'dz;
       siren<=1'b0;
       p_state<=3'd2;
      end
    end
  end
endmodule

module divider(clk,ck,reset);
 input reset,clk;
 output reg ck;
 reg p_clk2;
 reg [39:0]cnt2;
 always@(posedge clk)
 begin
  if(reset==1'b1)
  begin
   p_clk2=1'b0;
   cnt2=0;
  end;
  cnt2=cnt2+1;
  if(cnt2==40'd1000000000000)
  begin
   ck=~p_clk2;
   p_clk2=ck;
   cnt2=40'd0;  
  end
 end
endmodule

module Timer(exp,start,clk,st,reset);
 reg [3:0]val;
 reg [1:0]a;
 input [1:0]st;
 input start,clk,reset;
 reg clk_reset;
 output reg exp;
 reg [3:0]count;
 reg [3:0]T_arm_delay=4'd10, T_driver_delay=4'd8, T_pass_delay=4'd15, T_alarm_delay=4'd3;
 reg [38:0] cnt;
 always@(negedge clk)
 begin
   if(exp==1'b1)
   begin
     a<=a+1;
     if(a==2'd3)
     begin
       a<=2'd0;
       exp=1'b0;
     end   
   end
   if(reset==1'b1)
    begin
      val<=T_driver_delay;
      count<=T_driver_delay;
      a<=2'd0;
      cnt=1'b1;
    end 
   case(st)
     2'd0 : begin val<=T_arm_delay; end
     2'd1 : begin val<=T_driver_delay; end
     2'd2 : begin val<=T_pass_delay; end
     2'd3 : begin val<=T_alarm_delay; end
   endcase    
   if(start==1'b0)
   begin
     count<=val;   
   end
   cnt=cnt+1;
   if(cnt==39'd500000000000)
   begin
     if(start==1'b1)
     begin
       count<=count-1;
       if(count==0) 
       begin
         exp=1'b1;
         clk_reset=1'b1;
        end       
     end
     else begin clk_reset=1'b0; exp=1'b0; end
     if(clk_reset==1'b1) begin count<=val; end
     cnt=39'd0;
   end
  end
endmodule

module Car_alarm_system(in,reset,power,siren,stat,clk);
 input reset,clk;
 input [4:0]in;
 output power,siren,stat;
 wire [1:0] st;
 wire ck,dd,pd,brk,hids,ign,exp,start;
 Debouncer D1(in,brk,hids,ign,dd,pd,clk);
 fuel_pump f1(ign,hids,brk,clk,power,reset);
 anti_theft_fsm a1(ign,dd,pd,st,exp,stat,siren,clk,start,ck,reset); 
 Timer tim(exp,start,clk,st,reset);
 divider d1(clk,ck,reset);
endmodule

