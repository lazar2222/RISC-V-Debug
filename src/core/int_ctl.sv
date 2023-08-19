`include "isa.svh"
`include "csr.svh"
`include "csr_if.svh"
`include "control_signals_if.svh"

module int_ctl (
    control_signals_if ctrl,
    csr_if             csrs,

    input breakpoint,
    input fault,
    input invalid_inst,
    input invalid_csr,
    input ialign,
    input ecall,
    input ebreak,
    input malign,

    output [`ISA__XLEN-1:0] tvec,
    output                  exception,
    output                  interrupt
);
    wire instruction_start = ctrl.write_ir;
    wire instruction_end   = ctrl.write_pc;
    wire load              = ctrl.load_op;
    wire csr               = ctrl.write_csr;

    wire inst_breakpoint = breakpoint   && instruction_start;
    wire inst_fault      = fault        && instruction_start;
    wire inst_invalid    = invalid_inst && instruction_start;
    wire csr_invalid     = invalid_csr  && instruction_start && csr;
    wire inst_align      = ialign       && instruction_end;
    wire env_call        = ecall        && instruction_end;
    wire env_break       = ebreak       && instruction_end;
    wire ls_breakpoint   = breakpoint   && instruction_end;
    wire l_align         = malign       && instruction_end && load;
    wire l_fault         = fault        && instruction_end && load;
    wire s_align         = malign       && instruction_end && !load;
    wire s_fault         = fault        && instruction_end && !load;

    assign exception =
    (  inst_breakpoint
    || inst_fault
    || inst_invalid
    || csr_invalid
    || inst_align
    || env_call
    || env_break
    || ls_breakpoint
    || l_align
    || l_fault
    || s_align
    || s_fault
    );

    assign interrupt = 1'b0;

    reg [`ISA__XLEN-1:0] mcause;

    always_comb begin
        if (inst_breakpoint) begin
            mcause = `CSR__MCAUSE_BREAKPOINT;
        end else if (inst_fault) begin
            mcause = `CSR__MCAUSE_INST_FAULT;
        end else if (inst_invalid) begin
            mcause = `CSR__MCAUSE_INST_INVALID;
        end else if (csr_invalid) begin
            mcause = `CSR__MCAUSE_INST_INVALID;
        end else if (inst_align) begin
            mcause = `CSR__MCAUSE_INST_MALIGN;
        end else if (env_call) begin
            mcause = `CSR__MCAUSE_ENV_CALL;
        end else if (env_break) begin
            mcause = `CSR__MCAUSE_BREAKPOINT;
        end else if (ls_breakpoint) begin
            mcause = `CSR__MCAUSE_BREAKPOINT;
        end else if (l_align) begin
            mcause = `CSR__MCAUSE_LOAD_MALIGN;
        end else if (l_fault) begin
            mcause = `CSR__MCAUSE_LOAD_FAULT;
        end else if (s_align) begin
            mcause = `CSR__MCAUSE_STORE_MALIGN;
        end else if (s_fault) begin
            mcause = `CSR__MCAUSE_STORE_FAULT;
        end else begin
            mcause = `ISA__ZERO;
        end
    end

    assign csrs.MCAUSE_in    = mcause;
    assign csrs.MCAUSE_write = exception;
    assign tvec              = csrs.MTVEC_reg;

endmodule
