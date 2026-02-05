.section .text
.global  _start

        .equ LEDR_BASE, 0xFF200000 # LED port base
        .equ KEY_BASE, 0xFF200050 # KEY data base
        .equ KEY_EDGE, 0xFF20005C # KEY edge-capture base
        .equ COUNTER_DELAY, 500000 # CPUlator delay

_start:
		# use s registers as we want to save these across the entire program 
        li s2, LEDR_BASE # LED address
        li s3, KEY_BASE # KEY data address
        li s4, KEY_EDGE # KEY edge address

        li s0, 0 # counter value
        sw s0, 0(s2) # show 0
        li s1, 1 # run flag (1 = running, 0 = stopped)

        li t0, 0xF # clear pending KEY edges (0xF = 0'b1111) to clear to ALL 0
        sw t0, 0(s4) # clear all 4 edge-capture bits

main_loop:
        call check_keys # checks edge capture register (may toggle run flag
        beq s1, x0, skip_count # if run flag = 0, skip increment

        addi s0, s0, 1 # counter++
        li t0, 256 # wrap at 256
        blt s0, t0, store_leds # if < 256, keep value
        li s0, 0 # else reset to 0

store_leds:
        sw s0, 0(s2) # update LEDs

skip_count:
        call delay # ~0.25s delay
        j main_loop # loop forever

delay:
        addi sp, sp, -4 # allocate stack
        sw ra, 0(sp) # save ra

        li t0, COUNTER_DELAY # delay count
delay_loop:
        addi t0, t0, -1 # decrement
        bnez t0, delay_loop # loop

        lw ra, 0(sp) # restore ra
        addi sp, sp, 4 # free stack (pop)
        ret # return

check_keys:
        addi sp, sp, -4 # allocate stack
        sw ra, 0(sp) # save ra

        lw t0, 0(s4) # read edge-capture
        beq t0, x0, ck_exit # no edges -> exit

        sw t0, 0(s4) # clear edges
        xori s1, s1, 1 # toggle run flag

ck_exit:
        lw ra, 0(sp) # restore ra
        addi sp, sp, 4 # free stack
        ret
