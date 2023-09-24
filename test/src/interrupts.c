#include "util.h"
#include "csr.h"
#include "tim.h"
#include "gpio.h"
#include "hex.h"
#include "exti.h"

void nmi_handler(void) __attribute__ ((interrupt ("machine")) );
void exception_handler(void) __attribute__ ((interrupt ("machine")) );
void timer_handler(void) __attribute__ ((interrupt ("machine")) );
void exti_handler(void) __attribute__ ((interrupt ("machine")) );

unsigned volatile int nmi_flag = 0;
unsigned volatile int tim_flag = 0;
unsigned volatile int exti_flag = 0;

void nmi_handler(void)
{
    nmi_flag = 1;
}

void exception_handler(void)
{
	GPIO->DOR = 1023 << 12;
}

void timer_handler(void)
{
	uint32_t old = TIM->TIMCMP;
	uint32_t new = old + TIM_TICK_PER_MS * 1000;
	if(new < old)
	{
		TIM->TIMCMPh++;
	}
	TIM->TIMCMP = new;
    tim_flag = 1;
}

void exti_handler(void)
{
    exti_flag = EXTI->IPR;
    EXTI->IPR = exti_flag;
}
