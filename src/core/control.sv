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

    input debug,
    input halted,
    input abstract,
    input step,
    input reg_error,
    input trigger,

    control_signals_if control_signals
);
    reg [`ISA__OPCODE_WIDTH-1:0] mcp_reg, mcp_next, mcp_addr;

    always @(posedge clk) begin
        if (!rst_n) begin
            mcp_reg <= `CONTROL_SIGNALS__PROLOGUE;
        end else begin
            mcp_reg <= mcp_next;
        end
    end

    always_comb begin
        mcp_addr = mcp_reg;
        if (mcp_reg == `CONTROL_SIGNALS__DISPATCH) begin
            mcp_addr = control_signals.opcode;
        end
        if (mcp_reg == `CONTROL_SIGNALS__HALTED && abstract) begin
            mcp_addr = control_signals.opcode;
        end
    end

    assign control_signals.write_ir = !
        (  mcp_reg == `CONTROL_SIGNALS__PROLOGUE
        || mcp_reg == `CONTROL_SIGNALS__LOAD_W
        || mcp_reg == `CONTROL_SIGNALS__LOAD_1
        || mcp_reg == `CONTROL_SIGNALS__STORE_W
        || mcp_reg == `CONTROL_SIGNALS__STORE_1
        || mcp_reg == `CONTROL_SIGNALS__HALTED
        || mcp_reg == `CONTROL_SIGNALS__RESUMING
        || mcp_reg == `CONTROL_SIGNALS__ABS_REG
        || mcp_reg == `CONTROL_SIGNALS__ABS_EXEC
        || mcp_reg == `CONTROL_SIGNALS__ABS_RMEM
        || mcp_reg == `CONTROL_SIGNALS__ABS_RMEM_1
        || mcp_reg == `CONTROL_SIGNALS__ABS_WMEM
        || mcp_reg == `CONTROL_SIGNALS__ABS_WMEM_1
        || mcp_reg == `CONTROL_SIGNALS__ABS_NA
        );

    assign control_signals.mcp_addr = mcp_addr;
    assign control_signals.write_pc = control_signals.write_pc_ne || control_signals.write_pc_ex;

    always_comb begin
        control_signals.write_pc_ne    = 1'b0;
        control_signals.write_pc_ex    = 1'b0;
        control_signals.write_rd       = 1'b0;
        control_signals.write_csr      = 1'b0;
        control_signals.mem_read       = 1'b0;
        control_signals.mem_write      = 1'b0;
        control_signals.addr_sel       = `CONTROL_SIGNALS__ADDR_PC;
        control_signals.rd_sel         = `CONTROL_SIGNALS__RD_ALU;
        control_signals.alu_insel1     = `CONTROL_SIGNALS__ALU1_RS;
        control_signals.alu_insel2     = `CONTROL_SIGNALS__ALU2_RS;
        control_signals.abstract_write = 1'b0;
        control_signals.abstract_done  = 1'b0;
        control_signals.progbuf        = 1'b0;
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
                control_signals.mem_read   = 1'b1;
            end
            `CONTROL_SIGNALS__LOAD_1: begin
                `CONTROL__WRITE_MEM

                `CONTROL__NEXT_INST
            end
            `CONTROL_SIGNALS__STORE, `CONTROL_SIGNALS__STORE_W: begin
                `CONTROL__ALU_ADDRESS
                control_signals.mem_write  = 1'b1;
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
                if (control_signals.f3 != `ISA__FUNCT3_PRIV) begin
                    control_signals.rd_sel    = `CONTROL_SIGNALS__RD_CSR;
                    control_signals.write_rd  = 1'b1;
                    control_signals.write_csr = 1'b1;
                end
                `CONTROL__NEXT_INST
            end
            `CONTROL_SIGNALS__RESUMING: begin
                control_signals.write_pc_ex = 1'b1;
            end
            `CONTROL_SIGNALS__ABS_REG: begin
                if (control_signals.f3[2]) begin
                    if (control_signals.f3[1]) begin
                        control_signals.write_csr   = 1'b1;
                    end else begin
                        control_signals.alu_insel1 = `CONTROL_SIGNALS__ALU1_ZR;
                        control_signals.alu_insel2 = `CONTROL_SIGNALS__ALU2_IM;
                        `CONTROL__WRITE_ALU
                    end
                end else begin
                    control_signals.abstract_write = 1'b1;
                    if (control_signals.f3[1]) begin
                        control_signals.rd_sel     = `CONTROL_SIGNALS__RD_CSR;
                    end else begin
                        control_signals.alu_insel1 = `CONTROL_SIGNALS__ALU1_ZR;
                        control_signals.alu_insel2 = `CONTROL_SIGNALS__ALU2_RS;
                        control_signals.rd_sel     = `CONTROL_SIGNALS__RD_ALU;
                    end
                end
                control_signals.abstract_done = control_signals.f3[0] ? 1'b0 : 1'b1;
            end
            `CONTROL_SIGNALS__ABS_NA: begin
                control_signals.abstract_done = 1'b1;
            end
            `CONTROL_SIGNALS__ABS_EXEC: begin
                control_signals.progbuf     = 1'b1;
                control_signals.write_pc_ne = 1'b1;
            end
            `CONTROL_SIGNALS__ABS_RMEM: begin
                control_signals.mem_read = 1'b1;
            end
            `CONTROL_SIGNALS__ABS_RMEM_1: begin
                control_signals.rd_sel         = `CONTROL_SIGNALS__RD_MEM;
                control_signals.abstract_write = 1'b1;
                control_signals.abstract_done  = 1'b1;
            end
            `CONTROL_SIGNALS__ABS_WMEM: begin
                control_signals.mem_write  = 1'b1;
            end
            `CONTROL_SIGNALS__ABS_WMEM_1: begin
                control_signals.abstract_done = 1'b1;
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
        if (trigger) begin
            control_signals.write_rd    = 1'b0;
            control_signals.write_csr   = 1'b0;
            control_signals.mem_write   = 1'b0;
        end
    end

    always_comb begin
        case (mcp_addr)
            `CONTROL_SIGNALS__PROLOGUE,
            `CONTROL_SIGNALS__LUI,
            `CONTROL_SIGNALS__AUIPC,
            `CONTROL_SIGNALS__JAL,
            `CONTROL_SIGNALS__JALR,
            `CONTROL_SIGNALS__BRANCH,
            `CONTROL_SIGNALS__OPIMM,
            `CONTROL_SIGNALS__OP,
            `CONTROL_SIGNALS__MISCMEM,
            `CONTROL_SIGNALS__LOAD_1,
            `CONTROL_SIGNALS__STORE_1,
            `CONTROL_SIGNALS__SYSTEM:     mcp_next = control_signals.mem_complete ? `CONTROL_SIGNALS__DISPATCH : `CONTROL_SIGNALS__PROLOGUE;
            `CONTROL_SIGNALS__LOAD,
            `CONTROL_SIGNALS__LOAD_W:     mcp_next = control_signals.mem_complete ? `CONTROL_SIGNALS__LOAD_1   : `CONTROL_SIGNALS__LOAD_W;
            `CONTROL_SIGNALS__STORE,
            `CONTROL_SIGNALS__STORE_W:    mcp_next = control_signals.mem_complete ? `CONTROL_SIGNALS__STORE_1  : `CONTROL_SIGNALS__STORE_W;
            `CONTROL_SIGNALS__HALTED:     mcp_next = debug ? `CONTROL_SIGNALS__HALTED : `CONTROL_SIGNALS__RESUMING;
            `CONTROL_SIGNALS__RESUMING:   mcp_next = `CONTROL_SIGNALS__PROLOGUE;
            `CONTROL_SIGNALS__ABS_REG:    mcp_next = (control_signals.f3[0] && !reg_error) ? `CONTROL_SIGNALS__ABS_EXEC : `CONTROL_SIGNALS__HALTED;
            `CONTROL_SIGNALS__ABS_NA:     mcp_next = `CONTROL_SIGNALS__HALTED;
            `CONTROL_SIGNALS__ABS_EXEC:   mcp_next = `CONTROL_SIGNALS__PROLOGUE;
            `CONTROL_SIGNALS__ABS_RMEM:   mcp_next = control_signals.mem_complete ? `CONTROL_SIGNALS__ABS_RMEM_1 : `CONTROL_SIGNALS__ABS_RMEM;
            `CONTROL_SIGNALS__ABS_RMEM_1: mcp_next = `CONTROL_SIGNALS__HALTED;
            `CONTROL_SIGNALS__ABS_WMEM:   mcp_next = control_signals.mem_complete ? `CONTROL_SIGNALS__ABS_WMEM_1 : `CONTROL_SIGNALS__ABS_WMEM;
            `CONTROL_SIGNALS__ABS_WMEM_1: mcp_next = `CONTROL_SIGNALS__HALTED;
            default:                      mcp_next = mcp_addr + 5'd1;
        endcase
        if (exception) begin
            mcp_next = debug ? `CONTROL_SIGNALS__HALTED : control_signals.mem_complete ? `CONTROL_SIGNALS__DISPATCH : `CONTROL_SIGNALS__PROLOGUE;
        end
        if (debug && !halted && (mcp_next == `CONTROL_SIGNALS__DISPATCH || mcp_next == `CONTROL_SIGNALS__PROLOGUE)) begin
            mcp_next = `CONTROL_SIGNALS__HALTED;
        end
        if (trigger) begin
            mcp_next = `CONTROL_SIGNALS__HALTED;
        end
    end
endmodule
