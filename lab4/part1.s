
.global  _start

        .equ LEDR_BASE, 0xFF200000 # LED port base
        .equ KEY_BASE,  0xFF200050 # KEY port base

_start:
		li sp, 0x20000 # init stack pointer high up in memory
        
		# use s registers as we need to save these addresses across entire program
		li s1, LEDR_BASE # s1 <- LEDR address
        li s2, KEY_BASE # s2 <- KEY address

        li s0, 1 # current value s0 <- 1
        sw s0, 0(s1) # show 1 on LEDs 

main_loop:
        call wait_for_key # a0 <- key bits telling us which button was pressed
        mv a1, a0  # a1 <- key bits
        mv a0, s0 # a0 <- current value being displayed

        call handle_key # a0 <- new value (determines the operation and ret new value)
        mv s0, a0 # save new value into s0
        sw s0, 0(s1) # update LEDs
 
        call wait_for_release # wait until key released
        j main_loop

wait_for_key:
        addi sp, sp, -4  # allocate stack space
        sw ra, 0(sp) # save return address
wf_loop:
        lw t0, 0(s2) # read KEY data
        beq t0, x0, wf_loop # loop while no key (POLLING LOOP - keeps checking)
        mv a0, t0 # button was pressed - return key bits
		
        lw ra, 0(sp) # restore return address
        addi sp, sp, 4 # free stack space
        ret

wait_for_release:
        addi sp, sp, -4 # allocate stack space
        sw ra, 0(sp) # save return address	
wr_loop:
        lw t0, 0(s2)  # read KEY data
        bne t0, x0, wr_loop # loop while key pressed (POLLING LOOP if not equal for release)
		
        lw ra, 0(sp) # restore return address
        addi sp, sp, 4 # free stack space
        ret

handle_key:
        addi sp, sp, -4 # allocate stack space
        sw ra, 0(sp) # save return address

        li t0, 0b1000 # mask KEY3 (to filter about bits that are irrevelant for current key)
        and t1, a1, t0 # t1 = KEY3 bit (compares a1 with mask t0)
        bne t1, x0, hk_key3 # if KEY3 pressed (as it'll have the value)

        beq a0, x0, hk_restore_one # if blank and non-KEY3

        li t0, 0b0001 # mask KEY0
        and t1, a1, t0 # t1 = KEY0 bit 
        bne t1, x0, hk_key0 # if KEY0 pressed

        li t0, 0b0010 # mask KEY1
        and t1, a1, t0 # t1 = KEY1 bit
        bne t1, x0, hk_key1 # if KEY1 pressed

        li t0, 0b0100 # mask KEY2
        and t1, a1, t0 # t1 = KEY2 bit
        bne t1, x0, hk_key2 # if KEY2 pressed

hk_return:
        lw ra, 0(sp)  # restore return address
        addi sp, sp, 4  # free stack space
        ret

hk_key3:
        li a0, 0 # value = 0
        j hk_return

hk_restore_one:
        li a0, 1 # value = 1
        j hk_return

hk_key0:
        li a0, 1    # value = 1
        j hk_return

hk_key1:
        li t0, 15 # upper limit
        bge a0, t0, hk_return # if >= 15 skip
        addi a0, a0, 1 # value++
        j hk_return

hk_key2:
        li t0, 1 # lower limit
        bge t0, a0, hk_return # if <= 1 skip
        addi a0, a0, -1 # value--
        j hk_return
