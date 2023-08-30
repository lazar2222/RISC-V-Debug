#ifndef _TIM_H_
#define _TIM_H_

#include <stdint.h>

typedef struct
{
	uint32_t volatile TIM;
	uint32_t volatile TIMh;
	uint32_t volatile TIMCMP;
    uint32_t volatile TIMCMPh;
} TIM_RegisterMapType;

#define TIM ((TIM_RegisterMapType *) 0xF0000000)

#define TIM_TICK_PER_MS 40000

#endif
