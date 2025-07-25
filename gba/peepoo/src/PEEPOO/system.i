.EQU	CLR,					0
.EQU	SET,					1

.EQU	IRQ_HANDLER,				0x03000000
.EQU	DATA_AREA,				IRQ_HANDLER+0x200
.EQU	CODE_AREA,				DATA_AREA+0x0100

.EQU	SYS_IRQ_VECTOR,				0x03007FFC

.EQU	ENTRY_KERNEL_FUNCTIONS,			0
.EQU	ENTRY_RANDOM_SEED,			4
.EQU	FRAME_COUNTER,				8
.EQU	SLOW_CODE,				12
.EQU	INPUT_HANDLER,				16
.EQU	TASK_LIST,				20

.EQU	TASK_DEFAULT, 				0
.EQU	TASK_INIT, 				4
.EQU	TASK_INIT_TITLE, 			8
.EQU	TASK_INIT_MEMORY_GAME,			12

.EQU	GET_RESOURCE_ADDRESS,			0
.EQU	FDIV,					4

.EQU	RESOURCE_TITLE_GRAPHICS,		0
.EQU	RESOURCE_TITLE_OBJ_PALETTE,		1
.EQU	RESOURCE_TITLE_OBJ_DATA,		2
.EQU	RESOURCE_MEMORY_GAME_GRAPHICS,		3
.EQU	RESOURCE_MEMORY_GAME_OBJ_PALETTE,	4
.EQU	RESOURCE_MEMORY_GAME_OBJ_DATA,		5

.EQU	OBJ_ATTRIBUTE_0,			0
.EQU	OBJ_ATTRIBUTE_1,			2
.EQU	OBJ_ATTRIBUTE_2,			4
