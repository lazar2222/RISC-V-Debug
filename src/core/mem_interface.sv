`include "../system/arilla_bus_if.svh"

module mem_interface (
    clk,
    rst_n,
    bus_interface,
    address,
    sign_size,
    rd,
    wr,
    data_in,
    data_out,
    malign,
    complete_read,
    complete_write
);
    localparam int ByteSize = 8;
    localparam int DataWidth = $bits(bus_interface.data);
    localparam int WordAddressWidth = $bits(bus_interface.address);
    localparam int BytesPerWord = DataWidth / ByteSize;
    localparam int ByteAddressWidth = WordAddressWidth + $clog2(BytesPerWord);
    localparam int MaxSize = $clog2(BytesPerWord);
    localparam int SizeSize = $clog2(MaxSize + 1);

    input clk, rst_n;
    arilla_bus_if bus_interface;
    input [ByteAddressWidth-1:0] address;
    input [SizeSize:0] sign_size;
    input rd, wr;
    input [DataWidth-1:0] data_in;
    output [DataWidth-1:0] data_out;
    output malign, complete_read, complete_write;

    reg readout;
    reg [SizeSize:0] sign_size_reg;
    reg [ByteAddressWidth-1:0] address_reg;

    wire [SizeSize-1:0] size = sign_size[SizeSize-1:0];
    wire [SizeSize-1:0] size_reg = sign_size_reg[SizeSize-1:0];
    wire sign_reg = sign_size_reg[SizeSize];
    wire [MaxSize:0] maligns;

    genvar i;
    generate
        for (i = 1; i <= MaxSize; i++) begin : g_maligns
            assign maligns[i] = address[i-1:0] != {i{1'b0}};
        end
    endgenerate

    assign maligns[0] = 1'b0;
    assign malign = size > MaxSize || maligns[size];

    wire read = bus_interface.available && rd && !malign;
    wire write = bus_interface.available && wr && !malign;

    always @(posedge clk) begin
        if (!rst_n) begin
            readout <= 1'b0;
            sign_size_reg <= {MaxSize + 1{1'b0}};
            address_reg <= {ByteAddressWidth{1'b0}};
        end else begin
            readout <= read;
            sign_size_reg <= sign_size;
            address_reg <= address;
        end
    end

    assign complete_read = readout;
    assign complete_write = write;

    wire [BytesPerWord-1:0] byte_enable;
    wire [MaxSize-1:0] start_index = address[MaxSize-1:0];
    wire [MaxSize-1:0] end_index = start_index + ((1'b1 << size) - 1'b1);
    wire [DataWidth-1:0] shift_data_in = data_in << (start_index * ByteSize);
    genvar j;
    generate
        for (j = 0; j < BytesPerWord; j++) begin : g_byte_enables
            assign byte_enable[j] = j >= start_index && j <= end_index;
        end
    endgenerate

    assign bus_interface.data = write ? shift_data_in : {DataWidth{1'bz}};
    assign bus_interface.address = bus_interface.available ? address[ByteAddressWidth-1:MaxSize] : {WordAddressWidth{1'bz}};
    assign bus_interface.byte_enable = bus_interface.available ? byte_enable : {BytesPerWord{1'bz}};
    assign bus_interface.read = bus_interface.available ? read : 1'bz;
    assign bus_interface.write = bus_interface.available ? write : 1'bz;

    wire [DataWidth-1:0] data = bus_interface.data;
    wire [DataWidth-1:0] shift_data_out = data >> (address_reg[MaxSize-1:0] * ByteSize);
    wire [DataWidth-1:0] sign_extend_data[MaxSize+1];
    wire [DataWidth-1:0] zero_extend_data[MaxSize+1];

    genvar k;
    generate
        for (k = 0; k <= MaxSize; k++) begin : g_data_out
            localparam int WordEnd = ((1 << k) * ByteSize) - 1;
            localparam int ExtendBits = (BytesPerWord - (1 << k)) * ByteSize;
            assign sign_extend_data[k] = {{ExtendBits{shift_data_out[WordEnd]}}, shift_data_out[WordEnd:0]};
            assign zero_extend_data[k] = {{ExtendBits{1'b0}}, shift_data_out[WordEnd:0]};
        end
    endgenerate

    assign data_out = sign_reg ? zero_extend_data[size_reg] : sign_extend_data[size_reg];

endmodule
