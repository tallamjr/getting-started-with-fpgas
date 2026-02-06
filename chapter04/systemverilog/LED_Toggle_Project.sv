// SystemVerilog equivalent of LED_Toggle_Project.v
// Demonstrates sequential logic with flip-flops using always_ff
// Uses 'logic' type and proper SystemVerilog clocking constructs

module LED_Toggle_Project (
    input  logic i_Clk,
    input  logic i_Switch_1,
    output logic o_LED_1
);

  logic r_LED_1    = 1'b0;
  logic r_Switch_1 = 1'b0;

  // Purpose: Toggle LED output when i_Switch_1 is released.
  // Using always_ff to explicitly indicate flip-flop inference
  always_ff @(posedge i_Clk) begin
    r_Switch_1 <= i_Switch_1;  // Creates a Register

    // This conditional expression looks for a falling edge on i_Switch_1.
    // Here, the current value (i_Switch_1) is low, but the previous value
    // (r_Switch_1) is high.  This means that we found a falling edge.
    if (i_Switch_1 == 1'b0 && r_Switch_1 == 1'b1) begin
      r_LED_1 <= ~r_LED_1;  // Toggle LED output
    end
  end

  assign o_LED_1 = r_LED_1;

endmodule
