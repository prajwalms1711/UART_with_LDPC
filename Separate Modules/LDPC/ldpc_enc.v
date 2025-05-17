module ldpc_encoder (
    input clk,           // Clock input
    input rst,           // Synchronous reset
    input [7:0] m,       // 8-bit input message
    output reg [15:0] c  // 16-bit output codeword (8 bits message + 8 parity)
);

always @(posedge clk) begin
    if (rst)
        c <= 16'b0;      // On reset, clear the codeword
    else begin
        // Store message bits in the upper 8 bits of the codeword
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
endmodule
