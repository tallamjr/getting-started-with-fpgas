///////////////////////////////////////////////////////////////////////////////
// Module: State_Machine_Game
// Description: Main state machine to control the memory game.
//              Assumes switch inputs have been debounced.
//
// Game Flow:
//   - Push Switch 1 and Switch 2 to start the game
//   - Displays a pseudo-random pattern on the 4 LEDs
//   - Pseudo-random pattern is created using the LFSR from Chapter 6
//   - User must use buttons to repeat the pattern
//   - If correct, adds 1 more LED blink to the sequence
//   - Game is over at GAME_LIMIT successful in a row
///////////////////////////////////////////////////////////////////////////////

module State_Machine_Game #(
    parameter int CLKS_PER_SEC = 25000000,
    parameter int GAME_LIMIT   = 6
) (
    input  logic       i_Clk,
    input  logic       i_Switch_1,
    input  logic       i_Switch_2,
    input  logic       i_Switch_3,
    input  logic       i_Switch_4,
    output logic [3:0] o_Score,
    output logic       o_LED_1,
    output logic       o_LED_2,
    output logic       o_LED_3,
    output logic       o_LED_4
);

    // State encoding using typedef enum
    typedef enum logic [2:0] {
        START        = 3'd0,
        PATTERN_OFF  = 3'd1,
        PATTERN_SHOW = 3'd2,
        WAIT_PLAYER  = 3'd3,
        INCR_SCORE   = 3'd4,
        LOSER        = 3'd5,
        WINNER       = 3'd6
    } state_t;

    state_t r_SM_Main;
    state_t r_SM_Next;

    logic r_Toggle;
    logic r_Switch_1, r_Switch_2, r_Switch_3, r_Switch_4;
    logic r_Button_DV;
    logic [1:0] r_Pattern [0:10];  // 2D Array: 2-bit wide x 11 deep
    logic [21:0] w_LFSR_Data;
    logic [$clog2(GAME_LIMIT)-1:0] r_Index;  // Display index
    logic [1:0] r_Button_ID;
    logic w_Count_En;
    logic w_Toggle;

    // State Register (Sequential Logic)
    always_ff @(posedge i_Clk) begin
        // Reset game from any state
        if (i_Switch_1 & i_Switch_2)
            r_SM_Main <= START;
        else
            r_SM_Main <= r_SM_Next;
    end

    // Next State and Output Logic (Combinational)
    always_comb begin
        // Default: stay in current state
        r_SM_Next = r_SM_Main;

        unique case (r_SM_Main)
            START: begin
                // Stay in START state until user releases buttons
                // Wait for reset condition to go away
                if (!i_Switch_1 & !i_Switch_2 & r_Button_DV)
                    r_SM_Next = PATTERN_OFF;
            end

            PATTERN_OFF: begin
                if (!w_Toggle & r_Toggle)  // Falling edge found
                    r_SM_Next = PATTERN_SHOW;
            end

            PATTERN_SHOW: begin
                // Shows the next LED in the pattern
                if (!w_Toggle & r_Toggle) begin  // Falling edge found
                    if (o_Score == r_Index)
                        r_SM_Next = WAIT_PLAYER;
                    else
                        r_SM_Next = PATTERN_OFF;
                end
            end

            WAIT_PLAYER: begin
                if (r_Button_DV) begin
                    if (r_Pattern[r_Index] == r_Button_ID && r_Index == o_Score)
                        r_SM_Next = INCR_SCORE;
                    else if (r_Pattern[r_Index] != r_Button_ID)
                        r_SM_Next = LOSER;
                    // else stay in WAIT_PLAYER (index increments in sequential block)
                end
            end

            INCR_SCORE: begin
                // Used to increment Score Counter
                if (o_Score == GAME_LIMIT - 1)
                    r_SM_Next = WINNER;
                else
                    r_SM_Next = PATTERN_OFF;
            end

            WINNER: begin
                // Display 0xA on 7-Segment display, wait for new game
                r_SM_Next = WINNER;  // Stay here
            end

            LOSER: begin
                // Display 0xF on 7-Segment display, wait for new game
                r_SM_Next = LOSER;  // Stay here
            end

            default: r_SM_Next = START;
        endcase
    end

    // Sequential logic for score, index, and pattern storage
    always_ff @(posedge i_Clk) begin
        unique case (r_SM_Main)
            START: begin
                o_Score <= 4'd0;
                r_Index <= '0;
            end

            PATTERN_SHOW: begin
                if (!w_Toggle & r_Toggle) begin  // Falling edge found
                    if (o_Score == r_Index)
                        r_Index <= '0;
                    else
                        r_Index <= r_Index + 1;
                end
            end

            WAIT_PLAYER: begin
                if (r_Button_DV) begin
                    if (r_Pattern[r_Index] == r_Button_ID && r_Index == o_Score)
                        r_Index <= '0;
                    else if (r_Pattern[r_Index] == r_Button_ID)
                        r_Index <= r_Index + 1;
                end
            end

            INCR_SCORE: begin
                o_Score <= o_Score + 1;
            end

            WINNER: begin
                o_Score <= 4'hA;  // Winner!
            end

            LOSER: begin
                o_Score <= 4'hF;  // Loser!
            end

            default: ;  // No action for other states
        endcase
    end

    // Register in the LFSR to r_Pattern when game starts
    // Each 2-bits of LFSR is one value for r_Pattern 2D Array
    always_ff @(posedge i_Clk) begin
        if (r_SM_Main == START) begin
            r_Pattern[0]  <= w_LFSR_Data[1:0];
            r_Pattern[1]  <= w_LFSR_Data[3:2];
            r_Pattern[2]  <= w_LFSR_Data[5:4];
            r_Pattern[3]  <= w_LFSR_Data[7:6];
            r_Pattern[4]  <= w_LFSR_Data[9:8];
            r_Pattern[5]  <= w_LFSR_Data[11:10];
            r_Pattern[6]  <= w_LFSR_Data[13:12];
            r_Pattern[7]  <= w_LFSR_Data[15:14];
            r_Pattern[8]  <= w_LFSR_Data[17:16];
            r_Pattern[9]  <= w_LFSR_Data[19:18];
            r_Pattern[10] <= w_LFSR_Data[21:20];
        end
    end

    // LED Output Logic
    assign o_LED_1 = (r_SM_Main == PATTERN_SHOW && r_Pattern[r_Index] == 2'b00) ? 1'b1 : i_Switch_1;
    assign o_LED_2 = (r_SM_Main == PATTERN_SHOW && r_Pattern[r_Index] == 2'b01) ? 1'b1 : i_Switch_2;
    assign o_LED_3 = (r_SM_Main == PATTERN_SHOW && r_Pattern[r_Index] == 2'b10) ? 1'b1 : i_Switch_3;
    assign o_LED_4 = (r_SM_Main == PATTERN_SHOW && r_Pattern[r_Index] == 2'b11) ? 1'b1 : i_Switch_4;

    // Create registers to enable falling edge detection
    always_ff @(posedge i_Clk) begin
        r_Toggle   <= w_Toggle;
        r_Switch_1 <= i_Switch_1;
        r_Switch_2 <= i_Switch_2;
        r_Switch_3 <= i_Switch_3;
        r_Switch_4 <= i_Switch_4;

        if (r_Switch_1 & !i_Switch_1) begin
            r_Button_DV <= 1'b1;
            r_Button_ID <= 2'd0;
        end else if (r_Switch_2 & !i_Switch_2) begin
            r_Button_DV <= 1'b1;
            r_Button_ID <= 2'd1;
        end else if (r_Switch_3 & !i_Switch_3) begin
            r_Button_DV <= 1'b1;
            r_Button_ID <= 2'd2;
        end else if (r_Switch_4 & !i_Switch_4) begin
            r_Button_DV <= 1'b1;
            r_Button_ID <= 2'd3;
        end else begin
            r_Button_DV <= 1'b0;
            r_Button_ID <= 2'd0;
        end
    end

    // w_Count_En is high when state machine is in
    // PATTERN_SHOW state or PATTERN_OFF state, else false
    assign w_Count_En = (r_SM_Main == PATTERN_SHOW || r_SM_Main == PATTERN_OFF);

    Count_And_Toggle #(
        .COUNT_LIMIT(CLKS_PER_SEC / 4)
    ) Count_Inst (
        .i_Clk(i_Clk),
        .i_Enable(w_Count_En),
        .o_Toggle(w_Toggle)
    );

    // Generates 22-bit wide random data
    LFSR_22 LFSR_Inst (
        .i_Clk(i_Clk),
        .o_LFSR_Data(w_LFSR_Data),
        .o_LFSR_Done()  // leave unconnected
    );

endmodule : State_Machine_Game
