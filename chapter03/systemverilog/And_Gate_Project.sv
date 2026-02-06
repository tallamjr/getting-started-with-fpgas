// SystemVerilog equivalent of And_Gate_Project.v
// Demonstrates basic AND gate logic using assign statement
// Uses 'logic' type instead of 'wire' for modern SystemVerilog style

module And_Gate_Project (
    // Push-Button Switches:
    input  logic i_Switch_1,
    input  logic i_Switch_2,
    // LED Output
    output logic o_LED_1
);

  // LUT gets created here.
  // Combinational logic: AND gate between two switches
  assign o_LED_1 = i_Switch_1 & i_Switch_2;

endmodule
