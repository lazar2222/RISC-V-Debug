`ifndef ISA__SVH
`define ISA__SVH

`define ISA__XLEN 32
`define ISA__RNUM 32
`define ISA__RVEC 32'd0
`define ISA__RFLEN 5
`define ISA__INST_SIZE 2'b10

`define ISA__OPCODE_PFX(_ir)    _ir[1:0]
`define ISA__OPCODE(_ir)        _ir[6:2]
`define ISA__RD(_ir)            _ir[11:7]
`define ISA__RS1(_ir)           _ir[19:15]
`define ISA__RS2(_ir)           _ir[24:20]
`define ISA__FUNCT3(_ir)        _ir[14:12]
`define ISA__FUNCT7(_ir)        _ir[31:25]

`define ISA__I_IMMEDIATE(_ir)   {{21{_ir[31]}},_ir[30:25],_ir[24:21],_ir[20]}
`define ISA__S_IMMEDIATE(_ir)   {{21{_ir[31]}},_ir[30:25],_ir[11:8],_ir[7]}
`define ISA__B_IMMEDIATE(_ir)   {{20{_ir[31]}},_ir[7],_ir[30:25],_ir[11:8],1'b0}
`define ISA__U_IMMEDIATE(_ir)   {_ir[31],_ir[30:20],_ir[19:12],12'd0}
`define ISA__J_IMMEDIATE(_ir)   {{12{_ir[31]}},_ir[19:12],_ir[20],_ir[30:25],_ir[24:21],1'b0}

`define ISA__OPCODE_PFX_32BIT   2'b11

`define ISA__OPCODE_LOAD        5'b00_000
`define ISA__OPCODE_MISCMEM     5'b00_011
`define ISA__OPCODE_OPIMM       5'b00_100
`define ISA__OPCODE_AUIPC       5'b00_101
`define ISA__OPCODE_STORE       5'b01_000
`define ISA__OPCODE_OP          5'b01_100
`define ISA__OPCODE_LUI         5'b01_101
`define ISA__OPCODE_BRANCH      5'b11_000
`define ISA__OPCODE_JALR        5'b11_001
`define ISA__OPCODE_JAL         5'b11_011
`define ISA__OPCODE_SYSTEM      5'b11_100

`define ISA__FUNCT3_JALR        3'b000
`define ISA__FUNCT3_BEQ         3'b000
`define ISA__FUNCT3_BNE         3'b001
`define ISA__FUNCT3_BLT         3'b100
`define ISA__FUNCT3_BGE         3'b101
`define ISA__FUNCT3_BLTU        3'b110
`define ISA__FUNCT3_BGEU        3'b111
`define ISA__FUNCT3_LB          3'b000
`define ISA__FUNCT3_LH          3'b001
`define ISA__FUNCT3_LW          3'b010
`define ISA__FUNCT3_LBU         3'b100
`define ISA__FUNCT3_LHU         3'b101
`define ISA__FUNCT3_SB          3'b000
`define ISA__FUNCT3_SH          3'b001
`define ISA__FUNCT3_SW          3'b010
`define ISA__FUNCT3_ADDI        3'b000
`define ISA__FUNCT3_SLTI        3'b010
`define ISA__FUNCT3_SLTIU       3'b011
`define ISA__FUNCT3_XORI        3'b100
`define ISA__FUNCT3_ORI         3'b110
`define ISA__FUNCT3_ANDI        3'b111
`define ISA__FUNCT3_SLLI        3'b001
`define ISA__FUNCT3_SRLI        3'b101
`define ISA__FUNCT3_SRAI        3'b101
`define ISA__FUNCT3_ADD         3'b000
`define ISA__FUNCT3_SUB         3'b000
`define ISA__FUNCT3_SLL         3'b001
`define ISA__FUNCT3_SLT         3'b010
`define ISA__FUNCT3_SLTU        3'b011
`define ISA__FUNCT3_XOR         3'b100
`define ISA__FUNCT3_SRL         3'b101
`define ISA__FUNCT3_SRA         3'b101
`define ISA__FUNCT3_OR          3'b110
`define ISA__FUNCT3_AND         3'b111
`define ISA__FUNCT3_FENCE       3'b000
`define ISA__FUNCT3_ECALL       3'b000
`define ISA__FUNCT3_EBREAK      3'b000
`define ISA__FUNCT3_MUL         3'b000
`define ISA__FUNCT3_MULH        3'b001
`define ISA__FUNCT3_MULHSU      3'b010
`define ISA__FUNCT3_MULHU       3'b011
`define ISA__FUNCT3_DIV         3'b100
`define ISA__FUNCT3_DIVU        3'b101
`define ISA__FUNCT3_REM         3'b110
`define ISA__FUNCT3_REMU        3'b111
`define ISA__FUNCT3_CSRRW       3'b001
`define ISA__FUNCT3_CSRRS       3'b010
`define ISA__FUNCT3_CSRRC       3'b011
`define ISA__FUNCT3_CSRRWI      3'b101
`define ISA__FUNCT3_CSRRSI      3'b110
`define ISA__FUNCT3_CSRRCI      3'b111
`define ISA__FUNCT3_SYSINV      3'b100

`define ISA__FUNCT7_SLLI        7'b0000000
`define ISA__FUNCT7_SRLI        7'b0000000
`define ISA__FUNCT7_SRAI        7'b0100000
`define ISA__FUNCT7_ADD         7'b0000000
`define ISA__FUNCT7_SUB         7'b0100000
`define ISA__FUNCT7_SLL         7'b0000000
`define ISA__FUNCT7_SLT         7'b0000000
`define ISA__FUNCT7_SLTU        7'b0000000
`define ISA__FUNCT7_XOR         7'b0000000
`define ISA__FUNCT7_SRL         7'b0000000
`define ISA__FUNCT7_SRA         7'b0100000
`define ISA__FUNCT7_OR          7'b0000000
`define ISA__FUNCT7_AND         7'b0000000
`define ISA__FUNCT7_MUL         7'b0000001
`define ISA__FUNCT7_MULH        7'b0000001
`define ISA__FUNCT7_MULHSU      7'b0000001
`define ISA__FUNCT7_MULHU       7'b0000001
`define ISA__FUNCT7_DIV         7'b0000001
`define ISA__FUNCT7_DIVU        7'b0000001
`define ISA__FUNCT7_REM         7'b0000001
`define ISA__FUNCT7_REMU        7'b0000001

`define ISA__RD_ECALL           5'b00000
`define ISA__RS1_ECALL          5'b00000
`define ISA__IMM_ECALL          12'b000000000000
`define ISA__IMM_EBREAK         12'b000000000001

`endif
