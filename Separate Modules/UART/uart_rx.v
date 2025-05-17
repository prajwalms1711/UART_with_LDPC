module uart_rx (    
    input rx,                // Serial data input
    input clk,               // Clock (ideally baud rate clock)
    input reset,             // Asynchronous reset
    output reg [7:0] data_out, // Output parallel data (8-bit)
    output reg rx_done       // High when data reception is complete
); 

// UART Receiver State Machine States
localparam [1:0] 
    idle  = 2'b00,  // Waiting for start bit
    start = 2'b01,  // Start bit received
    trans = 2'b10,  // Data bits receiving
    stop  = 2'b11;  // Stop bit received

reg [1:0] PS, NS;        // Present and Next state
reg [3:0] count;         // Bit counter (0 to 7 for 8-bit data)
reg [7:0] temp_data;     // Temporary shift register to collect received bits

// State update logic (sequential block)
always @(posedge clk or posedge reset) begin
    if (reset) 
        PS <= idle; 
    else 
        PS <= NS; 
end 

// Next state logic (combinational block)
always @* begin
    case (PS) 
        idle  : NS = (rx == 1'b0) ? start : idle; // Start bit is logic 0
        start : NS = trans;                      // Move to data reception
        trans : NS = (count == 7) ? stop : trans;// After 8 bits, go to stop
        stop  : NS = idle;                       // Go back to idle
        default: NS = idle; 
    endcase 
end

// Output and data handling logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        data_out <= 8'b0;
        rx_done  <= 1'b0;
        count    <= 4'b0;
        temp_data <= 8'b0;
    end else begin
        case (PS) 
            idle : begin
                data_out <= 8'b0;
                rx_done  <= 1'b0;
            end

            start : begin
                count    <= 4'b0;
                rx_done  <= 1'b0;
            end

            trans : begin
                // Shift in received bit (LSB first)
                temp_data <= {rx, temp_data[7:1]};
                count     <= count + 1;
                rx_done   <= 1'b0;
            end

            stop : begin
                data_out <= temp_data; // Finalize received data
                rx_done  <= 1'b1;      // Indicate reception is complete
            end

            default : begin
                data_out <= 8'b0;
                rx_done  <= 1'b0;
            end
        endcase 
    end
end

endmodule
