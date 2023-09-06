`include "debug.svh"
`include "debug_if.svh"
`include "dmi_if.svh"
`include "../system/arilla_bus_if.svh"

module dm #(
    parameter logic [11:0] BaseAddress
) (
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
    arilla_bus_if bus_interface,
    output        mem_hit
);
    localparam logic [31:0] FullAddress  = {{20{BaseAddress[11]}},BaseAddress};
    localparam logic [11:0] DataStart    = BaseAddress + (`DEBUG__DATA0_OFFSET * 12'd4);
    localparam int          BusDataWidth = $bits(bus_interface.data_ctp);
    localparam int          DmiDataWidth = $bits(dmi.data);
    localparam int          NumWords     = 32;

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

    reg                    busy, exec;
    reg [             2:0] cmderr, cmderr_next;
    reg [DmiDataWidth-1:0] command;
    reg [DmiDataWidth-1:0] abstractauto;

    `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_INTERFACE)

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

    wire [DmiDataWidth-1:0] dmstatus   = {9'd0,1'b1,2'd0,havereset,havereset,resumeack,resumeack,2'd0,!available,!available,running,running,halted,halted,2'b10,2'b10,4'h2};
    wire [DmiDataWidth-1:0] dmcontrol  = {2'd0,hartreset,27'd0,ndmreset,dmactive};
    wire [DmiDataWidth-1:0] hartinfo   = {`DEBUG__HARTINFO_VALUE,DataStart};
    wire [DmiDataWidth-1:0] abstractcs = {3'd0,5'd16,11'd0,busy,1'b0,cmderr,4'd0,4'd12};
    wire [DmiDataWidth-1:0] haltsum    = {31'd0,halted};

    wor [DmiDataWidth-1:0] data;

    assign data = {DmiDataWidth{1'b0}};
    assign data = dmi.address == `DEBUG__DMSTATUS     ? dmstatus     : {DmiDataWidth{1'b0}};
    assign data = dmi.address == `DEBUG__DMCONTROL    ? dmcontrol    : {DmiDataWidth{1'b0}};
    assign data = dmi.address == `DEBUG__HARTINFO     ? hartinfo     : {DmiDataWidth{1'b0}};
    assign data = dmi.address == `DEBUG__ABSTRACTCS   ? abstractcs   : {DmiDataWidth{1'b0}};
    assign data = dmi.address == `DEBUG__ABSTRACTAUTO ? abstractauto : {DmiDataWidth{1'b0}};
    assign data = dmi.address == `DEBUG__HALTSUM0     ? haltsum      : {DmiDataWidth{1'b0}};

    `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_READ_ASSIGN)

    assign dmi.data = dmi.read ? data : {DmiDataWidth{1'bz}};

    assign debug.halt_req   = haltreq || (resethaltreq && hart_reset_tail);
    assign debug.resume_req = resumereq;
    assign debug.exec       = exec;
    assign debug.command    = command;
    assign debug.data0_in   = DATA0_reg;
    assign debug.data1_in   = DATA1_reg;

    assign DATA0_in    = debug.data0_out;
    assign DATA0_write = debug.write;

    wire [(BusDataWidth*NumWords)-1:0] memory;
    
    wire [BusDataWidth-1:0] mem_out;
    wire [    NumWords-1:0] mem_write;
    
    `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_MEMORY_ASSIGN)
    `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_MEMORY_GUARD_ASSIGN)
    
    wire aar = `DEBUG__AC_COMMAND(command) == `DEBUG__AC_COMMAND_ACCESS_REGISTER;
    wire aqa = `DEBUG__AC_COMMAND(command) == `DEBUG__AC_COMMAND_QUICK_ACCESS;
    wire aam = `DEBUG__AC_COMMAND(command) == `DEBUG__AC_COMMAND_ACCESS_MEMORY;
    
    assign DATA1_in    = DATA0_reg + 32'd1;
    assign DATA1_write = debug.done && aam && `DEBUG__AC_AARPOSTINC(command) && cmderr_next == `DEBUG__AC_ERR_NO_ERR;

    wire busy_err = busy &&
    (  dmi.address == `DEBUG__COMMAND      && dmi.write
    || dmi.address == `DEBUG__ABSTRACTCS   && dmi.write
    || dmi.address == `DEBUG__ABSTRACTAUTO && dmi.write
    `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_BUSY_ERROR)
    );

    wire notsupported_err = (aar && `DEBUG__AC_TRANSFER(command) && `DEBUG__AC_AARSIZE(command) != 3'd2) || (aam && (`DEBUG__AC_AARSIZE(command) == 3'd3 || `DEBUG__AC_AARSIZE(command) == 3'd4)) || (aam && `DEBUG__AC_AAMVIRTUAL(command));
    wire haltresume_err   = (aar && !halted) || (aqa && !running) || (aam && !halted) || (debug.haltresume && exec);

    always_comb begin
        cmderr_next = cmderr;
        if (dmi.address == `DEBUG__ABSTRACTCS && dmi.write) begin
            cmderr_next = cmderr_next & ~(dmi.data[10:8]);
        end
        if (busy) begin
            if(cmderr_next != `DEBUG__AC_ERR_NO_ERR) begin
                cmderr_next = cmderr_next;
            end else if(busy_err) begin
                cmderr_next = `DEBUG__AC_ERR_BUSY;
            end else if(notsupported_err) begin
                cmderr_next = `DEBUG__AC_ERR_NOT_SUPPORTED;
            end else if(debug.exception && exec) begin
                cmderr_next = `DEBUG__AC_ERR_EXCEPTION;
            end else if(haltresume_err) begin
                cmderr_next = `DEBUG__AC_ERR_HALT_RESUME;
            end else if(debug.bus && exec) begin
                cmderr_next = `DEBUG__AC_ERR_BUS;
            end else begin
                cmderr_next = cmderr_next;
            end
        end
    end

    always @(posedge clk) begin
        if (dm_reset) begin
            ndmreset        <= 1'b0;
            hartreset       <= 1'b0;
            havereset       <= 1'b0;
            resumeack       <= 1'b0;
            haltreq         <= 1'b0;
            resethaltreq    <= 1'b0;
            hart_reset_tail <= 1'b0;
            busy            <= 1'b0;
            exec            <= 1'b0;
            cmderr          <= `DEBUG__AC_ERR_NO_ERR;
            command         <= {BusDataWidth{1'b0}};
            abstractauto    <= {BusDataWidth{1'b0}};

            `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_INITIAL_VALUE_SIMPLE)
        end else begin
            havereset       <= (havereset || hart_reset) && !ackhavereset;
            resumeack       <= (resumeack || running)    && !resumereq;
            hart_reset_tail <= hart_reset;
            cmderr          <= cmderr_next;
            exec            <= busy && (cmderr_next == `DEBUG__AC_ERR_NO_ERR || cmderr_next == `DEBUG__AC_ERR_BUSY);
            busy            <= busy && (cmderr      == `DEBUG__AC_ERR_NO_ERR || cmderr      == `DEBUG__AC_ERR_BUSY);
            if (dmi.address == `DEBUG__DMCONTROL && dmi.write) begin
                ndmreset     <= `DEBUG__DMCONTROL_NDMRESET(dmi.data);
                hartreset    <= `DEBUG__DMCONTROL_HARTRESET(dmi.data);
                haltreq      <= `DEBUG__DMCONTROL_HALTREQ(dmi.data);
                resethaltreq <= `DEBUG__DMCONTROL_CLRRESETHALTREQ(dmi.data) ? 1'b0 : `DEBUG__DMCONTROL_SETRESETHALTREQ(dmi.data) ? 1'b1 : resethaltreq;
            end
            `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_WRITE_SIMPLE)
            if(dmi.address == `DEBUG__COMMAND && dmi.write && cmderr == `DEBUG__AC_ERR_NO_ERR && busy == 1'b0) begin
                command <= dmi.data;
                busy    <= 1'b1;
            end
            if(dmi.address == `DEBUG__ABSTRACTAUTO && dmi.write) begin
                abstractauto <= dmi.data && 32'hFFFF0FFF;
            end
            `DEBUGGEN__FOREACH_SIMPLE(DEBUGGEN__GENERATE_AUTOEXEC)
            if (debug.done) begin
                busy <= 1'b0;
                exec <= 1'b0;
                if (aar && `DEBUG__AC_AARPOSTINC(command) && cmderr_next == `DEBUG__AC_ERR_NO_ERR) begin
                    command <= {command[31:16],(command[15:0]+16'd1)};
                end
            end
        end
    end

    periph_mem_interface #(
        .BaseAddress(FullAddress),
        .SizeWords  (NumWords)
    ) periph_mem_interface (
        .clk              (clk),
        .rst_n            (!dm_reset),
        .bus_interface    (bus_interface),
        .hit              (mem_hit),
        .data_periph_in   (memory),
        .data_periph_out  (mem_out),
        .data_periph_write(mem_write)
    );

endmodule
