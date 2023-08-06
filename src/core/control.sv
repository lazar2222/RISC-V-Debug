`include "control_signals_if.svh"
`include "isa.svh"

module control (
    input clk,
    input rst_n,

    control_signals_if control_signals
);
    localparam logic [4:0] PROLOGUE = 5'd16;
    localparam logic [4:0] DISPATCH = 5'd17;
    localparam logic [4:0] LUI = `ISA__OPCODE_LUI;
    localparam logic [4:0] AUIPC = `ISA__OPCODE_AUIPC;
    localparam logic [4:0] JAL = `ISA__OPCODE_JAL;
    localparam logic [4:0] JALR = `ISA__OPCODE_JALR;
    localparam logic [4:0] BRANCH = `ISA__OPCODE_BRANCH;
    localparam logic [4:0] LOAD = `ISA__OPCODE_LOAD;
    localparam logic [4:0] LOAD_1 = 5'd1;
    localparam logic [4:0] STORE = `ISA__OPCODE_STORE;
    localparam logic [4:0] STORE_1 = 5'd9;
    localparam logic [4:0] STORE_2 = 5'd10;
    localparam logic [4:0] OPIMM = `ISA__OPCODE_OPIMM;
    localparam logic [4:0] OP = `ISA__OPCODE_OP;
    localparam logic [4:0] MISCMEM = `ISA__OPCODE_MISCMEM;
    localparam logic [4:0] SYSTEM = `ISA__OPCODE_SYSTEM;

    localparam logic ADDR_ALU = 1'b0;
    localparam logic ADDR_PC = 1'b1;
    localparam logic RD_ALU = 1'b0;
    localparam logic RD_MEM = 1'b1;
    localparam logic [1:0] ALU1_RS = 2'b00;
    localparam logic [1:0] ALU1_PC = 2'b01;
    localparam logic [1:0] ALU1_Z = 2'b11;
    localparam logic [1:0] ALU2_RS = 2'b00;
    localparam logic [1:0] ALU2_IM = 2'b01;
    localparam logic [1:0] ALU2_4 = 2'b11;

    reg [4:0] mcp_reg, mcp_next, mcp_addr;

    always @(posedge clk) begin
        if (!rst_n) begin
            mcp_reg <= PROLOGUE;
        end else begin
            mcp_reg <= mcp_next;
        end
    end

    assign control_signals.write_ir = !(mcp_reg == LOAD_1 || mcp_reg == STORE_1 || mcp_reg == STORE_2 || mcp_reg == PROLOGUE);

    always_comb begin
        mcp_addr = mcp_reg;
        if (mcp_reg == DISPATCH && control_signals.mem_complete_read) begin
            mcp_addr = control_signals.opcode;
        end
    end

    always_comb begin
        control_signals.write_pc   = 1'b0;
        control_signals.write_rd   = 1'b0;
        control_signals.mem_read   = 1'b0;
        control_signals.mem_write  = 1'b0;
        control_signals.addr_sel   = ADDR_ALU;
        control_signals.rd_sel     = RD_ALU;
        control_signals.alu_insel1 = ALU1_RS;
        control_signals.alu_insel2 = ALU2_RS;
        case (mcp_addr)
            PROLOGUE: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            DISPATCH: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            LUI: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_pc = 1'b1;

                control_signals.alu_insel1 = ALU1_Z;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;
            end
            AUIPC: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_pc = 1'b1;

                control_signals.alu_insel1 = ALU1_PC;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;
            end
            JAL: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_pc = 1'b1;

                control_signals.alu_insel1 = ALU1_PC;
                control_signals.alu_insel2 = ALU2_4;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;
            end
            JALR: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_pc = 1'b1;

                control_signals.alu_insel1 = ALU1_PC;
                control_signals.alu_insel2 = ALU2_4;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;
            end
            BRANCH: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_pc = 1'b1;
            end
            LOAD: begin
                control_signals.mem_read = 1'b1;
                control_signals.addr_sel = ADDR_ALU;
                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_IM;
            end
            LOAD_1: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_pc = 1'b1;
                control_signals.write_rd = 1'b1;
                control_signals.rd_sel   = RD_MEM;
            end
            STORE: begin
                control_signals.addr_sel = ADDR_PC;
            end
            STORE_1: begin
                control_signals.addr_sel = ADDR_ALU;
                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.mem_write = 1'b1;
            end
            STORE_2: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_pc = 1'b1;
            end
            OPIMM: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_pc = 1'b1;

                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;
            end
            OP: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_pc = 1'b1;

                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_RS;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;
            end
            MISCMEM: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_pc = 1'b1;
            end
            SYSTEM: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_pc = 1'b1;
            end
            default: begin
            end
        endcase
    end

    always_comb begin
        case (mcp_addr)
            DISPATCH: begin
                mcp_next = DISPATCH;
            end
            LUI: begin
                mcp_next = DISPATCH;
            end
            AUIPC: begin
                mcp_next = DISPATCH;
            end
            JAL: begin
                mcp_next = DISPATCH;
            end
            JALR: begin
                mcp_next = DISPATCH;
            end
            BRANCH: begin
                mcp_next = DISPATCH;
            end
            LOAD: begin
                mcp_next = LOAD_1;
            end
            LOAD_1: begin
                mcp_next = DISPATCH;
            end
            STORE: begin
                mcp_next = STORE_1;
            end
            STORE_1: begin
                mcp_next = STORE_2;
            end
            STORE_2: begin
                mcp_next = DISPATCH;
            end
            OPIMM: begin
                mcp_next = DISPATCH;
            end
            OP: begin
                mcp_next = DISPATCH;
            end
            MISCMEM: begin
                mcp_next = DISPATCH;
            end
            SYSTEM: begin
                mcp_next = DISPATCH;
            end
            default: mcp_next = mcp_addr + 5'd1;
        endcase
    end
endmodule
