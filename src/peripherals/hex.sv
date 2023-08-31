`include "../system/arilla_bus_if.svh"

module hex #(
    parameter int BaseAddress,
    parameter int NumDigits
) (
    clk,
    rst_n,
    dig,
    bus_interface
);
    localparam int DataWidth   = $bits(bus_interface.data_ctp);
    localparam int NumBits     = NumDigits * 8;
    localparam int MinNumWords = (NumBits + DataWidth - 1) / DataWidth;
    localparam int NumWords    = 2 ** $clog2(MinNumWords + 1);
    localparam int FillWords   = NumWords - (MinNumWords + 1);
    localparam int MaxVal      = (10 ** NumDigits) - 1;
    localparam int MinBits     = $clog2(MaxVal);

    localparam logic [31:0] MODE_DEC = 32'd0;
    localparam logic [31:0] MODE_HEX = 32'd1;
    localparam logic [31:0] MODE_MAN = 32'd2;

    input clk;
    input rst_n;

    output [(7*NumDigits)-1:0] dig;

    arilla_bus_if bus_interface;

    reg  [              DataWidth-1:0] mode;
    reg  [(MinNumWords*DataWidth)-1:0] data;
    wire [              DataWidth-1:0] null_word = {DataWidth{1'b0}};
    wire [   (NumWords*DataWidth)-1:0] memory    = {{FillWords{null_word}},data,mode};

    wire [6:0] digits     [NumDigits];
    wire [6:0] man_digits [NumDigits];
    wire [3:0] pre_digits [NumDigits];

    wire [DataWidth-1:0] data_out;
    wire [ NumWords-1:0] data_write;

    int j;

    genvar i;
    generate
        for (i = 0; i < NumDigits; i++) begin : g_sseg
            assign man_digits[i] = data[(8*i)+:7];
            assign pre_digits[i] = mode == MODE_HEX ? data[(4*i)+:4] : ((data[MinBits-1:0] / (MinBits'(10) ** MinBits'(i))) % MinBits'(10));
            assign dig[(7*i)+:7] = mode == MODE_MAN ? man_digits[i]  : digits[i];
            single_hex_interface single_hex_interface_inst (
                .in (pre_digits[i]),
                .out(digits[i])
            );
        end
    endgenerate

    always @(posedge clk) begin
        if (!rst_n) begin
            mode <= {DataWidth{1'b0}};
            data <= {(MinNumWords*DataWidth){1'b0}};
        end else begin
            if (data_write[0]) begin mode <= data_out; end
            for (j = 0; j < MinNumWords; j++) begin
                if (data_write[j+1]) begin data[(j * DataWidth)+:DataWidth] <= data_out; end
            end
        end
    end

    periph_mem_interface #(
        .BaseAddress(BaseAddress),
        .SizeWords  (NumWords)
    ) periph_mem_interface (
        .clk              (clk),
        .rst_n            (rst_n),
        .bus_interface    (bus_interface),
        .data_periph_in   (memory),
        .data_periph_out  (data_out),
        .data_periph_write(data_write)
    );

endmodule
