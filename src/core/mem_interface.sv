`include "../system/arilla_bus_if.svh"

module mem_interface #(
    parameter int DataWidth = 32,
    parameter int AddressWidth = 32
) (
    input clk,
    input rst_n,

    arilla_bus_if bus_interface,

    input  [DataWidth-1:0] data_in,
    output [DataWidth-1:0] data_out,

    input [                 AddressWidth-1:0] address,
    input [$clog2($clog2(DataWidth/8)+1)-1:0] size,
    input                                     rd,
    input                                     wr,
    input                                     singed,

    output malign,
    output complete
);
    localparam int ByteEnables = DataWidth / 8;
    localparam int MaxSize = $clog2(ByteEnables);

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

    reg  state;
    wire next_state = read;

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= 1'b0;
        end else begin
            state <= next_state;
        end
    end

    assign complete = write || (read && state);

    wire [ByteEnables-1:0] byte_enable;
    wire [MaxSize-1:0] start_index = address[MaxSize-1:0];
    wire [MaxSize-1:0] end_index = start_index + (1'b1 << size) - 1'b1;
    wire [DataWidth-1:0] shift_data_in = data_in << (start_index * 8);
    genvar j;
    generate
        for (j = 0; j < ByteEnables; j++) begin : g_byte_enables
            assign byte_enable[j] = j >= start_index && j <= end_index;
        end
    endgenerate

    wire output_address = write || read;

    assign bus_interface.data = write ? shift_data_in : {DataWidth{1'bz}};
    assign bus_interface.address = bus_interface.available ? address[AddressWidth-1:MaxSize] : {AddressWidth - MaxSize{1'bz}};
    assign bus_interface.byte_enable = bus_interface.available ? byte_enable : {ByteEnables{1'bz}};
    assign bus_interface.read = bus_interface.available ? read : 1'bz;
    assign bus_interface.write = bus_interface.available ? write : 1'bz;

    wire [DataWidth-1:0] data = bus_interface.data;
    wire [DataWidth-1:0] shift_data_out = data >> (start_index * 8);
    wire [DataWidth-1:0] sign_extend_data[MaxSize+1];
    wire [DataWidth-1:0] zero_extend_data[MaxSize+1];

    genvar k;
    generate
        for (k = 0; k <= MaxSize; k++) begin : g_data_out
            localparam int WordEnd = ((1 << k) * 8) - 1;
            localparam int ExtendBits = (ByteEnables - (1 << k)) * 8;
            assign sign_extend_data[k] = {{ExtendBits{shift_data_out[WordEnd]}}, shift_data_out[WordEnd:0]};
            assign zero_extend_data[k] = {{ExtendBits{1'b0}}, shift_data_out[WordEnd:0]};
        end
    endgenerate

    assign data_out = singed ? sign_extend_data[size] : zero_extend_data[size];
endmodule
