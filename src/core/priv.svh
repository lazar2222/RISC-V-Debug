`ifndef PRIV__SVH
`define PRIV__SVH

`include "isa.svh"

`define PRIV__MCAUSE_TIMER        {1'b1,31'd7}
`define PRIV__MCAUSE_EXTI         {1'b1,31'd11}
`define PRIV__MCAUSE_NMI          {1'b1,31'd0}
`define PRIV__MCAUSE_RESET        {1'b0,31'd0}
`define PRIV__MCAUSE_INST_MALIGN  32'd0
`define PRIV__MCAUSE_INST_FAULT   32'd1
`define PRIV__MCAUSE_INST_ILLEGAL 32'd2
`define PRIV__MCAUSE_BREAKPOINT   32'd3
`define PRIV__MCAUSE_LOAD_MALIGN  32'd4
`define PRIV__MCAUSE_LOAD_FAULT   32'd5
`define PRIV__MCAUSE_STORE_MALIGN 32'd6
`define PRIV__MCAUSE_STORE_FAULT  32'd7
`define PRIV__MCAUSE_ENV_CALL     32'd11

`endif
