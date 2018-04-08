.name "bull"
.comment "I'M THE CHAMPION"

start:	fork %:new
		ld %0, r1

live:	live %1
		zjmp %:live

new:	live %1
