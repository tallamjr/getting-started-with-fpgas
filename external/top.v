// top.v

module seg_decoder (
    input  [3:0] num,
    output reg [6:0] seg
);
  // Seven-segment decoder (assuming a common-cathode display)
  // Bit order: seg[0] = A, seg[1] = B, ... seg[6] = G.
  always @(*) begin
    case(num)
      4'd0: seg = 7'b0111111;
      4'd1: seg = 7'b0000110;
      4'd2: seg = 7'b1011011;
      4'd3: seg = 7'b1001111;
      4'd4: seg = 7'b1100110;
      4'd5: seg = 7'b1101101;
      4'd6: seg = 7'b1111101;
      4'd7: seg = 7'b0000111;
      4'd8: seg = 7'b1111111; // All segments on: displays "8"
      4'd9: seg = 7'b1101111;
      default: seg = 7'b0000000;
    endcase
  end
endmodule

module top (
    input i_Clk,  // Use the clock as defined in your PCF (i_Clk on pin 15)
    // Map the seven-segment outputs to the names in your PCF
    output o_Segment1_A,
    output o_Segment1_B,
    output o_Segment1_C,
    output o_Segment1_D,
    output o_Segment1_E,
    output o_Segment1_F,
    output o_Segment1_G
);
  // Drive a fixed number (8) for display
  wire [3:0] number = 4'd8;
  wire [6:0] seg;

  seg_decoder u_seg_decoder (
      .num(number),
      .seg(seg)
  );

  // Assign each bit to its respective output
  assign o_Segment1_A = seg[0];
  assign o_Segment1_B = seg[1];
  assign o_Segment1_C = seg[2];
  assign o_Segment1_D = seg[3];
  assign o_Segment1_E = seg[4];
  assign o_Segment1_F = seg[5];
  assign o_Segment1_G = seg[6];

endmodule

