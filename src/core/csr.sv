`include "csr.svh"
`include "csr_if.svh"
`include "../system/arilla_bus_if.svh"

module csr #(
    parameter int BaseAddress
) (
    input clk,
    input rst_n,

    csr_if        csr_interface,
    arilla_bus_if bus_interface,

    input [ `ISA__XLEN-1:0] reg_in,
    input [ `ISA__XLEN-1:0] imm_in,
    input [ `ISA__XLEN-1:0] addr,
    input [`ISA__RFLEN-1:0] rs,

    input [`ISA__FUNCT3_WIDTH-1:0] f3,

    input write,
    input debug,
    input retire,

    output tri0 [`ISA__XLEN-1:0] csr_out,
    output                       invalid,
    output tri0                  conflict,
    output                       timeint
);
    wire [`CSR__ALEN-1:0] address     = addr[`CSR__ALEN-1:0];
    wire [`ISA__XLEN-1:0] mask        = f3[2] ? imm_in : reg_in;
    wire [`ISA__XLEN-1:0] set_value   =   mask  | csr_out;
    wire [`ISA__XLEN-1:0] clear_value = (~mask) & csr_out;
    wire [`ISA__XLEN-1:0] value       = f3[1] ? (f3[0] ? clear_value : set_value ) : mask;

    tri0 hit;
    wire rs_zero   = rs     == {`ISA__RFLEN{1'b0}};
    wire imm_zero  = imm_in == { `ISA__XLEN{1'b0}};
    wire write_csr = !(f3[1] && (f3[2] ? imm_zero : rs_zero));

    assign invalid = !hit || (write_csr && `CSR__RW_FIELD(address) == `CSR__READ_ONLY) || (!debug && `CSR__DEBUG_FIELD(address) == `CSR__DEBUG_ONLY);

    wire write_reg = write && write_csr && !invalid;

    `CSRGEN__FOREACH_MCOUNTER(CSRGEN__GENERATE_READ_ASSIGN)
    `CSRGEN__FOREACH_MHPMCOUNTER(CSRGEN__GENERATE_ARRAY_READ_ASSIGN_MRO)
    `CSRGEN__FOREACH_MRO(CSRGEN__GENERATE_READ_ASSIGN_MRO)
    `CSRGEN__FOREACH_MRW(CSRGEN__GENERATE_READ_ASSIGN)

    `CSRGEN__GENERATE_CONFLICT(MSTATUS)
    `CSRGEN__GENERATE_CONFLICT(MCAUSE)
    `CSRGEN__GENERATE_CONFLICT(MTVAL)
    `CSRGEN__GENERATE_CONFLICT(MEPC)

    always @(posedge clk) begin
        if (!rst_n) begin
            `CSRGEN__FOREACH_MCOUNTER(CSRGEN__GENERATE_INITIAL_VALUE)
            `CSRGEN__FOREACH_MRW(CSRGEN__GENERATE_INITIAL_VALUE)
        end else begin
            `CSRGEN__FOREACH_MCOUNTER(CSRGEN__GENERATE_WRITE)
            `CSRGEN__FOREACH_MRW(CSRGEN__GENERATE_WRITE)
        end
    end

    wire [(2*`ISA__XLEN)-1:0] mcycle      = {csr_interface.MCYCLEH_reg,csr_interface.MCYCLE_reg};
    wire [(2*`ISA__XLEN)-1:0] mcycle_next = mcycle + 1'b1;

    assign csr_interface.MCYCLEH_in  = mcycle_next[(2*`ISA__XLEN)-1:`ISA__XLEN];
    assign csr_interface.MCYCLE_in = mcycle_next[`ISA__XLEN-1:0];
    assign csr_interface.MCYCLE_write  = !`CSR__MCOUNTINHIBIT_CY(csr_interface.MCOUNTINHIBIT_reg);
    assign csr_interface.MCYCLEH_write = !`CSR__MCOUNTINHIBIT_CY(csr_interface.MCOUNTINHIBIT_reg);

    wire [(2*`ISA__XLEN)-1:0] minstret      = {csr_interface.MINSTRETH_reg,csr_interface.MINSTRET_reg};
    wire [(2*`ISA__XLEN)-1:0] minstret_next = minstret + 1'b1;

    assign csr_interface.MINSTRETH_in  = minstret_next[(2*`ISA__XLEN)-1:`ISA__XLEN];
    assign csr_interface.MINSTRET_in = minstret_next[`ISA__XLEN-1:0];
    assign csr_interface.MINSTRET_write  = retire && !`CSR__MCOUNTINHIBIT_IR(csr_interface.MCOUNTINHIBIT_reg);
    assign csr_interface.MINSTRETH_write = retire && !`CSR__MCOUNTINHIBIT_IR(csr_interface.MCOUNTINHIBIT_reg);

    reg [(2*`ISA__XLEN)-1:0] mtime;
    reg [(2*`ISA__XLEN)-1:0] mtimecmp;
    reg [    `ISA__XLEN-1:0] tmp;

    localparam int DataWidth             = $bits(bus_interface.data_ctp);
    localparam int AddressWidth          = $bits(bus_interface.address);
    localparam int BytesPerWord          = $bits(bus_interface.byte_enable);
    localparam int ByteSize              = DataWidth / BytesPerWord;
    localparam int SizeWords             = 4;
    localparam int ByteAddressWidth      = AddressWidth + $clog2(BytesPerWord);
    localparam int LocalAddressWidth     = $clog2(SizeWords);
    localparam int LocalByteAddressWidth = LocalAddressWidth + $clog2(BytesPerWord);
    localparam int DeviceAddressWidth    = AddressWidth - LocalAddressWidth;
    localparam int DeviceAddress         = BaseAddress[ByteAddressWidth-1:LocalByteAddressWidth];

    wire [DeviceAddressWidth-1:0] device_address = bus_interface.address[AddressWidth-1:LocalAddressWidth];
    reg  [ LocalAddressWidth-1:0] local_address;
    wire [      BytesPerWord-1:0] byte_enable    = bus_interface.byte_enable;
    wire [         DataWidth-1:0] data_in        = bus_interface.data_ctp;
    wire [         DataWidth-1:0] data_mask;
    reg  [         DataWidth-1:0] data_out;

    genvar i;
    generate
        for(i = 0; i < BytesPerWord; i++) begin : g_mask
            assign data_mask[ByteSize*i+:ByteSize] = {ByteSize{byte_enable[i]}};
        end
    endgenerate

    reg  read_hit;
    wire mem_hit     = device_address == DeviceAddress;
    wire write_hit   = mem_hit && bus_interface.write;
    wire data_enable = read_hit && !bus_interface.intercept;

    assign bus_interface.hit      = mem_hit     ? 1'b1     : 1'bz;
    assign bus_interface.data_ptc = data_enable ? data_out : {DataWidth{1'bz}};

    always @(posedge clk) begin
        if (!rst_n) begin
            read_hit <= 1'b0;
        end else begin
            read_hit <= mem_hit && bus_interface.read;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            mtime         <= {2*`ISA__XLEN{1'b0}};
            mtimecmp      <= {2*`ISA__XLEN{1'b1}};
            local_address <= {LocalAddressWidth{1'b0}};
        end else begin
            local_address <= bus_interface.address[LocalAddressWidth-1:0];
            mtime         <= mtime + 1'd1;
            if (write_hit) begin
                case (local_address)
                    `CSR__MTIME_OFFSET:     tmp = mtime[`ISA__XLEN-1:0];
                    `CSR__MTIMEH_OFFSET:    tmp = mtime[(2*`ISA__XLEN)-1:`ISA__XLEN];
                    `CSR__MTIMECMP_OFFSET:  tmp = mtimecmp[`ISA__XLEN-1:0];
                    `CSR__MTIMECMPH_OFFSET: tmp = mtimecmp[(2*`ISA__XLEN)-1:`ISA__XLEN];
                    default:                tmp = `ISA__ZERO;
                endcase
                tmp = (data_in & data_mask) | (tmp & ~data_mask);
                case (local_address)
                    `CSR__MTIME_OFFSET:     mtime[`ISA__XLEN-1:0]                 <= tmp;
                    `CSR__MTIMEH_OFFSET:    mtime[(2*`ISA__XLEN)-1:`ISA__XLEN]    <= tmp;
                    `CSR__MTIMECMP_OFFSET:  mtimecmp[`ISA__XLEN-1:0]              <= tmp;
                    `CSR__MTIMECMPH_OFFSET: mtimecmp[(2*`ISA__XLEN)-1:`ISA__XLEN] <= tmp;
                    default:                                                            ;
                endcase
            end
        end
    end

    always_comb begin
        case (local_address)
            `CSR__MTIME_OFFSET:     data_out = mtime[`ISA__XLEN-1:0];
            `CSR__MTIMEH_OFFSET:    data_out = mtime[(2*`ISA__XLEN)-1:`ISA__XLEN];
            `CSR__MTIMECMP_OFFSET:  data_out = mtimecmp[`ISA__XLEN-1:0];
            `CSR__MTIMECMPH_OFFSET: data_out = mtimecmp[(2*`ISA__XLEN)-1:`ISA__XLEN];
            default:                data_out = `ISA__ZERO;
        endcase
    end

    assign timeint = mtime >= mtimecmp;

endmodule
