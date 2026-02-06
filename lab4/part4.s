.global  _start

        # I/O base addresses
        .equ LEDR_BASE,        0xFF200000  # LED port base
        .equ KEY_EDGE_BASE,    0xFF20005C  # KEY edge-capture base

        # Timer 0 base and register offsets
        .equ TIMER0_BASE,      0xFF202000  # timer base
        .equ TMR_STATUS_OFF,   0# status register
        .equ TMR_CONTROL_OFF,  4# control register
        .equ TMR_START_LO_OFF, 8# counter start low
        .equ TMR_START_HI_OFF, 12 # counter start high

        # 0.01 s at 100 MHz = 1,000,000 = 0x000F4240
        .equ TMR_001S_LO,      0x4240 # low  16 bits
        .equ TMR_001S_HI,      0x000F # high 16 bits

        # Control bits: bit0=ITO, bit1=CONT, bit2=START, bit3=STOP
        .equ TMR_CTRL_START_CONT, 0x6 # START=1, CONT=1

_start:
        li s2, LEDR_BASE # s2 = LED address
        li s3, KEY_EDGE_BASE # s3 = KEY edge address
        li s4, TIMER0_BASE # s4 = timer base

        li s0, 0 # s0 = seconds (0..7)
        li s1, 0 # s1 = hundredths (0..99)
        li s5, 1 # s5 = run flag (1=running)

        li t0, 0xF # clear KEY edges
        sw t0, 0(s3)

        # initialize timer for 0.01 s period
        li t0, TMR_001S_LO # low 16 bits
        sw t0, TMR_START_LO_OFF(s4) 
        li t0, TMR_001S_HI # high 16 bits
        sw t0, TMR_START_HI_OFF(s4)
        li t0, TMR_CTRL_START_CONT # START=1, CONT=1
        sw t0, TMR_CONTROL_OFF(s4)

        # show initial time 0:0000000
        slli t0, s0, 7 # seconds in bits 9..7
        or t0, t0, s1 # add hundredths in bits 6..0
        sw t0, 0(s2)

main_loop:
        call check_keys # a0=1 if any KEY edge
        bnez a0, toggle_run # toggle clock if pressed

after_toggle:
        call wait_for_timer # wait 0.01 s timeout

        beq s5, x0, update_leds_only # if stopped, don't advance

        # wrap from 7.99 to 0.00
        li t0, 7
        bne s0, t0, inc_hundredths # if seconds != 7
        li t0, 99
        bne s1, t0, inc_hundredths # if hundredths != 99
        li s0, 0 # seconds = 0
        li s1, 0 # hundredths = 0
        j update_leds

inc_hundredths:
        addi s1, s1, 1 # hundredths++
        li t0, 100
        blt s1, t0, update_leds # if <100, done
        li s1, 0 # hundredths -> 0
        addi s0, s0, 1 # seconds++

update_leds:
        slli t0, s0, 7 # seconds in bits 9..7
        or t0, t0, s1 # hundredths in bits 6..0
        sw t0, 0(s2)
        j main_loop

update_leds_only:
        j update_leds # redraw and loop

toggle_run:
        xori s5, s5, 1 # flip run flag
        j after_toggle

# wait_for_timer: wait for TO bit, then clear it
wait_for_timer:
        addi sp, sp, -4 # allocate stack
        sw ra, 0(sp) # save ra

wt_loop:
        lw t0, TMR_STATUS_OFF(s4) # read status
        andi t1, t0, 0x1 # TO bit
        beq t1, x0, wt_loop # wait for TO=1

        sw x0, TMR_STATUS_OFF(s4) # clear TO
        lw ra, 0(sp) # restore ra
        addi sp, sp, 4 # free stack
        ret # return

# check_keys: returns a0=1 if any KEY press edge, else 0
check_keys:
        addi sp, sp, -4 # allocate stack
        sw ra, 0(sp) # save ra

        lw t0, 0(s3) # read edge-capture
        beq t0, x0, no_edge # no KEY press

        sw t0, 0(s3) # clear those bits
        li a0, 1 # signal edge
        j ck_ret

no_edge:
        li a0, 0 # no edge

ck_ret:
        lw ra, 0(sp) # restore ra
        addi sp, sp, 4 # free stack
        ret # return
