module top_main_tb;
    reg clk;
    reg rst;
    reg [7:0] m;
    reg tx_start;
    wire tx;
    wire tx_done;
    wire rx;
    wire rx_done;
    wire [7:0] message;

    // DUT
    top_main uut (
        .clk(clk), .rst(rst), .m(m), .tx_start(tx_start),
        .tx(tx), .tx_done(tx_done), .rx(rx), .rx_done(rx_done), 
        .message(message)
    );

    // Loopback
    assign rx = tx;

    // Clock generation (100 MHz)
    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        tx_start = 0;
       // m = 8'b11010101;
         m = 8'b11011101;
        #105000;         // Reset time
        rst = 0;
        tx_start = 1;
        
end
endmodule
