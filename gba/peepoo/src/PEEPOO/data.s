.CODE 32
.ALIGN

.GLOBL	irq_handler, irq_handler_end
.GLOBL	sound_system, sound_system_end

.GLOBL	sfx, sfx_end

.GLOBL	title, title_end
.GLOBL	title_graphics, title_graphics_end
.GLOBL	title_obj_palette, title_obj_palette_end
.GLOBL	title_obj_data, title_obj_data_end

.GLOBL	memory_game, memory_game_end
.GLOBL	memory_game_graphics, memory_game_graphics_end

.GLOBL	memory_game_obj_palette, memory_game_obj_palette_end
.GLOBL	memory_game_obj_data, memory_game_obj_data_end

.ALIGN
irq_handler:
	.incbin "irq_handler.bin"
irq_handler_end:

.ALIGN
sound_system:
	.incbin "sound_system.bin"
sound_system_end:

.ALIGN
title_graphics:
	.incbin "title_graphics.bin"
title_graphics_end:

.ALIGN
title_obj_data:
	.incbin "t.bin"		@ 32x32
	.incbin "r.bin" 	@ 16x16
	.incbin "y.bin"		@ 32x32
	.incbin "k.bin"		@ 16x16
	.incbin "p.bin"		@ 16x32
	.incbin "aa.bin"	@ 16x32
	.incbin "s.bin"		@ 16x16
	.incbin "t2.bin"	@ 16x16
	.incbin "a.bin"		@ 16x32
title_obj_data_end:

.ALIGN
title_obj_palette:
	.incbin	"TrykPaaStart.pal"
title_obj_palette_end:

.ALIGN
title:
	.incbin "title.bin"
title_end:

.ALIGN
memory_game:
	.incbin "memory_game.bin"
memory_game_end:

.ALIGN
memory_game_graphics:
	.incbin "memory_graphics.bin"
memory_game_graphics_end:

.ALIGN
memory_game_obj_palette:
	.incbin	"card.pal"
memory_game_obj_palette_end:
	
.ALIGN
memory_game_obj_data:
	.incbin	"card.bin"
	.incbin "border.bin"
memory_game_obj_data_end:
