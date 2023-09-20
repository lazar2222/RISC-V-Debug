// Primer makroa koji definise DM registar
`define DEBUG__DATA0 7'h04 // Adresa
`define DEBUG__DATA0_AUTOEXEC 0 // Indeks bita u registru ABSTRACTAUTO
`define DEBUG__DATA0_OFFSET 12'd20 // Pomeraj od bazne adrese u memorijskoj mapi

`define DEBUGGEN__FOREACH_SIMPLE(TARGET) \
`TARGET(DATA0)\
`...
`TARGET(DATA11)\
`TARGET(PROGBUF0)\
...
`TARGET(PROGBUF15)\

`define DEBUGGEN__GENERATE_INTERFACE(register) \
reg  [31:0] ``register``_reg;\
wire [31:0] ``register``_in;\
wire        ``register``_write;\

`define DEBUGGEN__GENERATE_READ_ASSIGN(register) \
assign data = dmi.address == `DEBUG__``register`` ? ``register``_reg : {32{1'b0}};\

`define DEBUGGEN__GENERATE_MEMORY_ASSIGN(register) \
assign memory[(32*`DEBUG__``register``_OFFSET)+:32] = ``register``_reg;\

`define DEBUGGEN__GENERATE_MEMORY_GUARD_ASSIGN\
assign memory[(32*16)+:32] = `DEBUG__EBREAK;\
assign memory[(32*17)+:32] = `DEBUG__EBREAK;\
assign memory[(32*18)+:32] = `DEBUG__EBREAK;\
assign memory[(32*19)+:32] = `DEBUG__EBREAK;\

`define DEBUGGEN__GENERATE_INITIAL_VALUE_SIMPLE(register) \
``register``_reg <= `DEBUG__EBREAK;\

`define DEBUGGEN__GENERATE_WRITE_SIMPLE(register) \
if (dmi.address == `DEBUG__``register`` && dmi.write && busy == 1'b0) begin\
    ``register``_reg <= dmi.data;\
end else if (mem_write[`DEBUG__``register``_OFFSET]) begin\
    ``register``_reg <= mem_out;\
end else if (``register``_write) begin\
    ``register``_reg <= ``register``_in;\
end\

`define DEBUGGEN__GENERATE_AUTOEXEC(register) \
if (dmi.address == `DEBUG__``register`` && (dmi.write || dmi.read) && busy == 1'b0 && cmderr == `DEBUG__AC_ERR_NO_ERR && abstractauto[`DEBUG__``register``_AUTOEXEC]) begin\
    busy <= 1'b1;\
end\

`define DEBUGGEN__GENERATE_BUSY_ERROR(register) \
|| dmi.address == `DEBUG__``register`` && (dmi.write || dmi.read)\