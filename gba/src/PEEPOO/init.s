.CODE 32
.ALIGN

.GLOBL init
.GLOBL init_title
.GLOBL init_memory_game
        
.INCLUDE "gba.i"
.INCLUDE "system.i"

.INCLUDE "macros.m"

init:

	TASK_SWITCH TASK_INIT_TITLE
	
	bx	lr

init_title:
	
	@ Reset input handler
	ldr	r0,=DATA_AREA+INPUT_HANDLER
	mov	r1,#0
	str	r1,[r0]

	CPU_COPY_32 title, title_end, CODE_AREA
	TASK_SWITCH TASK_DEFAULT

	bx	lr

	
init_memory_game:

	SLOW_CODE_START
	
	@ Reset input handler
	ldr	r0,=DATA_AREA+INPUT_HANDLER
	mov	r1,#0
	str	r1,[r0]

	@ Clear screen
	CPU_CLEAR_32 VRAM, VRAM+(240*160*2)
	@mov	r0,#0b00001000
	@SWI	0x10000	
	
	CPU_COPY_32 memory_game, memory_game_end, CODE_AREA
	
	TASK_SWITCH TASK_DEFAULT

	SLOW_CODE_STOP
