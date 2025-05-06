@******************************************************************************
@   Title screen  
@******************************************************************************

.CODE 32
.ALIGN
      
.INCLUDE "gba.i"
.INCLUDE "system.i"

.INCLUDE "macros.m"

.EQU	TITLE_RESET, 	 	0
.EQU	TITLE,	 	 	4
.EQU	TITLE_INTRO, 	 	8
.EQU	TITLE_ZOOM_ROTATE,	12
.EQU	TITLE_EXIT, 	 	16

@------------------------------------------------------------------------------

title_screen:

	FUNCTION_ENTRY

	ldr	r0,=game_state
	ldr	r1,[r0],#4
	ldr	r0,[r0,r1]
	mov	lr,pc
     	bx	r0
 
	FUNCTION_EXIT

@------------------------------------------------------------------------------

title_exit:

	FUNCTION_ENTRY
	
	FRAME_COUNTER_WAIT 3
	
	ldr	r2,=REG_BLDY
	ldr	r1,=brightness_coefficient
	ldrh	r0,[r1]
	add	r0,r0,#1
	strh	r0,[r1]
	strh	r0,[r2]
	cmp	r0,#16
	bne	9999f

	TASK_SWITCH TASK_INIT_MEMORY_GAME

	FUNCTION_EXIT
	
@------------------------------------------------------------------------------

title_reset:

	SLOW_CODE_START
	
	@ Clear OAM
	mov	r0,#0b00010000
	SWI	0x10000	
	
	RESOURCE_GET RESOURCE_TITLE_GRAPHICS	
	ldr	r2,=VRAM
	CPU_COPY_32_REG

	ldr	r0,=REG_DISPCNT
	ldr	r1,=OBJ_ENABLE|BG2_ENABLE|OBJ_MAP_1D|MODE_3
	strh	r1,[r0]

	RESOURCE_GET RESOURCE_TITLE_OBJ_PALETTE
     	ldr	r1,=VPAL_OBJ
	mov	r2,#256 
1:
	ldrh	r3,[r0],#2
	strh	r3,[r1],#2
	subs	r2,r2,#1
	bne	1b

	RESOURCE_GET RESOURCE_TITLE_OBJ_DATA
	sub	r1,r1,r0
     	ldr	r2,=OBJ_BG_345
1:
	ldrh	r3,[r0],#2
	strh	r3,[r2],#2
	subs	r1,r1,#2
	bne	1b

	ldr	r0,=0b0000000000010000
	ldr	r1,=REG_BLDY
	strh	r0,[r1]

	@             FEDCBA9876543210
	ldr	r0,=0b0000000000000000
	ldr	r1,=REG_BLDCNT
	strh	r0,[r1]

	ldr	r0,=OAM
	ldr	r1,=obj_attributes
	ldr	r2,=obj_attributes_end
	sub	r2,r2,r1
1:
	ldrh	r3,[r1],#2
	strh	r3,[r0],#2
	subs	r2,r2,#2
	bne	1b

	ldr	r0,=obj_src
	ldr	r1,=OAM+6
	mov	r2,#11
	mov	r3,#8
	SWI	0xF0000
	
	@ Register input handler
	ldr	r0,=DATA_AREA+INPUT_HANDLER
	ldr	r1,=get_player_input
	str	r1,[r0]
	
	GAME_STATE_SWITCH TITLE_INTRO
	
	SLOW_CODE_STOP

@------------------------------------------------------------------------------

title_intro:

	FUNCTION_ENTRY

	bl	title_fade
	bl	title_zoom_rotate
	bl	press_start_zoom
	
	FUNCTION_EXIT
	
@------------------------------------------------------------------------------
		
title_fade:

	FUNCTION_ENTRY

	FRAME_COUNTER_WAIT 7
	
	ldr	r2,=REG_BLDY
	ldr	r1,=brightness_coefficient
	ldrh	r0,[r1]
	cmp	r0,#1
	subge	r0,r0,#1
	strh	r0,[r1]
	strh	r0,[r2]

	FUNCTION_EXIT

brightness_coefficient:
	.word	0b0000000000010000

@------------------------------------------------------------------------------

