`include "arilla_bus_if.svh"
`include "system.svh"
`include "../debug/dmi_if.svh"
`include "../debug/debug_if.svh"

module top #(
    parameter int PLL = 1
) (
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
    wire clk;
    wire power = key[0];
    wire nmi   = !key[1];

    generate
        if (PLL == 1) begin : g_pll
            pll pll (
            .refclk  (clock_50),
            .rst     (!power && nmi),
            .outclk_0(clk)
            );
        end else begin : g_nopll
            assign clk = clock_50;
        end
    endgenerate

    wire reset_n, hart_reset_n, rst_n;
    wire exti = 1'b0;

    tri0 [21:0] pins;

    assign pins[ 1:0] = key[3:2];
    assign pins[11:2] = sw;
    assign led        = pins[21:12];

    wire [41:0] hex;

    assign hex0 = hex[ 6: 0];
    assign hex1 = hex[13: 7];
    assign hex2 = hex[20:14];
    assign hex3 = hex[27:21];
    assign hex4 = hex[34:28];
    assign hex5 = hex[41:35];

    arilla_bus_if #(
        .DataWidth       (`SYSTEM__XLEN),
        .ByteAddressWidth(`SYSTEM__ALEN),
        .ByteSize        (`SYSTEM__BLEN)
    ) bus_interface ();

    assign bus_interface.inhibit   = 1'b0;
    assign bus_interface.intercept = 1'b0;

    dmi_if #(
        .DataWidth   (`SYSTEM__XLEN),
        .AddressWidth(`SYSTEM__DMI_ALEN)
    ) dmi_interface ();

    debug_if debug_interface ();

    por #(
        .Cycles(`SYSTEM__POR_TIME)
    ) por (
        .clk  (clk),
        .power(power),
        .rst_n(reset_n)
    );

    dm dm (
        .clk          (clk),
        .rst_n        (reset_n),
        .reset_n      (rst_n),
        .hart_reset_n (hart_reset_n),
        .dmi          (dmi_interface),
        .debug        (debug_interface),
        .bus_interface(bus_interface)
    );

    rv_core rv_core (
        .clk            (clk),
        .rst_n          (hart_reset_n),
        .nmi            (nmi),
        .exti           (exti),
        .bus_interface  (bus_interface),
        .debug_interface(debug_interface)
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

    gpio #(
        .BaseAddress(`SYSTEM__GPIO_BASE),
        .NumIO      (`SYSTEM__GPIO_NUM),
        .Mask       (`SYSTEM__GPIO_MASK)
    ) gpio_p (
        .clk          (clk),
        .rst_n        (rst_n),
        .pins         (pins),
        .bus_interface(bus_interface)
    );

    hex #(
        .BaseAddress(`SYSTEM__HEX_BASE),
        .NumDigits  (`SYSTEM__HEX_NUM)
    ) hex_p (
        .clk          (clk),
        .rst_n        (rst_n),
        .dig          (hex),
        .bus_interface(bus_interface)
    );

endmodule
