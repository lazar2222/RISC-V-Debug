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

    output tri0 [`ISA__XLEN-1:0] csr_out,
    output                       invalid
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

    always @(posedge clk) begin
        if (!rst_n) begin
            `CSRGEN__FOREACH_MCOUNTER(CSRGEN__GENERATE_INITIAL_VALUE)
            `CSRGEN__FOREACH_MRW(CSRGEN__GENERATE_INITIAL_VALUE)
        end else begin
            `CSRGEN__FOREACH_MCOUNTER(CSRGEN__GENERATE_WRITE)
            `CSRGEN__FOREACH_MRW(CSRGEN__GENERATE_WRITE)
        end
    end

endmodule
