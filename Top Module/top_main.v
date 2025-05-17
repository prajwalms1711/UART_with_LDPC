module top_main (
    input clk,
    input rst,
    input [7:0] m,
    output reg [15:0] c,
    input tx_start,
    output reg tx,
    output reg tx_done,
    output reg baud_clk,
    input rx,
    output reg rx_done,
    output reg [7:0] syndrome,
    output [7:0] message,
    output reg [15:0] corrected_codeword,
    output reg [4:0] count,
    output reg [15:0] temp_data
);
    reg [7:0] temp_message; 
    reg [4:0] count_tx;
    reg [13:0] cnt;
    wire temp_clk;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0;
            baud_clk <= 0;
        end else if (cnt == 14'd10415) begin
            cnt <= 0;
            baud_clk <= 1;
        end else begin
            cnt <= cnt + 1;
            baud_clk <= 0;
        end
    end

    assign temp_clk = baud_clk;

    // FSM States
    localparam [1:0]
        idle_tx  = 2'b00,
        start_tx = 2'b01,
        trans_tx = 2'b10,
        stop_tx  = 2'b11;

    reg [1:0] PS_tx, NS_tx;
    reg [15:0] temp_data_tx;

    // Codeword generation
    always @(posedge temp_clk) begin
        if (rst)
            c <= 16'b0;
        else begin
            c[15:8] <= m;
            c[7] <= m[7] ^ m[5] ^ m[3] ^ m[2];
            c[6] <= m[6] ^ m[5] ^ m[2] ^ m[1];
            c[5] <= m[5] ^ m[7] ^ m[4] ^ m[1];
            c[4] <= m[4] ^ m[0] ^ m[3] ^ m[6];
            c[3] <= m[7] ^ m[5] ^ m[0] ^ m[2] ^ m[4];
            c[2] <= m[6] ^ m[2] ^ m[1] ^ m[3] ^ m[0];
            c[1] <= m[7] ^ m[4] ^ m[1] ^ m[3] ^ m[0];
            c[0] <= m[6] ^ m[5] ^ m[0] ^ m[1] ^ m[4];
        end
    end

    // UART TX FSM
    always @(posedge temp_clk) begin
        if (rst) PS_tx <= idle_tx;
        else PS_tx <= NS_tx;
    end

    always @* begin
        case (PS_tx)
            idle_tx  : NS_tx = tx_start ? start_tx : idle_tx;
            start_tx : NS_tx = trans_tx;
            trans_tx : NS_tx = (count_tx >= 15) ? stop_tx : trans_tx;
            stop_tx  : NS_tx = idle_tx;
            default  : NS_tx = idle_tx;
        endcase
    end

    always @(posedge temp_clk) begin
        if (rst) begin
            tx <= 1'b1;
            tx_done <= 1'b0;
            count_tx <= 0;
            temp_data_tx <= 0;
        end else begin
            case (PS_tx)
                idle_tx: begin
                    tx <= 1'b1;
                    tx_done <= 1'b0;
                end
                start_tx: begin
                    tx <= 1'b0;
                    temp_data_tx <= c;
                    count_tx <= 0;
                    tx_done <= 1'b0;
                end
                trans_tx: begin
                    tx <= temp_data_tx[0];
                    temp_data_tx <= {1'b0, temp_data_tx[15:1]};
                    count_tx <= count_tx + 1;
                    tx_done <= 1'b0;
                end
                stop_tx: begin
                    tx <= 1'b1;
                    tx_done <= 1'b1;
                end
                default: begin
                    tx <= 1'b1;
                    tx_done <= 1'b0;
                end
            endcase
        end
    end

    // UART RX FSM
    localparam [1:0]
        idle  = 2'b00,
        start = 2'b01,
        trans = 2'b10,
        stop  = 2'b11;

    reg [1:0] PS, NS;
    reg [15:0] data_out;
    reg [15:0] H [7:0];
    integer i, j, k;
    reg [7:0] column_xor;
    reg found;

    always @(posedge temp_clk or posedge rst) begin
        if (rst) PS <= idle;
        else PS <= NS;
    end

    always @* begin
        case (PS)
            idle:  NS = (rx == 1'b0) ? trans : idle;
            trans: NS = (count == 15) ? stop : trans;
            stop:  NS = (rx == 1'b1) ? idle : stop;
            default: NS = idle;
        endcase
    end

    always @(posedge temp_clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            temp_data <= 0;
            data_out <= 0;
            rx_done <= 0;
        end else begin
            case (PS)
                idle: begin
                    count <= 0;
                    temp_data <= 0;
                    rx_done <= 0;
                end
                trans: begin
                    temp_data <= {rx, temp_data[15:1]};
                    count <= count + 1;
                    rx_done <= 0;
                end
                stop: begin
                    if (rx == 1'b1) begin
                        data_out <= temp_data;
                        rx_done <= 1;
                    end else begin
                        rx_done <= 0;
                    end
                end
                default: rx_done <= 0;
            endcase
        end
    end

    // LDPC H Matrix initialization during reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            H[0] <= 16'b1010110010000000;
            H[1] <= 16'b0110011001000000;
            H[2] <= 16'b1011001000100000;
            H[3] <= 16'b0101100100010000;
            H[4] <= 16'b1011010100001000;
            H[5] <= 16'b0100111100000100;
            H[6] <= 16'b1001101100000010;
            H[7] <= 16'b0111001100000001;
        end
    end

    // LDPC Decoding and Error Correction
    always @(posedge temp_clk or posedge rst) begin
        if (rst) begin
            syndrome <= 0;
            corrected_codeword <= 0;
        end else if (rx_done) begin
            for (i = 0; i < 8; i = i + 1)
                syndrome[i] <= ^(H[i] & data_out);

            corrected_codeword <= data_out;
            found <= 0;

            // One-bit error correction
            for (i = 0; i < 16; i = i + 1) begin
                if (!found) begin
                    for (j = 0; j < 8; j = j + 1)
                        column_xor[j] <= H[j][i];

                    if (column_xor == syndrome) begin
                        corrected_codeword[i] <= ~corrected_codeword[i];
                        found <= 1;
                    end
                end
            end

            // Two-bit error correction (static bounds)
            if (!found) begin
                for (i = 15; i > 0; i = i - 1) begin
                    for (j = 0; j < i; j = j + 1) begin
                        for (k = 0; k < 8; k = k + 1)
                            column_xor[k] <= H[k][i] ^ H[k][j];

                        if (column_xor == syndrome) begin
                            corrected_codeword[i] <= ~corrected_codeword[i];
                            corrected_codeword[j] <= ~corrected_codeword[j];
                            found <= 1;
                        end
                    end
                end
            end
            
        end
        
    end
    assign message = corrected_codeword[15:8];
endmodule
