#include "mainframe.h"
#include "OS4.h"

;;; **********************************************************************
;;;
;;; DECODE - decode X into hex number and append to ALPHA
;;;
;;; This is the well known conversion routine that shows you what the
;;; contents of X really is, no matter if it is a floating point value
;;; NNN or what.
;;;
;;; **********************************************************************

              .public DECODE
              .section BoostCode2
              .name   "DECODE"
DECODE:       st=1?   13            ; clear ALPHA if called from keyboard
              gsubnc  CLA
              c=regn  X
              m=c
              ldi     13            ; counter
              bcex    x
1$:           pt=     0             ; loop start
              c=m                   ; get next digit
              rcr     13
              m=c
              rcr     1             ; digit to s
              ldi     3             ; 0x30-0x3f
              rcr     13            ; to C[2:0]
              acex    x
              ldi     0x3a
              ?a<c    x             ; 0-9?
              goc     2$            ; yes
              ldi     7             ; no, A-F, adjust value
              a=a+c   x
2$:           acex    x
              g=c                   ; ASCII to g (for append)
              gosub   APPEND        ; append character to ALPHA
              abex    x             ; decrement counter
              a=a-1   x
              gsubc   resetMyBank   ; done
              abex    x
              goto    1$
