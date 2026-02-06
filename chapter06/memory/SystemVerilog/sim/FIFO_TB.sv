// Russell Merrick - http://www.nandland.com
//
// FIFO testbench.
// SystemVerilog implementation

module FIFO_TB ();

  localparam int DEPTH = 4;
  localparam int WIDTH = 8;

  logic r_Clk = 1'b0;
  logic r_Rst_L = 1'b0;
  logic r_Wr_DV = 1'b0;
  logic r_Rd_En = 1'b0;
  logic [WIDTH-1:0] r_Wr_Data = '0;
  logic [$clog2(DEPTH)-1:0] r_AF_Level = DEPTH - 1;
  logic [$clog2(DEPTH)-1:0] r_AE_Level = 1;
  logic w_AF_Flag;
  logic w_AE_Flag;
  logic w_Full;
  logic w_Empty;
  logic w_Rd_DV;
  logic [WIDTH-1:0] w_Rd_Data;

  FIFO #(
      .WIDTH(WIDTH),
      .DEPTH(DEPTH)
  ) UUT (
      .i_Rst_L(r_Rst_L),
      .i_Clk(r_Clk),
      // Write Side
      .i_Wr_DV(r_Wr_DV),
      .i_Wr_Data(r_Wr_Data),
      .i_AF_Level(r_AF_Level),
      .o_AF_Flag(w_AF_Flag),
      .o_Full(w_Full),
      // Read Side
      .i_Rd_En(r_Rd_En),
      .o_Rd_DV(w_Rd_DV),
      .o_Rd_Data(w_Rd_Data),
      .i_AE_Level(r_AE_Level),
      .o_AE_Flag(w_AE_Flag),
      .o_Empty(w_Empty)
  );

  always #10 r_Clk <= !r_Clk;  // create oscillating clock

  // This task triggers a reset condition to the FIFO.
  task automatic reset_fifo();
    @(posedge r_Clk);
    r_Rst_L <= 1'b0;
    r_Wr_DV <= 1'b0;  // ensure rd/wr are off
    r_Rd_En <= 1'b0;
    @(posedge r_Clk);
    r_Rst_L <= 1'b1;
    @(posedge r_Clk);
    @(posedge r_Clk);
  endtask

  initial begin
    int i;
    $dumpfile("dump.vcd");
    $dumpvars;  // for EDA Playground sim

    reset_fifo();

    // Write single word, ensure it appears on output
    r_Wr_DV   <= 1'b1;
    r_Wr_Data <= 8'hAB;
    @(posedge r_Clk);
    r_Wr_DV <= 1'b0;
    @(posedge r_Clk);
    assert (!w_Empty)
      else $error("FIFO should not be empty after write");

    repeat (4) @(posedge r_Clk);

    // Read out that word, ensure DV and empty is correct
    r_Rd_En <= 1'b1;
    @(posedge r_Clk);
    r_Rd_En <= 1'b0;
    @(posedge r_Clk);
    assert (w_Rd_DV)
      else $error("Read data valid should be asserted");
    assert (w_Empty)
      else $error("FIFO should be empty after reading last word");
    assert (w_Rd_Data == 8'hAB)
      else $error("Read data mismatch: expected 0xAB, got 0x%h", w_Rd_Data);


    // Test: Fill FIFO with incrementing pattern, then read it back.
    reset_fifo();
    r_Wr_Data <= 8'h30;
    repeat (DEPTH) begin
      r_Wr_DV <= 1'b1;
      @(posedge r_Clk);
      r_Wr_DV <= 1'b0;
      @(posedge r_Clk);
      r_Wr_Data <= r_Wr_Data + 1'b1;
    end
    r_Wr_DV <= 1'b0;
    @(posedge r_Clk);
    assert (w_Full)
      else $error("FIFO should be full");
    @(posedge r_Clk);

    // Read out and verify incrementing pattern
    for (i = 8'h30; i < 8'h30 + DEPTH; i = i + 1) begin
      r_Rd_En <= 1'b1;
      @(posedge r_Clk);
      r_Rd_En <= 1'b0;
      @(posedge r_Clk);
      assert (w_Rd_DV)
        else $error("Read data valid should be asserted");
      assert (w_Rd_Data == i)
        else $error("rd_data is %d i is %d", w_Rd_Data, i);
      @(posedge r_Clk);
    end
    assert (w_Empty)
      else $error("FIFO should be empty after reading all data");


    // Test: Read and write on same clock cycle when empty + full
    reset_fifo();
    r_Rd_En <= 1'b1;
    r_Wr_DV <= 1'b1;
    @(posedge r_Clk);
    @(posedge r_Clk);
    r_Rd_En <= 1'b0;
    repeat (DEPTH) @(posedge r_Clk);
    assert (w_Full)
      else $error("FIFO should be full");
    r_Rd_En <= 1'b1;
    @(posedge r_Clk);
    assert (w_Full)
      else $error("FIFO should remain full with simultaneous read/write");
    @(posedge r_Clk);
    assert (w_Full)
      else $error("FIFO should remain full with simultaneous read/write");
    r_Wr_DV <= 1'b0;
    r_Rd_En <= 1'b0;

    // Test: Almost Empty, Almost Full Flags
    // AE is set to 1, AF is set to 3
    reset_fifo();
    assert (w_AE_Flag)
      else $error("AE flag should be set when empty");
    assert (!w_AF_Flag)
      else $error("AF flag should not be set when empty");

    r_Wr_DV <= 1'b1;
    @(posedge r_Clk);
    assert (w_AE_Flag)
      else $error("AE flag should still be set after first write");
    assert (!w_AF_Flag)
      else $error("AF flag should not be set after first write");
    @(posedge r_Clk);
    assert (!w_AE_Flag)
      else $error("AE flag should be cleared after second write");
    assert (!w_AF_Flag)
      else $error("AF flag should not be set after second write");
    @(posedge r_Clk);
    assert (!w_AE_Flag)
      else $error("AE flag should be cleared");
    assert (w_AF_Flag)
      else $error("AF flag should be set after third write");
    @(posedge r_Clk);
    assert (!w_AE_Flag)
      else $error("AE flag should be cleared");
    assert (w_AF_Flag)
      else $error("AF flag should be set when full");
    assert (w_Full)
      else $error("FIFO should be full");

    $finish();
  end

endmodule
