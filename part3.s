/* Program to Count the number of 1's and Zeroes in a sequence of 32-bit words,
and determines the largest of each */

.global _start
_start:

/* Your code here  */

main: 
	la sp, 0x20000 # high up in memory
	la t0, TEST_NUM # pointer to first word in array
	
	li t5, 0 # reg to store largest ones
	li t6, 0 # reg to store largest zeros


loop: 
	lw t1, (t0)
	beqz t1, done # end of TEST_NUM array, go to done label
	
	# must push onto stack before call (t regs are temp registers from lecture 9)
	addi sp, sp, -12 # make room for 3 words

	# store into memory
	sw t0, 0(sp) 		
	sw t5, 4(sp)		
	sw t6, 8(sp)
	
	mv a0, t1 # input reg a0 gets the word from reg t1
	call ONES
	
	# get information off the stack 
	lw t0, (sp) 
	lw t5, 4(sp)
	lw t6, 8(sp)
	
	# change sp to new top of stack
	addi sp, sp, 12 

	bge t5, a0, skip_and_find_zeros # if t5 (old max) >= a0 (new max), then  skip
	mv t5, a0 		 # otherwise we found max num of ones

# since we found the largest ones (max), now do the same for zeros at this point of the program
skip_and_find_zeros: 
	# push onto stack (make room for 3 words & store into memory)
	addi sp, sp, -12 
	sw t0, 0(sp) 		
	sw t5, 4(sp)		
	sw t6, 8(sp)
	
	mv a0, t1 # putting the same word into input reg a0 for subroutine call
	xori a0, a0, -1 # flip bits (counts all 1s as normal but in reality they are 0s) 
	call ONES
	
	# pop off the stack
	lw t0, 0(sp)
	lw t5, 4(sp)
	lw t6, 8(sp)
	addi sp, sp, 12
	
	# to find largest zeros, compare if t6 (old max) >- a0 (new max)
	bge t6, a0, nextWord
	mv t6, a0 

# iterate to next word (can't do it at the top of the program since we'd skip the first word in the array)
nextWord:
	addi t0, t0, 4 
	j loop

done:
	# max ones live in t5
	# max zeros live in t6
	
	la t0, LargestOnes
	sw t5, (t0)
	
	la t0, LargestZeroes
	sw t6, (t0)
	
stop: j stop

ONES:
	# init counters
	li t2, 0
	li t3, 32
	
	loopp: # loopp to avoid name conflict with global loop outside of subroutine call 
		andi t4, a0, 1 # compare LSB per iteration with integer 1
		beqz t4, skipBit # if t4 == 0, then skipBit
		addi t2, t2, 1 # increment counter (b/c t4 is 1)

	skipBit:
		srli a0, a0, 1 # shift bit to right by 1 
		addi t3, t3, -1 # decrement total number of iterations (no subi in assembly)
		bnez t3, loopp # if t3 (num of iterations left) != 0, go back to loop

		mv a0, t2 # a0 <- t2 (t2 holds result)
		ret 


.data
TEST_NUM:  .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
            .word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
            .word 0  # end of list 

LargestOnes: .word 0
LargestZeroes: .word 0