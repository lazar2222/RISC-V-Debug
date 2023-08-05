`include "control_signals_if.svh"

module control (
    input clk,
    input rst_n,

    control_signals_if control_signals
);
    localparam int PROLOGUE = 32'd000;
    localparam int DISPATCH = 32'd001;
    localparam int LUI = 32'd016;
    localparam int AUIPC = 32'd032;
    localparam int JAL = 32'd048;
    localparam int JALR = 32'd064;
    localparam int BRANCH = 32'd080;
    localparam int LOAD = 32'd096;
    localparam int LOAD_1 = 32'd097;
    localparam int STORE = 32'd112;
    localparam int STORE_1 = 32'd113;
    localparam int STORE_2 = 32'd114;
    localparam int OPIMM = 32'd128;
    localparam int OP = 32'd144;
    localparam int MISCMEM = 32'd160;
    localparam int SYSTEM = 32'd176;

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

    localparam logic [4:0] ALU_ADD = 4'b0000;

    int mcp_reg, mcp_next, mcp_addr;

    always @(posedge clk) begin
        if (!rst_n) begin
            mcp_reg <= PROLOGUE;
        end else begin
            mcp_reg <= mcp_next;
        end
    end

    always_comb begin
        mcp_addr = mcp_reg;
        if (mcp_reg == DISPATCH && control_signals.mem_fc) begin
            if (control_signals.opcode_lui) begin
                mcp_addr = LUI;
            end else if (control_signals.opcode_auipc) begin
                mcp_addr = AUIPC;
            end else if (control_signals.opcode_jal) begin
                mcp_addr = JAL;
            end else if (control_signals.opcode_jalr) begin
                mcp_addr = JALR;
            end else if (control_signals.opcode_branch) begin
                mcp_addr = BRANCH;
            end else if (control_signals.opcode_load) begin
                mcp_addr = LOAD;
            end else if (control_signals.opcode_store) begin
                mcp_addr = STORE;
            end else if (control_signals.opcode_opimm) begin
                mcp_addr = OPIMM;
            end else if (control_signals.opcode_op) begin
                mcp_addr = OP;
            end else if (control_signals.opcode_miscmem) begin
                mcp_addr = MISCMEM;
            end else if (control_signals.opcode_system) begin
                mcp_addr = SYSTEM;
            end
        end
    end

    always_comb begin
        control_signals.write_pc   = 1'b0;
        control_signals.write_ir   = 1'b0;
        control_signals.write_rd   = 1'b0;
        control_signals.mem_read   = 1'b0;
        control_signals.mem_write  = 1'b0;
        control_signals.addr_sel   = ADDR_ALU;
        control_signals.rd_sel     = RD_ALU;
        control_signals.alu_insel1 = ALU1_RS;
        control_signals.alu_insel2 = ALU2_RS;
        control_signals.alu_op     = control_signals.aluop_in;
        case (mcp_addr)
            PROLOGUE: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
            end
            DISPATCH: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_ir = 1'b1;
            end
            LUI: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_ir = 1'b1;
                control_signals.write_pc = 1'b1;

                control_signals.alu_insel1 = ALU1_Z;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;
                control_signals.alu_op = ALU_ADD;
            end
            AUIPC: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_ir = 1'b1;
                control_signals.write_pc = 1'b1;

                control_signals.alu_insel1 = ALU1_PC;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;
                control_signals.alu_op = ALU_ADD;
            end
            JAL: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_ir = 1'b1;
                control_signals.write_pc = 1'b1;

                control_signals.alu_insel1 = ALU1_PC;
                control_signals.alu_insel2 = ALU2_4;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;
                control_signals.alu_op = ALU_ADD;
            end
            JALR: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_ir = 1'b1;
                control_signals.write_pc = 1'b1;

                control_signals.alu_insel1 = ALU1_PC;
                control_signals.alu_insel2 = ALU2_4;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;
                control_signals.alu_op = ALU_ADD;
            end
            BRANCH: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_ir = 1'b1;
                control_signals.write_pc = 1'b1;
            end
            LOAD: begin
                control_signals.write_ir = 1'b1;
                control_signals.mem_read = 1'b1;
                control_signals.addr_sel = ADDR_ALU;
                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.alu_op = ALU_ADD;
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
                control_signals.mem_read = 1'b1;
                control_signals.write_ir = 1'b1;
            end
            STORE_1: begin
                control_signals.addr_sel = ADDR_ALU;
                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.alu_op = ALU_ADD;
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
                control_signals.write_ir = 1'b1;
                control_signals.write_pc = 1'b1;

                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_IM;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;
                control_signals.alu_op = {2'b0, control_signals.aluop_in[2:0]};
            end
            OP: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_ir = 1'b1;
                control_signals.write_pc = 1'b1;

                control_signals.alu_insel1 = ALU1_RS;
                control_signals.alu_insel2 = ALU2_RS;
                control_signals.rd_sel = RD_ALU;
                control_signals.write_rd = 1'b1;
            end
            MISCMEM: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_ir = 1'b1;
                control_signals.write_pc = 1'b1;
            end
            SYSTEM: begin
                control_signals.addr_sel = ADDR_PC;
                control_signals.mem_read = 1'b1;
                control_signals.write_ir = 1'b1;
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
            default: mcp_next = mcp_addr + 1;
        endcase
    end
endmodule
