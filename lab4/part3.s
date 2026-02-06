.global  _start
        # I/O base addresses
        .equ LEDR_BASE, 0xFF200000  # LED port base
        .equ KEY_EDGE_BASE, 0xFF20005C  # KEY edge-capture base

        # Timer 0 base and register offsets 
        .equ TIMER0_BASE, 0xFF202000  # hardware timer base 
        .equ TMR_STATUS_OFF, 0 # status register offset
        .equ TMR_CONTROL_OFF, 4 # control register offset
        .equ TMR_START_LO_OFF, 8 # counter start low
        .equ TMR_START_HI_OFF, 12 # counter start high
        .equ TMR_LOAD_LO_OFF, 16 # load low
        .equ TMR_LOAD_HI_OFF, 20 # load high

        # 0.25 s at 100 MHz = 25,000,000 = 0x017D7840 in hex
		# 25,000,000 is a 32 bit number, meaning we must split into two 16 bits numbers (to represent)
        .equ TMR_025S_LO, 0x7840 # low  16 bits
        .equ TMR_025S_HI, 0x017D # high 16 bits

        # Control bits: bit0=ITO, bit1=CONT, bit2=START, bit3=STOP
        .equ TMR_CTRL_START_CONT, 0x6 # START=1, CONT=1

_start:
		# using s registers as need to save across program for subroutine calls 
        li s2, LEDR_BASE # s2 <- LED address
        li s4, KEY_EDGE_BASE # s4 <- KEY edge address
        li s5, TIMER0_BASE # s5 <- timer base

		# initalize counter, display on LEDS, run flag to 1
        li s0, 0 # counter value
        sw s0, 0(s2) # show 0 on LEDs
        li s1, 1 # run flag

        li t0, 0xF # clear bits 3..0 (0xF = 0'b1111) 
        sw t0, 0(s4) # clear pending KEY edges

        # Initialize timer for 0.25 s periodic timeout
        li t0, TMR_025S_LO # low 16 bits
        sw t0, TMR_START_LO_OFF(s5) # start low
        sw t0, TMR_LOAD_LO_OFF(s5) # load low
        li t0, TMR_025S_HI # high 16 bits
        sw t0, TMR_START_HI_OFF(s5) # start high
        sw t0, TMR_LOAD_HI_OFF(s5) # load high

        li t0, TMR_CTRL_START_CONT # START=1, CONT=1
        sw t0, TMR_CONTROL_OFF(s5) # enable timer
main_loop:
        call check_keys # may toggle run flag
        call wait_for_timer # wait for timer TO 

        beq s1, x0, main_loop # if stopped, skip increment (POLLING HERE)

        addi s0, s0, 1 # counter++
        li t0, 256 # wrap at 256
        blt s0, t0, store_leds # if < 256 keep value
        li s0, 0 # else reset to p0

store_leds:
        sw s0, 0(s2) # update LEDs (store counter value inside of LEDS) 
        j main_loop # repeat

# Wait until timer sets TO bit, then clear TO
wait_for_timer:
        addi sp, sp, -4 # allocate stack
        sw ra, 0(sp) # save ra

wt_loop:
        lw t0, TMR_STATUS_OFF(s5) # read status
        andi t1, t0, 0x1 # isolate TO bit (for comparison in next line) 
        beq t1, x0, wt_loop # loop until TO == 1

        sw x0, TMR_STATUS_OFF(s5) # write 0 to clear TO
        lw ra, 0(sp) # restore ra
        addi sp, sp, 4 # free  
        ret # return

# Check KEY edge-capture; toggle run flag if any KEY pressed
check_keys:
        addi sp, sp, -4 # allocate stack
        sw ra, 0(sp)# save ra

        lw t0, 0(s4) # read KEY edge-capture
        beq t0, x0, ck_exit # no edges -> exit

        sw t0, 0(s4) # clear any set edge bits
        xori s1, s1, 1 # toggle run flag

ck_exit:
        lw ra, 0(sp) # restore ra
        addi sp, sp, 4 # free stack
        ret # return
