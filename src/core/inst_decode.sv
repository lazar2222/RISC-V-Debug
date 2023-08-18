`include "isa.svh"

module inst_decode (
    input [`ISA__XLEN-1:0] inst,

    output invalid_inst,

    output [`ISA__OPCODE_WIDTH-1:0] opcode,

    output [`ISA__FUNCT3_WIDTH-1:0] f3,

    output [`ISA__RFLEN-1:0] rd,
    output [`ISA__RFLEN-1:0] rs1,
    output [`ISA__RFLEN-1:0] rs2,

    output reg [        `ISA__XLEN-1:0] imm,
    output     [        `ISA__XLEN-1:0] csri,
    output reg [`ISA__FUNCT3_WIDTH-1:0] op,
    output reg                          mod,
    output reg                          mul,
    output                              ecall,
    output                              ebreak
);
    wire [`ISA__FUNCT7_WIDTH-1:0] f7 = `ISA__FUNCT7(inst);
    wire [        `ISA__XLEN-1:0] ii = `ISA__I_IMMEDIATE(inst);
    wire [        `ISA__XLEN-1:0] ui = `ISA__U_IMMEDIATE(inst);
    wire [        `ISA__XLEN-1:0] bi = `ISA__B_IMMEDIATE(inst);
    wire [        `ISA__XLEN-1:0] ji = `ISA__J_IMMEDIATE(inst);
    wire [        `ISA__XLEN-1:0] si = `ISA__S_IMMEDIATE(inst);

    assign opcode = `ISA__OPCODE(inst);
    assign f3     = `ISA__FUNCT3(inst);
    assign rd     = `ISA__RD(inst);
    assign rs1    = `ISA__RS1(inst);
    assign rs2    = `ISA__RS2(inst);
    assign csri   = {{`ISA__XLEN - `ISA__RFLEN{1'b0}},rs1};

    wire invalid_opcode_pfx = `ISA__OPCODE_PFX(inst) != `ISA__OPCODE_PFX_32BIT;

    wire opcode_load    = opcode == `ISA__OPCODE_LOAD;
    wire opcode_miscmem = opcode == `ISA__OPCODE_MISCMEM;
    wire opcode_opimm   = opcode == `ISA__OPCODE_OPIMM;
    wire opcode_auipc   = opcode == `ISA__OPCODE_AUIPC;
    wire opcode_store   = opcode == `ISA__OPCODE_STORE;
    wire opcode_op      = opcode == `ISA__OPCODE_OP;
    wire opcode_lui     = opcode == `ISA__OPCODE_LUI;
    wire opcode_branch  = opcode == `ISA__OPCODE_BRANCH;
    wire opcode_jalr    = opcode == `ISA__OPCODE_JALR;
    wire opcode_jal     = opcode == `ISA__OPCODE_JAL;
    wire opcode_system  = opcode == `ISA__OPCODE_SYSTEM;

    wire invalid_opcode = !
        (  opcode_load
        || opcode_miscmem
        || opcode_opimm
        || opcode_auipc
        || opcode_store
        || opcode_op
        || opcode_lui
        || opcode_branch
        || opcode_jalr
        || opcode_jal
        || opcode_system
        );

    wire invalid_branch = opcode_branch && !
        (  f3 == `ISA__FUNCT3_BEQ
        || f3 == `ISA__FUNCT3_BNE
        || f3 == `ISA__FUNCT3_BLT
        || f3 == `ISA__FUNCT3_BGE
        || f3 == `ISA__FUNCT3_BLTU
        || f3 == `ISA__FUNCT3_BGEU
        );

    wire invalid_load = opcode_load && !
        (  f3 == `ISA__FUNCT3_LB
        || f3 == `ISA__FUNCT3_LH
        || f3 == `ISA__FUNCT3_LW
        || f3 == `ISA__FUNCT3_LBU
        || f3 == `ISA__FUNCT3_LHU
        );

    wire invalid_store = opcode_store && !
        (  f3 == `ISA__FUNCT3_SB
        || f3 == `ISA__FUNCT3_SH
        || f3 == `ISA__FUNCT3_SW
        );

    wire sub_or_sra =
        (  f3 == `ISA__FUNCT3_SUB
        || f3 == `ISA__FUNCT3_SRA
        );

    wire slli_or_srli_or_srai =
        (  f3 == `ISA__FUNCT3_SLLI
        || f3 == `ISA__FUNCT3_SRLI
        || f3 == `ISA__FUNCT3_SRAI
        );

    wire valid_funct7 =
        (  (f7 == `ISA__FUNCT7_ADD)
        || (f7 == `ISA__FUNCT7_MUL && `ISA__MEXT)
        || (f7 == `ISA__FUNCT7_SUB && sub_or_sra)
        );

    wire valid_csr =
        (  f3 == `ISA__FUNCT3_CSRRW
        || f3 == `ISA__FUNCT3_CSRRS
        || f3 == `ISA__FUNCT3_CSRRC
        || f3 == `ISA__FUNCT3_CSRRWI
        || f3 == `ISA__FUNCT3_CSRRSI
        || f3 == `ISA__FUNCT3_CSRRCI
        );

    assign ecall =
        (  f3 == `ISA__FUNCT3_ECALL
        && rd == `ISA__RD_ECALL
        && rs1 == `ISA__RS1_ECALL
        && ii == `ISA__IMM_ECALL
        );

    assign ebreak =
        (  f3 == `ISA__FUNCT3_ECALL
        && rd == `ISA__RD_ECALL
        && rs1 == `ISA__RS1_ECALL
        && ii == `ISA__IMM_EBREAK
        );

    wire invalid_jalr    = opcode_jalr    && !(f3 == `ISA__FUNCT3_JALR);
    wire invalid_opimm   = opcode_opimm   && slli_or_srli_or_srai && !valid_funct7;
    wire invalid_op      = opcode_op      && !valid_funct7;
    wire invalid_miscmem = opcode_miscmem && !(f3 == `ISA__FUNCT3_FENCE);
    wire invalid_system = opcode_system   && !(ecall || ebreak || valid_csr);

    assign invalid_inst =
        (  invalid_opcode_pfx
        || invalid_opcode
        || invalid_jalr
        || invalid_branch
        || invalid_load
        || invalid_store
        || invalid_opimm
        || invalid_op
        || invalid_miscmem
        || invalid_system
        );

    always_comb begin
        case (opcode)
            `ISA__OPCODE_LUI:     imm = ui;
            `ISA__OPCODE_AUIPC:   imm = ui;
            `ISA__OPCODE_JAL:     imm = ji;
            `ISA__OPCODE_JALR:    imm = ii;
            `ISA__OPCODE_BRANCH:  imm = bi;
            `ISA__OPCODE_LOAD:    imm = ii;
            `ISA__OPCODE_STORE:   imm = si;
            `ISA__OPCODE_OPIMM:   imm = ii;
            `ISA__OPCODE_MISCMEM: imm = ii;
            `ISA__OPCODE_SYSTEM:  imm = ii;
            default:              imm = {`ISA__XLEN{1'b0}};
        endcase
        case (opcode)
            `ISA__OPCODE_LUI:   begin op = `ISA__FUNCT3_ADD; mod =  1'b0; mul =  1'b0; end
            `ISA__OPCODE_AUIPC: begin op = `ISA__FUNCT3_ADD; mod =  1'b0; mul =  1'b0; end
            `ISA__OPCODE_JAL:   begin op = `ISA__FUNCT3_ADD; mod =  1'b0; mul =  1'b0; end
            `ISA__OPCODE_JALR:  begin op = `ISA__FUNCT3_ADD; mod =  1'b0; mul =  1'b0; end
            `ISA__OPCODE_LOAD:  begin op = `ISA__FUNCT3_ADD; mod =  1'b0; mul =  1'b0; end
            `ISA__OPCODE_STORE: begin op = `ISA__FUNCT3_ADD; mod =  1'b0; mul =  1'b0; end
            `ISA__OPCODE_OPIMM: begin op = f3;               mod =  1'b0; mul =  1'b0; end
            default:            begin op = f3;               mod = f7[5]; mul = f7[0] && `ISA__MEXT; end
        endcase
    end

endmodule
