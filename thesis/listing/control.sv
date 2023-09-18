`define CONTROL__READ_INST   control_signals.addr_sel    = `CONTROL_SIGNALS__ADDR_PC; \
                             control_signals.mem_read    = 1'b1;
`define CONTROL__NEXT_INST   control_signals.write_pc_ne = 1'b1; \
                             `CONTROL__READ_INST
`define CONTROL__ALU_ADDRESS control_signals.alu_insel1  = `CONTROL_SIGNALS__ALU1_RS; \
                             control_signals.alu_insel2  = `CONTROL_SIGNALS__ALU2_IM; \
                             control_signals.addr_sel    = `CONTROL_SIGNALS__ADDR_ALU;
`define CONTROL__WRITE_ALU   control_signals.rd_sel      = `CONTROL_SIGNALS__RD_ALU; \
                             control_signals.write_rd    = 1'b1;
`define CONTROL__WRITE_MEM   control_signals.rd_sel      = `CONTROL_SIGNALS__RD_MEM; \
                             control_signals.write_rd    = 1'b1;
module control ( ... );
    reg [`ISA__OPCODE_WIDTH-1:0] mcp_reg, mcp_next, mcp_addr;

    always @(posedge clk) begin
        if (!rst_n) mcp_reg <= `CONTROL_SIGNALS__PROLOGUE;
        else mcp_reg <= mcp_next;
    end

    always_comb begin
        mcp_addr = mcp_reg;
        if (mcp_reg == `CONTROL_SIGNALS__DISPATCH) mcp_addr = control_signals.opcode;
    end

    assign control_signals.write_ir = !
        (  mcp_reg == `CONTROL_SIGNALS__PROLOGUE
        || mcp_reg == `CONTROL_SIGNALS__LOAD_W
        || mcp_reg == `CONTROL_SIGNALS__LOAD_1
        || mcp_reg == `CONTROL_SIGNALS__STORE_W
        || mcp_reg == `CONTROL_SIGNALS__STORE_1);

    always_comb begin
        control_signals.write_pc    = 1'b0;
        control_signals.write_rd    = 1'b0;
        control_signals.write_csr   = 1'b0;
        control_signals.mem_read    = 1'b0;
        control_signals.mem_write   = 1'b0;
        control_signals.addr_sel    = `CONTROL_SIGNALS__ADDR_PC;
        control_signals.rd_sel      = `CONTROL_SIGNALS__RD_ALU;
        control_signals.alu_insel1  = `CONTROL_SIGNALS__ALU1_RS;
        control_signals.alu_insel2  = `CONTROL_SIGNALS__ALU2_RS;
        case (mcp_addr)
            `CONTROL_SIGNALS__PROLOGUE: begin
                `CONTROL__READ_INST
            end
            `CONTROL_SIGNALS__LUI: begin
                control_signals.alu_insel1 = `CONTROL_SIGNALS__ALU1_ZR;
                control_signals.alu_insel2 = `CONTROL_SIGNALS__ALU2_IM;
                `CONTROL__WRITE_ALU
                `CONTROL__NEXT_INST
            end
            `CONTROL_SIGNALS__AUIPC: begin
                control_signals.alu_insel1 = `CONTROL_SIGNALS__ALU1_PC;
                control_signals.alu_insel2 = `CONTROL_SIGNALS__ALU2_IM;
                `CONTROL__WRITE_ALU
                `CONTROL__NEXT_INST
            end
            `CONTROL_SIGNALS__JAL, `CONTROL_SIGNALS__JALR: begin
                control_signals.alu_insel1 = `CONTROL_SIGNALS__ALU1_PC;
                control_signals.alu_insel2 = `CONTROL_SIGNALS__ALU2_IS;
                `CONTROL__WRITE_ALU
                `CONTROL__NEXT_INST
            end
            `CONTROL_SIGNALS__BRANCH, `CONTROL_SIGNALS__STORE_1, `CONTROL_SIGNALS__MISCMEM: begin
                `CONTROL__NEXT_INST
            end
            `CONTROL_SIGNALS__LOAD, `CONTROL_SIGNALS__LOAD_W: begin
                `CONTROL__ALU_ADDRESS
                control_signals.mem_read = 1'b1;
            end
            `CONTROL_SIGNALS__LOAD_1: begin
                `CONTROL__WRITE_MEM
                `CONTROL__NEXT_INST
            end
            `CONTROL_SIGNALS__STORE, `CONTROL_SIGNALS__STORE_W: begin
                `CONTROL__ALU_ADDRESS
                control_signals.mem_write = 1'b1;
            end
            `CONTROL_SIGNALS__OPIMM: begin
                control_signals.alu_insel1 = `CONTROL_SIGNALS__ALU1_RS;
                control_signals.alu_insel2 = `CONTROL_SIGNALS__ALU2_IM;
                `CONTROL__WRITE_ALU
                `CONTROL__NEXT_INST
            end
            `CONTROL_SIGNALS__OP: begin
                control_signals.alu_insel1 = `CONTROL_SIGNALS__ALU1_RS;
                control_signals.alu_insel2 = `CONTROL_SIGNALS__ALU2_RS;
                `CONTROL__WRITE_ALU
                `CONTROL__NEXT_INST
            end
            `CONTROL_SIGNALS__SYSTEM: begin
                `CONTROL__NEXT_INST
            end
        endcase
    end

    always_comb begin
        case (mcp_addr)
            `CONTROL_SIGNALS__LOAD,
            `CONTROL_SIGNALS__LOAD_W:  mcp_next = control_signals.mem_complete ? `CONTROL_SIGNALS__LOAD_1   : `CONTROL_SIGNALS__LOAD_W;
            `CONTROL_SIGNALS__STORE,
            `CONTROL_SIGNALS__STORE_W: mcp_next = control_signals.mem_complete ? `CONTROL_SIGNALS__STORE_1  : `CONTROL_SIGNALS__STORE_W;
            default:                   mcp_next = control_signals.mem_complete ? `CONTROL_SIGNALS__DISPATCH : `CONTROL_SIGNALS__PROLOGUE;
        endcase
    end
endmodule
