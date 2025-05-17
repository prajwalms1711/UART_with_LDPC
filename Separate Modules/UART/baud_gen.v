module baud_gen (
    input wire clk,           // System clock input
    input wire rst_n,         // Active-low reset
    input wire [15:0] divisor, // Divisor to control baud rate
    output reg baud_clk       // Generated baud rate clock
);

    reg [15:0] counter;       // Counter to divide system clock

    // Always block triggered on rising edge of system clock
    always @(posedge clk) begin
        if (rst_n) begin
            // When reset is active, clear counter and baud_clk
            counter <= 0;
            baud_clk <= 0;
        end else begin
            // Check if counter has reached the divisor value - 1
            if (counter == divisor - 1) begin
                counter <= 0;           // Reset counter
                baud_clk <= ~baud_clk; // Toggle the baud clock
            end else begin
                counter <= counter + 1; // Increment counter
            end
        end
    end
endmodule
