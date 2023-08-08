module shadow_reg #(
    parameter int Width      = 32,
    parameter int ResetValue = 32'd0
) (
    input clk,
    input rst_n,

    input [Width-1:0] in,

    input write,

    output reg [Width-1:0] out,
    output     [Width-1:0] shadow_out
);
    assign shadow_out = write ? in : out;

    always @(posedge clk) begin
        if (!rst_n) begin
            out <= ResetValue;
        end else if (write) begin
            out <= in;
        end
    end

endmodule
