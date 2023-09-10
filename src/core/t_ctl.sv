`include "isa.svh"
`include "csr_if.svh"
`include "control_signals_if.svh"

module t_ctl (
    input clk,
    input rst_n,

    input [31:0] pc,
    input [31:0] ir,
    input [31:0] addr,
    input [31:0] mem_out,
    input [31:0] mem_in,
    input [ 1:0] mem_size,

    input debug,

    output trigger,

    control_signals_if ctrl,
    csr_if             csr_interface
);
    reg [1:0] tselect;

    wire [31:0] tdata1[4];
    wire [31:0] tdata2[4];
    wire [31:0] tdata3[4];
    wire [31:0]  tinfo[4];
    wire [ 3:0] triggers;

    wire loada  = ctrl.mcp_addr == `CONTROL_SIGNALS__LOAD;
    wire loadd  = ctrl.mcp_addr == `CONTROL_SIGNALS__LOAD_1;
    wire store  = ctrl.mcp_addr == `CONTROL_SIGNALS__STORE;
    wire retire = ctrl.write_pc && !(ctrl.mcp_addr == `CONTROL_SIGNALS__RESUMING || debug);

    assign trigger = |triggers;
    assign csr_interface.TDATA1_reg  = tdata1[tselect];
    assign csr_interface.TDATA2_reg  = tdata2[tselect];
    assign csr_interface.TDATA3_reg  = tdata3[tselect];
    assign csr_interface.TINFO_reg   = tinfo[tselect];
    assign csr_interface.TSELECT_reg = {30'd0,tselect};
    assign csr_interface.TCONTROL_reg = 32'd0;
    assign csr_interface.MCONTEXT_reg = 32'd0;
    assign csr_interface.SCONTEXT_reg = 32'd0;

    always @(posedge clk) begin
        if (!rst_n) begin
            tselect <= 2'd0;
        end else begin
            if (csr_interface.TSELECT_write && debug) begin
                tselect <= csr_interface.TSELECT_in[1:0];
            end
        end
    end

    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : g_trig
            trigger trigger (
                .clk         (clk),
                .rst_n       (rst_n),
                .tdata1_in   (csr_interface.TDATA1_in),
                .tdata2_in   (csr_interface.TDATA2_in),
                .tdata3_in   (csr_interface.TDATA3_in),
                .tdata1_write(csr_interface.TDATA1_write && tselect == i && debug),
                .tdata2_write(csr_interface.TDATA2_write && tselect == i && debug),
                .tdata3_write(csr_interface.TDATA3_write && tselect == i && debug),
                .tdata1_out  (tdata1[i]),
                .tdata2_out  (tdata2[i]),
                .tdata3_out  (tdata3[i]),
                .tinfo       (tinfo[i]),
                .pc          (pc),
                .ir          (ir),
                .addr        (addr),
                .mem_out     (mem_out),
                .mem_in      (mem_in),
                .mem_size    (mem_size),
                .debug       (debug),
                .retire      (retire),
                .loada       (loada),
                .loadd       (loadd),
                .store       (store),
                .trigger     (triggers[i])
            );
        end
    endgenerate

endmodule
