# UART with LDPC Encoding and Decoding

This project implements a UART (Universal Asynchronous Receiver Transmitter) module enhanced with LDPC (Low-Density Parity-Check) error correction in Verilog. It performs both transmission and reception of data with single- and two-bit error correction capability based on a predefined LDPC parity check matrix.

---

## 📁 Project Structure

- **top.v**: Top-level Verilog module containing:
  - Baud rate generator
  - LDPC encoding (codeword generation)
  - UART Transmitter FSM
  - UART Receiver FSM
  - LDPC Decoder (1-bit and 2-bit error correction)
- **top.sdc**: Timing constraints for synthesis.
- **run_synthesis.tcl**: TCL script for synthesizing the design in Cadence Genus.
- **slow.lib**: Target library used during synthesis.
- **README.md**: Project description and usage instructions.

---

## 🧠 Features

- **Baud Clock Generation**: Uses an internal counter to generate a baud_clk based on a system clock.
- **LDPC Encoder**: Generates a 16-bit codeword from 8-bit input using custom parity equations.
- **UART Transmitter**:
  - FSM with idle, start, transmit, and stop states.
  - Sends 16-bit codeword serially.
- **UART Receiver**:
  - FSM with similar states.
  - Receives serial data and stores the 16-bit word.
- **LDPC Decoder**:
  - Syndrome calculation using hardcoded 8x16 H-matrix.
  - Single- and double-bit error correction using column comparison.
- **Output**: Provides both the received codeword and the corrected 8-bit message.

---

## 🛠️ How to Use

### 1. Synthesis

To synthesize the design using Cadence Genus:

```bash
genus -files run_synthesis.tcl
```

Make sure the following paths in `run_synthesis.tcl` are correct:

```tcl
set_db lib_search_path /home/vlsi16/Digital/lib
set_db hdl_search_path /home/vlsi16/Digital
set_db library /home/vlsi16/Digital/lib/slow.lib
```

### 2. Simulation

You can simulate this design using any Verilog simulator (ModelSim, VCS, XSIM, etc). You'll need to write your own testbench to drive inputs such as:

- `m`: Input message (8 bits)
- `tx_start`: Trigger for UART transmission
- `rx`: Serial input for UART receiver

Expected outputs:

- `tx`: UART TX line
- `rx_done`: Indicates end of UART RX
- `message`: Final corrected message output (8 bits)
- `syndrome`: 8-bit syndrome vector
- `corrected_codeword`: Final 16-bit corrected word

---

## ⚙️ LDPC Matrix

The H-matrix used in decoding is hardcoded and corresponds to:

```
H[0] = 1010110010000000
H[1] = 0110011001000000
H[2] = 1011001000100000
H[3] = 0101100100010000
H[4] = 1011010100001000
H[5] = 0100111100000100
H[6] = 1001101100000010
H[7] = 0111001100000001
```

---

## 📌 Notes

- Baud rate is derived assuming a 50 MHz system clock and 4800 baud rate (10415 cycles).
- The module performs decoding only after full codeword reception.
- This design assumes ideal input and no metastability handling (suitable for simulation or tightly controlled hardware environments).

---

## 📃 License

This project is for academic and educational use. Contact the author for commercial licensing or reuse.
