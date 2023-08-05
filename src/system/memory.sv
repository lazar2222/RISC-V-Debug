`include "../system/arilla_bus_if.svh"

module memory #(
    parameter int BaseAddress = 32'h0
) (
    input clk,
    input rst_n,

    arilla_bus_if bus_interface
);
    localparam int DataWidth = 32;
    localparam int AddressWidth = 32;
    localparam int ByteEnables = DataWidth / 8;
    localparam int ActualAddressWidth = AddressWidth - $clog2(ByteEnables);
    localparam int SizeBytes = 524288;
    localparam int AddressBits = $clog2(SizeBytes) - 2;
    localparam int AddressLowIndex = AddressWidth - AddressBits;
    localparam int Base = BaseAddress[AddressWidth-1:AddressLowIndex];

    reg read_hit;

    wire [AddressBits-1:0] addr_comp = bus_interface.address[ActualAddressWidth-1:AddressLowIndex];
    wire write_hit = addr_comp == Base;
    wire bus_out = read_hit && bus_interface.read && !bus_interface.intercept;
    wire bus_write = write_hit && bus_interface.write;

    wire [DataWidth-1:0] data_in = bus_interface.data;
    wire [DataWidth-1:0] data_out;

    assign bus_interface.data = (bus_out) ? data_out : {DataWidth{1'bz}};

    main_memory mem (
        .address(bus_interface.address[AddressBits-1:0]),
        .byteena(bus_interface.byte_enable),
        .clock(clk),
        .data(data_in),
        .wren(bus_write),
        .q(data_out)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            read_hit <= 1'b0;
        end else begin
            read_hit <= write_hit;
        end
    end
endmodule
