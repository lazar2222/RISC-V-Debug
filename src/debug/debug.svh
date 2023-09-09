`ifndef DEBUG__SVH
`define DEBUG__SVH

`define DEBUG__AC_COMMAND_ACCESS_REGISTER 8'd0
`define DEBUG__AC_COMMAND_QUICK_ACCESS    8'd1
`define DEBUG__AC_COMMAND_ACCESS_MEMORY   8'd2

`define DEBUG__OPCODE_ACCESS_NA  5'b11_111
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
`define DEBUG__AC_AAMVIRTUAL(cmd) cmd[23]

`define DEBUG__AC_ERR_NO_ERR        3'd0
`define DEBUG__AC_ERR_BUSY          3'd1
`define DEBUG__AC_ERR_NOT_SUPPORTED 3'd2
`define DEBUG__AC_ERR_EXCEPTION     3'd3
`define DEBUG__AC_ERR_HALT_RESUME   3'd4
`define DEBUG__AC_ERR_BUS           3'd5
`define DEBUG__AC_ERR_OTHER         3'd7

`define DEBUG__DATA0        7'h04
`define DEBUG__DATA1        7'h05
`define DEBUG__DATA2        7'h06
`define DEBUG__DATA3        7'h07
`define DEBUG__DATA4        7'h08
`define DEBUG__DATA5        7'h09
`define DEBUG__DATA6        7'h0A
`define DEBUG__DATA7        7'h0B
`define DEBUG__DATA8        7'h0C
`define DEBUG__DATA9        7'h0D
`define DEBUG__DATA10       7'h0E
`define DEBUG__DATA11       7'h0F
`define DEBUG__DMCONTROL    7'h10
`define DEBUG__DMSTATUS     7'h11
`define DEBUG__HARTINFO     7'h12
`define DEBUG__ABSTRACTCS   7'h16
`define DEBUG__COMMAND      7'h17
`define DEBUG__ABSTRACTAUTO 7'h18
`define DEBUG__PROGBUF0     7'h20
`define DEBUG__PROGBUF1     7'h21
`define DEBUG__PROGBUF2     7'h22
`define DEBUG__PROGBUF3     7'h23
`define DEBUG__PROGBUF4     7'h24
`define DEBUG__PROGBUF5     7'h25
`define DEBUG__PROGBUF6     7'h26
`define DEBUG__PROGBUF7     7'h27
`define DEBUG__PROGBUF8     7'h28
`define DEBUG__PROGBUF9     7'h29
`define DEBUG__PROGBUF10    7'h2A
`define DEBUG__PROGBUF11    7'h2B
`define DEBUG__PROGBUF12    7'h2C
`define DEBUG__PROGBUF13    7'h2D
`define DEBUG__PROGBUF14    7'h2E
`define DEBUG__PROGBUF15    7'h2F
`define DEBUG__SBCS         7'h38
`define DEBUG__SBADDRESS0   7'h39
`define DEBUG__SBDATA0      7'h3c
`define DEBUG__HALTSUM0     7'h40

