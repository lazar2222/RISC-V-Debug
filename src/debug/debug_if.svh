`ifndef DEBUG_IF__SVH
`define DEBUG_IF__SVH

interface debug_if;
    wire        halt_req;
    wire        resume_req;

    wire        halted;
endinterface

`endif  //DEBUG_IF__SVH
