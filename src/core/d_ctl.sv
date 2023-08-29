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
    input ebreak,

    input [`ISA__XLEN-1:0] pc_reg,
    input [`ISA__XLEN-1:0] pc_next,

    output                  debug,
    output                  halted_ctrl,
    output                  step_en,
    output                  resuming,
    output [`ISA__XLEN-1:0] dpc_out,

    csr_if             csrs,
    control_signals_if ctrl,
    debug_if           debug_if
);
    wire halted;
    wire ctrl_halted     = ctrl.mcp_addr == `CONTROL_SIGNALS__HALTED;
    wire ctrl_resuming   = ctrl.mcp_addr == `CONTROL_SIGNALS__RESUMING;
    wire instruction_end = (ctrl.write_pc && !ctrl_resuming) || interrupt;
    wire trigger_cause   = 1'b0;
    wire ebreak_cause    = ebreak && ctrl.write_pc_ne && `CSR__DCSR_EBREAKM(csrs.DCSR_reg);
    wire halt_cause      = debug_if.halt_req;
    wire step_cause      = step_en && instruction_end;
    wire halt_req        = trigger_cause || ebreak_cause || halt_cause || step_cause;

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

    assign debug   = (debug_reg    || halt_req)                   && !debug_if.resume_req;
    assign halted  = (halted_reg   || (debug_reg && ctrl_halted)) && !ctrl_resuming;

    assign halted_ctrl = halted;
    assign step_en     = `CSR__DCSR_STEP(csrs.DCSR_reg);
    assign resuming    = ctrl_resuming;
    assign dpc_out     = csrs.DPC_reg;

    assign debug_if.halted = halted;

    reg [           2:0] cause;
    reg [`ISA__XLEN-1:0] dpc;

    assign csrs.DCSR_in    = {csrs.DCSR_reg[31:9], cause, csrs.DCSR_reg[5:4], nmi, csrs.DCSR_reg[2:0]};
    assign csrs.DCSR_write = 1'b1;
    assign csrs.DPC_in     = dpc;
    assign csrs.DPC_write  = debug && !debug_reg;

    always_comb begin
        if(trigger_cause) begin
            dpc = pc_reg;
        end else if (ebreak_cause) begin
            dpc = pc_reg;
        end else if (halt_cause) begin
            dpc = ctrl.write_pc_ne ? pc_next : pc_reg;
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
            if(debug && !debug_reg) begin
                if(trigger_cause) begin
                    cause <= `DEBUG__CAUSE_TRIGGER;
                end else if (ebreak_cause) begin
                    cause <= `DEBUG__CAUSE_EBREAK;
                end else if (halt_cause) begin
                    cause <= `DEBUG__CAUSE_HALTREQ;
                end else if (step_cause) begin
                    cause <= `DEBUG__CAUSE_STEP;
                end
            end
        end
    end

endmodule
