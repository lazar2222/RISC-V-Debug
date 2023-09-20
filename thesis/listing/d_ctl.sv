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
    input interrupt,
    input exception,
    input eb,
    input trig,

    input malign,
    input fault,
    input invalid_csr,

    input [`ISA__XLEN-1:0] pc_reg,
    input [`ISA__XLEN-1:0] pc_next,

    output                  debug,
    output                  halted,
    output                  halted_ctrl,
    output                  step_en,
    output                  resuming,
    output                  abstract,
    output                  reg_error,
    output [`ISA__XLEN-1:0] dpc_out,

    csr_if             csrs,
    control_signals_if ctrl,
    debug_if           debug_if
);
    wire progbuf;
    wire ebreak            = eb && ctrl.write_pc_ne;
    wire ctrl_halted       = ctrl.mcp_addr == `CONTROL_SIGNALS__HALTED;
    wire ctrl_resuming     = ctrl.mcp_addr == `CONTROL_SIGNALS__RESUMING;
    wire instruction_end   = (ctrl.write_pc && !ctrl_resuming) || interrupt;
    wire trigger_cause     = trig;
    wire ebreak_cause      = ebreak && `CSR__DCSR_EBREAKM(csrs.DCSR_reg) && !interrupt;
    wire halt_cause        = debug_if.halt_req;
    wire step_cause        = step_en && instruction_end;
    wire quickaccess_cause = `DEBUG__AC_COMMAND(debug_if.command) == `DEBUG__AC_COMMAND_QUICK_ACCESS && debug_if.exec;
    wire halt_req=trigger_cause||ebreak_cause||halt_cause||step_cause||quickaccess_cause;

    reg debug_reg;
    reg halted_reg;
    reg progbuf_reg;

    always @(posedge clk) begin
        if (!rst_n) begin
            debug_reg  <= 1'b0;
            halted_reg <= 1'b0;
            progbuf_reg <= 1'b0;
        end else begin
            debug_reg   <= debug && !(debug_if.done && quickaccess_cause);
            halted_reg  <= halted;
            progbuf_reg <= progbuf;
        end
    end

    assign debug  = (debug_reg    || halt_req)                   && !debug_if.resume_req;
    assign halted = (halted_reg   || (debug_reg && ctrl_halted)) && !ctrl_resuming;
    assign progbuf= (progbuf_reg  || ctrl.progbuf)               && !debug_if.done;

    assign halted_ctrl = halted && !(ebreak && progbuf_reg);
    assign step_en     = `CSR__DCSR_STEP(csrs.DCSR_reg);
    assign resuming    = ctrl_resuming;
    assign abstract    = debug_if.exec && !progbuf_reg && halted_reg;
    assign dpc_out     = csrs.DPC_reg;

    reg [           2:0] cause;
    reg [`ISA__XLEN-1:0] dpc;

    wire aar= `DEBUG__AC_COMMAND(debug_if.command) == `DEBUG__AC_COMMAND_ACCESS_REGISTER;
    wire aqa= `DEBUG__AC_COMMAND(debug_if.command) == `DEBUG__AC_COMMAND_QUICK_ACCESS;
    wire aam= `DEBUG__AC_COMMAND(debug_if.command) == `DEBUG__AC_COMMAND_ACCESS_MEMORY;

    assign reg_error      = (aar && ctrl.mcp_addr == `CONTROL_SIGNALS__ABS_REG && `DEBUG__AC_TRANSFER(debug_if.command)) && !(`DEBUG__AC_REG_GPR(debug_if.command) || (`DEBUG__AC_REG_CSR(debug_if.command) && !invalid_csr));
    wire   postexec_error = exception && !ebreak;
    wire   autohalt_error = aqa && cause != `DEBUG__CAUSE_HALTREQ && halted_reg;
    wire   bus_error      = aam && (malign || fault);

    assign debug_if.halted = halted;
    assign debug_if.done=ctrl.abstract_done||(ebreak && progbuf_reg)||postexec_error;
    assign debug_if.write = ctrl.abstract_write && !(reg_error || bus_error);
    assign debug_if.bus = bus_error;
    assign debug_if.haltresume = autohalt_error;
    assign debug_if.exception = reg_error || postexec_error;

    assign csrs.DCSR_in={csrs.DCSR_reg[31:9],cause,csrs.DCSR_reg[5:4],nmi,csrs.DCSR_reg[2:0]};
    assign csrs.DCSR_write = 1'b1;
    assign csrs.DPC_in     = dpc;
    assign csrs.DPC_write  = debug && !debug_reg;

    always_comb begin
        if (trigger_cause) begin
            dpc = pc_reg;
        end else if (ebreak_cause) begin
            dpc = pc_reg;
        end else if (halt_cause || quickaccess_cause) begin
            dpc = ctrl.mcp_addr == `CONTROL_SIGNALS__PROLOGUE ? pc_reg : pc_next;
        end else if (step_cause) begin
            dpc = pc_next;
        end else begin
            dpc = `ISA__ZERO;
        end
    end

    always @(posedge clk) begin;
        if (!rst_n) begin
            cause <= 3'd0;
        end else begin
            if (debug && !debug_reg) begin
                if (trigger_cause) begin
                    cause <= `DEBUG__CAUSE_TRIGGER;
                end else if (ebreak_cause) begin
                    cause <= `DEBUG__CAUSE_EBREAK;
                end else if (halt_cause || quickaccess_cause) begin
                    cause <= `DEBUG__CAUSE_HALTREQ;
                end else if (step_cause) begin
                    cause <= `DEBUG__CAUSE_STEP;
                end
            end
        end
    end

endmodule
