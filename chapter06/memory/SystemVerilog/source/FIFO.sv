// Russell Merrick - http://www.nandland.com
//
// Infers a Dual Port RAM (DPRAM) Based FIFO using a single clock
// Uses a Dual Port RAM but automatically handles read/write addresses.
// To use Almost Full/Empty Flags (dynamic)
// Set i_AF_Level to number of words away from full when o_AF_Flag goes high
// Set i_AE_Level to number of words away from empty when o_AE goes high
//   o_AE_Flag is high when this number OR LESS is in FIFO.
//
// Parameters:
// WIDTH     - Width of the FIFO
// DEPTH     - Max number of items able to be stored in the FIFO
//
// This FIFO cannot be used to cross clock domains, because in order to keep count
// correctly it would need to handle all metastability issues.
// If crossing clock domains is required, use FIFO primitives directly from the vendor.
//
// SystemVerilog implementation

module FIFO #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 256
) (
    input  logic                      i_Rst_L,
    input  logic                      i_Clk,
    // Write Side
    input  logic                      i_Wr_DV,
    input  logic [WIDTH-1:0]          i_Wr_Data,
    input  logic [$clog2(DEPTH)-1:0]  i_AF_Level,
    output logic                      o_AF_Flag,
    output logic                      o_Full,
    // Read Side
    input  logic                      i_Rd_En,
    output logic                      o_Rd_DV,
    output logic [WIDTH-1:0]          o_Rd_Data,
    input  logic [$clog2(DEPTH)-1:0]  i_AE_Level,
    output logic                      o_AE_Flag,
    output logic                      o_Empty
);

  // Local parameters for width matching
  localparam int ADDR_WIDTH = $clog2(DEPTH);
  localparam int COUNT_WIDTH = $clog2(DEPTH) + 1;

  logic [ADDR_WIDTH-1:0]  r_Wr_Addr, r_Rd_Addr;
  logic [COUNT_WIDTH-1:0] r_Count;  // 1 extra bit to go to DEPTH

  logic w_Rd_DV;
  logic [WIDTH-1:0] w_Rd_Data;

  // Dual Port RAM used for storing FIFO data
  RAM_2Port #(
      .WIDTH(WIDTH),
      .DEPTH(DEPTH)
  ) FIFO_Inst (
      // Write Port
      .i_Wr_Clk (i_Clk),
      .i_Wr_Addr(r_Wr_Addr),
      .i_Wr_DV  (i_Wr_DV),
      .i_Wr_Data(i_Wr_Data),
      // Read Port
      .i_Rd_Clk (i_Clk),
      .i_Rd_Addr(r_Rd_Addr),
      .i_Rd_En  (i_Rd_En),
      .o_Rd_DV  (w_Rd_DV),
      .o_Rd_Data(w_Rd_Data)
  );

  always_ff @(posedge i_Clk or negedge i_Rst_L) begin
    if (~i_Rst_L) begin
      r_Wr_Addr <= '0;
      r_Rd_Addr <= '0;
      r_Count   <= '0;
    end else begin
      // Write
      if (i_Wr_DV) begin
        if (r_Wr_Addr == ADDR_WIDTH'(DEPTH - 1))
          r_Wr_Addr <= '0;
        else
          r_Wr_Addr <= r_Wr_Addr + 1'b1;
      end

      // Read
      if (i_Rd_En) begin
        if (r_Rd_Addr == ADDR_WIDTH'(DEPTH - 1))
          r_Rd_Addr <= '0;
        else
          r_Rd_Addr <= r_Rd_Addr + 1'b1;
      end

      // Keeps track of number of words in FIFO
      // Read with no write
      if (i_Rd_En & ~i_Wr_DV) begin
        if (r_Count != '0) begin
          r_Count <= r_Count - 1'b1;
        end
      end  // Write with no read
      else if (i_Wr_DV & ~i_Rd_En) begin
        if (r_Count != COUNT_WIDTH'(DEPTH)) begin
          r_Count <= r_Count + 1'b1;
        end
      end

      if (i_Rd_En) begin
        o_Rd_Data <= w_Rd_Data;
      end
    end
  end

  // Combinational flag generation
  always_comb begin
    o_Full    = (r_Count == COUNT_WIDTH'(DEPTH)) ||
                (r_Count == COUNT_WIDTH'(DEPTH - 1) && i_Wr_DV && !i_Rd_En);
    o_Empty   = (r_Count == '0);
    o_AF_Flag = (r_Count > COUNT_WIDTH'(DEPTH) - COUNT_WIDTH'(i_AF_Level));
    o_AE_Flag = (r_Count < COUNT_WIDTH'(i_AE_Level));
    o_Rd_DV   = w_Rd_DV;
  end

  /////////////////////////////////////////////////////////////////////////////
  // ASSERTION CODE, NOT SYNTHESIZED
  // synthesis translate_off

  // Simple assertion checks compatible with most simulators
  // Ensures that we never read from empty FIFO or write to full FIFO.
  always_ff @(posedge i_Clk) begin
    if (i_Rst_L) begin
      if (i_Rd_En && !i_Wr_DV && r_Count == '0) begin
        $error("Error! Reading Empty FIFO");
      end

      if (i_Wr_DV && !i_Rd_En && r_Count == COUNT_WIDTH'(DEPTH)) begin
        $error("Error! Writing Full FIFO");
      end
    end
  end

  // Alternative: SystemVerilog Assertions (SVA) for advanced simulators
  // Uncomment below if your simulator supports SVA (VCS, ModelSim, Questa, etc.)
  //
  // property no_read_when_empty;
  //   @(posedge i_Clk) disable iff (!i_Rst_L)
  //     (i_Rd_En && !i_Wr_DV) |-> (r_Count != '0);
  // endproperty
  //
  // property no_write_when_full;
  //   @(posedge i_Clk) disable iff (!i_Rst_L)
  //     (i_Wr_DV && !i_Rd_En) |-> (r_Count != COUNT_WIDTH'(DEPTH));
  // endproperty
  //
  // assert property (no_read_when_empty)
  //   else $error("Error! Reading Empty FIFO");
  //
  // assert property (no_write_when_full)
  //   else $error("Error! Writing Full FIFO");

  // synthesis translate_on
  /////////////////////////////////////////////////////////////////////////////

endmodule
