// Demonstrates various algebra equations and common pitfalls doing math in SystemVerilog.
// This module showcases signed/unsigned arithmetic, overflow conditions,
// and fixed-point Q notation examples.

module Math_Examples ();

  // Unsigned 4-bit variables
  logic unsigned [3:0] i1_u4, i2_u4, o_u4;
  // Signed 4-bit variables
  logic signed [3:0] i1_s4, i2_s4, o_s4;

  // Extended width variables for overflow prevention
  logic unsigned [4:0] o_u5, i2_u5;
  logic signed [4:0] o_s5, i1_s5, i2_s5;
  logic unsigned [5:0] o_u6;

  // 8-bit variables for multiplication results
  logic unsigned [7:0] o_u8, i_u8;
  logic signed [7:0] o_s8;

  initial begin

    // Unsigned + Unsigned = Unsigned (Rule #1 violation)
    // Result overflows because sum exceeds 4-bit capacity
    i1_u4 = 4'b1001;  // dec 9
    i2_u4 = 4'b1011;  // dec 11
    o_u4  = i1_u4 + i2_u4;
    $display("Ex01: %2d + %2d = %3d", $unsigned(i1_u4), $unsigned(i2_u4), $unsigned(o_u4));

    // Signed + Signed = Signed (Rule #1 violation)
    // Result overflows because sum exceeds 4-bit signed range
    i1_s4 = 4'b1001;  // dec -7
    i2_s4 = 4'b1011;  // dec -5
    o_s4  = i1_s4 + i2_s4;
    $display("Ex02: %2d + %2d = %3d", $signed(i1_s4), $signed(i2_s4), $signed(o_s4));

    // Unsigned + Unsigned = Unsigned (Rule #1 Fix)
    // Using 5-bit output prevents overflow
    i1_u4 = 4'b1001;  // dec 9
    i2_u4 = 4'b1011;  // dec 11
    o_u5  = i1_u4 + i2_u4;
    $display("Ex03: %2d + %2d = %3d", $unsigned(i1_u4), $unsigned(i2_u4), $unsigned(o_u5));

    // Signed + Signed = Signed (Rule #1 fix)
    // Using 5-bit signed output prevents overflow
    i1_s4 = 4'b1001;  // dec -7
    i2_s4 = 4'b1011;  // dec -5
    o_s5  = i1_s4 + i2_s4;
    $display("Ex04: %2d + %2d = %3d", $signed(i1_s4), $signed(i2_s4), $signed(o_s5));

    // Unsigned - Unsigned = Unsigned (bad)
    // Subtraction produces negative result which cannot be represented unsigned
    i1_u4 = 4'b1001;  // dec 9
    i2_u4 = 4'b1011;  // dec 11
    o_u5  = i1_u4 - i2_u4;
    $display("Ex05: %2d - %2d = %3d", $unsigned(i1_u4), $unsigned(i2_u4), $unsigned(o_u5));

    // Signed - Signed = Signed (fix)
    // Convert to signed before subtraction to handle negative results
    i1_u4 = 4'b1001;  // dec 9
    i2_u4 = 4'b1011;  // dec 11
    i1_s5 = $signed({1'b0, i1_u4});
    i2_s5 = $signed({1'b0, i2_u4});
    o_s5  = i1_s5 - i2_s5;
    $display("Ex06: %2d - %2d = %3d", $signed(i1_s5), $signed(i2_s5), $signed(o_s5));

    // Unsigned * Unsigned = Unsigned (Rule #4 violation)
    // Product overflows 4-bit capacity
    i1_u4 = 4'b1001;  // dec 9
    i2_u4 = 4'b1011;  // dec 11
    o_u4  = i1_u4 * i2_u4;
    $display("Ex07: %2d * %2d = %3d", $unsigned(i1_u4), $unsigned(i2_u4), $unsigned(o_u4));

    // Signed * Signed = Signed (Rule #4 violation)
    // Product overflows 4-bit signed capacity
    i1_s4 = 4'b1000;  // dec -8
    i2_s4 = 4'b0111;  // dec 7
    o_s4  = i1_s4 * i2_s4;
    $display("Ex08: %2d * %2d = %3d", $signed(i1_s4), $signed(i2_s4), $signed(o_s4));

    // Unsigned * Unsigned = Unsigned (Rule #4 fix)
    // Using 8-bit output accommodates full product range
    i1_u4 = 4'b1001;  // dec 9
    i2_u4 = 4'b1011;  // dec 11
    o_u8  = i1_u4 * i2_u4;
    $display("Ex09: %2d * %2d = %3d", $unsigned(i1_u4), $unsigned(i2_u4), $unsigned(o_u8));

    // Signed * Signed = Signed (Rule #4 fix)
    // Using 8-bit signed output accommodates full product range
    i1_s4 = 4'b1000;  // dec -8
    i2_s4 = 4'b0111;  // dec 7
    o_s8  = i1_s4 * i2_s4;
    $display("Ex10: %2d * %2d = %3d", $signed(i1_s4), $signed(i2_s4), $signed(o_s8));


    // Demonstrate: Multiply and Divide by base 2 numbers using shifts
    i_u8 = 8'd3;
    o_u8 = i_u8 << 1;
    $display("Ex11: %d * 2 = %d", $unsigned(i_u8), $unsigned(o_u8));
    o_u8 = i_u8 << 2;
    $display("Ex12: %d * 4 = %d", $unsigned(i_u8), $unsigned(o_u8));
    o_u8 = i_u8 << 4;
    $display("Ex13: %d * 16 = %d", $unsigned(i_u8), $unsigned(o_u8));

    i_u8 = 8'd128;
    o_u8 = i_u8 >> 1;
    $display("Ex14: %d / 2 = %d", $unsigned(i_u8), $unsigned(o_u8));
    o_u8 = i_u8 >> 2;
    $display("Ex15: %d / 4 = %d", $unsigned(i_u8), $unsigned(o_u8));
    o_u8 = i_u8 >> 4;
    $display("Ex16: %d / 16 = %d", $unsigned(i_u8), $unsigned(o_u8));

    i_u8 = 8'd15;
    o_u8 = i_u8 >> 1;
    $display("Ex17: %d / 2 = %d", $unsigned(i_u8), $unsigned(o_u8));
    o_u8 = i_u8 >> 2;
    $display("Ex18: %d / 4 = %d", $unsigned(i_u8), $unsigned(o_u8));
    o_u8 = i_u8 >> 3;
    $display("Ex19: %d / 8 = %d", $unsigned(i_u8), $unsigned(o_u8));


    // Demonstrate: Modified Q Notation Examples
    // U3.1 + U4.0 = U4.1 (Rule #5 violation)
    // Misaligned decimal points produce incorrect result
    i1_u4 = 4'b0011;
    i2_u4 = 4'b0011;
    o_u5  = i1_u4 + i2_u4;
    $display("Ex20: %2.3f + %2.3f = %2.3f", $unsigned(i1_u4) / 2.0, $unsigned(i2_u4), $unsigned(o_u5) / 2.0);

    // Convert U3.1 to U4.0
    // U4.0 + U4.0 = U5.0 (Rule #5 fix, using truncation)
    i1_u4 = 4'b0011;
    i2_u4 = 4'b0011;
    i1_u4 = i1_u4 >> 1;  // Convert U3.1 to U4.0 by dropping decimal
    o_u5  = i1_u4 + i2_u4;
    $display("Ex21: %2.3f + %2.3f = %2.3f", $unsigned(i1_u4), $unsigned(i2_u4), $unsigned(o_u5));

    // Or Convert U4.0 to U4.1
    // U3.1 + U4.1 = U5.1 (Rule #5 fix, using expansion)
    i1_u4 = 4'b0011;
    i2_u4 = 4'b0011;
    i2_u5 = i2_u4 << 1;
    o_u6  = i1_u4 + i2_u5;
    $display("Ex22: %2.3f + %2.3f = %2.3f", $unsigned(i1_u4) / 2.0, $unsigned(i2_u5) / 2.0, $unsigned(o_u6) / 2.0);

    // Multiplication with Decimals
    // U2.2 * U3.1 = U5.3
    i1_u4 = 4'b0101;
    i2_u4 = 4'b1011;
    o_u8  = i1_u4 * i2_u4;
    $display("Ex23: %2.3f * %2.3f = %2.3f", $unsigned(i1_u4) / 4.0, $unsigned(i2_u4) / 2.0, $unsigned(o_u8) / 8.0);

    // S2.2 * S4.0 = S6.2
    i1_s4 = 4'b0110;
    i2_s4 = 4'b1010;
    o_s8  = i1_s4 * i2_s4;
    $display("Ex24: %2.3f * %2.3f = %2.3f", $signed(i1_s4) / 4.0, $signed(i2_s4), $signed(o_s8) / 4.0);

    $finish();
  end

endmodule
