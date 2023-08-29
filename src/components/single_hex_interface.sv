module single_hex_interface (
    input      [3:0] in,
    output reg [6:0] out
);
    always_comb begin
        case (in)
            4'h0:    out = ~7'h3F;
            4'h1:    out = ~7'h06;
            4'h2:    out = ~7'h5B;
            4'h3:    out = ~7'h4F;
            4'h4:    out = ~7'h66;
            4'h5:    out = ~7'h6D;
            4'h6:    out = ~7'h7D;
            4'h7:    out = ~7'h07;
            4'h8:    out = ~7'h7F;
            4'h9:    out = ~7'h6F;
            4'hA:    out = ~7'h77;
            4'hB:    out = ~7'h7C;
            4'hC:    out = ~7'h39;
            4'hD:    out = ~7'h5E;
            4'hE:    out = ~7'h79;
            4'hF:    out = ~7'h71;
            default: out = ~7'h00;
        endcase
    end

endmodule
