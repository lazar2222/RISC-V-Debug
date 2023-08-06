module reg_file #(
    parameter int Width = 32,
    parameter int Depth = 32
) (
    input clk,
    input rst_n,

    input [$clog2(Depth)-1:0] rd_addr1,
    input [$clog2(Depth)-1:0] rd_addr2,
    input [$clog2(Depth)-1:0] wr_addr,
    input [        Width-1:0] wr_data,
    input                     wr_en,

    output [Width-1:0] rd_data1,
    output [Width-1:0] rd_data2
);
    localparam logic [Width-1:0] ZERO = {Width{1'b0}};
    localparam logic [$clog2(Depth)-1:0] REG_ZERO = {$clog2(Depth) - 1{1'b0}};

    reg [Width-1:0] registers[Depth];

    assign rd_data1 = rd_addr1 == REG_ZERO ? ZERO : registers[rd_addr1];
    assign rd_data2 = rd_addr2 == REG_ZERO ? ZERO : registers[rd_addr2];

    always @(posedge clk) begin
        if (!rst_n) begin
            registers <= '{default: ZERO};
        end else begin
            if (wr_en && wr_addr != REG_ZERO) begin
                registers[wr_addr] <= wr_data;
            end
        end
    end

endmodule
