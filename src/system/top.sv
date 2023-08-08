`include "arilla_bus_if.svh"
`include "system.svh"

module top (
    input CLOCK_50,

    input [3:0] KEY,

    input [9:0] SW,

    output [9:0] LED,

    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,

    output [12:0] DRAM_ADDR,
    output [ 1:0] DRAM_BA,
    output        DRAM_CLK,
    output        DRAM_CKE,
    output        DRAM_RAS_N,
    output        DRAM_CAS_N,
    output        DRAM_CS_N,
    output        DRAM_WE_N,
    output        DRAM_LDQM,
    output        DRAM_UDQM,
    inout  [15:0] DRAM_DQ,

    output       VGA_CLK,
    output       VGA_HS,
    output       VGA_VS,
    output       VGA_SYNC_N,
    output       VGA_BLANK_N,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,

    output AUD_XCK,
    output AUD_BCLK,
    output AUD_DACLRCK,
    output AUD_DACDAT,
    output I2C_SCLK,
    inout  I2C_SDAT,

    inout PS2_CLK1,
    inout PS2_DAT1,
    inout PS2_CLK2,
    inout PS2_DAT2,

    inout [35:0] GPIO
);
    wire clk = CLOCK_50;
    wire rst_n = KEY[0];

    arilla_bus_if #(
        .DataWidth       (`SYSTEM__XLEN),
        .ByteAddressWidth(`SYSTEM__ALEN),
        .ByteSize        (`SYSTEM__BLEN)
    ) bus_interface ();

    assign bus_interface.available = 1'b1;
    assign bus_interface.intercept = 1'b0;

    rv_core rv_core (
        .clk          (clk),
        .rst_n        (rst_n),
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
