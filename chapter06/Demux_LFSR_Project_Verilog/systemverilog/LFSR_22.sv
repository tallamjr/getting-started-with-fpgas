// SystemVerilog equivalent of LFSR_22.v
// 22-bit wide Linear Feedback Shift Register
//
// Uses always_ff for sequential logic and logic types throughout.
// The XNOR feedback polynomial generates a maximal-length sequence
// of 2^22 - 1 states before repeating.

module LFSR_22 (
    input  logic        i_Clk,
    output logic [21:0] o_LFSR_Data,
    output logic        o_LFSR_Done
);

  logic [21:0] r_LFSR = '0;
  logic        w_XNOR;

  // Sequential shift register logic
  always_ff @(posedge i_Clk) begin
    r_LFSR <= {r_LFSR[20:0], w_XNOR};
  end

  // XNOR feedback from taps at bits 21 and 20
  // This polynomial provides maximal length sequence for 22-bit LFSR
  assign w_XNOR = r_LFSR[21] ^~ r_LFSR[20];

  // Completion signal when LFSR returns to all zeros
  assign o_LFSR_Done = (r_LFSR == 22'd0);

  // Output the current LFSR state
  assign o_LFSR_Data = r_LFSR;

endmodule : LFSR_22
