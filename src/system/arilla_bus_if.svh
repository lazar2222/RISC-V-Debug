`ifndef ARILLA_BUS_IF__SVH
`define ARILLA_BUS_IF__SVH

interface arilla_bus_if #(
    parameter int DataWidth = 32,
    parameter int ByteAddressWidth = 32
);
    localparam int ByteSize = 8;
    localparam int BytesPerWord = DataWidth / ByteSize;
    localparam int WordAddressWidth = ByteAddressWidth - $clog2(BytesPerWord);

    wire [       DataWidth-1:0] data;
    wire [       DataWidth-1:0] data_in;
    wire [WordAddressWidth-1:0] address;
    wire [    BytesPerWord-1:0] byte_enable;
    wire                        read;
    wire                        write;
    wire                        available;
    wire                        intercept;

endinterface

`endif
