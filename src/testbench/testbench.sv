module testbench ();

    reg clk;
    reg rst_n;
    reg inhibit;

    always #50 clk = !clk;

    initial begin
        clk   = 1'b1;
        rst_n = 1'b0;
        #100;
        rst_n = 1'b1;
    end

    initial begin
        inhibit = 1'b0;
        #1
        forever begin
            inhibit = 1'b0;
            #300;
            inhibit = 1'b0;
            #200;
        end
    end

    wire [3:0] key = {3'b111,rst_n};

    wire [9:0] sw  = 10'd0;

    wire [9:0] led;

    wire [6:0] hex0;
    wire [6:0] hex1;
    wire [6:0] hex2;
    wire [6:0] hex3;
    wire [6:0] hex4;
    wire [6:0] hex5;

    wire [35:0] gpio = 36'd0;

    top top (
        .clock_50(clk),
        .key     (key),
        .sw      (sw),
        .led     (led),
        .hex0    (hex0),
        .hex1    (hex1),
        .hex2    (hex2),
        .hex3    (hex3),
        .hex4    (hex4),
        .hex5    (hex5),
        .gpio    (gpio)
    );

endmodule