title_zoom_rotate:

	FUNCTION_ENTRY

	ldr	r0,=sx
	ldrh	r1,[r0]
	cmp	r1,#0x0100
	subne	r1,r1,#0x20
	strh	r1,[r0]
	
	ldr	r0,=sy
	ldrh	r1,[r0]
	cmp	r1,#0x0100
	subne	r1,r1,#0x20
	strh	r1,[r0]

	ldr	r0,=r
	ldrh	r1,[r0]
	add	r1,r1,#0x200
	strh	r1,[r0]

	ldr	r0,=src
	ldr	r1,=REG_BG2PA	@ Make BIOS write to custom registers (REG_BG2PA, REG_BG2PB, ...) directly
	mov	r2,#1
	swi	0xE0000

	ldr	r0,=r
	ldrh	r1,[r0]
	cmp	r1,#0
	bne	9999f

	GAME_STATE_SWITCH TITLE

	FUNCTION_EXIT
	
src:
        .word	120<<8	@s32  Original data's center X coordinate (8bit fractional portion)

        .word	80<<8   @64*256	@s32  Original data's center Y coordinate (8bit fractional portion)

        .byte	120	@s16  Display's center X coordinate
        .byte   0

        .byte	80	@s16  Display's center Y coordinate
        .byte	0

sx:     .short	0x0e00	@s16  Scaling ratio in X direction (8bit fractional portion)
sy:     .short	0x0e00	@s16  Scaling ratio in Y direction (8bit fractional portion)

r:      .word	0x0

.align	4

@------------------------------------------------------------------------------

title:
	FUNCTION_ENTRY

	bl	press_start_rotate

	FUNCTION_EXIT

@------------------------------------------------------------------------------

get_player_input:

	FUNCTION_ENTRY

	CONTINUE_IF_GAME_STATE TITLE	

1:	
	@ Check if player has pressed the START or A button
	ldr	r0,=KEYINPUT
	ldr	r0,[r0]
	ands	r1,r0,#KEYINPUT_ST
	andnes	r1,r0,#KEYINPUT_A
	bne	9999f

	@             FEDCBA9876543210
	ldr	r0,=0b0001010011010100
	ldr	r1,=REG_BLDCNT
	strh	r0,[r1]

	ldrh	r0,=0b0000000000000000
	ldr	r1,=REG_BLDY
	strh	r0,[r1]
					
	GAME_STATE_SWITCH TITLE_EXIT

	FUNCTION_EXIT

@------------------------------------------------------------------------------

press_start_zoom:

	FUNCTION_ENTRY

	FRAME_COUNTER_WAIT 3

	ldr	r0,=obj_src
	mov	r4,#11
