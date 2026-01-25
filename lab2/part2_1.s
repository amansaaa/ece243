.global _start
_start:

# s3 should contain the grade of the person with the student number, -1 if not found
# s0 has the student number being searched

    li s0, 718293

# Your code goes below this line and above iloop

la t0, Snumbers; # holds the address of first element Snumbers in array
la t1, Grades; # holds the address of first element in Grades array

loop:
	lw t2, (t0) # load t2 with contents of t0 (Snumber)
	
	beq t2, x0, missing # check if t2 == 0, then go to missing label 
	beq t2, s0, found # if we find student number, then go to found label 
	
	addi t0, t0, 4 # next Snumbers word (4 bytes)
	addi t1, t1, 4 # next Grades word (4 bytes)
	j loop

missing: 
	li s3, -1 # s3 <- -1
	la t4, result # t4 <- address of result
	sw s3, (t4) # contents of s3 go into memory address at t4
	j iloop # iloop label is already defined above (don't need to put iloop: j iloop)


found: 
	lw s3, (t1) # dereference t1 and store the contents at t1 memory address inside s3 (grade that matched student number) 
	la t4, result 
	sw s3, (t4)
	j iloop 
	
iloop: j iloop

/* result should hold the grade of the student number put into s0, or
-1 if the student number isn't found */ 

result: .word 0
		
/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0

/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .word 99, 68, 90, 85, 91, 67, 80
        .word 66, 95, 91, 91, 99, 76, 68  
        .word 69, 93, 90, 72
