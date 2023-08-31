`include "debug.svh"
`include "debug_if.svh"
`include "dmi_if.svh"
`include "../system/arilla_bus_if.svh"

module dm (
    input clk,
    input rst_n,

    input  n_trst,
    input  n_rst,

    output vt_ref,
    output reset_n,
    output hart_reset_n,
    output dtm_reset_n,

    dmi_if        dmi,
    debug_if      debug,
    arilla_bus_if bus_interface
);
    reg dmactive;

    always @(posedge clk) begin
        if (!rst_n) begin
            dmactive <= 1'b0;
        end else begin
            if (dmi.address == `DEBUG__DMCONTROL && dmi.write) begin
                dmactive <= `DEBUG__DMCONTROL_DMACTIVE(dmi.data);
            end
        end
    end

    wire dm_reset = !rst_n || !dmactive;

    reg ndmreset, hartreset, hart_reset_tail;
    reg havereset, resumeack;
    reg haltreq, resethaltreq;

    wire resumereq    = dmi.address == `DEBUG__DMCONTROL && dmi.write && `DEBUG__DMCONTROL_RESUMEREQ(dmi.data) && !`DEBUG__DMCONTROL_HALTREQ(dmi.data);
    wire ackhavereset = dmi.address == `DEBUG__DMCONTROL && dmi.write && `DEBUG__DMCONTROL_ACKHAVERESET(dmi.data);

    wire system_reset = !rst_n       || ndmreset || !n_rst;
    wire hart_reset   = system_reset || hartreset;
    wire dtm_reset    = !rst_n       || !n_trst;

    assign vt_ref       = rst_n;
    assign reset_n      = !system_reset;
    assign hart_reset_n = !hart_reset;
    assign dtm_reset_n  = !dtm_reset;

    wire available = !hart_reset;
    wire running   = available && !debug.halted;
    wire halted    = available && debug.halted;

    wire [31:0] dmstatus   = {9'd0,1'b1,2'd0,havereset,havereset,resumeack,resumeack,2'd0,!available,!available,running,running,halted,halted,2'b10,2'b10,4'h2};
    wire [31:0] dmcontrol  = {2'd0,hartreset,27'd0,ndmreset,dmactive};

    assign dmi.data = (dmi.address == `DEBUG__DMSTATUS  && dmi.read) ? dmstatus  : {32{1'bz}};
    assign dmi.data = (dmi.address == `DEBUG__DMCONTROL && dmi.read) ? dmcontrol : {32{1'bz}};

    assign debug.halt_req   = haltreq || (resethaltreq && hart_reset_tail);
    assign debug.resume_req = resumereq;

    always @(posedge clk) begin
        if (dm_reset) begin
            ndmreset        <= 1'b0;
            hartreset       <= 1'b0;
            havereset       <= 1'b0;
            resumeack       <= 1'b0;
            haltreq         <= 1'b0;
            resethaltreq    <= 1'b0;
            hart_reset_tail <= 1'b0;
        end else begin
            havereset       <= (havereset || hart_reset) && !ackhavereset;
            resumeack       <= (resumeack || running)    && !resumereq;
            hart_reset_tail <= hart_reset;
            if (dmi.address == `DEBUG__DMCONTROL && dmi.write) begin
                ndmreset     <= `DEBUG__DMCONTROL_NDMRESET(dmi.data);
                hartreset    <= `DEBUG__DMCONTROL_HARTRESET(dmi.data);
                haltreq      <= `DEBUG__DMCONTROL_HALTREQ(dmi.data);
                resethaltreq <= `DEBUG__DMCONTROL_CLRRESETHALTREQ(dmi.data) ? 1'b0 : `DEBUG__DMCONTROL_SETRESETHALTREQ(dmi.data) ? 1'b1 : resethaltreq;
            end
        end
    end

endmodule
