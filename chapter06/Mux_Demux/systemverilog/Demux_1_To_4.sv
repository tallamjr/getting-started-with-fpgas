// Implements a 1-4 Demultiplexer.
// In reality, it is unlikely you would put a demux in a dedicated module.

module Demux_1_To_4 (
    input  logic i_Data,
    input  logic i_Sel1,
    input  logic i_Sel0,
    output logic o_Data0,
    output logic o_Data1,
    output logic o_Data2,
    output logic o_Data3
);

  always_comb begin
    // Default all outputs to 0
    o_Data0 = 1'b0;
    o_Data1 = 1'b0;
    o_Data2 = 1'b0;
    o_Data3 = 1'b0;

    unique case ({i_Sel1, i_Sel0})
      2'b00:   o_Data0 = i_Data;
      2'b01:   o_Data1 = i_Data;
      2'b10:   o_Data2 = i_Data;
      2'b11:   o_Data3 = i_Data;
    endcase
  end

endmodule
