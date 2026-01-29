/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
	
	# load InputWord from memory
	la t0, InputWord # t0 <- address of InputWord
	lw t1, (t0) # t1 <- contents of t0 (aka. value of InputWord)
	
	# init counters
	li t2, 0
	li t3, 32
	
loop: 
	andi t4, t1, 1 	# compare LSB per iteration with integer 1 (t4 = 1 if t2 == 1)
	beqz t4, skipBit # if t4 equal zero then go to the skipBit label
	addi t2, t2, 1 # if t4 == 1 (meaning it skipped line above), then increment counter
	
skipBit:
	srli t1, t1, 1 # shift bit to right by 1
	addi t3, t3, -1 # decrement total number of iterations (no subi in assembly)
	bnez t3, loop # if t3 (num of iterations left) not equal to zero, go back to loop
	
	# store result inside of Answer
	la t5, Answer # t5 <- address of Answer
	sw t2, (t5) # put contents of t2 inside of memory address pointed by t5 (in Answer)
	
stop: j stop

.data
InputWord: .word 0x4a01fead

Answer: .word 0
