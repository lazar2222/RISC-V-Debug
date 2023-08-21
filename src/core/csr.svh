`ifndef CSR__SVH
`define CSR__SVH

`include "isa.svh"

`define CSR__NUM  4096
`define CSR__ALEN $clog2(`CSR__NUM)

`define CSR__RW_FIELD(addr)    addr[11:10]
`define CSR__DEBUG_FIELD(addr) addr[11:4]

`define CSR__READ_ONLY  2'b11
`define CSR__DEBUG_ONLY 8'h7B

`define CSR__MVENDORID        12'hF11
`define CSR__MARCHID          12'hF12
`define CSR__MIMPID           12'hF13
`define CSR__MHARTID          12'hF14
`define CSR__MCONFIGPTR       12'hF15

`define CSR__MSTATUS          12'h300
`define CSR__MISA             12'h301
`define CSR__MIE              12'h304
`define CSR__MTVEC            12'h305
`define CSR__MSTATUSH         12'h310

`define CSR__MSCRATCH         12'h340
`define CSR__MEPC             12'h341
`define CSR__MCAUSE           12'h342
`define CSR__MTVAL            12'h343
`define CSR__MIP              12'h344

`define CSR__MCYCLE           12'hB00
`define CSR__MINSTRET         12'hB02
`define CSR__MHPMCOUNTER(i)  (12'hB00 + i)
`define CSR__MCYCLEH          12'hB80
`define CSR__MINSTRETH        12'hB82
`define CSR__MHPMCOUNTERH(i) (12'hB83 + i)

`define CSR__MCOUNTINHIBIT    12'h320
`define CSR__MHPMEVENT(i)    (12'h320 + i)

`define CSR__MCYCLE_MASK         32'hFFFFFFFF
`define CSR__MCYCLEH_MASK        32'hFFFFFFFF
`define CSR__MINSTRET_MASK       32'hFFFFFFFF
`define CSR__MINSTRETH_MASK      32'hFFFFFFFF

`define CSR__MSTATUS_MASK        32'h00000088
`define CSR__MSTATUSH_MASK       32'h00000000
`define CSR__MIP_MASK            32'h00000000
`define CSR__MIE_MASK            32'h00000880
`define CSR__MTVEC_MASK          32'hFFFFFFFD
`define CSR__MEPC_MASK           32'hFFFFFFFC
`define CSR__MCAUSE_MASK         32'hFFFFFFFF
`define CSR__MTVAL_MASK          32'hFFFFFFFF
`define CSR__MSCRATCH_MASK       32'hFFFFFFFF
`define CSR__MCOUNTINHIBIT_MASK  32'h00000005

`define CSR__MCYCLE_VALUE        32'h00000000
`define CSR__MCYCLEH_VALUE       32'h00000000
`define CSR__MINSTRET_VALUE      32'h00000000
`define CSR__MINSTRETH_VALUE     32'h00000000

`define CSR__MHPMCOUNTER_VALUE   32'h00000000
`define CSR__MHPMCOUNTERH_VALUE  32'h00000000
`define CSR__MHPMEVENT_VALUE     32'h00000000

`define CSR__MVENDORID_VALUE     32'h00000000
`define CSR__MARCHID_VALUE       32'h00000000
`define CSR__MIMPID_VALUE        32'h00000000
`define CSR__MHARTID_VALUE       32'h00000000
`define CSR__MCONFIGPTR_VALUE    32'h00000000
`define CSR__MISA_VALUE          32'h40000100

`define CSR__MSTATUS_VALUE       32'h00001800
`define CSR__MSTATUSH_VALUE      32'h00000000
`define CSR__MIP_VALUE           32'h00000000
`define CSR__MIE_VALUE           32'h00000000
`define CSR__MTVEC_VALUE         {`ISA__TVEC >> 2,1'b0,`ISA__VECT}
`define CSR__MEPC_VALUE          32'h00000000
`define CSR__MCAUSE_VALUE        32'h00000000
`define CSR__MTVAL_VALUE         32'h00000000
`define CSR__MSCRATCH_VALUE      32'h00000000
`define CSR__MCOUNTINHIBIT_VALUE 32'h00000000

`define CSR__MSTATUS_MPIE(csr)     csr[7]
`define CSR__MSTATUS_MIE(csr)      csr[3]
`define CSR__MSTATUS_MPIE_MASK     32'h00000080
`define CSR__MSTATUS_MIE_MASK      32'h00000008

`define CSR__TVEC_TVEC(csr)        (csr & 32'hFFFFFFFC)
`define CSR__TVEC_VECT(csr)        csr[0]

`define CSR__MI_MEI(csr)           csr[11]
`define CSR__MI_MTI(csr)           csr[7]
`define CSR__MI_MEI_MASK           32'h00000800
`define CSR__MI_MTI_MASK           32'h00000080

`define CSR__MCOUNTINHIBIT_IR(csr) csr[2]
`define CSR__MCOUNTINHIBIT_CY(csr) csr[0]

`define CSR__MCAUSE_TIMER        {1'b1,31'd7}
`define CSR__MCAUSE_EXTI         {1'b1,31'd11}
`define CSR__MCAUSE_NMI          {1'b1,31'd0}
`define CSR__MCAUSE_INST_MALIGN  32'd0
`define CSR__MCAUSE_INST_FAULT   32'd1
`define CSR__MCAUSE_INST_INVALID 32'd2
`define CSR__MCAUSE_BREAKPOINT   32'd3
`define CSR__MCAUSE_LOAD_MALIGN  32'd4
`define CSR__MCAUSE_LOAD_FAULT   32'd5
`define CSR__MCAUSE_STORE_MALIGN 32'd6
`define CSR__MCAUSE_STORE_FAULT  32'd7
`define CSR__MCAUSE_ENV_CALL     32'd11



`define CSRGEN__FOREACH_ARRAY(TARGET, CSR) \
`TARGET(CSR, 3)  \
`TARGET(CSR, 4)  \
`TARGET(CSR, 5)  \
`TARGET(CSR, 6)  \
`TARGET(CSR, 7)  \
`TARGET(CSR, 8)  \
`TARGET(CSR, 9)  \
`TARGET(CSR, 10) \
`TARGET(CSR, 11) \
`TARGET(CSR, 12) \
`TARGET(CSR, 13) \
`TARGET(CSR, 14) \
`TARGET(CSR, 15) \
`TARGET(CSR, 16) \
`TARGET(CSR, 17) \
`TARGET(CSR, 18) \
`TARGET(CSR, 19) \
`TARGET(CSR, 20) \
`TARGET(CSR, 21) \
`TARGET(CSR, 22) \
`TARGET(CSR, 23) \
`TARGET(CSR, 24) \
`TARGET(CSR, 25) \
`TARGET(CSR, 26) \
`TARGET(CSR, 27) \
`TARGET(CSR, 28) \
`TARGET(CSR, 29) \
`TARGET(CSR, 30) \
`TARGET(CSR, 31) \

`define CSRGEN__FOREACH_MCOUNTER(TARGET) \
`TARGET(MCYCLE)    \
`TARGET(MCYCLEH)   \
`TARGET(MINSTRET)  \
`TARGET(MINSTRETH) \

`define CSRGEN__FOREACH_MHPMCOUNTER(TARGET) \
`CSRGEN__FOREACH_ARRAY(TARGET, MHPMCOUNTER)  \
`CSRGEN__FOREACH_ARRAY(TARGET, MHPMCOUNTERH) \
`CSRGEN__FOREACH_ARRAY(TARGET, MHPMEVENT)    \

`define CSRGEN__FOREACH_MRO(TARGET) \
`TARGET(MVENDORID)  \
`TARGET(MARCHID)    \
`TARGET(MIMPID)     \
`TARGET(MHARTID)    \
`TARGET(MCONFIGPTR) \
`TARGET(MISA)       \

`define CSRGEN__FOREACH_MRW(TARGET) \
`TARGET(MSTATUS)       \
`TARGET(MSTATUSH)      \
`TARGET(MIP)           \
`TARGET(MIE)           \
`TARGET(MTVEC)         \
`TARGET(MEPC)          \
`TARGET(MCAUSE)        \
`TARGET(MTVAL)         \
`TARGET(MSCRATCH)      \
`TARGET(MCOUNTINHIBIT) \

`define CSRGEN__GENERATE_INTERFACE(csr) \
reg  [`ISA__XLEN-1:0] ``csr``_reg;   \
tri0 [`ISA__XLEN-1:0] ``csr``_in;    \
tri0                  ``csr``_write; \

`define CSRGEN__GENERATE_READ_ASSIGN(csr) \
assign csr_out = address == `CSR__``csr`` ? csr_interface.``csr``_reg : {`ISA__XLEN{1'bz}}; \
assign hit     = address == `CSR__``csr`` ? 1'b1 : 1'bz;                                    \

`define CSRGEN__GENERATE_READ_ASSIGN_MRO(csr) \
assign csr_out = address == `CSR__``csr`` ? `CSR__``csr``_VALUE : {`ISA__XLEN{1'bz}}; \
assign hit     = address == `CSR__``csr`` ? 1'b1 : 1'bz;                              \

`define CSRGEN__GENERATE_ARRAY_READ_ASSIGN_MRO(csr, i) \
assign csr_out = address == `CSR__``csr``(i) ? `CSR__``csr``_VALUE : {`ISA__XLEN{1'bz}}; \
assign hit     = address == `CSR__``csr``(i) ? 1'b1 : 1'bz;                              \

`define CSRGEN__GENERATE_INITIAL_VALUE(csr) \
csr_interface.``csr``_reg <= `CSR__``csr``_VALUE; \

`define CSRGEN__GENERATE_WRITE(csr) \
if (address == `CSR__``csr`` && write_reg && `CSR__``csr``_MASK != `ISA__ZERO) begin                                                                   \
    csr_interface.``csr``_reg <= (value & `CSR__``csr``_MASK) | (csr_interface.``csr``_reg & ~`CSR__``csr``_MASK); \
end else if (csr_interface.``csr``_write) begin                                                                    \
    csr_interface.``csr``_reg <= csr_interface.``csr``_in;                                                         \
end                                                                                                                \

`define CSRGEN__GENERATE_CONFLICT(csr) \
assign conflict = (address == `CSR__``csr`` && write_reg && `CSR__``csr``_MASK != `ISA__ZERO) ? 1'b1 : 1'bz; \

`endif  //CSR__SVH
