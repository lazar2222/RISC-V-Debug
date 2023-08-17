`ifndef CSR_IF__SVH
`define CSR_IF__SVH

`include "csr.svh"

interface csr_if;
    `CSRGEN__FOREACH(CSRGEN__GENERATE_INTERFACE)
endinterface

`endif
