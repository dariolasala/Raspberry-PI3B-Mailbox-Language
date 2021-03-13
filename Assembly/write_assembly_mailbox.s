/* Function write_mailbox
 *
 * Target: Raspberry PI 3B+
 * Created by Dario La Sala on 28/02/19.
 *
 * Argument passed through STACK : ( msg_addr channel )
 * Mailbox 0
 */
STATUS_REG=0x3F00B898
WRITE_REG=0x3F00B8A0
MAIL_FULL=0x80000000    ; set if mail is full

.global _start

_start:
    bl check_status
    ldr r0,=WRITE_REG
    pop {r1, r2}        ; pop channel and msg_addr
    orr r1,r1,r2        ; add channel to msg_addr
    str r1,[r0]
    bx lr

check_status:
    ldr r0,=STATUS_REG
1:  ldr r1,[r0]         ; load on r1 the value of the status register
    tst r1,=MAIL_FULL   ; (r1 AND MAIL_FULL) and set condition flags
    bne 1b              ; if mail is full, return to label 1 before
    bx lr               ; return to _start
