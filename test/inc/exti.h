#ifndef _EXTI_H_
#define _EXTI_H_

#include <stdint.h>

typedef struct
{
	uint32_t volatile IMR;
	uint32_t volatile IPR;
	uint32_t volatile ISR;
	uint32_t volatile RER;
	uint32_t volatile FER;
} EXTI_RegisterMapType;

#define EXTI ((EXTI_RegisterMapType *) 0x30000000)

#define EXTI_LINE(NUM) (1 << NUM)

#endif