1:	mov	r3,r4
2:	mov	r1,r0
	ldrh	r2,[r1]
	cmp	r2,#0x0100
	beq	3f
	sub	r2,r2,#0x10
	strh	r2,[r1]
	strh	r2,[r1,#2]
	
3:	cmp	r3,#0
	beq	4f
	sub	r3,r3,#1
	add	r1,r1,#8
	b	2b

4:	sub	r4,r4,#1
	cmp	r4,#0
	beq	1f
	add	r0,r0,#8
	b	1b

1:
	cmp	r2,#0x0100
	bne	1f

	GAME_STATE_SWITCH TITLE_ZOOM_ROTATE
1:

/*
SWI 15 (0Fh) - ObjAffineSet
Calculates and sets the OBJ's affine parameters from the scaling ratio and angle of rotation.
The affine parameters are calculated from the parameters set in Srcp.
The four affine parameters are set every Offset bytes, starting from the Destp address.
If the Offset value is 2, the parameters are stored contiguously. If the value is 8, they match the structure of OAM.
When Srcp is arrayed, the calculation can be performed continuously by specifying Num.
  r0   Source Address, pointing to data structure as such:
        s16  Scaling ratio in X direction (8bit fractional portion)
        s16  Scaling ratio in Y direction (8bit fractional portion)
        u16  Angle of rotation (8bit fractional portion) Effective Range 0-FFFF
  r1   Destination Address, pointing to data structure as such:
        s16  Difference in X coordinate along same line
        s16  Difference in X coordinate along next line
        s16  Difference in Y coordinate along same line
        s16  Difference in Y coordinate along next line
  r2   Number of calculations
  r3   Offset in bytes for parameter addresses (2=contigiously, 8=OAM)

 
Return: No return value, Data written to destination address.

For both Bg- and ObjAffineSet, Rotation angles are specified as 0-FFFFh (covering a range of 360 degrees), however, the GBA BIOS recurses only the upper 8bit; the lower 8bit may contain a fractional portion, but it is ignored by the BIOS.
*/
	ldr	r0,=obj_src
	ldr	r1,=OAM+6
	mov	r2,#11
	mov	r3,#8
	SWI	0xF0000
		
	FUNCTION_EXIT

@------------------------------------------------------------------------------

press_start_rotate:

	FUNCTION_ENTRY
	
	ldr	r0,=obj_src+4
	ldr	r2,=obj_src_rotate_direction
	ldr	r7,=0x0200
	ldr	r8,=0x2000
	ldr	r9,=0xE000
	
	mov	r10,#10
0:
	ldrh	r1,[r0]
	ldrb	r3,[r2]
	cmp	r3,#0
 	bne	1f
 	cmp	r1,r8
 	beq	2f
	add	r1,r1,r7
	b	3f

1:	cmp	r1,r9
	beq	2f
	sub	r1,r1,r7
	b	3f
	
2:	eor	r3,r3,#1
	strb	r3,[r2]

3:	strh	r1,[r0]

	cmp	r10,#0
	beq	1f
	
	add	r0,r0,#8
	add	r2,r2,#1
	sub	r10,r10,#1
	b	0b
	
1:
	ldr	r0,=obj_src
	ldr	r1,=OAM+6
	mov	r2,#11
	mov	r3,#8
	SWI	0xF0000
		
		
	FUNCTION_EXIT

obj_src:
	.short	0x800	@s16  Scaling ratio in X direction (8bit fractional portion)
	.short	0x800	@s16  Scaling ratio in Y direction (8bit fractional portion)
	.word	0xF800

	.short	0x820
	.short	0x820
	.word	0x0

	.short	0x840
	.short	0x840
	.word	0x0800

	.short	0x860
	.short	0x860
	.word	0x1000

	.short	0x880
	.short	0x880
	.word	0x1000

	.short	0x8a0
	.short	0x8a0
	.word	0x1800

	.short	0x8c0
	.short	0x8c0
	.word	0x2000

	.short	0x8e0
	.short	0x8e0
	.word	0x1800

	.short	0x910
	.short	0x910
	.word	0x0800

	.short	0x830
	.short	0x830
	.word	0x1000

	.short	0x650
	.short	0x650
	.word	0xF800

.align	4

obj_src_rotate_direction:
	.byte	0,0,0,0,0,0,0,0,0,0,0

.align	4

game_state:

	.long	TITLE_RESET	@ Index into game_state function list

	.long	title_reset
	.long	title
	.long	title_intro
	.long	title_zoom_rotate
	.long	title_exit

obj_attributes:

/*
	OBJ Attribute 0
	0-7	y-coordinate
	8	Rotation/Scaling flag
	9	Rotation/Scaling flag Double-Size flag
	A-B	OBJ Mode	00=Normal OBJ, 01=Semi-transparant OBJ, 10=OBJ window, 11=Illegal (Do not use)
	C	OBJ Mosaic
	D	Color Mode	0 = 16 colors x 16 palettes, 1 = 256 colors x 1 palette
	E-F	OBJ Shape

	OBJ Attribute 1	
	0-8	x-coordinate
	9-D	Rotation/scaling selection, Horizontal and Vertical flip flags
	E-F	OBJ Size

	OBJ Attribute 2
	0-9	Character name
	A-B	Priority Specification relative to BG
	C-F	Palette number 

*/
		@ FEDCBA9876543210  @ FEDCBA9876543210  @ FEDCBA9876543210  @ FEDCBA9876543210
		@ Attribute 0	    @ Attribute 1	@ Attribute 2	    @ Rotating/Scaling parameter
	
	.hword	0b0010001101100011, 0b1000000000000000, 0b0000001000000000, 0	@T
	.hword	0b0010001101111000, 0b0100001000011101, 0b0000001000110000, 0	@r
	.hword	0b0010001101101110, 0b1000010000011100, 0b0000001001001000, 0	@y
	.hword	0b0010001101111000, 0b0100011001000000, 0b0000001001111000, 0	@k
	.hword	0b1010001101101110, 0b1000100001011100, 0b0000001010010000, 0	@p
	.hword	0b1010001101100110, 0b1000101001101101, 0b0000001010110000, 0	@å
	.hword	0b0010001101111000, 0b0100110010000110, 0b0000001011010000, 0	@s
	.hword	0b0010001101111000, 0b0100111010010110, 0b0000001011101000, 0	@t
	.hword	0b1010001101101001, 0b1001000010100111, 0b0000001100000000, 0	@a
	.hword	0b0010001101111000, 0b0101001010110111, 0b0000001000110000, 0	@r
	.hword	0b0010001101111000, 0b0101010011000111, 0b0000001011101000, 0	@t

obj_attributes_end:
