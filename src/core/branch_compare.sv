module branch_compare #(
    parameter int Width = 32
) (
    input [Width-1:0] a,
    input [Width-1:0] b,

    input [2:0] op,

    output reg take
);
    wire signed [Width-1:0] sign_a = $signed(a);
    wire signed [Width-1:0] sign_b = $signed(b);

    always_comb begin
        case (op)
            3'b000:  take = a == b;
            3'b001:  take = a != b;
            3'b100:  take = sign_a < sign_b;
            3'b101:  take = sign_a >= sign_b;
            3'b110:  take = a < b;
            3'b111:  take = a >= b;
            default: take = 1'b0;
        endcase
    end

endmodule
