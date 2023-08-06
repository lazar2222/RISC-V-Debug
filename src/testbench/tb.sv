`include "../system/arilla_bus_if.svh"

module tb ();

    reg clk = 1'b1;
    reg rst_n = 1'b0;
    reg available = 1'b1;
    reg intercept = 1'b0;

    arilla_bus_if bus_interface ();

    rv_core rv_core (
        .clk(clk),
        .rst_n(rst_n),
        .bus_interface(bus_interface)
    );

    memory #(
        .BaseAddress(32'h0),
        .InitFile("C:/Users/lazar/Desktop/RISC-V_Debug/src/system/main.mif"),
        .Hint("ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=MAIN")
    ) memory (
        .clk(clk),
        .rst_n(rst_n),
        .bus_interface(bus_interface)
    );

    assign bus_interface.available = available;
    assign bus_interface.intercept = intercept;

    always #50 clk = !clk;

endmodule