`define DEBUG__HARTINFO_VALUE     20'h0021C

`define DEBUG__DATA0_AUTOEXEC     0
`define DEBUG__DATA1_AUTOEXEC     1
`define DEBUG__DATA2_AUTOEXEC     2
`define DEBUG__DATA3_AUTOEXEC     3
`define DEBUG__DATA4_AUTOEXEC     4
`define DEBUG__DATA5_AUTOEXEC     5
`define DEBUG__DATA6_AUTOEXEC     6
`define DEBUG__DATA7_AUTOEXEC     7
`define DEBUG__DATA8_AUTOEXEC     8
`define DEBUG__DATA9_AUTOEXEC     9
`define DEBUG__DATA10_AUTOEXEC    10
`define DEBUG__DATA11_AUTOEXEC    11
`define DEBUG__PROGBUF0_AUTOEXEC  16
`define DEBUG__PROGBUF1_AUTOEXEC  17
`define DEBUG__PROGBUF2_AUTOEXEC  18
`define DEBUG__PROGBUF3_AUTOEXEC  19
`define DEBUG__PROGBUF4_AUTOEXEC  20
`define DEBUG__PROGBUF5_AUTOEXEC  21
`define DEBUG__PROGBUF6_AUTOEXEC  22
`define DEBUG__PROGBUF7_AUTOEXEC  23
`define DEBUG__PROGBUF8_AUTOEXEC  24
`define DEBUG__PROGBUF9_AUTOEXEC  25
`define DEBUG__PROGBUF10_AUTOEXEC 26
`define DEBUG__PROGBUF11_AUTOEXEC 27
`define DEBUG__PROGBUF12_AUTOEXEC 28
`define DEBUG__PROGBUF13_AUTOEXEC 29
`define DEBUG__PROGBUF14_AUTOEXEC 30
`define DEBUG__PROGBUF15_AUTOEXEC 31

`define DEBUG__PROGBUF0_OFFSET  12'd0
`define DEBUG__PROGBUF1_OFFSET  12'd1
`define DEBUG__PROGBUF2_OFFSET  12'd2
`define DEBUG__PROGBUF3_OFFSET  12'd3
`define DEBUG__PROGBUF4_OFFSET  12'd4
`define DEBUG__PROGBUF5_OFFSET  12'd5
`define DEBUG__PROGBUF6_OFFSET  12'd6
`define DEBUG__PROGBUF7_OFFSET  12'd7
`define DEBUG__PROGBUF8_OFFSET  12'd8
`define DEBUG__PROGBUF9_OFFSET  12'd9
`define DEBUG__PROGBUF10_OFFSET 12'd10
`define DEBUG__PROGBUF11_OFFSET 12'd11
`define DEBUG__PROGBUF12_OFFSET 12'd12
`define DEBUG__PROGBUF13_OFFSET 12'd13
`define DEBUG__PROGBUF14_OFFSET 12'd14
`define DEBUG__PROGBUF15_OFFSET 12'd15
`define DEBUG__DATA0_OFFSET     12'd20
`define DEBUG__DATA1_OFFSET     12'd21
`define DEBUG__DATA2_OFFSET     12'd22
`define DEBUG__DATA3_OFFSET     12'd23
`define DEBUG__DATA4_OFFSET     12'd24
`define DEBUG__DATA5_OFFSET     12'd25
`define DEBUG__DATA6_OFFSET     12'd26
`define DEBUG__DATA7_OFFSET     12'd27
`define DEBUG__DATA8_OFFSET     12'd28
`define DEBUG__DATA9_OFFSET     12'd29
`define DEBUG__DATA10_OFFSET    12'd30
`define DEBUG__DATA11_OFFSET    12'd31

`define DEBUG__DMCONTROL_HALTREQ(r)         r[31]
`define DEBUG__DMCONTROL_RESUMEREQ(r)       r[30]
`define DEBUG__DMCONTROL_HARTRESET(r)       r[29]
`define DEBUG__DMCONTROL_ACKHAVERESET(r)    r[28]
`define DEBUG__DMCONTROL_SETRESETHALTREQ(r) r[3]
`define DEBUG__DMCONTROL_CLRRESETHALTREQ(r) r[2]
`define DEBUG__DMCONTROL_NDMRESET(r)        r[1]
`define DEBUG__DMCONTROL_DMACTIVE(r)        r[0]

`define DEBUG__CAUSE_TRIGGER 3'd2
`define DEBUG__CAUSE_EBREAK  3'd1
`define DEBUG__CAUSE_HALTREQ 3'd3
`define DEBUG__CAUSE_STEP    3'd4

`define DEBUG__EBREAK 32'h00100073

`define DEBUG__SBCS_SBBUSYERROR(r)     r[22]
`define DEBUG__SBCS_SBREADONADDR(r)    r[20]
`define DEBUG__SBCS_SBACCESS(r)        r[19:17]
`define DEBUG__SBCS_SBAUTOINCREMENT(r) r[16]
`define DEBUG__SBCS_SBREADONDATA(r)    r[15]
`define DEBUG__SBCS_SBERROR(r)         r[14:12]

