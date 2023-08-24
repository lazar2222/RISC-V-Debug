`ifndef DEBUG_IF__SVH
`define DEBUG_IF__SVH

interface debug_if;
    wire        halt_req;
    wire        resume_req;
    wire        exec;
    wire [31:0] command;
    wire [31:0] data0_in;
    wire [31:0] data1_in;

    wire        halted;
    wire        done;
    wire        write;
    wire [31:0] data0_out;
endinterface

`endif  //DEBUG_IF__SVH
