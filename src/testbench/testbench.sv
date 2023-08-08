`include "../system/arilla_bus_if.svh"
`include "../system/system.svh"

module testbench ();

    reg clk;
    reg rst_n;

    always #50 clk = !clk;

    initial begin
        clk = 1'b1;
        rst_n = 1'b0;
        #100;
        rst_n = 1'b1;
    end

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
