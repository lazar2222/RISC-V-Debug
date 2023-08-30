#ifndef _GPIO_H_
#define _GPIO_H_

#include <stdint.h>

typedef struct
{
	uint32_t volatile DDR;
	uint32_t volatile DOR;
	uint32_t volatile DIR;
} GPIO_RegisterMapType;

#define GPIO ((GPIO_RegisterMapType *) 0x10000000)

#define GPIO_BTN_MASK(BTN) (1 << (BTN - 2))
#define GPIO_SW_MASK(SW) (1 << (SW + 2))
#define GPIO_LED_MASK(LED) (1 << (LED + 12))

#endif
