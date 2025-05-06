.CODE 32
.ALIGN
      
.GLOBL fdiv

fdiv:
	cmp r1,#1
	beq uo
	mov r2,#0
	cmp r1,r0,lsr#15
	bhi l0_15
	@ 16_31
	cmp r1,r0,lsr#23
	bhi l16_23
	@ 24_31
	cmp r1,r0,lsr#27
	bhi l24_27
	@ 28_31
	cmp r1,r0,lsr#29
	bhi l28_29
	@ 30_31
	cmp r1,r0,lsr#30
	bhi u30
	b u31 
l28_29:
	cmp r1,r0,lsr#28
	bhi u28
	b u29
l24_27:
	cmp r1,r0,lsr#25
	bhi l24_25
	@ 26_27
	cmp r1,r0,lsr#26
	bhi u26
	b u27  
l24_25:
	cmp r1,r0,lsr#24
	bhi u24
	b u25  
l16_23:
	cmp r1,r0,lsr#19
	bhi l16_19
	@ 20_23
	cmp r1,r0,lsr#21
	bhi l20_21
	@ 22_23
	cmp r1,r0,lsr#22
	bhi u22
	b u23
l20_21:
	cmp r1,r0,lsr#20
	bhi u20
	b u21
l16_19:
	cmp r1,r0,lsr#17
	bhi l16_17
	@ l18_19
	cmp r1,r0,lsr#18
	bhi u18
	b u19  
l16_17:
	cmp r1,r0,lsr#16
	bhi u16
	b u17	  
l0_15:
	cmp r1,r0,lsr#7
	bhi l0_7
	@ 8_15
	cmp r1,r0,lsr#11
	bhi l8_11
	@ 12_15
	cmp r1,r0,lsr#13
	bhi l12_13
	@ 14_15
	cmp r1,r0,lsr#14
	bhi u14
	b u15  
l12_13:
	cmp r1,r0,lsr#12
	bhi u12
	b u13
l8_11:
	cmp r1,r0,lsr#9
	bhi l8_9
	@ 10_11
	cmp r1,r0,lsr#10
	bhi u10
	b u11  
l8_9:
	cmp r1,r0,lsr#8
	bhi u8
	b u9
l0_7:
	cmp r1,r0,lsr#3
	bhi l0_3
	@ 4_7
	cmp r1,r0,lsr#5
	bhi l4_5
	@ 6_7
	cmp r1,r0,lsr#6
	bhi u6
	b u7
l4_5:
	cmp r1,r0,lsr#4
	bhi u4
	b u5   
l0_3:
	cmp r1,r0,lsr#1
	bhi l0_1
	@ 2_3
	cmp r1,r0,lsr#2
	bhi u2
	b u3 
l0_1:
	cmp r1,r0
	bhi u0
	b u1
u31:
	cmp r0,r1,lsl#30
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#30
u30:
	cmp r0,r1,lsl#29
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#29
u29:
	cmp r0,r1,lsl#28
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#28
u28:
	cmp r0,r1,lsl#27
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#27
u27:
	cmp r0,r1,lsl#26
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#26
u26:
	cmp r0,r1,lsl#25
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#25
u25:
	cmp r0,r1,lsl#24
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#24
u24:
	cmp r0,r1,lsl#23
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#23
u23:
	cmp r0,r1,lsl#22
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#22
u22:
	cmp r0,r1,lsl#21
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#21
u21:
	cmp r0,r1,lsl#20
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#20
u20:
	cmp r0,r1,lsl#19
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#19
u19:
	cmp r0,r1,lsl#18
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#18
u18:
	cmp r0,r1,lsl#17
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#17
u17:
	cmp r0,r1,lsl#16
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#16
u16:
	cmp r0,r1,lsl#15
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#15
u15:
	cmp r0,r1,lsl#14
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#14
u14:
	cmp r0,r1,lsl#13
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#13
u13:
	cmp r0,r1,lsl#12
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#12
u12:
	cmp r0,r1,lsl#11
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#11
u11:
	cmp r0,r1,lsl#10
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#10
u10:
	cmp r0,r1,lsl#9
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#9
u9:
	cmp r0,r1,lsl#8
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#8
u8:
	cmp r0,r1,lsl#7
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#7
u7:
	cmp r0,r1,lsl#6
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#6
u6:
	cmp r0,r1,lsl#5
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#5
u5:
	cmp r0,r1,lsl#4
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#4
u4:
	cmp r0,r1,lsl#3
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#3
u3:
	cmp r0,r1,lsl#2
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#2
u2:
	cmp r0,r1,lsl#1
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#1
u1:
	cmp r0,r1,lsl#0
	adc r2,r2,r2
	subcs r0,r0,r1,lsl#0
u0:
	mov r1,r0
	mov r0,r2
	bx	lr

uo:
	mov r1,#0
	bx	lr
