`ifndef SYSTEM__SVH
`define SYSTEM__SVH

`define SYSTEM__XLEN 32
`define SYSTEM__RNUM 32
`define SYSTEM__RVEC 32'd0
`define SYSTEM__NMI  32'd4
`define SYSTEM__TVEC 32'd8
`define SYSTEM__VECT 1'b0

`define SYSTEM__ALEN `SYSTEM__XLEN
`define SYSTEM__BLEN 8

`define SYSTEM__MEM_BASE 32'h0000_0000
//`define SYSTEM__MEM_SIZE (64 * 1024)
`define SYSTEM__MEM_SIZE (32 * 1024)
`define SYSTEM__MEM_INIT "C:/Users/lazar/Desktop/RISC-V_Debug/src/memory/main.mif"
`define SYSTEM__MEM_HINT "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=MAIN"

`define SYSTEM__TIME_BASE 32'hF000_0000

//`define SYSTEM__POR_TIME 50_000_000
`define SYSTEM__POR_TIME 1

`endif  //SYSTEM__SVH
