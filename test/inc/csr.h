#ifndef _CSR_H_
#define _CSR_H_

#define STRINGIFY2(X) #X
#define STRINGIFY(X) STRINGIFY2(X)

#define CSR_MIE 0x304

#define CSR_MIE_MTIE 0x80
#define CSR_MIE_MEIE 0x800

#define CSR_MSTATUS 0x300

#define CSR_MSTATUS_MIE 0x8

#define READ_CSR(var, csr) \
    __asm__ volatile ("csrr %0, "STRINGIFY(csr) \
    : "=r" (var)                                \
    :                                           \
    : )                                         \

#define WRITE_CSR(val, csr) \
    __asm__ volatile ("csrw "STRINGIFY(csr)", %0" \
    :                                                \
    : "r" (val)                                      \
    :)                                               \

#define SET_CSR(val, csr) \
    __asm__ volatile ("csrsi "STRINGIFY(csr)", %0" \
    :                                              \
    : "i" (val)                                    \
    :)                                             \

#define CLEAR_CSR(val, csr) \
    __asm__ volatile ("csrci "STRINGIFY(csr)", %0" \
    :                                              \
    : "i" (val)                                    \
    :)                                             \

#endif
