`include "isa.svh"

module alu #(
    parameter int Width
) (
    input [Width-1:0] a,
    input [Width-1:0] b,

    input [`ISA__FUNCT3_WIDTH-1:0] op,
    input                          mod,

    output reg [Width-1:0] c
);
    localparam logic [Width-1:0] ZERO = {Width{1'b0}};
    localparam logic [Width-1:0] ONE  = {{Width - 1{1'b0}}, 1'b1};

    wire        [$clog2(Width)-1:0] mini_b     = b[$clog2(Width)-1:0];
    wire signed [        Width-1:0] sign_a     = $signed(a);
    wire signed [        Width-1:0] sign_b     = $signed(b);
    wire signed [        Width-1:0] sign_shift = sign_a >>> mini_b;

    always_comb begin
        case (op)
            `ISA__FUNCT3_ADD:  c = mod ? a - b : a + b;
            `ISA__FUNCT3_SLT:  c = sign_a < sign_b ? ONE : ZERO;
            `ISA__FUNCT3_SLTU: c = a < b ? ONE : ZERO;
            `ISA__FUNCT3_XOR:  c = a ^ b;
            `ISA__FUNCT3_OR:   c = a | b;
            `ISA__FUNCT3_AND:  c = a & b;
            `ISA__FUNCT3_SLL:  c = a << mini_b;
            `ISA__FUNCT3_SRL:  c = mod ? sign_shift : a >> mini_b;
            default:           c = ZERO;
        endcase
    end

endmodule
