///////////////////////////////////////////////////////////////////////////////
// Module: Turnstile_Example
// Description: Classic turnstile state machine example demonstrating
//              a simple two-state FSM with LOCKED and UNLOCKED states.
//
// State transitions:
//   LOCKED   + i_Coin -> UNLOCKED
//   UNLOCKED + i_Push -> LOCKED
///////////////////////////////////////////////////////////////////////////////

module Turnstile_Example (
    input  logic i_Reset,
    input  logic i_Clk,
    input  logic i_Coin,
    input  logic i_Push,
    output logic o_Locked
);

    // State encoding using typedef enum
    typedef enum logic {
        LOCKED   = 1'b0,
        UNLOCKED = 1'b1
    } state_t;

    state_t r_Curr_State;
    state_t r_Next_State;

    // Current State Register (Sequential Logic)
    always_ff @(posedge i_Clk or posedge i_Reset) begin
        if (i_Reset)
            r_Curr_State <= LOCKED;
        else
            r_Curr_State <= r_Next_State;
    end

    // Next State Determination (Combinational Logic)
    always_comb begin
        // Default: stay in current state
        r_Next_State = r_Curr_State;

        unique case (r_Curr_State)
            LOCKED: begin
                if (i_Coin)
                    r_Next_State = UNLOCKED;
            end

            UNLOCKED: begin
                if (i_Push)
                    r_Next_State = LOCKED;
            end
        endcase
    end

    // Output Logic
    assign o_Locked = (r_Curr_State == LOCKED);

endmodule : Turnstile_Example
