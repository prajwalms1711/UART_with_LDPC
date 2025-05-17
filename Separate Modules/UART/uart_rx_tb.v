module uart_rx_tb();
    reg rx;  
    reg clk;
    reg reset;
    wire [7:0] data_out;
    wire rx_done;
uart_rx u2(rx,clk,reset,data_out,rx_done);
initial begin
clk=1'b1;
forever #5 clk=~clk;
end
initial begin
reset=1'b1;
#10 reset=1'b0;
#10 rx=1'b0;#10 rx=1'b1;#10 rx=1'b1;#10 rx=1'b0;#10 rx=1'b0;#10 rx=1'b1;#10 rx=1'b1;#10 rx=1'b0;#10 rx=1'b0;
end
endmodule
