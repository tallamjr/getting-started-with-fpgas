// Description: Simple Testbench for LFSR.  Set NUM_BITS to different
// values to verify operation of LFSR
module LFSR_TB;

  parameter int NUM_BITS = 4;

  logic r_Clk;

  logic [NUM_BITS-1:0] w_LFSR_Data;
  logic w_LFSR_Done;

  // Instantiate the LFSR module
  LFSR #(
      .NUM_BITS(NUM_BITS)
  ) LFSR_inst (
      .i_Clk(r_Clk),
      .i_Enable(1'b1),
      .i_Seed_DV(1'b0),
      .i_Seed_Data({NUM_BITS{1'b0}}),
      .o_LFSR_Data(w_LFSR_Data),
      .o_LFSR_Done(w_LFSR_Done)
  );

  // Clock generation
  initial begin
    r_Clk = 1'b0;
    forever #10 r_Clk = ~r_Clk;
  end

  // Optional: Add simulation control and monitoring
  initial begin
    $display("LFSR Testbench - NUM_BITS = %0d", NUM_BITS);
    $display("Expected cycle count before done: %0d", (2**NUM_BITS) - 1);
    $monitor("Time: %0t | LFSR_Data: %b | LFSR_Done: %b", $time, w_LFSR_Data, w_LFSR_Done);

    // Run for enough cycles to see the full LFSR sequence
    repeat ((2**NUM_BITS) + 10) @(posedge r_Clk);

    $display("Simulation complete");
    $finish;
  end

endmodule
