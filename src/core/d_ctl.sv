`include "control_signals_if.svh"
`include "../debug/debug_if.svh"

module d_ctl (
    input clk,
    input rst_n,

    output debug,
    output halted_ctrl,
    control_signals_if ctrl,
    debug_if           debug_if
);
    wire halted;

    reg debug_reg;
    reg halted_reg;

    always @(posedge clk) begin
        if(!rst_n) begin
            debug_reg  <= 1'b0;
            halted_reg <= 1'b0;
        end else begin
            debug_reg   <= debug;
            halted_reg  <= halted;
        end
    end

    assign debug   = (debug_reg    || debug_if.halt_req)          && !debug_if.resume_req;
    assign halted  = (halted_reg   || (debug_reg && ctrl.halted)) && (debug_reg || ctrl.halted);

    assign halted_ctrl = halted;

    assign debug_if.halted    = halted;

endmodule
