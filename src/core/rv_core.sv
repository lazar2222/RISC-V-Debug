`include "../system/arilla_bus_if.svh"
`include "isa.svh"

module rv_core (
    input clk,
    input rst_n,

    arilla_bus_if bus_if
);
    wire [`ISA__XLEN-1:0] pc, next_pc, shadow_pc;
    wire [`ISA__XLEN-1:0] ir, next_ir;
    wire [`ISA__XLEN-1:0] rs1, rs2, rd;
    wire [`ISA__XLEN-1:0] mem_out, mem_in, mem_addr;

    wire [`ISA__RFLEN-1:0] rs1_a, rs2_a, rd_a;
    wire [1:0] mem_size;

    wire write_pc, write_ir, write_rd;
    wire mem_read, mem_write, mem_fc, mem_signed, mem_malign;

    shadow_reg #(
        .Width(`ISA__XLEN),
        .ResetValue(`ISA__RVEC)
    ) pc_reg (
        .clk(clk),
        .rst_n(rst_n),
        .in(next_pc),
        .write(write_pc),
        .out(pc),
        .shadow_out(shadow_pc)
    );

    shadow_reg #(
        .Width(`ISA__XLEN),
        .ResetValue(`ISA__RVEC)
    ) ir_reg (
        .clk(clk),
        .rst_n(rst_n),
        .in(next_ir),
        .write(write_ir),
        .shadow_out(ir)
    );

    reg_file #(
        .Width(`ISA__XLEN),
        .Depth(`ISA__RNUM)
    ) reg_file (
        .clk(clk),
        .rst_n(rst_n),
        .rd_addr1(rs1_a),
        .rd_addr2(rs2_a),
        .wr_addr(rd_a),
        .wr_data(rd),
        .wr_en(write_rd),
        .rd_data1(rs1),
        .rd_data2(rs2)
    );

    mem_interface #(
        .DataWidth(`ISA__XLEN),
        .AddressWidth(`ISA__XLEN)
    ) mem_interface_inst (
        .clk(clk),
        .rst_n(rst_n),
        .bus_interface(bus_if),
        .data_in(mem_out),
        .data_out(mem_in),
        .address(mem_addr),
        .size(mem_size),
        .rd(mem_read),
        .wr(mem_write),
        .singed(mem_signed),
        .malign(mem_malign),
        .complete(mem_fc)
    );

endmodule
