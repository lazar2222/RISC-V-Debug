#include "util.h"
#include "csr.h"
#include "tim.h"
#include "gpio.h"
#include "hex.h"
#include "exti.h"
#include "interrupts.h"

unsigned int time = 0;
uint8_t count = 1;

void main()
{
    GPIO->DDR = SET_BITS(GPIO->DDR, 1023 << 12);

    TIM->TIMCMP = 100;
    TIM->TIMCMPh = 0;

    EXTI->FER = 0x003;
    EXTI->RER = 0xFFC;

    EXTI->IMR = 0xFFF;

    uint32_t mie = CSR_MIE_MTIE | CSR_MIE_MEIE;
    WRITE_CSR(mie, CSR_MIE);

    SET_CSR(CSR_MSTATUS_MIE, CSR_MSTATUS);

    while(1)
    {
        if(nmi_flag)
        {
        	count = !count;
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
        	GPIO->DOR = TOGGLE_BITS(GPIO->DOR,exti_flag << 10);
        	exti_flag = 0;
        }
    }
}
