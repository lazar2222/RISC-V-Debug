`include "isa.svh"
`include "control_signals_if.svh"
`include "../debug/debug_if.svh"

module d_ctl (
    input clk,
    input rst_n,

    output reg debug,

    control_signals_if ctrl,
    debug_if           debug_if
);
    reg halted;

    always @(posedge clk) begin
        if(!rst_n) begin
            debug  <= 1'b0;
            halted <= 1'b0;
        end else begin
            debug  <= (debug  || debug_if.halt_req) && !debug_if.resume_req;
            halted <= (halted || (debug && ctrl.halted)) && (debug || ctrl.halted);
        end
    end

    assign debug_if.halted = halted;

endmodule
