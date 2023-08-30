#ifndef _HEX_H_
#define _HEX_H_

#include <stdint.h>

typedef struct
{
	uint32_t volatile MODE;
	uint32_t volatile DATA;
	uint32_t volatile DATA1;
} HEX_RegisterMapType;

#define HEX ((HEX_RegisterMapType *) 0x20000000)

#define HEX_MODE_DEC 0
#define HEX_MODE_HEX 1
#define HEX_MODE_MAN 2

#endif
