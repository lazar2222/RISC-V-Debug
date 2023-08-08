`include "isa.svh"

module alu_m #(
    parameter int Width = `ISA__XLEN
) (
    input [Width-1:0] a,
    input [Width-1:0] b,

    input [`ISA__FUNCT3_WIDTH-1:0] f3,

    output reg [Width-1:0] c
);
    localparam logic [Width-1:0] ZERO = {Width{1'b0}};

    wire signed [    Width-1:0] sign_a = $signed(a);
    wire signed [    Width-1:0] sign_b = $signed(b);
    wire signed [(2*Width)-1:0] mul_ss = sign_a * sign_b;
    wire signed [(2*Width)-1:0] mul_su = sign_a * b;
    wire signed [(2*Width)-1:0] mul_uu = a * b;

    always_comb begin
        case (f3)
            `ISA__FUNCT3_MUL:    c = mul_ss[Width-1:0];
            `ISA__FUNCT3_MULH:   c = mul_ss[(2*Width)-1:Width];
            `ISA__FUNCT3_MULHSU: c = mul_su[(2*Width)-1:Width];
            `ISA__FUNCT3_MULHU:  c = mul_uu[(2*Width)-1:Width];
            `ISA__FUNCT3_DIV:    c = sign_a / sign_b;
            `ISA__FUNCT3_DIVU:   c = a / b;
            `ISA__FUNCT3_REM:    c = sign_a % sign_b;
            `ISA__FUNCT3_REMU:   c = a % b;
            default:             c = ZERO;
        endcase
    end

endmodule
