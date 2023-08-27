`include "control_signals_if.svh"
`include "isa.svh"

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

module control (
    input clk,
    input rst_n,

    input exception,
    input interrupt_pending,

    control_signals_if control_signals
);
    localparam logic [`ISA__OPCODE_WIDTH-1:0] PROLOGUE = 5'b10_000;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] DISPATCH = 5'b10_001;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] LUI      = `ISA__OPCODE_LUI;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] AUIPC    = `ISA__OPCODE_AUIPC;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] JAL      = `ISA__OPCODE_JAL;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] JALR     = `ISA__OPCODE_JALR;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] BRANCH   = `ISA__OPCODE_BRANCH;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] LOAD     = `ISA__OPCODE_LOAD;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] LOAD_W   = `ISA__OPCODE_LOAD  + 5'd1;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] LOAD_1   = `ISA__OPCODE_LOAD  + 5'd2;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] STORE    = `ISA__OPCODE_STORE;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] STORE_W  = `ISA__OPCODE_STORE + 5'd1;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] STORE_1  = `ISA__OPCODE_STORE + 5'd2;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] OPIMM    = `ISA__OPCODE_OPIMM;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] OP       = `ISA__OPCODE_OP;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] MISCMEM  = `ISA__OPCODE_MISCMEM;
    localparam logic [`ISA__OPCODE_WIDTH-1:0] SYSTEM   = `ISA__OPCODE_SYSTEM;

    reg [`ISA__OPCODE_WIDTH-1:0] mcp_reg, mcp_next, mcp_addr;

    always @(posedge clk) begin
        if (!rst_n) begin
            mcp_reg <= PROLOGUE;
        end else begin
            mcp_reg <= mcp_next;
        end
    end

    always_comb begin
        mcp_addr = mcp_reg;
        if (mcp_reg == DISPATCH) begin
            mcp_addr = control_signals.opcode;
        end
    end

    assign control_signals.write_ir = !
        (  mcp_reg == PROLOGUE
        || mcp_reg == LOAD_W
        || mcp_reg == LOAD_1
        || mcp_reg == STORE_W
        || mcp_reg == STORE_1
        );

    assign control_signals.write_pc = control_signals.write_pc_ne || control_signals.write_pc_ex;

    always_comb begin
        control_signals.write_pc_ne = 1'b0;
        control_signals.write_pc_ex = 1'b0;
        control_signals.write_rd    = 1'b0;
        control_signals.write_csr   = 1'b0;
        control_signals.mem_read    = 1'b0;
        control_signals.mem_write   = 1'b0;
        control_signals.addr_sel    = `CONTROL_SIGNALS__ADDR_PC;
        control_signals.rd_sel      = `CONTROL_SIGNALS__RD_ALU;
        control_signals.alu_insel1  = `CONTROL_SIGNALS__ALU1_RS;
        control_signals.alu_insel2  = `CONTROL_SIGNALS__ALU2_RS;
        case (mcp_addr)
            PROLOGUE: begin
                `CONTROL__READ_INST
            end
            LUI: begin
                control_signals.alu_insel1 = `CONTROL_SIGNALS__ALU1_ZR;
                control_signals.alu_insel2 = `CONTROL_SIGNALS__ALU2_IM;
                `CONTROL__WRITE_ALU

                `CONTROL__NEXT_INST
            end
            AUIPC: begin
                control_signals.alu_insel1 = `CONTROL_SIGNALS__ALU1_PC;
                control_signals.alu_insel2 = `CONTROL_SIGNALS__ALU2_IM;
                `CONTROL__WRITE_ALU

                `CONTROL__NEXT_INST
            end
            JAL, JALR: begin
                control_signals.alu_insel1 = `CONTROL_SIGNALS__ALU1_PC;
                control_signals.alu_insel2 = `CONTROL_SIGNALS__ALU2_IS;
                `CONTROL__WRITE_ALU

                `CONTROL__NEXT_INST
            end
            BRANCH, STORE_1, MISCMEM: begin
                `CONTROL__NEXT_INST
            end
            LOAD, LOAD_W: begin
                `CONTROL__ALU_ADDRESS
                control_signals.mem_read   = 1'b1;
            end
            LOAD_1: begin
                `CONTROL__WRITE_MEM

                `CONTROL__NEXT_INST
            end
            STORE, STORE_W: begin
                `CONTROL__ALU_ADDRESS
                control_signals.mem_write  = 1'b1;
            end
            OPIMM: begin
                control_signals.alu_insel1 = `CONTROL_SIGNALS__ALU1_RS;
                control_signals.alu_insel2 = `CONTROL_SIGNALS__ALU2_IM;
                `CONTROL__WRITE_ALU

                `CONTROL__NEXT_INST
            end
            OP: begin
                control_signals.alu_insel1 = `CONTROL_SIGNALS__ALU1_RS;
                control_signals.alu_insel2 = `CONTROL_SIGNALS__ALU2_RS;
                `CONTROL__WRITE_ALU

                `CONTROL__NEXT_INST
            end
            SYSTEM: begin
                if (control_signals.f3 != `ISA__FUNCT3_PRIV) begin
                    control_signals.rd_sel    = `CONTROL_SIGNALS__RD_CSR;
                    control_signals.write_rd  = 1'b1;
                    control_signals.write_csr = 1'b1;
                    `CONTROL__NEXT_INST
                end
                if (interrupt_pending) begin
                    `CONTROL__NEXT_INST
                end
            end
            default: begin
            end
        endcase
        if (exception) begin
            control_signals.write_rd    = 1'b0;
            control_signals.write_csr   = 1'b0;
            control_signals.mem_write   = 1'b0;
            control_signals.write_pc_ex = 1'b1;
            `CONTROL__READ_INST
        end
    end

    always_comb begin
        case (mcp_addr)
            PROLOGUE,
            LUI,
            AUIPC,
            JAL,
            JALR,
            BRANCH,
            OPIMM,
            OP,
            MISCMEM,
            LOAD_1,
            STORE_1: mcp_next = control_signals.mem_complete ? DISPATCH : PROLOGUE;
            LOAD,
            LOAD_W:  mcp_next = control_signals.mem_complete ? LOAD_1   : LOAD_W;
            STORE,
            STORE_W: mcp_next = control_signals.mem_complete ? STORE_1  : STORE_W;
            SYSTEM:  mcp_next = (control_signals.f3 != `ISA__FUNCT3_PRIV || interrupt_pending) ? (control_signals.mem_complete ? DISPATCH : PROLOGUE) : SYSTEM;
            default: mcp_next = mcp_addr + 5'd1;
        endcase
        if (exception) begin
            mcp_next = control_signals.mem_complete ? DISPATCH : PROLOGUE;
        end
    end
endmodule
