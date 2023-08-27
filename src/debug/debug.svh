`ifndef DEBUG__SVH
`define DEBUG__SVH

`define DEBUG__DMCONTROL    7'h10
`define DEBUG__DMSTATUS     7'h11

`define DEBUG__DMCONTROL_HALTREQ(r)         r[31]
`define DEBUG__DMCONTROL_RESUMEREQ(r)       r[30]
`define DEBUG__DMCONTROL_HARTRESET(r)       r[29]
`define DEBUG__DMCONTROL_ACKHAVERESET(r)    r[28]
`define DEBUG__DMCONTROL_SETRESETHALTREQ(r) r[3]
`define DEBUG__DMCONTROL_CLRRESETHALTREQ(r) r[2]
`define DEBUG__DMCONTROL_NDMRESET(r)        r[1]
`define DEBUG__DMCONTROL_DMACTIVE(r)        r[0]

`endif  //DEBUG__SVH
