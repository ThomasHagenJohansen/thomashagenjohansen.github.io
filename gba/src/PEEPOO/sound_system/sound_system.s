@******************************************************************************
@   Sound system

@   Definitions:
@   
@******************************************************************************

.CODE 32
.ALIGN

.INCLUDE "gba.i"
.INCLUDE "macros.m"


sound_system:

	ldr	r0,=function_list
	bx	lr

sound_player:

	FUNCTION_ENTRY
	
	bl	sound_buffer_switch
	
	@ Define sound buffer
	ldr	r0,=sound_buffer	@
	ldr	r1,=304			@ buffer size
	ldr	r2,=BufferSwitch	
	ldr	r3,[r2]
	cmp	r3,#1
	addeq	r0,r0,r1
	
	@ Clear sound buffer
	mov	r2,r0
	mov	r3,#0
	mov	r4,r1,lsr #2
1:	str	r3,[r2],#4
	sub	r4,r4,#1
	cmp	r4,#0
	bne	1b

	ldr	r2,=channel1
	ldr	r3,[r2]			@ any sample to play?
	cmp	r3,#0
	beq	9999f

	ldr	r4,[r2,#4]		@ size
	ldr	r5,[r2,#8]		@ position
	add	r6,r3,r5		@ r6 = sample + position

	sub	r7,r4,r5
	
	add	r5,r5,r1
	str	r5,[r2,#8]
	
	cmp	r7,r1
	bge	1f

	mov	r1,r7
	
	mov	r8,#0
	str	r8,[r2]
	str	r8,[r2,#4]
	str	r8,[r2,#8]	

1:	cmp	r1,#0
	beq	9999f

1:	ldrb	r8,[r6],#1
	strb	r8,[r0],#1
	sub	r1,r1,#1
	cmp	r1,#0
	bne	1b	

	FUNCTION_EXIT	

sound_play_sfx:
	
	ldr	r4,=channel1
	ldr	r3,=sfx_list
	add	r3,r3,r0,LSL #3
	ldr	r2,[r3]
	str	r2,[r4]		@ sample sfx
	ldr	r2,[r3,#4]
	str	r2,[r4,#4]	@ sample sfx size
	mov	r2,#0
	str	r2,[r4,#8]	@ sample sfx play position
	
	bx	lr
	
sound_init:

/* REG_SOUND_CNT_H
Bits Function 
0-1 Output sound ratio for channels 1 - 4 (00 = 25%, 01 = 50%, 10 = 100%) 
2 Direct Sound A output ratio (0 = 50%, 1 = 100%) 
3 Direct Sound B output ratio (0 = 50%, 1 = 100%) 
4-7 Unused 
8 Enable Direct Sound A output to right speaker (0 = No, 1 = Yes) 
9 Enable Direct Sound A output to left speaker (0 = No, 1 = Yes) 
A Direct Sound A sampling rate Timer (0 = Timer 0, 1 = Timer 1) 
B Direct Sound A FIFO reset (write a 1 here to reset the FIFO) 
C Enable Direct Sound B output to right speaker (0 = No, 1 = Yes) 
D Enable Direct Sound B output to left speaker (0 = No, 1 = Yes) 
E Direct Sound B sampling rate Timer (0 = Timer 0, 1 = Timer 1) 
F Direct Sound B FIFO reset (write a 1 here to reset the FIFO) 
*/

	@ Enable and reset Direct Sound channel A, at full volume, using Timer 0 to determine frequency
	@             FEDCBA9876543210
	ldr	r0,=0b0000101100000100
	ldr	r1,=REG_SOUNDCNT_H
	strh	r0,[r1]

	@ Set master flag for all sounds
	@             FEDCBA9876543210
	ldr	r0,=0b0000000010000000
	ldr	r1,=REG_SOUNDCNT_X
	strh	r0,[r1]

	@ Stop Direct Sound DMA transfer
	mov	r0,#0
	ldr	r1,=REG_DMA1CNT_H
	strh	r0,[r1]
	
	@ Initialize the DMA transfer - source and destination
	ldr	r0,=REG_FIFO_A
	ldr	r1,=REG_DMA1DAD
	str	r0,[r1]
	ldr	r0,=sound_buffer
	ldr	r1,=REG_DMA1SAD
	str	r0,[r1]

	@ Start Direct Sound DMA transfer
	@             FEDCBA9876543210
	ldrh	r0,=0b1011011001000000
	ldr	r1,=REG_DMA1CNT_H
	strh	r0,[r1]

	@ Set the timer to overflow at the appropriate frequency and start it
	ldr	r0,=(65535-(16777216/18157))
	ldr	r1,=REG_TM0CNT_L
	strh	r0,[r1]

	@             FEDCBA9876543210
	ldr	r0,=0b0000000010000000
	ldr	r1,=REG_TM0CNT_H
	strh	r0,[r1]
	
	bx	lr

sound_buffer_switch:

	ldr	r0,=BufferSwitch
	ldr	r1,[r0]
	eors	r2,r1,#1
	str	r2,[r0]
	beq	1f

	@ Stop Direct Sound DMA transfer
	mov	r0,#0
	ldr	r1,=REG_DMA1CNT_H
	strh	r0,[r1]

	@ Initialize Direct Sound DMA transfer
	ldr	r0,=sound_buffer
	ldr	r1,=REG_DMA1SAD
	str	r0,[r1]

	@ Start Direct Sound DMA transfer
	@             FEDCBA9876543210
	ldrh	r0,=0b1011011001000000
	ldr	r1,=REG_DMA1CNT_H
	strh	r0,[r1]

1:
	bx	lr
	
.POOL

.ALIGN
function_list:
	.long	sound_init
	.long	sound_player
	.long	sound_play_sfx

.ALIGN
BufferSwitch:
	.long	0

.ALIGN
sound_buffer:
	.fill	304,2,0	

.ALIGN
channel1:
	.long	0	@ sample
	.long	0	@ size
	.long	0	@ position


.ALIGN
sfx_list:
	.long	sfx_select_brick, 6864
	.long	sfx_flot_klaret, 11384
	.long	sfx_try_again, 8854
	.long	sfx_godt_gjort, 65792

.ALIGN
sfx_godt_gjort:
	.incbin	"sfx\\godt_gjort.s8"

.ALIGN
sfx_flot_klaret:
	.incbin	"sfx\\flot_klaret.s8"

.ALIGN
sfx_select_brick:
	.incbin	"sfx\\select_brick.s8"
	.align

.ALIGN
sfx_try_again:
	.incbin	"sfx\\try_again.s8"
	.align


.ALIGN
