.CODE 32
.ALIGN
.GLOBL data_area, data_area_end

.INCLUDE "system.i"

data_area:

	.long	kernel_functions	

	.long	0			@ Random seed
	.long	0			@ Frame counter

	.long	0			@ Slow code

	.long	0			@ Task input handler

	.long	TASK_INIT		@ Task list index
	
	.long	CODE_AREA		@ Task list
	.long	init			
	.long	init_title
	.long	init_memory_game

	.long	0
	
data_area_end:
