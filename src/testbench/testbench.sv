`include "../system/arilla_bus_if.svh"
`include "../system/system.svh"

module testbench ();

    reg clk;
    reg rst_n;
    reg available;

    always #50 clk = !clk;

    initial begin
        clk = 1'b1;
        rst_n = 1'b0;
        #100;
        rst_n = 1'b1;
    end

    initial begin
        available = 1'b1;
        #1
        forever begin
            available = 1'b1;
            #400;
            available = 1'b0;
            #400;
        end
    end

    arilla_bus_if #(
        .DataWidth       (`SYSTEM__XLEN),
        .ByteAddressWidth(`SYSTEM__ALEN),
        .ByteSize        (`SYSTEM__BLEN)
    ) bus_interface ();

    assign bus_interface.available = available;
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
