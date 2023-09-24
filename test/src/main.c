#include "util.h"
#include "csr.h"
#include "tim.h"
#include "gpio.h"
#include "hex.h"
#include "exti.h"
#include "interrupts.h"

unsigned int time = 0;
int8_t count = 1;

void main()
{
	time = 0;
	count = 1;

    GPIO->DDR = SET_BITS(GPIO->DDR, 1023 << 12);

    TIM->TIMCMP = 100;
    TIM->TIMCMPh = 0;

    EXTI->FER = 0x003;

    EXTI->IMR = 0x003;

    uint32_t mie = CSR_MIE_MTIE | CSR_MIE_MEIE;
    WRITE_CSR(mie, CSR_MIE);

    SET_CSR(CSR_MSTATUS_MIE, CSR_MSTATUS);

    while(1)
    {
        if(nmi_flag)
        {
            nmi_flag = 0;
        }
        if(tim_flag)
        {
            time += count;
            HEX->DATA = time;
            tim_flag = 0;
        }
        if(exti_flag != 0)
        {
        	if(exti_flag & 0x1)
        	{
        		count = count + ((GPIO->DIR & GPIO_SW_MASK(0)) ? 1 : -1);
        	}
        	if(exti_flag & 0x2)
			{
        		time = (GPIO->DIR >> 2) & 0x3FF;
        		HEX->DATA = time;
			}
        	exti_flag = 0;
        }
    }
}
