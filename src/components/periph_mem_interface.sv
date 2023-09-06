`include "../system/arilla_bus_if.svh"

module periph_mem_interface #(
    parameter int BaseAddress,
    parameter int SizeWords
) (
    clk,
    rst_n,
    bus_interface,
    hit,
    data_periph_in,
    data_periph_out,
    data_periph_write
);
    localparam int DataWidth             = $bits(bus_interface.data_ctp);
    localparam int AddressWidth          = $bits(bus_interface.address);
    localparam int BytesPerWord          = $bits(bus_interface.byte_enable);
    localparam int ByteSize              = DataWidth / BytesPerWord;
    localparam int SizeBytes             = SizeWords * BytesPerWord;
    localparam int ByteAddressWidth      = AddressWidth + $clog2(BytesPerWord);
    localparam int LocalAddressWidth     = $clog2(SizeWords);
    localparam int LocalByteAddressWidth = LocalAddressWidth + $clog2(BytesPerWord);
    localparam int DeviceAddressWidth    = AddressWidth - LocalAddressWidth;
    localparam int DeviceAddress         = BaseAddress[ByteAddressWidth-1:LocalByteAddressWidth];

    input clk;
    input rst_n;

    arilla_bus_if bus_interface;

    output hit;

    input [(SizeWords*DataWidth)-1:0] data_periph_in;

    output [DataWidth-1:0] data_periph_out;
    output [SizeWords-1:0] data_periph_write;

    wire [DataWidth-1:0] data_periph [SizeWords];

    wire [DeviceAddressWidth-1:0] device_address = bus_interface.address[AddressWidth-1:LocalAddressWidth];
    wire [ LocalAddressWidth-1:0] local_address  = bus_interface.address[LocalAddressWidth-1:0];
    wire [      BytesPerWord-1:0] byte_enable    = bus_interface.byte_enable;
    wire [         DataWidth-1:0] data_in        = bus_interface.data_ctp;
    wire [         DataWidth-1:0] data_mask;
    reg  [         DataWidth-1:0] data_out;

    reg  read_hit;
    assign hit       = device_address == DeviceAddress && rst_n;
    wire write_hit   = hit && bus_interface.write;
    wire data_enable = read_hit && !bus_interface.intercept;

    assign bus_interface.data_ptc = data_enable ? data_out : {DataWidth{1'bz}};

    assign data_periph_out = (data_in & data_mask) | (data_periph[local_address] & ~data_mask);

    always @(posedge clk) begin
        if (!rst_n) begin
            read_hit <= 1'b0;
            data_out <= {DataWidth{1'b0}};
        end else begin
            read_hit <= hit && bus_interface.read;
            data_out <= data_periph[local_address];
        end
    end

    genvar i;
    generate
        for(i = 0; i < BytesPerWord; i++) begin : g_mask
            assign data_mask[ByteSize*i+:ByteSize] = {ByteSize{byte_enable[i]}};
        end
        for(i = 0; i < SizeWords; i++) begin : g_write
            assign data_periph_write[i] = local_address == i ? write_hit : 1'b0;
            assign data_periph[i]       = data_periph_in[(DataWidth*i)+:DataWidth];
        end
    endgenerate

endmodule
