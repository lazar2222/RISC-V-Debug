`include "isa.svh"
`include "csr.svh"
`include "csr_if.svh"
`include "control_signals_if.svh"
`include "../debug/debug_if.svh"
`include "../debug/debug.svh"

module d_ctl (
    input clk,
    input rst_n,

    input nmi,
    input ebreak,

    input malign,
    input fault,
    input invalid_csr,

    output debug,
    output abstract,
    output step,

    csr_if             csrs,
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
            debug_reg  <= debug;
            halted_reg <= halted;
        end
    end

    assign debug  = (debug_reg  || debug_if.halt_req)          && !debug_if.resume_req;
    assign halted = (halted_reg || (debug_reg && ctrl.halted)) && (debug_reg || ctrl.halted);

    wire memory_error = (malign || fault) && `DEBUG__AC_COMMAND(debug_if.command) == `DEBUG__AC_COMMAND_ACCESS_MEMORY;
    wire csr_error = invalid_csr && `DEBUG__AC_COMMAND(debug_if.command) == `DEBUG__AC_COMMAND_ACCESS_REGISTER && `DEBUG__AC_REG_CSR(debug_if.command);

    assign abstract           = debug_if.exec;
    assign debug_if.halted    = halted;
    assign debug_if.done      = ctrl.abstract_done;
    assign debug_if.write     = ctrl.abstract_write;
    assign debug_if.error     = (memory_error || csr_error) && ctrl.abstract_done;
    assign debug_if.exception = 1'b0;

    reg [2:0] cause;

    assign csrs.DCSR_in    = {csrs.DCSR_reg[31:9], cause, csrs.DCSR_reg[5:4], nmi, csrs.DCSR_reg[2:0]};
    assign csrs.DCSR_write = 1'b1;

    assign step = 1'b0;

endmodule
