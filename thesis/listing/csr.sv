    assign hit = 1'b0;
    `CSRGEN__FOREACH_MCOUNTER(CSRGEN__GENERATE_READ_ASSIGN)
    `CSRGEN__FOREACH_MHPMCOUNTER(CSRGEN__GENERATE_ARRAY_READ_ASSIGN_MRO)
    `CSRGEN__FOREACH_MRO(CSRGEN__GENERATE_READ_ASSIGN_MRO)
    `CSRGEN__FOREACH_MRW(CSRGEN__GENERATE_READ_ASSIGN)

    assign conflict = 1'b0;
    `CSRGEN__GENERATE_CONFLICT(MSTATUS)
    `CSRGEN__GENERATE_CONFLICT(MCAUSE)
    `CSRGEN__GENERATE_CONFLICT(MTVAL)
    `CSRGEN__GENERATE_CONFLICT(MEPC)

    always @(posedge clk) begin
        if (!rst_n) begin
            `CSRGEN__FOREACH_MCOUNTER(CSRGEN__GENERATE_INITIAL_VALUE)
            `CSRGEN__FOREACH_MRW(CSRGEN__GENERATE_INITIAL_VALUE)
        end else begin
            `CSRGEN__FOREACH_MCOUNTER(CSRGEN__GENERATE_WRITE)
            `CSRGEN__FOREACH_MRW(CSRGEN__GENERATE_WRITE)
        end
    end

    wire [(2*`ISA__XLEN)-1:0] mcycle      = {csr_interface.MCYCLEH_reg,csr_interface.MCYCLE_reg};
    wire [(2*`ISA__XLEN)-1:0] mcycle_next = mcycle + 1'b1;

    assign csr_interface.MCYCLEH_in    = mcycle_next[(2*`ISA__XLEN)-1:`ISA__XLEN];
    assign csr_interface.MCYCLE_in     = mcycle_next[`ISA__XLEN-1:0];
    assign csr_interface.MCYCLE_write  = !`CSR__MCOUNTINHIBIT_CY(csr_interface.MCOUNTINHIBIT_reg) && !(debug && `CSR__DCSR_STOPCOUNT(csr_interface.DCSR_reg));
    assign csr_interface.MCYCLEH_write = !`CSR__MCOUNTINHIBIT_CY(csr_interface.MCOUNTINHIBIT_reg) && !(debug && `CSR__DCSR_STOPCOUNT(csr_interface.DCSR_reg));

    wire [(2*`ISA__XLEN)-1:0] minstret      = {csr_interface.MINSTRETH_reg,csr_interface.MINSTRET_reg};
    wire [(2*`ISA__XLEN)-1:0] minstret_next = minstret + 1'b1;

    assign csr_interface.MINSTRETH_in    = minstret_next[(2*`ISA__XLEN)-1:`ISA__XLEN];
    assign csr_interface.MINSTRET_in     = minstret_next[`ISA__XLEN-1:0];
    assign csr_interface.MINSTRET_write  = retire && !`CSR__MCOUNTINHIBIT_IR(csr_interface.MCOUNTINHIBIT_reg) && !(debug && `CSR__DCSR_STOPCOUNT(csr_interface.DCSR_reg));
    assign csr_interface.MINSTRETH_write = retire && !`CSR__MCOUNTINHIBIT_IR(csr_interface.MCOUNTINHIBIT_reg) && !(debug && `CSR__DCSR_STOPCOUNT(csr_interface.DCSR_reg));

    reg [(2*`ISA__XLEN)-1:0] mtime;
    reg [(2*`ISA__XLEN)-1:0] mtimecmp;

    wire [(4*`ISA__XLEN)-1:0] memory = {mtimecmp,mtime};
    wire [    `ISA__XLEN-1:0] data_periph_out;
    wire [               3:0] data_periph_write;

    always @(posedge clk) begin
        if (!rst_n) begin
            mtime    <= {2*`ISA__XLEN{1'b0}};
            mtimecmp <= {2*`ISA__XLEN{1'b1}};
        end else begin
            if (!(debug && `CSR__DCSR_STOPTIME(csr_interface.DCSR_reg)))
            begin
                mtime <= mtime + 1'd1;
            end
            if (data_periph_write[0]) begin mtime[`ISA__XLEN-1:0]                 <= data_periph_out; end
            if (data_periph_write[1]) begin mtime[(2*`ISA__XLEN)-1:`ISA__XLEN]    <= data_periph_out; end
            if (data_periph_write[2]) begin mtimecmp[`ISA__XLEN-1:0]              <= data_periph_out; end
            if (data_periph_write[3]) begin mtimecmp[(2*`ISA__XLEN)-1:`ISA__XLEN] <= data_periph_out; end
        end
    end

    periph_mem_interface #(
        .BaseAddress(`ISA__TIME_BASE),
        .SizeWords  (4)
    ) periph_mem_interface (
        .clk              (clk),
        .rst_n            (rst_n),
        .bus_interface    (bus_interface),
        .hit              (mem_hit),
        .data_periph_in   (memory),
        .data_periph_out  (data_periph_out),
        .data_periph_write(data_periph_write)
    );

    assign timeint = mtime >= mtimecmp;

endmodule
