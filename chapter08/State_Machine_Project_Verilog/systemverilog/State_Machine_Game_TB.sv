///////////////////////////////////////////////////////////////////////////////
// Module: State_Machine_Game_TB
// Description: Testbench for State Machine Game
//              Simple tests to ensure that state machine works correctly.
///////////////////////////////////////////////////////////////////////////////

module State_Machine_Game_TB;

    localparam int CLKS_PER_SEC = 6;
    localparam int GAME_LIMIT   = 3;

    logic       r_Clk      = 1'b0;
    logic       r_Switch_1 = 1'b0;
    logic       r_Switch_2 = 1'b0;
    logic       r_Switch_3 = 1'b0;
    logic       r_Switch_4 = 1'b0;
    logic       w_LED_1;
    logic       w_LED_2;
    logic       w_LED_3;
    logic       w_LED_4;
    logic [3:0] w_Score;

    // Clock generation: 4 time unit period
    always #2 r_Clk <= !r_Clk;

    // Device Under Test
    State_Machine_Game #(
        .CLKS_PER_SEC(CLKS_PER_SEC),
        .GAME_LIMIT  (GAME_LIMIT)
    ) Game_Inst (
        .i_Clk      (r_Clk),
        .i_Switch_1 (r_Switch_1),
        .i_Switch_2 (r_Switch_2),
        .i_Switch_3 (r_Switch_3),
        .i_Switch_4 (r_Switch_4),
        .o_Score    (w_Score),
        .o_LED_1    (w_LED_1),
        .o_LED_2    (w_LED_2),
        .o_LED_3    (w_LED_3),
        .o_LED_4    (w_LED_4)
    );

    // Task: Sets switches to desired value for one clock cycle,
    // then drives back to 0.
    task automatic set_switches(
        input logic i_1,
        input logic i_2,
        input logic i_3,
        input logic i_4
    );
        begin
            @(posedge r_Clk);
            r_Switch_1 <= i_1;
            r_Switch_2 <= i_2;
            r_Switch_3 <= i_3;
            r_Switch_4 <= i_4;
            @(posedge r_Clk);
            r_Switch_1 <= 1'b0;
            r_Switch_2 <= 1'b0;
            r_Switch_3 <= 1'b0;
            r_Switch_4 <= 1'b0;
            @(posedge r_Clk);
        end
    endtask : set_switches

    // Main test sequence
    initial begin
        // Required for EDA Playground and waveform viewing
        $dumpfile("dump.vcd");
        $dumpvars;

        // Initial switch state
        set_switches(1'b0, 1'b0, 1'b0, 1'b0);
        repeat (CLKS_PER_SEC) @(posedge r_Clk);

        // Start game by pressing SW1 and SW2
        set_switches(1'b1, 1'b1, 1'b0, 1'b0);
        repeat (2 * CLKS_PER_SEC) @(posedge r_Clk);

        // Player input: Press SW4
        set_switches(1'b0, 1'b0, 1'b0, 1'b1);
        repeat (3 * CLKS_PER_SEC) @(posedge r_Clk);

        // Player input: Press SW4 again
        set_switches(1'b0, 1'b0, 1'b0, 1'b1);
        repeat (2 * CLKS_PER_SEC) @(posedge r_Clk);

        // Player input: Press SW4 again
        set_switches(1'b0, 1'b0, 1'b0, 1'b1);
        repeat (2 * CLKS_PER_SEC) @(posedge r_Clk);

        // Reset game back to start
        set_switches(1'b1, 1'b1, 1'b0, 1'b0);
        repeat (2 * CLKS_PER_SEC) @(posedge r_Clk);

        $display("Test Complete");
        $finish();
    end

endmodule : State_Machine_Game_TB
