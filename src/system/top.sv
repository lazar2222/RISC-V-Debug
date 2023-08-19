`include "arilla_bus_if.svh"
`include "system.svh"

module top (
    input clock_50,

    input [3:0] key,

    input [9:0] sw,

    output [9:0] led,

    output [6:0] hex0,
    output [6:0] hex1,
    output [6:0] hex2,
    output [6:0] hex3,
    output [6:0] hex4,
    output [6:0] hex5,

    inout [35:0] gpio
);
    wire clk   = clock_50;
    wire power = key[0];
    wire nmi   = !key[1];
    wire exti  = !key[2];

    wire rst_n;

    por #(
        .Cycles(50_000_000)
    ) por_inst (
        .clk  (clk),
        .power(power),
        .rst_n(rst_n)
    );

    assign led[0] = rst_n;

    arilla_bus_if #(
        .DataWidth       (`SYSTEM__XLEN),
        .ByteAddressWidth(`SYSTEM__ALEN),
        .ByteSize        (`SYSTEM__BLEN)
    ) bus_interface ();

    assign bus_interface.inhibit   = sw[9];
    assign bus_interface.intercept = sw[8];

    rv_core rv_core (
        .clk          (clk),
        .rst_n        (rst_n),
        .nmi          (nmi),
        .exti         (exti),
        .bus_interface(bus_interface)
    );

    memory #(
        .BaseAddress(`SYSTEM__MEM_BASE),
        .SizeBytes  (`SYSTEM__MEM_SIZE),
        .InitFile   (`SYSTEM__MEM_INIT),
        .Hint       (`SYSTEM__MEM_HINT)
    ) memory (
        .clk          (clk),
        .rst_n        (rst_n),
        .bus_interface(bus_interface)
    );

endmodule
