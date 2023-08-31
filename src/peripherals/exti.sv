`include "../system/arilla_bus_if.svh"

module exti #(
    parameter int BaseAddress,
    parameter int NumIO
) (
    clk,
    rst_n,
    pins,
    intr,
    bus_interface,
    hit
);
    localparam int DataWidth   = $bits(bus_interface.data_ctp);
    localparam int MinNumWords = (NumIO + DataWidth - 1) / DataWidth;
    localparam int NumWords    = 2 ** $clog2(5 * MinNumWords);
    localparam int FillWords   = NumWords - (5 * MinNumWords);

    input clk;
    input rst_n;

    input [NumIO-1:0] pins;

    output intr;

    arilla_bus_if bus_interface;

    output hit;

    reg  [NumIO-1:0] in1_reg, in2_reg;
    wire [NumIO-1:0] rising, falling;
    reg  [NumIO-1:0] reen, feen;
    reg  [NumIO-1:0] enable, pending;

    assign rising  =  in1_reg & ~in2_reg;
    assign falling = ~in1_reg &  in2_reg;
    assign intr    = |(pending & enable);

    int j, k, l;

    wire [(MinNumWords*DataWidth)-1:0] reen_mem;
    wire [(MinNumWords*DataWidth)-1:0] feen_mem;
    wire [(MinNumWords*DataWidth)-1:0] enable_mem;
    wire [(MinNumWords*DataWidth)-1:0] pending_mem;
    wire [              DataWidth-1:0] null_word = {DataWidth{1'b0}};
    wire [   (NumWords*DataWidth)-1:0] memory    = {{FillWords{null_word}},feen_mem,reen_mem,pending_mem,pending_mem,enable_mem};

    wire [DataWidth-1:0] data_out;
    wire [ NumWords-1:0] data_write;

    always @(posedge clk) begin
        if (!rst_n) begin
            in1_reg <= {NumIO{1'b0}};
            in2_reg <= {NumIO{1'b0}};
            enable  <= {NumIO{1'b0}};
            pending <= {NumIO{1'b0}};
            reen    <= {NumIO{1'b0}};
            feen    <= {NumIO{1'b0}};
        end else begin
            in1_reg <= pins;
            in2_reg <= in1_reg;
            pending <= pending | (rising & reen) | (falling & feen);
            for (j = 0; j < MinNumWords; j++) begin
                if (data_write[j]) begin
                    for (k = 0; k < DataWidth; k++) begin
                       l = j * DataWidth + k;
                       if (l < NumIO) begin
                            enable[l] <= data_out[k];
                       end
                    end
                end
            end
            for (j = 0; j < MinNumWords; j++) begin
                if (data_write[MinNumWords + j]) begin
                    for (k = 0; k < DataWidth; k++) begin
                       l = j * DataWidth + k;
                       if (l < NumIO) begin
                            pending[l] <= (pending[l] | (rising[l] & reen[l]) | (falling[l] & feen[l])) & !data_out[k];
                       end
                    end
                end
            end
            for (j = 0; j < MinNumWords; j++) begin
                if (data_write[(2 * MinNumWords) + j]) begin
                    for (k = 0; k < DataWidth; k++) begin
                       l = j * DataWidth + k;
                       if (l < NumIO) begin
                        pending[l] <= pending[l] | (rising[l] & reen[l]) | (falling[l] & feen[l]) | data_out[k];
                       end
                    end
                end
            end
            for (j = 0; j < MinNumWords; j++) begin
                if (data_write[(3 * MinNumWords) + j]) begin
                    for (k = 0; k < DataWidth; k++) begin
                       l = j * DataWidth + k;
                       if (l < NumIO) begin
                            reen[l] <= data_out[k];
                       end
                    end
                end
            end
            for (j = 0; j < MinNumWords; j++) begin
                if (data_write[(4 * MinNumWords) + j]) begin
                    for (k = 0; k < DataWidth; k++) begin
                       l = j * DataWidth + k;
                       if (l < NumIO) begin
                            feen[l] <= data_out[k];
                       end
                    end
                end
            end
        end
    end

    genvar i;
    generate
        for (i = 0; i < MinNumWords * DataWidth; i++) begin : g_mem
            assign reen_mem[i]    = i < NumIO ?    reen[i] : 1'b0;
            assign feen_mem[i]    = i < NumIO ?    feen[i] : 1'b0;
            assign enable_mem[i]  = i < NumIO ?  enable[i] : 1'b0;
            assign pending_mem[i] = i < NumIO ? pending[i] : 1'b0;
        end
    endgenerate

    periph_mem_interface #(
        .BaseAddress(BaseAddress),
        .SizeWords  (NumWords)
    ) periph_mem_interface (
        .clk              (clk),
        .rst_n            (rst_n),
        .bus_interface    (bus_interface),
        .hit              (hit),
        .data_periph_in   (memory),
        .data_periph_out  (data_out),
        .data_periph_write(data_write)
    );

endmodule
