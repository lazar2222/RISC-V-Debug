`ifndef ARILLA_BUS_IF__SVH
`define ARILLA_BUS_IF__SVH

interface arilla_bus_if #(
    parameter int DataWidth = 32,
    parameter int AddressWidth = 32
);
    localparam int ByteEnables = DataWidth / 8;
    localparam int ActualAddressWidth = AddressWidth - $clog2(ByteEnables);

    wire [         DataWidth-1:0] data;
    wire [ActualAddressWidth-1:0] address;
    wire [       ByteEnables-1:0] byte_enable;
    wire                          read;
    wire                          write;
    wire                          available;
    wire                          intercept;
endinterface

`endif
