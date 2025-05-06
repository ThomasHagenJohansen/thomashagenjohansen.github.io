cursor_flash:

     	ldr	r1,=VPAL_OBJ+(255*2)
     	ldr	r2,=0b0000010000100001
     	ldrh	r0,[r1]
	ldr	r3,=cursor_fade_direction
	ldrh	r4,[r3]
	cmp	r4,#1
	beq	inc
dec:
     	sub	r0,r0,r2
	cmp	r0,#0
	bne	c
	mov	r4,#1
	strh	r4,[r3]
	b	c

inc:
	add	r0,r0,r2
	ldr	r5,=0b0111111111111111
	cmp	r0,r5
	bne	c
	mov	r4,#0
	strh	r4,[r3]

c:	strh	r0,[r1]

	bx	lr

@------------------------------------------------------------------------------

cursor_move_up:

	FUNCTION_ENTRY

	ldr	r3,=cursor_vpos
	ldrh	r4,[r3]
	cmp	r4,#0
	beq	9999f
 
	ldr	r0,=OAM+(8*512)
	ldr	r0,=OAM
	ldrh	r1,[r0]
	ldr	r2,=48
	sub	r1,r1,r2
	strh	r1,[r0]
	
	sub	r4,r4,#1
	strh	r4,[r3]
	
	FUNCTION_EXIT


@------------------------------------------------------------------------------

cursor_move_down:

	FUNCTION_ENTRY

 	ldr	r3,=cursor_vpos
	ldrh	r4,[r3]
	cmp	r4,#2
	bxeq	lr
	
	ldr	r0,=OAM+(8*512)
	ldr	r0,=OAM
	ldrh	r1,[r0]
	ldr	r2,=48
	add	r1,r1,r2
	strh	r1,[r0]

	add	r4,r4,#1
	strh	r4,[r3]
		
	FUNCTION_EXIT

@------------------------------------------------------------------------------

cursor_move_right:

	FUNCTION_ENTRY

	ldr	r3,=cursor_hpos
	ldrh	r4,[r3]
	cmp	r4,#3
	bxeq	lr
	
	ldr	r0,=OAM+(8*512)+2
	ldr	r0,=OAM+2
	ldrh	r1,[r0]
	ldr	r2,=48
	add	r1,r1,r2
	strh	r1,[r0]

	add	r4,r4,#1
	strh	r4,[r3]

	FUNCTION_EXIT
	
@------------------------------------------------------------------------------

cursor_move_left:

	FUNCTION_ENTRY

	ldr	r3,=cursor_hpos
	ldrh	r4,[r3]
	cmp	r4,#0
	bxeq	lr
	
	ldr	r0,=OAM+(8*512)+2
	ldr	r0,=OAM+2
	ldrh	r1,[r0]
	ldr	r2,=48
	sub	r1,r1,r2
	strh	r1,[r0]
	
	sub	r4,r4,#1
	strh	r4,[r3]
	
	FUNCTION_EXIT

@------------------------------------------------------------------------------

cursor_select:

	FUNCTION_ENTRY
	
	ldr	r0,=cursor_hpos
	ldrh	r0,[r0]
	ldr	r1,=cursor_vpos
	ldrh	r1,[r1]

	@ Same brick selected two times?
	ldr	r2,=game_brick_logic
	ldrb	r3,[r2,#1]
	ldrb	r4,[r2,#2]
	cmp	r0,r3
	bne	1f
	cmp	r1,r4
	beq	9999f
1:	
	mov	r1,r1,LSL #2
	add	r1,r1,r0
	ldr	r2,=brick_list
	ldrb	r0,[r2],#1
	add	r2,r2,r0
	ldrb	r1,[r2,r1]
	cmp	r1,#0x000000ff
	beq	9999f

	ldr	r0,=alpha_blending_coefficients
	ldrb	r1,=0b00010000
	strb	r1,[r0]
	mov	r1,#0
	strb	r1,[r0,#1]
	bl	alpha_blending_set_coefficient

	ldr	r0,=cursor_hpos
	ldrh	r0,[r0]
	ldr	r1,=cursor_vpos
	ldrh	r1,[r1]
	ldr	r2,=0b0000010000000000
	mov	r3,#SET
	mov	r4,#OBJ_ATTRIBUTE_0
	bl	card_attribute_set

	@ Play sfx
	ldr	r4,=0x02000000
	mov	lr,pc
 	bx	r4	
	ldr	r4,[r0,#8]		@ sound_play_sfx
	mov	r0,#0
	mov	lr,pc
 	bx	r4

	GAME_STATE_SWITCH CARD_ALPHA_BLENDING
	
	FUNCTION_EXIT
	
@------------------------------------------------------------------------------

cursor_fade_direction:
	.hword	0
cursor_vpos:
	.hword	0
cursor_hpos:
        .hword  0

.align 4
