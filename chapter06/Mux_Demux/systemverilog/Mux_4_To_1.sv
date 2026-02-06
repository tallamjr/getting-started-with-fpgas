module Mux_4_To_1 (
    input  logic i_Data0,
    input  logic i_Data1,
    input  logic i_Data2,
    input  logic i_Data3,
    input  logic i_Sel0,
    input  logic i_Sel1,
    output logic o_Data
);

  always_comb begin
    unique case ({i_Sel1, i_Sel0})
      2'b00:   o_Data = i_Data0;
      2'b01:   o_Data = i_Data1;
      2'b10:   o_Data = i_Data2;
      2'b11:   o_Data = i_Data3;
    endcase
  end

endmodule
