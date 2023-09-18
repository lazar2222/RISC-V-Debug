// Primer makroa koji definise CSR registar
`define CSR__MVENDORID 12'hF11 // Adresa
`define CSR__MCYCLE_MASK 32'hFFFFFFFF // Maska bita koji mogu biti upisani
`define CSR__MCYCLE_VALUE 32'h00000000 // Podrazumevana vrednost
`define CSR__MSTATUS_MPP(csr) csr[12:11] // Makroi za pristup poljima

// Makroi koji definisu srodne grupe registara
`define CSRGEN__FOREACH_ARRAY(TARGET, CSR) \
`TARGET(CSR, 3) \
...
`TARGET(CSR, 31)

`define CSRGEN__FOREACH_MCOUNTER(TARGET) \
`TARGET(MCYCLE) \
...

`define CSRGEN__FOREACH_MHPMCOUNTER(TARGET) \
`CSRGEN__FOREACH_ARRAY(TARGET, MHPMCOUNTER) \
...

`define CSRGEN__FOREACH_MRO(TARGET) \
`TARGET(MVENDORID) \
...

`define CSRGEN__FOREACH_MRW(TARGET) \
`TARGET(MSTATUS) \
...

// Makroi koji definisu hardver
`define CSRGEN__GENERATE_INTERFACE(csr) \
reg  [`ISA__XLEN-1:0] ``csr``_reg;\
wire [`ISA__XLEN-1:0] ``csr``_in;\
wire                  ``csr``_write;

`define CSRGEN__GENERATE_READ_ASSIGN(csr) \
assign csr_out = address == `CSR__``csr`` ? csr_interface.``csr``_reg : 32'bz;\
assign hit     = address == `CSR__``csr``;

`define CSRGEN__GENERATE_READ_ASSIGN_MRO(csr) \
assign csr_out = address == `CSR__``csr`` ? `CSR__``csr``_VALUE : 32'bz;\
assign hit     = address == `CSR__``csr``;

`define CSRGEN__GENERATE_ARRAY_READ_ASSIGN_MRO(csr, i) \
assign csr_out = address == `CSR__``csr``(i) ? `CSR__``csr``_VALUE : 32'bz;\
assign hit     = address == `CSR__``csr``(i);

`define CSRGEN__GENERATE_INITIAL_VALUE(csr) \
csr_interface.``csr``_reg <= `CSR__``csr``_VALUE;

`define CSRGEN__GENERATE_WRITE(csr) \
if (address == `CSR__``csr`` && write_reg && `CSR__``csr``_MASK != `ISA__ZERO) begin\
    csr_interface.``csr``_reg <= (value & `CSR__``csr``_MASK) | (csr_interface.``csr``_reg & ~`CSR__``csr``_MASK);\
end else if (csr_interface.``csr``_write) begin\
    csr_interface.``csr``_reg <= csr_interface.``csr``_in;\
end

`define CSRGEN__GENERATE_CONFLICT(csr) \
assign conflict = (address == `CSR__``csr`` && write_reg && `CSR__``csr``_MASK != `ISA__ZERO);