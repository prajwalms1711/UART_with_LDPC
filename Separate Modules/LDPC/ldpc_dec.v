module ldpc_decoder(
    input clk,
    input rst,
    input [16:0] codeword,
    output reg [7:0] syndrome,
    output reg [7:0] message,
    output reg [16:0] corrected_codeword
);

    reg [10:0] H [3:0]; // 4x11 H matrix
    integer i, j, k;
    reg [3:0] column_xor;
    reg found;

    initial begin
        H[0] = 11'b10010101000;
        H[1] = 11'b01011000100;
        H[2] = 11'b00101110010;
        H[3] = 11'b11100010001;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            syndrome <= 4'b0;
            corrected_codeword <= 11'b0;
            message <= 7'b0;
        end else begin
            // Calculate syndrome
            for (i = 0; i < 4; i = i + 1)
                syndrome[i] = ^(H[i] & codeword);

            corrected_codeword = codeword;
            found = 0;

            // 1-bit error correction
            for (i = 0; i < 11 && !found; i = i + 1) begin
                for (j = 0; j < 4; j = j + 1)
                    column_xor[j] = H[j][i];
                if (column_xor == syndrome) begin
                    corrected_codeword[i] = ~corrected_codeword[i];
                    found = 1;
                end
            end

            // 2-bit error correction (brute force)
            for (i = 10; i > 0 && !found; i = i - 1) begin
                for (j = i - 1; j >= 0 && !found; j = j - 1) begin
                    for (k = 0; k < 4; k = k + 1)
                        column_xor[k] = H[k][i] ^ H[k][j];
                    if (column_xor == syndrome) begin
                        corrected_codeword[i] = ~corrected_codeword[i];
                        corrected_codeword[j] = ~corrected_codeword[j];
                        found = 1;
                    end
                end
            end

            // Extract message bits from corrected codeword
            message = corrected_codeword[10:4]; // m6 to m0
        end
    end
endmodule
