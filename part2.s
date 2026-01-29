/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
	
main: 

	# reg a0 as input (before subroutine call)
	la t0, InputWord
	lw a0, (t0) # reg a0 receieves input InputWord
	call ONES 
	
	# reg a0 as output (after subroutine call)  
	la t1, Answer 
	sw a0, (t1) # store result a0 into Answer

stop: j stop # good practice to be stop above subroutines (done in lectures)

ONES:
	# init counters
	li t2, 0
	li t3, 32
	
	loop: 
		andi t4, a0, 1 	# compare LSB per iteration with integer 1 (now a0 has input) 
		beqz t4, skipBit # if t4 equal zero then go to the skipBit label
		addi t2, t2, 1 # if t4 == 1 (meaning it skipped line above), then increment counter

	skipBit:
		srli a0, a0, 1 # shift bit to right by 1 (now shift a0 to right instead of t1) 
		addi t3, t3, -1 # decrement total number of iterations (no subi in assembly)
		bnez t3, loop # if t3 (num of iterations left) not equal to zero, go back to loop

		# instead of creating pointer reg and storing result inside of it
		# we just move the result inside of t2 into dest reg a0 
		mv a0, t2
		ret 

.data
InputWord: .word 0x4a01fead

Answer: .word 0