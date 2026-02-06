// Russell Merrick - http://www.nandland.com
//
// Dual Port RAM testbench.
// SystemVerilog implementation

module RAM_2Port_TB ();

  localparam int DEPTH = 4;
  localparam int WIDTH = 8;

  logic r_Clk = 1'b0;
  logic r_Wr_DV = 1'b0;
  logic r_Rd_En = 1'b0;
  logic [$clog2(DEPTH)-1:0] r_Wr_Addr = '0;
  logic [$clog2(DEPTH)-1:0] r_Rd_Addr = '0;
  logic [WIDTH-1:0] r_Wr_Data = '0;
  logic [WIDTH-1:0] w_Rd_Data;
  logic w_Rd_DV;

  always #10 r_Clk <= !r_Clk;  // create oscillating clock

  RAM_2Port #(
      .WIDTH(WIDTH),
      .DEPTH(DEPTH)
  ) UUT (
      // Write Signals
      .i_Wr_Clk (r_Clk),
      .i_Wr_Addr(r_Wr_Addr),
      .i_Wr_DV  (r_Wr_DV),
      .i_Wr_Data(r_Wr_Data),
      // Read Signals
      .i_Rd_Clk (r_Clk),
      .i_Rd_Addr(r_Rd_Addr),
      .i_Rd_En  (r_Rd_En),
      .o_Rd_DV  (w_Rd_DV),
      .o_Rd_Data(w_Rd_Data)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;  // for EDA Playground sim

    repeat (4) @(posedge r_Clk);  // Give simulation a few clocks to start

    // Fill memory with incrementing pattern
    repeat (DEPTH) begin
      r_Wr_DV <= 1'b1;
      @(posedge r_Clk);
      r_Wr_Data <= r_Wr_Data + 1'b1;
      r_Wr_Addr <= r_Wr_Addr + 1'b1;
    end
    r_Wr_DV <= 1'b0;

    // Read out incrementing pattern
    repeat (DEPTH) begin
      r_Rd_En <= 1'b1;
      @(posedge r_Clk);
      r_Rd_Addr <= r_Rd_Addr + 1'b1;
    end
    r_Rd_En <= 1'b0;

    repeat (4) @(posedge r_Clk);

    // Test reading and writing at the same time
    r_Wr_Addr <= 2'b01;
    r_Wr_Data <= 8'd84;
    r_Rd_Addr <= 2'b01;
    r_Rd_En   <= 1'b1;
    r_Wr_DV   <= 1'b1;
    @(posedge r_Clk);
    r_Rd_En <= 1'b0;
    r_Wr_DV <= 1'b0;
    repeat (3) @(posedge r_Clk);
    r_Rd_En <= 1'b1;
    @(posedge r_Clk);
    r_Rd_En <= 1'b0;
    repeat (3) @(posedge r_Clk);

    $finish();
  end

endmodule
