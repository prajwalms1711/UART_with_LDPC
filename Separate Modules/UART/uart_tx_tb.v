module uart_tx_tb();
    reg [7:0] data;  
    reg clk;
    reg reset;
    reg tx_start;
    wire tx , tx_done;
uart_tx u1(data,clk,reset,tx_start,tx , tx_done);
initial begin
clk=1'b1;
forever #5 clk=~clk;
end
initial begin
reset=1'b1;tx_start=1'b1;
#5 reset=1'b0;data=8'b11010101;
end
endmodule
