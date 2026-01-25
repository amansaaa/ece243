.global _start
_start:
	
li t0, 1 /* t0 <- 1 */
li t1, 30 /* t1 <- 30 */
li s1, 0 /* s1 <- 0 */

myloop: add s1, s1, t0 /* s1 <- s1 + t0 , essentially s1 += t0 */
		addi t0, t0, 1 /* t0 <- t0 + 1 , essentially t0 += 1 */
		ble t0, t1, myloop /* if t0 <= t1, then myloop, else next line */

iloop: j iloop /* infinite loop, jump back to iloop label */