#include "mainframe.h"
#include "OS4.h"

;;; **********************************************************************
;;;
;;; CTRST - Set contrast by value in X, for Halfnut displays
;;;
;;; **********************************************************************

              .public CTRST, `CTRST?`
              .section BoostCode
              .name   "CTRST"
CTRST:        c=regn  x
              gosub   BCDBIN
              a=c     x
              ldi     0x10
              dadd=c
              pfad=c
              acex    x
              regn=c  m
              golong  ENCP00

;************************************************************
; CTRST? - Recall contrast of LCD, for Halfnut displays
;************************************************************

              .name   "CTRST?"
`CTRST?`:     ldi     0x10
              dadd=c
              pfad=c
              c=regn  m
              acex     x
              gosub   ENCP00
              goto    toCXtoX

;************************************************************
; AVAIL - Gives number of free registers
;************************************************************

              .public AVAILMEM
              .name   "AVAIL"
AVAILMEM:     gosub   MEMLFT     ; Fetch # of free regs
              acex
toCXtoX:      acex
              golong  CXtoX

;************************************************************
; RTNS - Gives number of pending return address levels.
;************************************************************

              .name   "RTNS"
              .public RTNS
RTNS:         c=regn  a
              bcex
              pt=     3
              c=regn  b
              c=0     wpt           ; erase PC
              bcex    x             ; C[1:0]= part of third return
              bcex    xs            ; B[1:0]= 0

              a=0     x             ; clear counter

10$:          rcr     4             ; C[3:0]= next pending return
              ?c#0    wpt           ; one more pending return?
              gonc    toCXtoX       ; no
              a=a+1   x             ; yes, increment counter
              c=0     wpt           ; reset this one
              ?c#0                  ; any more in this register?
              goc     10$           ; yes, keep going
              bcex                  ; B=0, C=second register of returns
              rcr     -2
              goto    10$           ; take care of second return register

;;; **********************************************************************
;;; * getX<256 - routine to get int(X) and check if int(X) < 256
;;; *   input  : chip 0 enable
;;; *              if int(X) >= 256 will exit to "DATA ERROR"
;;; *              if X has a string, will say "ALPHA DATA"
;;; * getX<999 - get int(X) and check if int(X) < 1000
;;; *   input  : chip 0 enable
;;; *   output : A.X = C.X = int(decimal number)
;;; *   used  A, B.X, C, S8    +2 sub levels
;;;
;;; This code is taken from Extended Functions

              .public `getX<256`, `getX<999`, `getA<999`
              .section BoostCode

`getX<999`:   c=regn  X
              a=c
`getA<999`:   ldi     1000
              goto    INT10
`getX<256`:   c=regn  X
              a=c
              ldi     256
INT10:        bcex    x
              acex
              gosub   CHK_NO_S      ; see if it is a number
              sethex
              a=c
              ?a#0    xs            ; is the number < 1 ?
              goc     INT20         ; yes, its integer is zero anyway
              ldi     3
              ?a<c    x             ; is the number < 1000 ?
INTER:        golnc   ERRDE         ; no, say "DATA ERROR"
              acex
INT20:        gosub   BCDBIN        ; convert the number to binary
              a=c     x             ; A.X = the binary of the number
              ?a<b    x             ; is the number too big ?
              gonc    INTER
              rtn
