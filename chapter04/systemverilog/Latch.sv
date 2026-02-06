// SystemVerilog equivalent of Latch.v
// Demonstrates intentional latch behaviour using always_latch
// Uses 'logic' type and proper SystemVerilog latch constructs

module Latch (
    input  logic i_A,
    input  logic i_B,
    output logic o_Q
);

  // Using always_latch to explicitly indicate latch inference
  // The missing else case is intentional to create latch behaviour
  always_latch begin
    if (i_A == 1'b0 && i_B == 1'b0) o_Q <= 1'b0;
    else if (i_A == 1'b0 && i_B == 1'b1) o_Q <= 1'b1;
    else if (i_A == 1'b1 && i_B == 1'b0) o_Q <= 1'b1;
    // Missing one last ELSE statement!
    // This creates intentional latch behaviour - o_Q retains its value
    // when i_A == 1'b1 && i_B == 1'b1
  end

endmodule
