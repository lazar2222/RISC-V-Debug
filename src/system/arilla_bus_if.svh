`ifndef ARILLA_BUS_IF__SVH
`define ARILLA_BUS_IF__SVH

interface arilla_bus_if #(
    parameter int DataWidth        = 32,
    parameter int ByteAddressWidth = 32,
    parameter int ByteSize         = 8
);
    localparam int BytesPerWord     = DataWidth / ByteSize;
    localparam int WordAddressWidth = ByteAddressWidth - $clog2(BytesPerWord);

    tri1 [       DataWidth-1:0] data_ctp;
    tri0 [       DataWidth-1:0] data_ptc;
    tri1 [WordAddressWidth-1:0] address;
    tri1 [    BytesPerWord-1:0] byte_enable;
    tri0                        read;
    tri0                        write;
    tri1                        available;
    tri0                        intercept;
    tri0                        hit;

endinterface

`endif
