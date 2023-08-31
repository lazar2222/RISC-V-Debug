`ifndef DMI_IF__SVH
`define DMI_IF__SVH

interface dmi_if #(
    parameter int DataWidth,
    parameter int AddressWidth
);
    wire [   DataWidth-1:0] data;
    wire [AddressWidth-1:0] address;
    wire                    read;
    wire                    write;

endinterface

`endif  //DMI_IF__SVH
