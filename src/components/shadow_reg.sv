module shadow_reg #(
    parameter int Width = 32,
    parameter int ResetValue = 32'd0
) (
    input clk,
    input rst_n,

    input [Width-1:0] in,

    input write,

    output [Width-1:0] out,
    output [Width-1:0] shadow_out
);
    reg [Width-1:0] value;

    assign out = value;
    assign shadow_out = write ? in : value;

    always @(posedge clk) begin
        if (!rst_n) begin
            value <= ResetValue;
        end else if (write) begin
            value <= in;
        end
    end
endmodule
