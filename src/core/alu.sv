module alu #(
    parameter int Width = 32
) (
    input [Width-1:0] a,
    input [Width-1:0] b,

    input [3:0] op,

    output reg [Width-1:0] c
);
    localparam logic [Width-1:0] ZERO = {Width{1'b0}};
    localparam logic [Width-1:0] ONE = {{Width - 1{1'b0}}, 1'b1};

    wire [$clog2(Width)-1:0] mini_b = b[$clog2(Width)-1:0];

    wire signed [Width-1:0] sign_a = $signed(a);
    wire signed [Width-1:0] sign_b = $signed(b);
    wire signed [Width-1:0] sign_shift = sign_a >>> mini_b;

    always_comb begin
        case (op[2:0])
            3'b000:  c = op[3] ? a - b : a + b;
            3'b010:  c = sign_a < sign_b ? ZERO : ONE;
            3'b011:  c = a < b ? ZERO : ONE;
            3'b100:  c = a ^ b;
            3'b110:  c = a | b;
            3'b111:  c = a & b;
            3'b001:  c = a << mini_b;
            3'b101:  c = op[3] ? sign_shift : a >> mini_b;
            default: c = ZERO;
        endcase
    end
endmodule
