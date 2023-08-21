`include "csr.svh"
`include "csr_if.svh"
`include "../system/arilla_bus_if.svh"

module csr (
    input clk,
    input rst_n,

    csr_if        csr_interface,
    arilla_bus_if bus_interface,

    input [ `ISA__XLEN-1:0] reg_in,
    input [ `ISA__XLEN-1:0] imm_in,
    input [ `ISA__XLEN-1:0] addr,
    input [`ISA__RFLEN-1:0] rs,

    input [`ISA__FUNCT3_WIDTH-1:0] f3,

    input write,
    input debug,
    input retire,

    output tri0 [`ISA__XLEN-1:0] csr_out,
    output                       invalid,
    output tri0                  conflict
);
    wire [`CSR__ALEN-1:0] address     = addr[`CSR__ALEN-1:0];
    wire [`ISA__XLEN-1:0] mask        = f3[2] ? imm_in : reg_in;
    wire [`ISA__XLEN-1:0] set_value   =   mask  | csr_out;
    wire [`ISA__XLEN-1:0] clear_value = (~mask) & csr_out;
    wire [`ISA__XLEN-1:0] value       = f3[1] ? (f3[0] ? clear_value : set_value ) : mask;

    tri0 hit;
    wire rs_zero   = rs     == {`ISA__RFLEN{1'b0}};
    wire imm_zero  = imm_in == { `ISA__XLEN{1'b0}};
    wire write_csr = !(f3[1] && (f3[2] ? imm_zero : rs_zero));

    assign invalid = !hit || (write_csr && `CSR__RW_FIELD(address) == `CSR__READ_ONLY) || (!debug && `CSR__DEBUG_FIELD(address) == `CSR__DEBUG_ONLY);

    wire write_reg = write && write_csr && !invalid;

    `CSRGEN__FOREACH_MCOUNTER(CSRGEN__GENERATE_READ_ASSIGN)
    `CSRGEN__FOREACH_MHPMCOUNTER(CSRGEN__GENERATE_ARRAY_READ_ASSIGN_MRO)
    `CSRGEN__FOREACH_MRO(CSRGEN__GENERATE_READ_ASSIGN_MRO)
    `CSRGEN__FOREACH_MRW(CSRGEN__GENERATE_READ_ASSIGN)

    `CSRGEN__GENERATE_CONFLICT(MSTATUS)
    `CSRGEN__GENERATE_CONFLICT(MCAUSE)
    `CSRGEN__GENERATE_CONFLICT(MTVAL)
    `CSRGEN__GENERATE_CONFLICT(MEPC)

    always @(posedge clk) begin
        if (!rst_n) begin
            `CSRGEN__FOREACH_MCOUNTER(CSRGEN__GENERATE_INITIAL_VALUE)
            `CSRGEN__FOREACH_MRW(CSRGEN__GENERATE_INITIAL_VALUE)
        end else begin
            `CSRGEN__FOREACH_MCOUNTER(CSRGEN__GENERATE_WRITE)
            `CSRGEN__FOREACH_MRW(CSRGEN__GENERATE_WRITE)
        end
    end

    wire [(2*`ISA__XLEN)-1:0] mcycle      = {csr_interface.MCYCLEH_reg,csr_interface.MCYCLE_reg};
    wire [(2*`ISA__XLEN)-1:0] mcycle_next = mcycle + 1'b1;

    assign csr_interface.MCYCLE_in  = mcycle_next[(2*`ISA__XLEN)-1:`ISA__XLEN];
    assign csr_interface.MCYCLEH_in = mcycle_next[`ISA__XLEN-1:0];
    assign csr_interface.MCYCLE_write  = !`CSR__MCOUNTINHIBIT_CY(csr_interface.MCOUNTINHIBIT_reg);
    assign csr_interface.MCYCLEH_write = !`CSR__MCOUNTINHIBIT_CY(csr_interface.MCOUNTINHIBIT_reg);

    wire [(2*`ISA__XLEN)-1:0] minstret      = {csr_interface.MINSTRETH_reg,csr_interface.MINSTRET_reg};
    wire [(2*`ISA__XLEN)-1:0] minstret_next = minstret + 1'b1;

    assign csr_interface.MINSTRET_in  = minstret_next[(2*`ISA__XLEN)-1:`ISA__XLEN];
    assign csr_interface.MINSTRETH_in = minstret_next[`ISA__XLEN-1:0];
    assign csr_interface.MINSTRET_write  = retire && !`CSR__MCOUNTINHIBIT_IR(csr_interface.MCOUNTINHIBIT_reg);
    assign csr_interface.MINSTRETH_write = retire && !`CSR__MCOUNTINHIBIT_IR(csr_interface.MCOUNTINHIBIT_reg);

endmodule