`define DEBUG__SB_ERR_NO_ERR  3'd0
`define DEBUG__SB_ERR_TIMEOUT 3'd1
`define DEBUG__SB_ERR_FAULT   3'd2
`define DEBUG__SB_ERR_MALIGN  3'd3
`define DEBUG__SB_ERR_SIZE    3'd4
`define DEBUG__SB_ERR_OTHER   3'd7

`define DEBUGGEN__FOREACH_SIMPLE(TARGET) \
`TARGET(DATA0)        \
`TARGET(DATA1)        \
`TARGET(DATA2)        \
`TARGET(DATA3)        \
`TARGET(DATA4)        \
`TARGET(DATA5)        \
`TARGET(DATA6)        \
`TARGET(DATA7)        \
`TARGET(DATA8)        \
`TARGET(DATA9)        \
`TARGET(DATA10)       \
`TARGET(DATA11)       \
`TARGET(PROGBUF0)     \
`TARGET(PROGBUF1)     \
`TARGET(PROGBUF2)     \
`TARGET(PROGBUF3)     \
`TARGET(PROGBUF4)     \
`TARGET(PROGBUF5)     \
`TARGET(PROGBUF6)     \
`TARGET(PROGBUF7)     \
`TARGET(PROGBUF8)     \
`TARGET(PROGBUF9)     \
`TARGET(PROGBUF10)    \
`TARGET(PROGBUF11)    \
`TARGET(PROGBUF12)    \
`TARGET(PROGBUF13)    \
`TARGET(PROGBUF14)    \
`TARGET(PROGBUF15)    \

`define DEBUGGEN__GENERATE_INTERFACE(register) \
reg  [31:0] ``register``_reg;   \
wire [31:0] ``register``_in;    \
wire        ``register``_write; \

`define DEBUGGEN__GENERATE_READ_ASSIGN(register) \
assign data = dmi.address == `DEBUG__``register`` ? ``register``_reg : {32{1'b0}}; \

`define DEBUGGEN__GENERATE_MEMORY_ASSIGN(register) \
assign memory[(32*`DEBUG__``register``_OFFSET)+:32] = ``register``_reg; \

`define DEBUGGEN__GENERATE_MEMORY_GUARD_ASSIGN(register) \
assign memory[(32*16)+:32] = `DEBUG__EBREAK; \
assign memory[(32*17)+:32] = `DEBUG__EBREAK; \
assign memory[(32*18)+:32] = `DEBUG__EBREAK; \
assign memory[(32*19)+:32] = `DEBUG__EBREAK; \

`define DEBUGGEN__GENERATE_INITIAL_VALUE_SIMPLE(register) \
``register``_reg <= `DEBUG__EBREAK; \

`define DEBUGGEN__GENERATE_WRITE_SIMPLE(register) \
if (dmi.address == `DEBUG__``register`` && dmi.write && busy == 1'b0) begin \
    ``register``_reg <= dmi.data;                                           \
end else if (mem_write[`DEBUG__``register``_OFFSET]) begin                  \
    ``register``_reg <= mem_out;                                            \
end else if (``register``_write) begin                                      \
    ``register``_reg <= ``register``_in;                                    \
end                                                                         \

`define DEBUGGEN__GENERATE_AUTOEXEC(register) \
if (dmi.address == `DEBUG__``register`` && (dmi.write || dmi.read) && busy == 1'b0 && cmderr == `DEBUG__AC_ERR_NO_ERR && abstractauto[`DEBUG__``register``_AUTOEXEC]) begin \
    busy <= 1'b1;                                                                                                                                           \
end                                                                                                                                                         \

`define DEBUGGEN__GENERATE_BUSY_ERROR(register) \
|| dmi.address == `DEBUG__``register`` && (dmi.write || dmi.read) \

`endif  //DEBUG__SVH
