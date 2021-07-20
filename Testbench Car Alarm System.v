`timescale 10ps/1ps
module stimulus();
 reg [4:0]In;
 reg clock,reset;
 wire expire,ignition,brake,hid_switch,d_d,p_d;
 wire power,Status_ind,Siren,ck;
 wire [1:0]state;
 wire [3:0]count;
 wire [39:0]cnt2;
 initial
 clock=1'b0;
 initial
 #1000000000 $finish;
 always
 begin
   #2 clock=~clock;
 end
 Debouncer D1(In,brake,hid_switch,ignition,d_d,p_d,clock);
 fuel_pump f1(ignition,hid_switch,brake,clock,power,reset);
 anti_theft_fsm a1(ignition,d_d,p_d,state,expire,Status_ind,Siren,clock,start,ck,reset);//here state stands for start timer 
 Timer tim(expire,start,clock,state,reset);
 divider d1(clock,ck,reset,p_clk2,cnt2);
 initial
 begin
   $monitor("brake=%b, hidden switch=%b, ignition=%b, dd=%b, pd=%b, clock=%b, state=%b, power=%b, ep=%b, status=%b, siren=%b, start=%b, reset=%b, ck=%b, p_clk2=%b, cnt2=%b",brake,hid_switch,ignition,d_d,p_d,clock,state,power,expire,Status_ind,Siren,start,reset,ck,p_clk2,cnt2);
   $dumpfile("atf.vcd");
   $dumpvars(0,stimulus);
   In=5'b00000;
   reset=1'b0;
   #10000 reset=1'b1;
   #10000 reset=1'b0;
   #800000 In=6'b00010;
   #60000 In=6'b00001;
   #40000 In=6'b00011;
   #40000 In=6'b00101;
   #40000 In=6'b00110;
   #40000 In=6'b00111;
   #40000 In=6'b00100;
   #40000 In=6'b10100;
   #40000 In=6'b01100;
   #40000 In=6'b11100;
   #40000 In=6'b00000;
   #40000 In=6'b11111;
   #40000 In=6'b00100;
   #40000 In=6'b00000;
   #2060000 In=6'b00010;
   #600000 In=6'b00010;
   #2000000 In=6'b00000;

  end
endmodule