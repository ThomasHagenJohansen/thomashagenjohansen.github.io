.MACRO FUNCTION_ENTRY

	ldr	r10,=999f
	str	lr,[r10]

.ENDM

.MACRO FUNCTION_EXIT

9999:	ldr	r10,=999f
	ldr	lr,[r10]
	bx	lr
999:	.long	0

.ENDM


.MACRO SLOW_CODE_START

	ldr	r0,=1f
	ldr	r1,=DATA_AREA+SLOW_CODE
	str	r0,[r1]

 	bx	lr
1:
.ENDM

.MACRO SLOW_CODE_STOP

	mov	r0,#0
	ldr	r1,=DATA_AREA+SLOW_CODE
	str	r0,[r1]
	
	bx	lr

.ENDM

.MACRO GAME_STATE_SWITCH state

	ldr	r0,=game_state
	ldr	r1,=\state
	str	r1,[r0]	

.ENDM

.MACRO CONTINUE_GAME_STATE state

	ldr	r0,=game_state
	ldr	r0,[r0]
	ldr	r1,=\state
	cmp	r1,r0

.ENDM

.MACRO CONTINUE_IF_GAME_STATE state

	CONTINUE_GAME_STATE \state
	bne	9999f

.ENDM

.MACRO CONTINUE_IF_NOT_GAME_STATE state

	CONTINUE_GAME_STATE \state
	beq	9999f

.ENDM

.MACRO CHECK_BUTTON key, prev_key, func

	ldr	r0,=KEYINPUT
	ldr	r0,[r0]
	ands	r0,r0,#\key
	bne	1f

	ldr	r0,=\prev_key
	ldrh	r1,[r0]
	mov	r2,r1
	ands	r2,r2,#\key
	bne	2f
	orr	r1,r1,#\key
	strh	r1,[r0]
	
	bl	\func		
	b	2f
	
1:
	ldr	r0,=\prev_key
	ldrh	r1,[r0]
	bic	r1,r1,#\key
	strh	r1,[r0]

2:

.ENDM	
	
.MACRO TASK_SWITCH index
	
	ldr	r0,=DATA_AREA+TASK_LIST
	ldr	r1,=\index
	str	r1,[r0]
	
.ENDM

.MACRO CPU_COPY_32 begin, end, dest

	ldr	r0,=\begin
	ldr	r1,=\end
	ldr	r2,=\dest
	CPU_COPY_32_REG

.ENDM

.MACRO CPU_COPY_32_REG
	sub	r1,r1,r0

1:	ldr	r3,[r0],#4
	str	r3,[r2],#4
	subs	r1,r1,#4
	bne	1b

.ENDM

.MACRO CPU_CLEAR_32 begin, end

	mov	r0,#0
	ldr	r1,=\begin
	ldr	r2,=\end
	sub	r2,r2,r1
1:
	str	r0,[r1],#4
	subs	r2,r2,#4
	bne	1b

.ENDM

.MACRO RANDOM_SEED_INCREASE
    	
     	ldr	r2,=DATA_AREA+ENTRY_RANDOM_SEED
     	ldr	r1,[r2]
     	add	r1,r1,r0
     	str	r1,[r2]

.ENDM

.MACRO FRAME_COUNTER_INCREASE

	ldr	r2,=DATA_AREA+FRAME_COUNTER
     	ldr	r1,[r2]
     	mov	r0,#1
     	add	r1,r1,r0
     	str	r1,[r2]

.ENDM

.MACRO FRAME_COUNTER_GET reg

	ldr	\reg,=DATA_AREA+FRAME_COUNTER
     	ldr	\reg,[\reg]

.ENDM

.MACRO	FRAME_COUNTER_WAIT frames

	@ Ready to receive input?
	ldr	r2,=1f
	ldr	r0,[r2]
	mov	r1,#1
	add	r0,r0,r1
	cmp	r0,#\frames
	beq	1f+4
	str	r0,[r2]
	b	9999f
1:	.long	0
	mov	r0,#0
	str	r0,[r2]

.ENDM

.MACRO RAND max

/*
	http://www.intel.com/cd/ids/developer/asmo-na/eng/microprocessors/ia32/pentium4/hyperthreading/43797.htm?page=2
*/
    	ldr	r1,=DATA_AREA+ENTRY_RANDOM_SEED
     	ldr	r1,[r1]
   	ldr	r2,=2531011		@ some magic number
   	ldr	r3,=214013		@ another magic number
  	mla	r0,r3,r1,r2
    	ldr	r1,=DATA_AREA+ENTRY_RANDOM_SEED
	str	r0,[r1]
	
	mov	r0,r0,LSR #16
	ldr	r1,=\max
	swi	0x60000		
/*
    	ldr	r3,=DATA_AREA+ENTRY_KERNEL_FUNCTIONS
    	ldr	r3,[r3]
    	ldr	r2,=FDIV
    	ldr	r3,[r3,r2]
    	mov	r4,lr
    	mov	lr,pc
     	bx	r3
     	mov	lr,r4
*/     	
.ENDM

.MACRO RESOURCE_GET resource

    	ldr	r1,=DATA_AREA+ENTRY_KERNEL_FUNCTIONS
    	ldr	r1,[r1]
    	ldr	r0,=GET_RESOURCE_ADDRESS
    	ldr	r1,[r1,r0]
    	mov	r0,#\resource
    	mov	r4,lr
    	mov	lr,pc
     	bx	r1
     	mov	lr,r4
     	
.ENDM

