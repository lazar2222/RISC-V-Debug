`include "isa.svh"

module pc_calc #(
    parameter int Width
) (
    input [Width-1:0] pc,
    input [Width-1:0] a,
    input [Width-1:0] b,
    input [Width-1:0] imm,

    input [`ISA__OPCODE_WIDTH-1:0] opcode,
    input [`ISA__FUNCT3_WIDTH-1:0] f3,

    output [Width-1:0] next_pc,
    output             ialign
);
    wire        [Width-1:0] next_bj  = pc + imm;
    wire        [Width-1:0] next_r   = pc + `ISA__INST_SIZE;
    wire        [Width-1:0] next_inc = a + imm;
    wire        [Width-1:0] next_i   = {next_inc[Width-1:1], 1'b0};
    wire signed [Width-1:0] sign_a   = $signed(a);
    wire signed [Width-1:0] sign_b   = $signed(b);
    wire                    branch   = opcode == `ISA__OPCODE_BRANCH;
    wire                    jal      = opcode == `ISA__OPCODE_JAL;
    wire                    jalr     = opcode == `ISA__OPCODE_JALR;

    reg take;

    always_comb begin
        case (f3)
            `ISA__FUNCT3_BEQ:  take = a == b;
            `ISA__FUNCT3_BNE:  take = a != b;
            `ISA__FUNCT3_BLT:  take = sign_a < sign_b;
            `ISA__FUNCT3_BGE:  take = sign_a >= sign_b;
            `ISA__FUNCT3_BLTU: take = a < b;
            `ISA__FUNCT3_BGEU: take = a >= b;
            default:           take = 1'b0;
        endcase
    end

    assign next_pc = ((branch && take) || jal) ? next_bj : (jalr ? next_i : next_r);
    assign ialign  = next_pc[`ISA__INST_LOAD_SIZE-1:0] != {`ISA__INST_LOAD_SIZE{1'b0}};

endmodule
