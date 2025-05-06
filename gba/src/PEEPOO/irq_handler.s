.CODE 32
.ALIGN
	
.INCLUDE "gba.i"
.INCLUDE "system.i"

.INCLUDE "macros.m"


irq_handler:
	
	FUNCTION_ENTRY
	
        ldr     r0,=REG_IF	@ Read Interrupt Request Register
        ldrh	r1,[r0]

	ldr	r3,=0x3fffff8
 	ldrh    r2,[r3]		@ mix up with BIOS irq flags at 3007FF8h,
 	orr	r2,r2,r1        @ aka mirrored at 3FFFFF8h, this is required
 	strh    r2,[r3]		@ when using the (VBlank-)IntrWait functions

	strh	r1,[r0]
	
	ands	r2,r1,#1
	beq	irq_handler_exit

vblank:

	@ Sound
	ldr	r0,=0x02000000
	mov	lr,pc
	bx	r0
	ldr	r0,[r0,#4]	@ sound_player
	mov	lr,pc
 	bx	r0

   	@ Kernel data area maintenance
   	mov	r0,#1
	RANDOM_SEED_INCREASE

	FRAME_COUNTER_INCREASE
     	
	@ Input handler
	ldr	r0,=DATA_AREA+INPUT_HANDLER
	ldr	r0,[r0]
	cmp	r0,#0
	beq	1f
	mov	lr,pc
     	bx	r0

1:     	
	@ Single task switching
	ldr	r0,=DATA_AREA+TASK_LIST
	ldr	r1,[r0],#4
	ldr	r0,[r0,r1]
	mov	lr,pc	
     	bx	r0

irq_handler_exit:

 	FUNCTION_EXIT


.align

.pool

