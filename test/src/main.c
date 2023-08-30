#include "util.h"
#include "csr.h"
#include "tim.h"
#include "gpio.h"
#include "hex.h"
#include "interrupts.h"

unsigned int time;

void main()
{

    GPIO->DDR = SET_BITS(GPIO->DDR, GPIO_LED_MASK(1));

    TIM->TIMCMP = 100;
    TIM->TIMCMPh = 0;

    uint32_t mie = CSR_MIE_MTIE;
    WRITE_CSR(mie, CSR_MIE);

    SET_CSR(CSR_MSTATUS_MIE, CSR_MSTATUS);

    while(1)
    {
        if(nmi_flag)
        {
            GPIO->DOR = TOGGLE_BITS(GPIO->DOR, GPIO_LED_MASK(1));
            nmi_flag = 0;
        }
        if(tim_flag)
        {
            time++;
            HEX->DATA = time;
            tim_flag = 0;
        }
    }
}
