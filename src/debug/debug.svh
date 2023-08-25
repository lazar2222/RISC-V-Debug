`ifndef DEBUG__SVH
`define DEBUG__SVH

`define DEBUG__OPCODE_ACCESS_REG 5'b10_010
`define DEBUG__OPCODE_EXEC       5'b10_011
`define DEBUG__OPCODE_READ_MEM   5'b10_100
`define DEBUG__OPCODE_WRITE_MEM  5'b10_110

`define DEBUG__AC_COMMAND(cmd)    cmd[31:24]
`define DEBUG__AC_AARSIZE(cmd)    cmd[22:20]
`define DEBUG__AC_AARPOSTINC(cmd) cmd[19]
`define DEBUG__AC_POSTEXEC(cmd)   cmd[18]
`define DEBUG__AC_TRANSFER(cmd)   cmd[17]
`define DEBUG__AC_WRITE(cmd)      cmd[16]
`define DEBUG__AC_REG(cmd)        cmd[15:0]
`define DEBUG__AC_REG_CSR(cmd)    cmd[15:12] == 4'd0
`define DEBUG__AC_REG_GPR(cmd)    cmd[15:5] == 11'h080

`define DEBUG__AC_COMMAND_ACCESS_REGISTER 8'd0
`define DEBUG__AC_COMMAND_QUICK_ACCESS    8'd1
`define DEBUG__AC_COMMAND_ACCESS_MEMORY   8'd2

`endif  //DEBUG__SVH
