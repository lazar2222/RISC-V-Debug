`include "isa.svh"
`include "csr.svh"
`include "csr_if.svh"
`include "control_signals_if.svh"

module int_ctl (
    control_signals_if ctrl,
    csr_if             csrs,

    input nmi,
    input exti,
    input timer,

    input breakpoint,
    input fault,
    input invalid_inst,
    input invalid_csr,
    input ialign,
    input ecall,
    input ebreak,
    input malign,

    input mret,

    input conflict,

    input  [`ISA__XLEN-1:0] pc,
    input  [`ISA__XLEN-1:0] next_pc,
    input  [`ISA__XLEN-1:0] mem_addr,
    input  [`ISA__XLEN-1:0] ir,

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

    assign `CSR__MI_MEI(csrs.MIP_in) = exti;
    assign `CSR__MI_MTI(csrs.MIP_in) = timer;
    assign csrs.MIP_write = 1'b1;

    wire interrupt_enabled = `CSR__MSTATUS_MIE(csrs.MSTATUS_reg);
    wire exti_enabled      = `CSR__MI_MEI(csrs.MIE_reg);
    wire timer_enabled     = `CSR__MI_MTI(csrs.MIE_reg);
    wire exti_interrupt    = exti  && exti_enabled  && interrupt_enabled;
    wire timer_interrupt   = timer && timer_enabled && interrupt_enabled;

    assign interrupt = !conflict && (instruction_end || exception) &&
    (  nmi
    || exti_interrupt
    || timer_interrupt
    );

    wire ret     = mret && !exception;
    wire trap    = exception || interrupt || ret;
    wire trap_nm = exception || (interrupt && !ret);

    assign `CSR__MSTATUS_MPIE(csrs.MSTATUS_in) = ret ? 1'b1 :`CSR__MSTATUS_MIE(csrs.MSTATUS_reg);
    assign `CSR__MSTATUS_MIE(csrs.MSTATUS_in)  = ret ? `CSR__MSTATUS_MPIE(csrs.MSTATUS_reg) : 1'b0;
    assign csrs.MSTATUS_write = trap;

    reg [`ISA__XLEN-1:0] mcause;
    reg [`ISA__XLEN-1:0] mtval;

    always_comb begin
        if (nmi) begin
            mcause = `CSR__MCAUSE_NMI;
            mtval  = `ISA__ZERO;
        end else if (exti_interrupt) begin
            mcause = `CSR__MCAUSE_EXTI;
            mtval  = `ISA__ZERO;
        end else if (timer_interrupt) begin
            mcause = `CSR__MCAUSE_NMI;
            mtval  = `ISA__ZERO;
        end else if (inst_breakpoint) begin
            mcause = `CSR__MCAUSE_BREAKPOINT;
            mtval  = mem_addr;
        end else if (inst_fault) begin
            mcause = `CSR__MCAUSE_INST_FAULT;
            mtval  = mem_addr;
        end else if (inst_invalid) begin
            mcause = `CSR__MCAUSE_INST_INVALID;
            mtval  = ir;
        end else if (csr_invalid) begin
            mcause = `CSR__MCAUSE_INST_INVALID;
            mtval  = ir;
        end else if (inst_align) begin
            mcause = `CSR__MCAUSE_INST_MALIGN;
            mtval  = mem_addr;
        end else if (env_call) begin
            mcause = `CSR__MCAUSE_ENV_CALL;
            mtval  = `ISA__ZERO;
        end else if (env_break) begin
            mcause = `CSR__MCAUSE_BREAKPOINT;
            mtval  = `ISA__ZERO;
        end else if (ls_breakpoint) begin
            mcause = `CSR__MCAUSE_BREAKPOINT;
            mtval  = mem_addr;
        end else if (l_align) begin
            mcause = `CSR__MCAUSE_LOAD_MALIGN;
            mtval  = mem_addr;
        end else if (l_fault) begin
            mcause = `CSR__MCAUSE_LOAD_FAULT;
            mtval  = mem_addr;
        end else if (s_align) begin
            mcause = `CSR__MCAUSE_STORE_MALIGN;
            mtval  = mem_addr;
        end else if (s_fault) begin
            mcause = `CSR__MCAUSE_STORE_FAULT;
            mtval  = mem_addr;
        end else begin
            mcause = `ISA__ZERO;
            mtval  = `ISA__ZERO;
        end
    end

    assign csrs.MTVAL_in     = mtval;
    assign csrs.MCAUSE_in    = mcause;
    assign csrs.MCAUSE_write = trap_nm;
    assign csrs.MTVAL_write  = trap_nm;

    assign csrs.MEPC_in    = exception ? pc : next_pc;
    assign csrs.MEPC_write = trap_nm;

    wire trap_vector = `CSR__TVEC_TVEC(csrs.TVEC_reg) + ((`CSR__TVEC_VECT(csrs.TVEC_reg) && interrupt) ? {mcause[29:0], 2'b0} : `ISA__ZERO);
    wire mret_vector = csrs.MEPC_reg;

    assign tvec = ret ? mret_vector : trap_vector;

endmodule
