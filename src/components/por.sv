module por #(
    parameter int Cycles
) (
    input clk,
    input power,

    output rst_n
);
    int cnt;

    assign rst_n = cnt == Cycles;

    initial begin
        cnt = 0;
    end

    always @(posedge clk) begin
        if (power) begin
            if (cnt != Cycles) begin
                cnt <= cnt + 1;
            end
        end else begin
            cnt <= 0;
        end
    end

endmodule
