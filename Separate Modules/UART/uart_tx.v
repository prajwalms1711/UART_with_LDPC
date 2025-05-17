module uart_tx (    
    input [7:0] data,        // Parallel data to be transmitted
    input baud_clk,          // Baud rate clock
    input reset,             // Asynchronous reset
    input tx_start,          // Transmission start signal
    output reg tx,           // Serial output line
    output reg tx_done       // Transmission complete flag
); 

// UART Transmitter FSM States
localparam [1:0] 
    idle  = 2'b00,  // Idle state (line held high)
    start = 2'b01,  // Send start bit (logic 0)
    trans = 2'b10,  // Send data bits (LSB first)
    stop  = 2'b11;  // Send stop bit (logic 1)

reg [1:0] PS, NS;        // Present State and Next State
reg [3:0] count;         // Bit counter (0-7 for 8 bits)
reg [7:0] temp_data;     // Temporary register for shifting data bits

// State transition logic
always @ (posedge baud_clk or posedge reset) begin
    if (reset) 
        PS <= idle; 
    else 
        PS <= NS; 
end 

// Next state logic
always @* begin
    case (PS) 
        idle  : NS = tx_start ? start : idle;     // Wait for start signal
        start : NS = trans;                       // After start bit, go to transmit data
        trans : NS = (count == 7) ? stop : trans; // After 8 bits, go to stop bit
        stop  : NS = idle;                        // Return to idle after stop bit
        default: NS = idle; 
    endcase 
end

// Output logic and data handling
always @ (posedge baud_clk or posedge reset) begin
    if(reset) begin
        tx         <= 1'b1;      // Line idle (high)
        tx_done    <= 1'b0;      // Clear transmission done flag
        count      <= 4'b0;      // Reset bit counter
        temp_data  <= 8'b0;      // Clear temporary data
    end else begin
        case (PS) 
            idle : begin
                tx      <= 1'b1;  // Keep line high
                tx_done <= 1'b0;
            end

            start : begin
                tx         <= 1'b0;    // Start bit (logic 0)
                temp_data  <= data;    // Load data to be transmitted
                count      <= 4'b0;
                tx_done    <= 1'b0;
            end

            trans : begin
                tx         <= temp_data[0];                   // Transmit LSB
                temp_data  <= {1'b0, temp_data[7:1]};         // Shift data right
                count      <= count + 1;
                tx_done    <= 1'b0;
            end

            stop : begin
                tx      <= 1'b1;  // Stop bit (logic 1)
                tx_done <= 1'b1;  // Transmission complete
            end

            default : begin
                tx      <= 1'b1;
                tx_done <= 1'b0;
            end
        endcase 
    end
end

endmodule
