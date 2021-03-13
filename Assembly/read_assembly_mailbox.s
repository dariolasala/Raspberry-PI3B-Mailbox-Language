/* Function read_mailbox
 *
 * Target: Raspberry PI 3B+
 * Created by Dario La Sala on 28/02/19.
 *
 * Argument passed through STACK : ( channel )
 * Mailbox 0
 */
STATUS_REG=0x3F00B898
READ_REG=0x3F00B880
MAIL_EMPTY=0x40000000    ; set if mail is empty

.global _start

_start:
    bl check_status
    ldr r0,=READ_REG
    ldr r0,[r0]         ; load on r0 the value of the read register
    bl check_channel
    bne end
    and r0,r0,#0xFFFFFFF0
    push {r0}
end:
    bx lr

check_status:
    ldr r0,=STATUS_REG
1:  ldr r1,[r0]         ; load on r1 the value of the status register
    tst r1,=MAIL_EMPTY  ; (r1 AND MAIL_EMPTY) and set condition flags
    bne 1b              ; if mail is full, return to label 1 before
    bx lr               ; return to _start

check_channel:
    pop {r1}            ; pop the channel
    and r2,r0,#0xF      ; get channel from the value of read register
    cmp r1,r2           ; set condition flags
    bx lr
