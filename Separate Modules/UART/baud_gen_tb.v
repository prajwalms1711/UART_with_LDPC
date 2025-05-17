module baud_gen_tb;
    reg clk;        
    reg rst_n;        
    reg [15:0] divisor; 
    wire baud_clk;
    baud_gen uut (
        clk,rst_n,divisor,baud_clk
    );
    initial begin
       rst_n=1'b1;
       clk=0;  
   #10 rst_n=1'b0;
       divisor = 2604;
    end
    always begin
    #10 clk=~clk;
    end
endmodule
