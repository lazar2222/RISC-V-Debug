`include "../system/arilla_bus_if.svh"

module gpio #(
    parameter int BaseAddress,
    parameter int NumIO,
    parameter     Mask
) (
    clk,
    rst_n,
    pins,
    bus_interface
);
    localparam int DataWidth   = $bits(bus_interface.data_ctp);
    localparam int MinNumWords = (NumIO + DataWidth - 1) / DataWidth;
    localparam int NumWords    = 2 ** $clog2(3 * MinNumWords);
    localparam int FillWords   = NumWords - (3 * MinNumWords);

    input clk;
    input rst_n;

    inout [NumIO-1:0] pins;

    arilla_bus_if bus_interface;

    reg  [NumIO-1:0] dir;
    reg  [NumIO-1:0] out;
    wire [NumIO-1:0] in;

    wire [(MinNumWords*DataWidth)-1:0] dir_mem;
    wire [(MinNumWords*DataWidth)-1:0] out_mem;
    wire [(MinNumWords*DataWidth)-1:0] in_mem;
    wire [              DataWidth-1:0] null_word = {DataWidth{1'b0}};
    wire [   (NumWords*DataWidth)-1:0] memory    = {dir_mem,out_mem,in_mem,{FillWords{null_word}}};

    wire [DataWidth-1:0] data_out;
    wire [ NumWords-1:0] data_write;

    int j, k, l;

    assign in = pins;

    genvar i;
    generate
        for (i = 0; i < NumIO; i++) begin : g_output
            assign pins[i] = (dir[i] && Mask[i]) ? out[i] : 1'bz;
        end
        for (i = 0; i < MinNumWords * DataWidth; i++) begin : g_mem
            assign dir_mem[i] = i < NumIO ? dir[i] : 1'b0;
            assign out_mem[i] = i < NumIO ? out[i] : 1'b0;
            assign  in_mem[i] = i < NumIO ?  in[i] : 1'b0;
        end
    endgenerate

    always @(posedge clk) begin
        if (!rst_n) begin
            dir <= {NumIO{1'b0}};
            out <= {NumIO{1'b0}};
        end else begin
            for (j = 0; j < MinNumWords; j++) begin
                if (data_write[j]) begin
                    for (k = 0; k < DataWidth; k++) begin
                       l = j * DataWidth + k;
                       if (l < NumIO) begin
                            dir[l] <= data_out[k];
                       end
                    end
                end
            end
            for (j = 0; j < MinNumWords; j++) begin
                if (data_write[MinNumWords + j]) begin
                    for (k = 0; k < DataWidth; k++) begin
                       l = j * DataWidth + k;
                       if (l < NumIO) begin
                            out[l] <= data_out[k];
                       end
                    end
                end
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
