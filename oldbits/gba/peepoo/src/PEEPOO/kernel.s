.CODE 32
.ALIGN
.GLOBL kernel_functions

	
.INCLUDE "gba.i"
.INCLUDE "system.i"

.INCLUDE "macros.m"

	b	kernel
	
.ORG	0xc0

kernel:

	@ Initialize kernel data area
	CPU_COPY_32 data_area, data_area_end, DATA_AREA
	
	@ Install sound system
	CPU_COPY_32 sound_system, sound_system_end, 0x02000000

	bl	interrupt_init
	
	ldr	r0,=0x02000000
	mov	lr,pc
	bx	r0
	ldr	r0,[r0]		@ sound_init
	mov	lr,pc
 	bx	r0
	
forever:

	@ Handle "slow" code which takes more than one frame to complete
	ldr	r1,=DATA_AREA+SLOW_CODE
	ldr	r0,[r1]
	cmp	r0,#0
	bne	slow

	swi	0x20000		@ Halt CPU (to save power) until an interrupt occurs

	b	forever
slow:
	mov	lr,pc
	bx	r0

	b 	forever


get_resource_address:

	mov	r0,r0,asl #3
	ldr	r1,=resource_address_list
	mov	r2,r0
	ldr	r0,[r1,r0]
	add	r2,r2,#4
	ldr	r1,[r1,r2]

	bx	lr

interrupt_init:

	@ "Install" interrupt handler
	CPU_COPY_32 irq_handler, irq_handler_end, IRQ_HANDLER

	@ Interrupt handler setup
 	ldr	r0,=IRQ_HANDLER
	ldr	r1,=SYS_IRQ_VECTOR
 	str	r0,[r1]
 	
 	ldr	r0,=0b0000000000001000	@ V-Blank Interrupt Request Enable Flag
 	ldr	r1,=REG_DISPSTAT
 	strh	r0,[r1]
 	
 	ldr	r0,=0b0000000000000001	@ Enable "Rendering blank" interrupt
 	ldr	r1,=REG_IE
 	strh	r0,[r1]

 	ldr	r0,=0b0000000000000001	@ Enable interrupts defined in REG_IE
 	ldr	r1,=REG_IME
 	strh	r0,[r1]

	bx	lr

kernel_functions:

	.long	get_resource_address, fdiv
	
resource_address_list:

	.long	title_graphics, title_graphics_end
	.long	title_obj_palette, title_obj_palette_end
	.long	title_obj_data, title_obj_data_end
	.long	memory_game_graphics, memory_game_graphics_end
	.long	memory_game_obj_palette, memory_game_obj_palette_end
	.long	memory_game_obj_data, memory_game_obj_data_end

