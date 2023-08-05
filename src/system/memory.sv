`include "../system/arilla_bus_if.svh"

module memory #(
    parameter int BaseAddress = 32'h0,
    parameter int SizeBytes = 524288,
    //"C:/Users/lazar/Desktop/RISC-V_Debug/src/system/main.mif"
    parameter string InitFile = "UNUSED",
    //"ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=MAIN"
    parameter string Hint = "UNUSED"
) (
    input clk,
    input rst_n,

    arilla_bus_if bus_interface
);
    localparam int ByteSize = 8;
    localparam int DataWidth = $bits(bus_interface.data);
    localparam int AddressWidth = $bits(bus_interface.address);
    localparam int BytesPerWord = DataWidth / ByteSize;
    localparam int SizeWords = SizeBytes / BytesPerWord;
    localparam int ByteAddressWidth = AddressWidth + $clog2(BytesPerWord);
    localparam int LocalAddressWidth = $clog2(SizeWords);
    localparam int LocalByteAddressWidth = LocalAddressWidth + $clog2(BytesPerWord);
    localparam int DeviceAddressWidth = AddressWidth - LocalAddressWidth;
    localparam int DeviceAddress = BaseAddress[ByteAddressWidth-1:LocalByteAddressWidth];

    wire [DeviceAddressWidth-1:0] device_address = bus_interface.address[AddressWidth-1:LocalAddressWidth];
    wire [LocalAddressWidth-1:0] local_address = bus_interface.address[LocalAddressWidth-1:0];
    wire [BytesPerWord-1:0] byte_enable = bus_interface.byte_enable;
    wire [DataWidth-1:0] data_in = bus_interface.data;
    wire [DataWidth-1:0] data_out;

    reg read_hit;
    wire hit = device_address == DeviceAddress;
    wire data_enable = read_hit && !bus_interface.intercept;
    wire data_write = hit && bus_interface.write;

    assign bus_interface.data = (data_enable) ? data_out : {DataWidth{1'bz}};

    always @(posedge clk) begin
        if (!rst_n) begin
            read_hit <= 1'b0;
        end else begin
            read_hit <= hit && bus_interface.read;
        end
    end

    altsyncram #(
        .byte_size(ByteSize),
        .clock_enable_input_a("BYPASS"),
        .clock_enable_output_a("BYPASS"),
        .init_file(InitFile),
        .intended_device_family("Cyclone V"),
        .lpm_hint(Hint),
        .lpm_type("altsyncram"),
        .numwords_a(SizeWords),
        .operation_mode("SINGLE_PORT"),
        .outdata_aclr_a("NONE"),
        .outdata_reg_a("UNREGISTERED"),
        .power_up_uninitialized("FALSE"),
        .read_during_write_mode_port_a("DONT_CARE"),
        .widthad_a(LocalAddressWidth),
        .width_a(DataWidth),
        .width_byteena_a(BytesPerWord)
    ) altsyncram_component (
        .address_a(local_address),
        .byteena_a(byte_enable),
        .clock0(clk),
        .data_a(data_in),
        .wren_a(data_write),
        .q_a(data_out),
        .aclr0(1'b0),
        .aclr1(1'b0),
        .address_b(1'b1),
        .addressstall_a(1'b0),
        .addressstall_b(1'b0),
        .byteena_b(1'b1),
        .clock1(1'b1),
        .clocken0(1'b1),
        .clocken1(1'b1),
        .clocken2(1'b1),
        .clocken3(1'b1),
        .data_b(1'b1),
        .eccstatus(),
        .q_b(),
        .rden_a(1'b1),
        .rden_b(1'b1),
        .wren_b(1'b0)
    );

endmodule
