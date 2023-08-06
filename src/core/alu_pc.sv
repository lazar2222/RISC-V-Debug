module alu_pc #(
    parameter int Width = 32
) (
    input [Width-1:0] pc,
    input [Width-1:0] rs,
    input [Width-1:0] imm,

    input branch,
    input jal,
    input jalr,
    input take,

    output [Width-1:0] next_pc,
    output ialign
);
    wire [Width-1:0] next_bj = pc + imm;
    wire [Width-1:0] next_r = pc + 4;
    wire [Width-1:0] next_inc = rs + imm;
    wire [Width-1:0] next_i = {next_inc[Width-1:1], 1'b0};

    assign next_pc = ((branch && take) || jal) ? next_bj : (jalr ? next_i : next_r);
    assign ialign = next_pc[1:0] != 2'd0;

endmodule
