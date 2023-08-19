`ifndef CSR_IF__SVH
`define CSR_IF__SVH

`include "csr.svh"

interface csr_if;
    `CSRGEN__FOREACH_MCOUNTER(CSRGEN__GENERATE_INTERFACE)
    `CSRGEN__FOREACH_MRW(CSRGEN__GENERATE_INTERFACE)
endinterface

`endif  //CSR_IF__SVH