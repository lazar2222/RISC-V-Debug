`ifndef ARILLA_BUS_IF__SVH
`define ARILLA_BUS_IF__SVH

interface arilla_bus_if #(
    parameter int DataWidth = 32,
    parameter int AddressWidth = 32
);
    localparam int ByteEnables = DataWidth / 8;
    localparam int ActualAddressWidth = AddressWidth - $clog2(ByteEnables);

    logic [         DataWidth-1:0] data;
    logic [ActualAddressWidth-1:0] address;
    logic [       ByteEnables-1:0] byte_enable;
    logic                          read;
    logic                          write;
    logic                          available;
    logic                          intercept;
endinterface

`endif
