// SystemVerilog equivalent of Switches_To_LEDs.v
// Demonstrates basic combinational logic using assign statements
// Uses 'logic' type instead of 'wire' for modern SystemVerilog style

module Switches_To_LEDs (
    input  logic i_Switch_1,
    input  logic i_Switch_2,
    input  logic i_Switch_3,
    input  logic i_Switch_4,
    output logic o_LED_1,
    output logic o_LED_2,
    output logic o_LED_3,
    output logic o_LED_4
);

  // Combinational logic: directly connect switches to LEDs
  assign o_LED_1 = i_Switch_1;
  assign o_LED_2 = i_Switch_2;
  assign o_LED_3 = i_Switch_3;
  assign o_LED_4 = i_Switch_4;

endmodule
