#include "mainframe.h"
#include "OS4.h"

              .section DelayShell, rodata
              .align  4
delayShell:   .con    TransAppShell
              .con    0                 ; no display handler defined
              .con    .low12 delayKeypress ; standard keys
              .con    .low12 delayKeypress ; user keys
              .con    .low12 delayKeypress ; alpha keys, use default
              .con    .low12 delayName
              .con    .low12 delayEnd      ; timeout handler

              .section BoostCode1
              .align  4
delayName:    .messl  "DELAY"

              .section KeyInputShell, rodata
              .align  4
keyInputShell:
              .con    TransAppShell
              .con    0                 ; no display handler defined
              .con    .low12 keycodeEntered ; standard keys
              .con    .low12 keycodeEntered ; user keys
              .con    .low12 keycodeEntered ; alpha keys, use default
              .con    .low12 keycodeName
              .con    .low12 noKeycodeEntered ; timeout handler

              .section BoostCode1
              .align  4
keycodeName:  .messl  "KEY?"

              .section BoostCode1
              .align  4
delayKeypress:
              gosub   clearTimeout
              gosub   RSTKB         ; reset key board and ignore key
              goto    delayEnd
              .align   4
delayEnd:     gosub   exitTransientApp
              s13=1                 ; continue executing
              golong  NFRC

              .section BoostCode1
              .align  4
keycodeEntered:
              gosub   clearTimeout
              gosub   exitTransientApp
              c=keys
              rcr     3
              c=0     xs            ; C.X= key code
              gosub   assignKeycode
              bcex                  ; B= floating point key code
              gosub   RSTKB         ; reset key board
runRCL:       s13=1                 ; continue executing
              golong  RCL           ; push keycode on stack

              .align  4
noKeycodeEntered:
              gosub   exitTransientApp
              b=0
              golong  RCL

;;; **********************************************************************
;;;
;;; DELAY - wait a given time and resume execution
;;;
;;; Delay program execution for given number of tenths of a second.
;;; If a key is pressed while waiting the key press causes early
;;; termination and execution resumes on key up.
;;; The key press is otherwise ignored.
;;;
;;; **********************************************************************

              .section BoostCode1
              .public DELAY
              .name   "DELAY"
DELAY:        nop
              nop
              gosub argument
              .con    25 + SEMI_MERGED_NO_STACK
              n=c                   ; N= argument
              ldi     .low12 delayShell
              goto     argTimeout

toNoRoom:     golong  noRoom

              .public KEY
              .name   "KEY"
KEY:          nop
              nop
              gosub   argument
              .con    25 + SEMI_MERGED_NO_STACK
              n=c
              ldi     .low12 keyInputShell

argTimeout:   ?s13=1                ; running?
              rtnnc                 ; no
              gosub   activateShell
              goto    toNoRoom
              gosub   ensureTimer
              c=n
              st=c
              ?s7=1                 ; indirect?
              gonc    20$           ; no
              s7=0
              gosub   ADRFCH        ; read register indirect
              gosub   CHK_NO_S      ; see if it is a number
              sethex
              a=c
              ?a#0    xs            ; is the number < 1 ?
              goc     toERRDE       ; yes, DATA ERROR
              ldi     4             ; is number < 10000?
              ?a<c    x
              gonc    toERRDE       ; no, say DATA ERROR
              c=0     x
              rcr     -2
10$:          rcr     -1
              a=a-1   x
              gonc    10$
15$:          pt=     4
              ?c#0    wpt
              gonc    toERRDE
              gosub   setTimeout
              nop                   ; (P+1) checked above that timer is present
                                    ;  just carry on if there is something
                                    ;  goes wrong
              s13=0                 ; stop execution
              rtn

20$:          c=0
              c=st
              pt=     0
              a=0     x
              a=c     pt            ; A[0]= low digit
              csr     x             ; C.X= high digit
              setdec
              c=c+1   x             ; convert to decimal
              c=c-1   x
              c=c+c   x             ; multiply by 16
              c=c+c   x
              c=c+c   x
              c=c+c   x
              a=a+1   x             ; convert low digit to decimal
              a=a-1   x
              c=a+c   x             ; add to result
              rcr     -1
              sethex
              goto    15$

toERRDE:      gosub   exitTransientApp
              golong  ERRDE
