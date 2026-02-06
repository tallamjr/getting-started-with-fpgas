// Simple testbench to verify Demux functionality

module Demux_1_To_4_TB ();

  logic w_Data0;
  logic w_Data1;
  logic w_Data2;
  logic w_Data3;
  logic r_Sel1 = 1'b0;
  logic r_Sel0 = 1'b0;
  logic r_Data = 1'b1;

  Demux_1_To_4 UUT (
      .i_Data (r_Data),
      .i_Sel1 (r_Sel1),
      .i_Sel0 (r_Sel0),
      .o_Data0(w_Data0),
      .o_Data1(w_Data1),
      .o_Data2(w_Data2),
      .o_Data3(w_Data3)
  );

  // Takes input integer and drives select inputs
  task automatic set_select(input logic [1:0] sel);
    #1;
    r_Sel1 = sel[1];
    r_Sel0 = sel[0];
    #1;
  endtask

  initial begin
    set_select(2'b00);
    assert (w_Data0) else $error("Demux select 0: o_Data0 should be high");
    assert (!w_Data1) else $error("Demux select 0: o_Data1 should be low");
    assert (!w_Data2) else $error("Demux select 0: o_Data2 should be low");
    assert (!w_Data3) else $error("Demux select 0: o_Data3 should be low");

    set_select(2'b01);
    assert (!w_Data0) else $error("Demux select 1: o_Data0 should be low");
    assert (w_Data1) else $error("Demux select 1: o_Data1 should be high");
    assert (!w_Data2) else $error("Demux select 1: o_Data2 should be low");
    assert (!w_Data3) else $error("Demux select 1: o_Data3 should be low");

    set_select(2'b10);
    assert (!w_Data0) else $error("Demux select 2: o_Data0 should be low");
    assert (!w_Data1) else $error("Demux select 2: o_Data1 should be low");
    assert (w_Data2) else $error("Demux select 2: o_Data2 should be high");
    assert (!w_Data3) else $error("Demux select 2: o_Data3 should be low");

    set_select(2'b11);
    assert (!w_Data0) else $error("Demux select 3: o_Data0 should be low");
    assert (!w_Data1) else $error("Demux select 3: o_Data1 should be low");
    assert (!w_Data2) else $error("Demux select 3: o_Data2 should be low");
    assert (w_Data3) else $error("Demux select 3: o_Data3 should be high");

    $finish();
  end

endmodule
