`define CONTROL_SIGNALS__HALTED     5'b01_110
`define CONTROL_SIGNALS__RESUMING   5'b01_111
`define CONTROL_SIGNALS__ABS_REG    `DEBUG__OPCODE_ACCESS_REG
`define CONTROL_SIGNALS__ABS_NA     `DEBUG__OPCODE_ACCESS_NA
`define CONTROL_SIGNALS__ABS_EXEC   `DEBUG__OPCODE_EXEC
`define CONTROL_SIGNALS__ABS_RMEM   `DEBUG__OPCODE_READ_MEM
`define CONTROL_SIGNALS__ABS_RMEM_1 (`DEBUG__OPCODE_READ_MEM + 5'd1)
`define CONTROL_SIGNALS__ABS_WMEM   `DEBUG__OPCODE_WRITE_MEM
`define CONTROL_SIGNALS__ABS_WMEM_1 (`DEBUG__OPCODE_WRITE_MEM + 5'd1)

interface control_signals_if;
    wire [`ISA__FUNCT3_WIDTH-1:0] f3;
    reg  [`ISA__OPCODE_WIDTH-1:0] mcp_addr;
    reg                           write_pc_ne, write_pc_ex; // Ticu se implementacionih detalja podrske za prekide, nece biti diskutovane
    reg                           write_csr; // Tice se implementacionih detalja Zicsr ekstenzije, nece biti diskutovan
    reg                           abstract_write, abstract_done, progbuf;
endinterface