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
    complete,
    malign,
    fault
);
    localparam int DataWidth        = $bits(bus_interface.data_ctp);
    localparam int WordAddressWidth = $bits(bus_interface.address);
    localparam int BytesPerWord     = $bits(bus_interface.byte_enable);
    localparam int ByteSize         = DataWidth / BytesPerWord;
    localparam int ByteAddressWidth = WordAddressWidth + $clog2(BytesPerWord);
    localparam int MaxSize          = $clog2(BytesPerWord);
    localparam int SizeSize         = $clog2(MaxSize + 1);

    input clk;
    input rst_n;

    arilla_bus_if bus_interface;

    input [ByteAddressWidth-1:0] address;
    input [          SizeSize:0] sign_size;
    input                        rd;
    input                        wr;

    input  [DataWidth-1:0] data_in;
    output [DataWidth-1:0] data_out;

    output complete;
    output reg malign;
    output reg fault;

    reg [ByteAddressWidth-1:0] address_reg;
    reg [        SizeSize-1:0] size_reg;
    reg                        sign_reg;

    wire [SizeSize-1:0] size = sign_size[SizeSize-1:0];
    wire [   MaxSize:0] maligns;

    assign maligns[0] = 1'b0;
    genvar i;
    generate
        for (i = 1; i <= MaxSize; i++) begin : g_maligns
            assign maligns[i] = address[i-1:0] != {i{1'b0}};
        end
    endgenerate
    wire malign_w = size > MaxSize || maligns[size];

    always @(posedge clk) begin
        if (!rst_n) begin
            address_reg <= {ByteAddressWidth{1'b0}};
            size_reg    <= {MaxSize{1'b0}};
            sign_reg    <= 1'b0;
            malign      <= 1'b0;
            fault       <= 1'b0;
        end else begin
            address_reg <= address;
            size_reg    <= size;
            sign_reg    <= sign_size[SizeSize-1];
            malign      <= malign_w;
            fault       <= !bus_interface.hit;
        end
    end

    wire [BytesPerWord-1:0] byte_enable;
    wire [     MaxSize-1:0] start_index   = address[MaxSize-1:0];
    wire [     MaxSize-1:0] end_index     = start_index + ((1'b1 << size) - 1'b1);
    wire [   DataWidth-1:0] shift_data_in = data_in << (start_index * ByteSize);

    genvar j;
    generate
        for (j = 0; j < BytesPerWord; j++) begin : g_byte_enables
            assign byte_enable[j] = j >= start_index && j <= end_index;
        end
    endgenerate

    wire valid = !malign_w && bus_interface.hit;

    assign bus_interface.data_ctp    = !bus_interface.inhibit ? shift_data_in : {DataWidth{1'bz}};
    assign bus_interface.address     = !bus_interface.inhibit ? address[ByteAddressWidth-1:MaxSize] : {WordAddressWidth{1'bz}};
    assign bus_interface.byte_enable = !bus_interface.inhibit ? byte_enable : {BytesPerWord{1'bz}};
    assign bus_interface.read        = !bus_interface.inhibit ? valid && rd : 1'bz;
    assign bus_interface.write       = !bus_interface.inhibit ? valid && wr : 1'bz;
    assign complete                  = !bus_interface.inhibit && (rd || wr);

    wire [DataWidth-1:0] data           = bus_interface.data_ptc;
    wire [DataWidth-1:0] shift_data_out = data >> (address_reg[MaxSize-1:0] * ByteSize);
    wire [DataWidth-1:0] sign_extend_data[MaxSize+1];
    wire [DataWidth-1:0] zero_extend_data[MaxSize+1];

    genvar k;
    generate
        for (k = 0; k <= MaxSize; k++) begin : g_data_out
            localparam int WordEnd     = ((1 << k) * ByteSize) - 1;
            localparam int ExtendBits  = (BytesPerWord - (1 << k)) * ByteSize;
            assign sign_extend_data[k] = {{ExtendBits{shift_data_out[WordEnd]}}, shift_data_out[WordEnd:0]};
            assign zero_extend_data[k] = {{ExtendBits{1'b0}}, shift_data_out[WordEnd:0]};
        end
    endgenerate

    assign data_out = sign_reg ? zero_extend_data[size_reg] : sign_extend_data[size_reg];

endmodule
