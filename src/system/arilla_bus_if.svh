`ifndef ARILLA_BUS_IF__SVH
`define ARILLA_BUS_IF__SVH

interface arilla_bus_if #(
    parameter int DataWidth,
    parameter int ByteAddressWidth,
    parameter int ByteSize
);
    localparam int BytesPerWord     = DataWidth / ByteSize;
    localparam int WordAddressWidth = ByteAddressWidth - $clog2(BytesPerWord);

    wire [       DataWidth-1:0] data_ctp;
    wire [       DataWidth-1:0] data_ptc;
    wire [WordAddressWidth-1:0] address;
    wire [    BytesPerWord-1:0] byte_enable;
    wire                        hit;
    wire                        read;
    wire                        write;
    wire                        inhibit;
    wire                        intercept;

endinterface

`endif  //ARILLA_BUS_IF__SVH
