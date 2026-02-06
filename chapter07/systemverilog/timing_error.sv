///////////////////////////////////////////////////////////////////////////////
// Module: timing_error
// Description: Educational timing violation example demonstrating long
//              combinational paths that can cause timing failures.
//
// This module intentionally creates a long propagation delay by performing
// multiple arithmetic operations (division, addition, multiplication) in a
// single clock cycle. This is kept for educational purposes to demonstrate
// how pipelining can resolve timing issues.
///////////////////////////////////////////////////////////////////////////////

module timing_error (
    input  logic        i_Clk,
    input  logic [7:0]  i_Data,
    output logic [15:0] o_Data
);

    logic [7:0] r0_Data;
    // Pipeline registers for the fix (commented out for educational purposes)
    // logic [7:0] r1_Data;
    // logic [7:0] r2_Data;

    always_ff @(posedge i_Clk) begin
        // Register so tools know r0_Data
        // is in i_Clk clock domain.
        r0_Data <= i_Data;

        // BAD: Long propagation delay
        // Division, addition, and multiplication all in one clock cycle
        // creates a very long combinational path that may violate timing.
        o_Data <= ((r0_Data / 3) + 1) * 5;

        // FIX: Pipeline math operations
        // By breaking the operations into separate clock cycles,
        // each stage has a shorter combinational path.
        // r1_Data <= r0_Data / 3;
        // r2_Data <= r1_Data + 1;
        // o_Data  <= r2_Data * 5;

    end

endmodule : timing_error
