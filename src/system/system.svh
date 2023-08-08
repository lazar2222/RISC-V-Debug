`ifndef SYSTEM__SVH
`define SYSTEM__SVH

`define SYSTEM__XLEN 32
`define SYSTEM__RNUM 32
`define SYSTEM__RVEC 32'd0
`define SYSTEM__MEXT  1'b0

`define SYSTEM__ALEN `SYSTEM__XLEN
`define SYSTEM__BLEN 8

`define SYSTEM__MEM_BASE 32'h00000000
`define SYSTEM__MEM_SIZE 65536
`define SYSTEM__MEM_INIT "C:/Users/lazar/Desktop/RISC-V_Debug/src/memory/main.mif"
`define SYSTEM__MEM_HINT "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=MAIN"

`endif
