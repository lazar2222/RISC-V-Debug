.extern __global_pointer$
.extern __stack_pointer
.extern main
.global _start

.weak nmi_handler
.set nmi_handler, default_handler
.weak exception_handler
.set exception_handler, default_handler
.weak timer_handler
.set timer_handler, default_handler
.weak exti_handler
.set exti_handler, default_handler

.section .ivt, "a"

j _start
j nmi_handler
j exception_handler
.rept 6
	j default_handler
.endr
j timer_handler
.rept 3
	j default_handler
.endr
j exti_handler

.section .startup

.type _start, %function
_start:
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    li x2, 0
    la x2, __stack_pointer
    call main
    j .

.type default_handler, %function
default_handler:
    j .

.end
