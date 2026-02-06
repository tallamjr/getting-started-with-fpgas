module Mux_4_To_1_TB ();

  logic r_Data0 = 1'b1;
  logic r_Data1 = 1'b0;
  logic r_Data2 = 1'b0;
  logic r_Data3 = 1'b0;
  logic r_Sel1 = 1'b0;
  logic r_Sel0 = 1'b0;
  logic w_Out;

  Mux_4_To_1 UUT (
      .i_Data0(r_Data0),
      .i_Data1(r_Data1),
      .i_Data2(r_Data2),
      .i_Data3(r_Data3),
      .i_Sel0 (r_Sel0),
      .i_Sel1 (r_Sel1),
      .o_Data (w_Out)
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
    assert (w_Out == r_Data0) else $error("Mux select 0 failed");
    set_select(2'b01);
    assert (w_Out == r_Data1) else $error("Mux select 1 failed");
    set_select(2'b10);
    assert (w_Out == r_Data2) else $error("Mux select 2 failed");
    set_select(2'b11);
    assert (w_Out == r_Data3) else $error("Mux select 3 failed");
    $finish();
  end

endmodule
