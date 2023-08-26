`include "debug.svh"
`include "debug_if.svh"
`include "dmi_if.svh"

module dm (
    input clk,
    input rst_n,

    output reset_n,
    output hart_reset_n,

    dmi_if   dmi,
    debug_if debug
);
    reg dmactive;

    always @(posedge clk) begin
        if(!rst_n) begin
            dmactive <= 1'b0;
        end else begin
            if(dmi.address == `DEBUG__DMCONTROL && dmi.write) begin
                dmactive <= dmi.data[0];
            end
        end
    end

    wire dm_reset = !rst_n || !dmactive;

    reg        ndmreset, hartreset;
    reg        haltonreset, haltreq;
    reg        havereset, resumeack;
    reg        busy;
    reg [ 2:0] cmderr, cmderr_next;
    reg [31:0] command;
    reg [31:0] abstractauto;

    `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_INTERFACE)

    wire resumereq    = dmi.address == `DEBUG__DMCONTROL && dmi.write && dmi.data[30];
    wire ackhavereset = dmi.address == `DEBUG__DMCONTROL && dmi.write && dmi.data[28];

    always @(posedge clk) begin
        if(dm_reset) begin
            ndmreset     <= 1'b0;
            hartreset    <= 1'b0;
            haltonreset  <= 1'b0;
            haltreq      <= 1'b0;
            busy         <= 1'b0;
            cmderr       <= 3'd0;
            command      <= 32'd0;
            abstractauto <= 32'd0;

            `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_INITIAL_VALUE_SIMPLE)
        end else begin
            if(dmi.address == `DEBUG__DMCONTROL && dmi.write) begin
                haltreq     <= dmi.data[31];
                hartreset   <= dmi.data[29];
                haltonreset <= dmi.data[2] ? 1'b0 : dmi.data[3] ? 1'b1 : haltonreset;
                ndmreset    <= dmi.data[1];
            end
            if(dmi.address == `DEBUG__COMMAND && dmi.write && cmderr == 3'd0) begin
                command <= dmi.data;
                busy    <= 1'b1;
            end
            if(dmi.address == `DEBUG__ABSTRACTAUTO && dmi.write) begin
                abstractauto <= dmi.data && 32'hFFFF0FFF;
            end

            `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_WRITE_SIMPLE)
            `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_AUTOEXEC)

            if (debug.done) begin
                busy <= 1'b0;
            end

            cmderr <= cmderr_next;
        end
    end

    wire system_reset = !rst_n || ndmreset;
    wire hart_reset   = system_reset || hartreset;

    assign reset_n      = !system_reset;
    assign hart_reset_n = !hart_reset;

    wire available = !hart_reset;
    wire running   = available && !debug.halted;
    wire halted    = available && debug.halted;

    assign DATA0_in    = debug.data0_out;
    assign DATA0_write = debug.write;

    wire [31:0] dmstatus   = {9'd0,1'b1,2'd0,havereset,havereset,resumeack,resumeack,2'd0,!available,!available,running,running,halted,halted,2'b10,2'b10,4'h2};
    wire [31:0] dmcontrol  = {2'd0,hartreset,27'd0,ndmreset,dmactive};
    wire [31:0] abstractcs = {3'd0,5'd16,11'd0,busy,1'b0,cmderr,4'd0,4'd12};

    assign dmi.data = (dmi.address == `DEBUG__DMSTATUS     && dmi.read) ? dmstatus               : {32{1'bz}};
    assign dmi.data = (dmi.address == `DEBUG__DMCONTROL    && dmi.read) ? dmcontrol              : {32{1'bz}};
    assign dmi.data = (dmi.address == `DEBUG__HARTINFO     && dmi.read) ? `DEBUG__HARTINFO_VALUE : {32{1'bz}};
    assign dmi.data = (dmi.address == `DEBUG__ABSTRACTCS   && dmi.read) ? abstractcs             : {32{1'bz}};
    assign dmi.data = (dmi.address == `DEBUG__ABSTRACTAUTO && dmi.read) ? abstractauto           : {32{1'bz}};
    `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_READ_ASSIGN)
    assign dmi.data = (dmi.address == `DEBUG__HALTSUM0     && dmi.read)   ? {31'd0,halted}       : {32{1'bz}};

    assign debug.halt_req   = haltreq;
    assign debug.resume_req = resumereq;
    assign debug.exec       = busy;
    assign debug.command    = command;
    assign debug.data0_in   = DATA0_reg;
    assign debug.data1_in   = DATA1_reg;

    always @(posedge clk) begin
        if(dm_reset) begin
            havereset   <= 1'b0;
            resumeack   <= 1'b0;
        end else begin
            havereset <= (havereset || hart_reset)                             && !ackhavereset;
            resumeack <= (resumeack || running)                                && !resumereq;
        end
    end

    wire busy_err = busy &&
    (  dmi.address == `DEBUG__COMMAND      && dmi.write
    || dmi.address == `DEBUG__ABSTRACTCS   && dmi.write
    || dmi.address == `DEBUG__ABSTRACTAUTO && dmi.write
    `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_BUSY_ERROR)
    );

    wire notsupported_err = 1'b0;
    wire haltresume_err   = 1'b0;

    always_comb begin
        if (dmi.address == `DEBUG__ABSTRACTCS && dmi.write) begin
            cmderr_next = cmderr & ~(dmi.data[10:8]);
        end else if(cmderr != 3'd0) begin
            cmderr_next = cmderr;
        end else if(busy_err) begin
            cmderr_next = 3'd1;
        end else if(notsupported_err) begin
            cmderr_next = 3'd2;
        end else if(debug.exception) begin
            cmderr_next = 3'd3;
        end else if(haltresume_err) begin
            cmderr_next = 3'd4;
        end else if(debug.error) begin
            cmderr_next = 3'd5;
        end else begin
            cmderr_next = cmderr;
        end
    end

endmodule
