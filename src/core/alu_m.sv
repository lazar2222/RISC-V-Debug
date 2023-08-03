module alu_m #(
    parameter int Width = 32
) (
    input [Width-1:0] a,
    input [Width-1:0] b,

    input [2:0] op,

    output reg [Width-1:0] c
);
    localparam logic [Width-1:0] ZERO = {Width{1'b0}};

    wire signed [Width-1:0] sign_a = $signed(a);
    wire signed [Width-1:0] sign_b = $signed(b);
    wire signed [(2*Width)-1:0] mul_ss = sign_a * sign_b;
    wire signed [(2*Width)-1:0] mul_su = sign_a * b;
    wire signed [(2*Width)-1:0] mul_u = a * b;

    always_comb begin
        case (op[2:0])
            3'b000:  c = mul_ss[Width-1:0];
            3'b001:  c = mul_ss[(2*Width)-1:Width];
            3'b010:  c = mul_su[(2*Width)-1:Width];
            3'b011:  c = mul_u[(2*Width)-1:Width];
            3'b100:  c = sign_a / sign_b;
            3'b101:  c = a / b;
            3'b110:  c = sign_a % sign_b;
            3'b111:  c = a % b;
            default: c = ZERO;
        endcase
    end
endmodule
