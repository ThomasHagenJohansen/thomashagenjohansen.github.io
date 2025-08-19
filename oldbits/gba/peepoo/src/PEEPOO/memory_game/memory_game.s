@******************************************************************************
@   Memory game - 4x3 (12 bricks, 6 unique with resolution 48x48 ) 
@   		  
@   
@   Definitions:
@   Brick - A picture of which the player tries to find two matching instances
@   Card  - A sprite (OBJ) which hides the brick picture
@   
@******************************************************************************

.CODE 32
.ALIGN
      
.INCLUDE "gba.i"
.INCLUDE "system.i"
.INCLUDE "macros.m"
.INCLUDE "memory_game.i"

memory_game:

	FUNCTION_ENTRY

	ldr	r0,=game_state
	ldr	r1,[r0],#4
	ldr	r0,[r0,r1]
	mov	lr,pc
     	bx	r0
 
	FUNCTION_EXIT

@------------------------------------------------------------------------------
@	Set BLDALPHA register from coefficient
@           
@ 	r0	Pointer to coefficient	EVA (byte), EVB (byte)
@------------------------------------------------------------------------------

alpha_blending_set_coefficient:
	
	ldrb	r1,[r0]			@ EVA
	ldrb	r2,[r0,#1]		@ EVB
	mov	r3,r2,LSL #8
	orr	r3,r3,r1		@ EVA + EVB
	ldr	r4,=REG_BLDALPHA
	strh	r3,[r4]

	bx	lr

@------------------------------------------------------------------------------
@  	Alpha blend a single card	
@------------------------------------------------------------------------------

card_alpha_blending:

	FUNCTION_ENTRY

	FRAME_COUNTER_WAIT 2

	ldr	r0,=alpha_blending_coefficients
	bl	alpha_blending_set_coefficient

	@ Adjust alpha blending coefficients
	ldr	r0,=alpha_blending_coefficients
	ldrb	r2,[r0,#1]		@ EVB
	add	r2,r2,#1
	strb	r2,[r0,#1]
	ldrb	r1,[r0]			@ EVA
	sub	r1,r1,#1
	strb	r1,[r0]
	cmp	r1,#0
	bne	9999f

	@ Hide card when alpha blending is done
	@ This is done because alpha blending is done on all semi-transparent enabled OBJs (cards),
	@ and we only what to show alpha blending on the selected card.
	ldr	r0,=cursor_hpos
	ldrh	r0,[r0]
	ldr	r1,=cursor_vpos
	ldrh	r1,[r1]
	ldr	r2,=0b0000110000000000
	mov	r3,#SET
	mov	r4,#OBJ_ATTRIBUTE_2
	bl	card_attribute_set
	
	GAME_STATE_SWITCH GAME_LOGIC

	FUNCTION_EXIT

alpha_blending_coefficients:
	.byte	0b10000
	.byte	0b00000

.ALIGN

@------------------------------------------------------------------------------

game_logic:

	FUNCTION_ENTRY

	@ Keep track on number of bricks selected
	ldr	r0,=game_brick_logic
	ldrb	r1,[r0]			@ Brick selected
	cmp	r1,#0
	beq	compare_bricks		@ Two bricks selected. Now verify if they are equal.
	add	r1,r1,#1
	strb	r1,[r0]
	
	@ Remember last selected brick
	ldr	r1,=cursor_hpos
	ldrh	r1,[r1]
	strb	r1,[r0,#1]
	ldr	r2,=cursor_vpos
	ldrh	r1,[r2]
	strb	r1,[r0,#2]

	@ One brick selected, so continue game
	GAME_STATE_SWITCH MEMORY_GAME_4x3
	
	b	9999f
	
compare_bricks:

	ldr	r1,=game_brick_logic
	ldrb	r2,[r1,#1]
	ldrb	r3,[r1,#2]
	ldr	r4,=cursor_hpos
	ldrh	r4,[r4]
	ldr	r5,=cursor_vpos
	ldrh	r5,[r5]
	
	ldr	r0,=brick_list
	ldrb	r1,[r0],#1
	add	r0,r0,r1
	mov	r3,r3,LSL #2
	add	r3,r3,r2
	ldrb	r2,[r0,r3]
	mov	r5,r5,LSL #2
	add	r5,r5,r4
	ldrb	r4,[r0,r5]

	cmp	r2,r4
	beq	match

	@ Play sfx
	ldr	r4,=0x02000000
	mov	lr,pc
 	bx	r4	
	ldr	r4,[r0,#8]		@ sound_play_sfx
	mov	r0,#2
	mov	lr,pc
 	bx	r4
 			
	GAME_STATE_SWITCH BRICK_NOT_MATCH_PAUSE

	b	9999f

match:
	@ Mark bricks 'taken' in brick_list table
	ldrb	r1,=-1
	strb	r1,[r0,r3]
	strb	r1,[r0,r5]

	@ Play sfx
	ldr	r4,=0x02000000
	mov	lr,pc
 	bx	r4	
	ldr	r4,[r0,#8]		@ sound_play_sfx
	mov	r0,#1
	mov	lr,pc
 	bx	r4

	@ All pairs found?
	ldr	r1,=game_brick_logic
	ldrb	r2,[r1,#3]
	cmp	r2,#0
	bne	1f

	@ Play sfx
	ldr	r4,=0x02000000
	mov	lr,pc
 	bx	r4	
	ldr	r4,[r0,#8]		@ sound_play_sfx
	mov	r0,#3
	mov	lr,pc
 	bx	r4
 	
	GAME_STATE_SWITCH MEMORY_GAME_RESET

	b	9999f

1:
	sub	r2,r2,#2
	strb	r2,[r1,#3]
	
	GAME_STATE_SWITCH MEMORY_GAME_4x3

	@ Reset bricks selected by player
	ldr	r0,=game_brick_logic
	ldrb	r1,=-1
	strb	r1,[r0]
	strb	r1,[r0,#1]
	strb	r1,[r0,#2]

	FUNCTION_EXIT

@------------------------------------------------------------------------------
@	Set a cards (OBJ) priority or semi-transparent mode
@
@	r0	cursor_hpos
@	r1	cursor_vpos
@	r2	bitmask
@	r3	clear or set
@	r4	attribute number
@------------------------------------------------------------------------------

card_attribute_set:
	
	mov	r5,r0
	mov	r6,#8
	mul	r0,r5,r6

	mov	r5,r1
	mov	r6,#32
	mul	r1,r5,r6
	add	r1,r1,r0

	ldr	r5,=OAM+(8*512)+8
	ldr	r5,=OAM+8
	add	r5,r5,r1
	
	ldrh	r6,[r5,r4]

	cmp	r3,#SET
	orreq	r6,r6,r2
	andne	r6,r6,r2
	
	strh	r6,[r5,r4]
	
	bx	lr

@------------------------------------------------------------------------------
@	Hide brick by showing a card on top of it
@
@	r0	hpos
@	r1	vpos
@------------------------------------------------------------------------------

brick_hide:

	FUNCTION_ENTRY

	mov	r7,r0
	mov	r8,r1

	@ Unhide card and thereby hide brick
	ldr	r2,=0b1111001111111111
	mov	r3,#CLR
	mov	r4,#OBJ_ATTRIBUTE_2
	bl	card_attribute_set

	mov	r0,r7
	mov	r1,r8

	@ Disable alpha blending (semi transpaterent) for card (OBJ)
	ldr	r2,=0b1111101111111111
	mov	r3,#CLR
	mov	r4,#OBJ_ATTRIBUTE_0
	bl	card_attribute_set

	FUNCTION_EXIT


@------------------------------------------------------------------------------
@	When player has selected two bricks that don't match
@	then wait a period and thereafter hide bricks
@------------------------------------------------------------------------------

brick_not_match_pause:

	FUNCTION_ENTRY
	
	FRAME_COUNTER_WAIT 50

	@ Hide first selected brick
	ldr	r1,=game_brick_logic
	ldrb	r0,[r1,#1]
	ldrb	r1,[r1,#2]
	bl	brick_hide

	@ Hide last selected brick
	ldr	r0,=cursor_hpos
	ldrh	r0,[r0]
	ldr	r1,=cursor_vpos
	ldrh	r1,[r1]
	bl	brick_hide

	@ Reset selection data structure
	ldr	r0,=game_brick_logic
	ldrb	r1,=-1
	strb	r1,[r0]
	strb	r1,[r0,#1]
	strb	r1,[r0,#2]

	@ Continue game	
	GAME_STATE_SWITCH MEMORY_GAME_4x3
	
	FUNCTION_EXIT
		
@------------------------------------------------------------------------------

game_4x3:

	FUNCTION_ENTRY

	bl	cursor_flash
	
	FUNCTION_EXIT

@------------------------------------------------------------------------------
@	Initialize game
@------------------------------------------------------------------------------

game_reset:

	FUNCTION_ENTRY

	@ Register input handler
	ldr	r0,=DATA_AREA+INPUT_HANDLER
	ldr	r1,=input_handler
	str	r1,[r0]

	@ Reset cards placement indexes
	ldr	r0,=card_placement
	mov	r1,#0
	str	r1,[r0]
	ldr	r0,=card_placements
	strb	r1,[r0]
	strb	r1,[r0,#25]
	strb	r1,[r0,#50]
	strb	r1,[r0,#75]
	
	@ Reset game logic
	ldr	r0,=game_brick_logic
	mov	r1,#-1
	mov	r2,#12-2
	strb	r1,[r0]
	strb	r1,[r0,#1]
	strb	r1,[r0,#2]
	strb	r2,[r0,#3]

	@ Reset brick list
	ldr	r0,=brick_list_4x3
	ldr	r1,=brick_list_4x3_end
	sub	r2,r1,r0
	ldr	r1,=brick_list
1:	ldrb	r3,[r0],#1
	strb	r3,[r1],#1
	sub	r2,r2,#1
	cmp	r2,#0
	bne	1b

	@ Reset cursor settings
	ldr	r0,=cursor_fade_direction
	mov	r1,#0
	strh	r1,[r0]
	strh	r1,[r0,#2]	@ cursor_vpos
	strh	r1,[r0,#4]	@ cursor_hpos
	ldr	r0,=obj_attributes
	ldr	r1,=0b0010000000001000
	strh	r1,[r0]
	ldr	r1,=0b1100000000011000
	strh	r1,[r0,#2]
	ldr	r1,=0b0000001010000000
	strh	r1,[r0,#4]

   	@ Place cards
	ldr	r0,=OAM+(8*512)
	ldr	r0,=OAM
	ldr	r1,=obj_attributes
	ldr	r2,=obj_attributes_end
	sub	r2,r2,r1
1:
	ldrh	r3,[r1],#2
	strh	r3,[r0],#2
	subs	r2,r2,#2
	bne	1b   	

 	RAND	3
 	ldr	r0,=25
	ldr	r3,=card_placements
 	mla	r2,r1,r0,r3
	ldr	r3,=card_placement
	str	r2,[r3]

	GAME_STATE_SWITCH PLACE_CARDS

	ldr	r0,=REG_DISPCNT
	ldr	r1,=OBJ_ENABLE|BG2_ENABLE|OBJ_MAP_1D|MODE_3
	str	r1,[r0]

	RESOURCE_GET RESOURCE_MEMORY_GAME_OBJ_PALETTE
     	ldr	r1,=VPAL_OBJ
	mov	r2,#256 
1:
	ldrh	r3,[r0],#2
	strh	r3,[r1],#2
	subs	r2,r2,#1
	bne	1b

	RESOURCE_GET RESOURCE_MEMORY_GAME_OBJ_DATA
	sub	r1,r1,r0
     	ldr	r2,=OBJ_BG_345
1:
	ldrh	r3,[r0],#2
	strh	r3,[r2],#2
	subs	r1,r1,#2
	bne	1b
		
	@             FEDCBA9876543210
	ldr	r0,=0b0001010001000000
	ldr	r1,=REG_BLDCNT
	strh	r0,[r1]

	@             FEDCBA9876543210
	ldr	r0,=0b0000000000010000
	ldr	r1,=REG_BLDALPHA
	strh	r0,[r1]

	FUNCTION_EXIT
	
@------------------------------------------------------------------------------

place_card:

	FUNCTION_ENTRY

	FRAME_COUNTER_WAIT 1

	bl	background_zoom

	ldr	r0,=REG_BLDALPHA
	ldrh	r1,[r0]
	add	r1,r1,#1
	ldr	r2,=0b0001000000010000
	cmp	r1,r2
	beq	1f
	strh	r1,[r0]

	b	9999f

1:
	ldr	r2,=card_placement
	ldr	r2,[r2]
	ldrb	r3,[r2],#1
	add	r2,r2,r3
	ldrb	r0,[r2],#1
	ldrb	r1,[r2]
	ldr	r2,=0b1111101111111111
	mov	r3,#CLR
	mov	r4,#OBJ_ATTRIBUTE_0
	bl	card_attribute_set

	ldr	r2,=card_placement
	ldr	r2,[r2]
	ldrb	r3,[r2]
	add	r3,r3,#2
	strb	r3,[r2]
	cmp	r3,#12*2
	bne	1f
   	
	GAME_STATE_SWITCH BACKGROUND_ZOOM_FINISH
	b	9999f
1:
	GAME_STATE_SWITCH PLACE_CARDS

	FUNCTION_EXIT

@------------------------------------------------------------------------------

place_cards:

	FUNCTION_ENTRY
	
	bl	background_zoom

	@             FEDCBA9876543210
	ldr	r0,=0b0001010001000000
	ldr	r1,=REG_BLDCNT
	strh	r0,[r1]			

	ldr	r0,=REG_BLDALPHA	
	ldr	r2,=0b0001000000000000
	strh	r2,[r0]         

	ldr	r2,=card_placement
	ldr	r2,[r2]
	ldrb	r3,[r2],#1
	add	r2,r2,r3
	ldrb	r0,[r2],#1
	ldrb	r1,[r2]
	ldr	r2,=0b0000010000000000
	mov	r3,#SET
	mov	r4,#OBJ_ATTRIBUTE_0
	bl	card_attribute_set

	ldr	r2,=card_placement
	ldr	r2,[r2]
	ldrb	r3,[r2],#1
	add	r2,r2,r3
	ldrb	r0,[r2],#1
	ldrb	r1,[r2]
	ldr	r2,=0b1111001111111111
	mov	r3,#CLR
	mov	r4,#OBJ_ATTRIBUTE_2
	bl	card_attribute_set

	GAME_STATE_SWITCH PLACE_CARD

	FUNCTION_EXIT

@------------------------------------------------------------------------------

background_zoom_finish:

	FUNCTION_ENTRY

	bl	background_zoom

	FUNCTION_EXIT

@------------------------------------------------------------------------------

background_zoom:

	FUNCTION_ENTRY

	ldr	r0,=src
	ldr	r1,=REG_BG2PA	@ Make BIOS write to custom registers (REG_BG2PA, REG_BG2PB, ...) directly
	mov	r2,#1
	swi	0xE0000

	ldr	r0,=sx
	ldrh	r1,[r0]
	sub	r1,r1,#2
	strh	r1,[r0]
	
	ldr	r0,=sy
	ldrh	r1,[r0]
	sub	r1,r1,#2
	strh	r1,[r0]

	ldr	r0,=0xFF00
	cmp	r0,r1
	bne	9999f

	@ Reset background zoom
	ldr	r0,=0x0100
	ldr	r1,=sx
	strh	r0,[r1]
	ldr	r1,=sy
	strh	r0,[r1]

	ldr	r0,=src
	ldr	r1,=REG_BG2PA	@ Make BIOS write to custom registers (REG_BG2PA, REG_BG2PB, ...) directly
	mov	r2,#1
	swi	0xE0000

	GAME_STATE_SWITCH PLACE_BRICKS

	FUNCTION_EXIT

src:
        .word	120<<8	@s32  Original data's center X coordinate (8bit fractional portion)

        .word	80<<8   @64*256	@s32  Original data's center Y coordinate (8bit fractional portion)

        .byte	120	@s16  Display's center X coordinate
        .byte   0

        .byte	80	@s16  Display's center Y coordinate
        .byte	0

sx:     .short	0xa0	@s16  Scaling ratio in X direction (8bit fractional portion)
sy:     .short	0xa0	@s16  Scaling ratio in Y direction (8bit fractional portion)

r:      .word	0x0

.align	4

@------------------------------------------------------------------------------

place_bricks:

	@ Shuffle bricks
	ldr	r5,=brick_list

	RAND	8
	mov	r1,r1,lsl #1
	strb	r1,[r5]

	ldrb	r6,[r5],#1
	add	r5,r5,r6
	mov	r6,#12
	add	r6,r6,r5
1:
	RAND	11
	mov	r9,r1
	RAND	11
	ldrb	r7,[r5,r1]
	ldrb	r8,[r5,r9]
	strb	r7,[r5,r9]
	strb	r8,[r5,r1]
	subs	r6,r6,#1
   	cmp	r5,r6
   	blt	1b
	
	RESOURCE_GET RESOURCE_MEMORY_GAME_GRAPHICS
     	
	@ Draw bricks
	mov	r6,#0
	ldr	r7,=VRAM+(24*2)+(8*(240*2))
    	ldr	r8,=brick_list
	ldrb	r9,[r8],#1
	add	r8,r8,r9
	mov	r9,#12
	add	r9,r9,r8
draw:
	@ Calculate brick graphics memory location
	mov	r4,#0
	ldr	r3,=(48*2)			@ r3 = brick width
	ldr	r2,=((240*2)*48)		@ r2 = brick line distance
    	ldrb	r1,[r8],#1
	cmp	r1,#4
	addgt	r4,r4,r2
	subgt	r1,r1,#5
	cmp	r1,#4
	addgt	r4,r4,r2
	subgt	r1,r1,#5
	add	r4,r4,r0
	mla	r10,r3,r1,r4

	@ Calculate brick draw location
	mov	r4,#0
	ldr	r3,=(48*2)			@ r3 = brick width
	ldr	r2,=((240*2)*48)		@ r2 = brick line distance
    	mov	r1,r6
	cmp	r1,#3
	addgt	r4,r4,r2
	subgt	r1,r1,#4
	cmp	r1,#3
	addgt	r4,r4,r2
	subgt	r1,r1,#4
	add	r4,r4,r7
	mla	r5,r3,r1,r4
	
	@ Draw
	mov	r1,#48
1:	mov	r2,#24
2:	ldr	r3,[r10],#4
	str	r3,[r5],#4
	subs	r2,r2,#1
	bne	2b
	add	r10,r10,#(240*2)-(48*2)
	add	r5,r5,#(240*2)-(48*2)
	subs	r1,r1,#1
	bne	1b
   
   	@ Next brick
   	add	r6,r6,#1
   	
   	@ All done?
   	cmp	r8,r9
   	blt	draw

	GAME_STATE_SWITCH MEMORY_GAME_4x3
	
	bx	lr

@------------------------------------------------------------------------------

input_handler:

	FUNCTION_ENTRY

	CHECK_BUTTON KEYINPUT_SL,  input_handler_previous_key,	return_to_title_screen
	
	CONTINUE_IF_GAME_STATE MEMORY_GAME_4x3

	CHECK_BUTTON KEYINPUT_UP,  input_handler_previous_key, 	cursor_move_up
	CHECK_BUTTON KEYINPUT_DWN, input_handler_previous_key, 	cursor_move_down
	CHECK_BUTTON KEYINPUT_LFT, input_handler_previous_key, 	cursor_move_left
	CHECK_BUTTON KEYINPUT_RT,  input_handler_previous_key, 	cursor_move_right
	CHECK_BUTTON KEYINPUT_A,   input_handler_previous_key,	cursor_select

	FUNCTION_EXIT

input_handler_previous_key:
	.word	0

@------------------------------------------------------------------------------

return_to_title_screen:

	TASK_SWITCH TASK_INIT_TITLE
	
	bx	lr		

	
	.INCLUDE "cursor.s"
	
@------------------------------------------------------------------------------

game_state:

	.long	MEMORY_GAME_RESET	@ Index into game_state function list

	.long	game_reset
	.long	game_4x3
	.long	card_alpha_blending
	.long	brick_not_match_pause
	.long	place_cards
	.long	place_card
	.long	place_bricks
	.long	game_logic
	.long	background_zoom_finish

brick_list:
	@ Index into brick list
	.byte	0x00
	.byte	0x00,0x00,0x01,0x01,0x02,0x02,0x03,0x03,0x04,0x04
	.byte	0x05,0x05,0x06,0x06,0x07,0x07,0x08,0x08,0x09,0x09
	.byte	0x0A,0x0A,0x0B,0x0B,0x0C,0x0C,0x0D,0x0D,0x0E,0x0E
brick_list_end:
.ALIGN

brick_list_4x3:
	@ Index into brick list
	.byte	0x00
	.byte	0x00,0x00,0x01,0x01,0x02,0x02,0x03,0x03,0x04,0x04
	.byte	0x05,0x05,0x06,0x06,0x07,0x07,0x08,0x08,0x09,0x09
	.byte	0x0A,0x0A,0x0B,0x0B,0x0C,0x0C,0x0D,0x0D,0x0E,0x0E
brick_list_4x3_end:
.ALIGN


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
@ Cursor
	.hword	0b0010000000001000, 0b1100000000011000, 0b0000001010000000, 0
@ Bricks
	.hword	0b0010000000001000, 0b1100000000011000, 0b0000011000000000, 0			
	.hword	0b0010000000001000, 0b1100000001001000, 0b0000011000000000, 0
	.hword	0b0010000000001000, 0b1100000001111000, 0b0000111000000000, 0
	.hword	0b0010000000001000, 0b1100000010101000, 0b0000111000000000, 0

	.hword	0b0010000000111000, 0b1100000000011000, 0b0000111000000000, 0
	.hword	0b0010000000111000, 0b1100000001001000, 0b0000111000000000, 0
	.hword	0b0010000000111000, 0b1100000001111000, 0b0000111000000000, 0
	.hword	0b0010000000111000, 0b1100000010101000, 0b0000111000000000, 0

	.hword	0b0010000001101000, 0b1100000000011000, 0b0000111000000000, 0
	.hword	0b0010000001101000, 0b1100000001001000, 0b0000111000000000, 0
	.hword	0b0010000001101000, 0b1100000001111000, 0b0000111000000000, 0
	.hword	0b0010000001101000, 0b1100000010101000, 0b0000111000000000, 0

obj_attributes_end:


card_placement:

	.long	0	@ Pointer into card placements

card_placements:

	.byte	0		@ Index
	.byte	0,0,1,0,2,0,3,0
	.byte	3,1,2,1,1,1,0,1
	.byte	0,2,1,2,2,2,3,2

	.byte	0		@ Index
	.byte	0,0,0,1,0,2,1,2
	.byte	1,1,1,0,2,0,2,1
	.byte	2,2,3,2,3,1,3,0

	.byte	0		@ Index
	.byte	0,0,3,2,0,1,3,1
	.byte	0,2,3,0,1,2,2,0
	.byte	1,1,2,1,1,0,2,2

	.byte	0		@ Index
	.byte	0,0,1,0,0,1,2,0
	.byte	1,1,0,2,3,0,2,1
	.byte	1,2,3,1,2,2,3,2

game_brick_logic:

	.byte	-1	@ Brick selected, -1 = none, 0 = first, 1 = second
	.byte	-1, -1	@ Last brick selected (column, row)
	.byte	12-2	@ Number of bricks
	