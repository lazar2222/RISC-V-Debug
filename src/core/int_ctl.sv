`include "isa.svh"
`include "csr.svh"
`include "csr_if.svh"
`include "priv.svh"
`include "control_signals_if.svh"

module int_ctl (
    control_signals_if ctrl,

    input breakpoint,
    input hit,
    input illegal,
    input ialign,
    input ecall,
    input ebreak,
    input malign,

    csr_if csrs,

    output [`ISA__XLEN-1:0] ivec,
    output trap
);
    wire write_ir   = ctrl.write_ir;
    wire write_pc   = ctrl.write_pc;
    wire store      = ctrl.store;

    wire inst_breakpoint = breakpoint && write_ir;
    wire inst_fault      = !hit       && write_ir;
    wire inst_invalid    = illegal    && write_ir;
    wire inst_align      = ialign     && write_pc;
    wire env_call        = ecall      && write_pc;
    wire env_break       = ebreak     && write_pc;
    wire ls_breakpoint   = breakpoint && write_pc;
    wire l_align         = malign     && write_pc && !store;
    wire l_fault         = !hit       && write_pc && !store;
    wire s_align         = malign     && write_pc && store;
    wire s_fault         = !hit       && write_pc && store;

    wire sync_ex =
    (  inst_breakpoint
    || inst_fault
    || inst_invalid
    || inst_align
    || env_call
    || env_break
    || ls_breakpoint
    || l_align
    || l_fault
    || s_align
    || s_fault
    );

    assign trap = sync_ex;

    reg [`ISA__XLEN-1:0] mcause;

    always_comb begin
        if (inst_breakpoint) begin
            mcause = `PRIV__MCAUSE_BREAKPOINT;
        end else if (inst_fault) begin
            mcause = `PRIV__MCAUSE_INST_FAULT;
        end else if (inst_invalid) begin
            mcause = `PRIV__MCAUSE_INST_ILLEGAL;
        end else if (inst_align) begin
            mcause = `PRIV__MCAUSE_INST_MALIGN;
        end else if (env_call) begin
            mcause = `PRIV__MCAUSE_ENV_CALL;
        end else if (env_break) begin
            mcause = `PRIV__MCAUSE_BREAKPOINT;
        end else if (ls_breakpoint) begin
            mcause = `PRIV__MCAUSE_BREAKPOINT;
        end else if (l_align) begin
            mcause = `PRIV__MCAUSE_LOAD_MALIGN;
        end else if (l_fault) begin
            mcause = `PRIV__MCAUSE_LOAD_FAULT;
        end else if (s_align) begin
            mcause = `PRIV__MCAUSE_STORE_MALIGN;
        end else if (s_fault) begin
            mcause = `PRIV__MCAUSE_STORE_FAULT;
        end else begin
            mcause = `ISA__ZERO;
        end
    end

    assign csrs.MCAUSE_in = mcause;
    assign csrs.MCAUSE_write = trap;

    assign ivec = csrs.MTVEC_reg;

endmodule
