`include "control_signals_if.svh"
`include "isa.svh"

module control (
    input clk,
    input rst_n,

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

    localparam logic       ADDR_ALU = 1'b0;
    localparam logic       ADDR_PC  = 1'b1;
    localparam logic [1:0] RD_ALU   = 2'b00;
    localparam logic [1:0] RD_MEM   = 2'b10;
    localparam logic [1:0] RD_CSR   = 2'b11;
    localparam logic [1:0] ALU1_RS  = 2'b00;
    localparam logic [1:0] ALU1_PC  = 2'b01;
    localparam logic [1:0] ALU1_ZR  = 2'b11;
    localparam logic [1:0] ALU2_RS  = 2'b00;
    localparam logic [1:0] ALU2_IM  = 2'b01;
    localparam logic [1:0] ALU2_IS  = 2'b11;

    reg [4:0] mcp_reg, mcp_next, mcp_addr;

    always @(posedge clk) begin
        if (!rst_n) begin
            mcp_reg <= PROLOGUE;
        end else begin
            mcp_reg <= mcp_next;
        end
    end

    assign control_signals.write_ir = !(mcp_reg == LOAD_1 || mcp_reg == STORE_1 || mcp_reg == PROLOGUE || mcp_reg == LOAD_W || mcp_reg == STORE_W);

    always_comb begin
        mcp_addr = mcp_reg;
        if (mcp_reg == DISPATCH) begin
            mcp_addr = control_signals.opcode;
        end
    end

    always_comb begin
        control_signals.store        = 1'b0;
        control_signals.write_pc     = 1'b0;
        control_signals.write_rd     = 1'b0;
        control_signals.write_csr    = 1'b0;
        control_signals.mem_read     = 1'b0;
        control_signals.mem_write    = 1'b0;
        control_signals.addr_sel     = ADDR_PC;
        control_signals.rd_sel       = RD_ALU;
        control_signals.alu_insel1   = ALU1_RS;
        control_signals.alu_insel2   = ALU2_RS;
        case (mcp_addr)
            PROLOGUE: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            LUI: begin
                control_signals.alu_insel1 = ALU1_ZR;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.rd_sel     = RD_ALU;
                control_signals.write_rd   = 1'b1;

                control_signals.write_pc = 1'b1;
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            AUIPC: begin
                control_signals.alu_insel1 = ALU1_PC;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.rd_sel     = RD_ALU;
                control_signals.write_rd   = 1'b1;

                control_signals.write_pc = 1'b1;
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            JAL: begin
                control_signals.alu_insel1 = ALU1_PC;
                control_signals.alu_insel2 = ALU2_IS;
                control_signals.rd_sel     = RD_ALU;
                control_signals.write_rd   = 1'b1;

                control_signals.write_pc = 1'b1;
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            JALR: begin
                control_signals.alu_insel1 = ALU1_PC;
                control_signals.alu_insel2 = ALU2_IS;
                control_signals.rd_sel     = RD_ALU;
                control_signals.write_rd   = 1'b1;

                control_signals.write_pc = 1'b1;
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            BRANCH: begin
                control_signals.write_pc = 1'b1;
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            LOAD: begin
                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.addr_sel   = ADDR_ALU;
                control_signals.mem_read   = 1'b1;
            end
            LOAD_W: begin
                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.addr_sel   = ADDR_ALU;
                control_signals.mem_read   = 1'b1;
            end
            LOAD_1: begin
                control_signals.rd_sel   = RD_MEM;
                control_signals.write_rd = 1'b1;

                control_signals.write_pc = 1'b1;
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            STORE: begin
                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.addr_sel   = ADDR_ALU;
                control_signals.mem_write  = 1'b1;
            end
            STORE_W: begin
                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.addr_sel   = ADDR_ALU;
                control_signals.mem_write  = 1'b1;
            end
            STORE_1: begin
                control_signals.store    = 1'b1;
                control_signals.write_pc = 1'b1;
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            OPIMM: begin
                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;

                control_signals.write_pc = 1'b1;
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            OP: begin
                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_RS;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;

                control_signals.write_pc = 1'b1;
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            MISCMEM: begin
                control_signals.write_pc = 1'b1;
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            SYSTEM: begin
                if (control_signals.f3 != `ISA__FUNCT3_ECALL) begin
                    control_signals.rd_sel    = RD_CSR;
                    control_signals.write_csr = 1'b1;
                    control_signals.write_rd  = 1'b1;
                end
                control_signals.write_pc = 1'b1;
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            default: begin
            end
        endcase
    end

    always_comb begin
        case (mcp_addr)
            PROLOGUE: mcp_next = control_signals.mem_complete_read  ? DISPATCH : PROLOGUE;
            LUI:      mcp_next = control_signals.mem_complete_read  ? DISPATCH : PROLOGUE;
            AUIPC:    mcp_next = control_signals.mem_complete_read  ? DISPATCH : PROLOGUE;
            JAL:      mcp_next = control_signals.mem_complete_read  ? DISPATCH : PROLOGUE;
            JALR:     mcp_next = control_signals.mem_complete_read  ? DISPATCH : PROLOGUE;
            BRANCH:   mcp_next = control_signals.mem_complete_read  ? DISPATCH : PROLOGUE;
            LOAD:     mcp_next = control_signals.mem_complete_read  ? LOAD_1   : LOAD_W;
            LOAD_W:   mcp_next = control_signals.mem_complete_read  ? LOAD_1   : LOAD_W;
            LOAD_1:   mcp_next = control_signals.mem_complete_read  ? DISPATCH : PROLOGUE;
            STORE:    mcp_next = control_signals.mem_complete_write ? STORE_1  : STORE_W;
            STORE_W:  mcp_next = control_signals.mem_complete_write ? STORE_1  : STORE_W;
            STORE_1:  mcp_next = control_signals.mem_complete_read  ? DISPATCH : PROLOGUE;
            OPIMM:    mcp_next = control_signals.mem_complete_read  ? DISPATCH : PROLOGUE;
            OP:       mcp_next = control_signals.mem_complete_read  ? DISPATCH : PROLOGUE;
            MISCMEM:  mcp_next = control_signals.mem_complete_read  ? DISPATCH : PROLOGUE;
            SYSTEM:   mcp_next = control_signals.mem_complete_read  ? DISPATCH : PROLOGUE;
            default:  mcp_next = mcp_addr + 5'd1;
        endcase
    end
endmodule
