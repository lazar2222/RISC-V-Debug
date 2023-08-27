`ifndef DMI_IF__SVH
`define DMI_IF__SVH

interface dmi_if #(
    parameter int DataWidth,
    parameter int AddressWidth
);
    tri0 [   DataWidth-1:0] data;
    tri0 [AddressWidth-1:0] address;
    tri0                    read;
    tri0                    write;

endinterface

`endif  //DMI_IF__SVH
