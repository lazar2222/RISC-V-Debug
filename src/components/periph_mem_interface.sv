`include "../system/arilla_bus_if.svh"

module periph_mem_interface #(
    parameter int BaseAddress,
    parameter int SizeWords
) (
    clk,
    rst_n,
    bus_interface,
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

    input [(SizeWords*DataWidth)-1:0] data_periph_in;

    output reg [DataWidth-1:0] data_periph_out;
    output reg [SizeWords-1:0] data_periph_write;

    wire [DeviceAddressWidth-1:0] device_address = bus_interface.address[AddressWidth-1:LocalAddressWidth];
    wire [ LocalAddressWidth-1:0] local_address  = bus_interface.address[LocalAddressWidth-1:0];
    wire [      BytesPerWord-1:0] byte_enable    = bus_interface.byte_enable;
    wire [         DataWidth-1:0] data_in        = bus_interface.data_ctp;
    wire [         DataWidth-1:0] data_mask;
    reg  [         DataWidth-1:0] data_out;

    reg  read_hit;
    wire hit         = device_address == DeviceAddress;
    wire write_hit   = hit && bus_interface.write;
    wire data_enable = read_hit && !bus_interface.intercept;

    assign bus_interface.hit      = hit         ? 1'b1     : 1'bz;
    assign bus_interface.data_ptc = data_enable ? data_out : {DataWidth{1'bz}};

    always @(posedge clk) begin
        if (!rst_n) begin
            read_hit <= 1'b0;
            data_out <= {DataWidth{1'b0}};
        end else begin
            read_hit <= hit && bus_interface.read;
            data_out <= data_periph_in[(DataWidth*local_address)+:DataWidth];
        end
    end

    genvar i;
    generate
        for(i = 0; i < BytesPerWord; i++) begin : g_mask
            assign data_mask[ByteSize*i+:ByteSize] = {ByteSize{byte_enable[i]}};
        end
    endgenerate

    always_comb begin
        data_periph_out                  = (data_in & data_mask) | (data_periph_in[(DataWidth*local_address)+:DataWidth] & ~data_mask);
        data_periph_write                = {SizeWords{1'b0}};
        data_periph_write[local_address] = write_hit;
    end

endmodule
