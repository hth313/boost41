#include "mainframe.h"

;************************************************************
; AVAIL - Gives number of free registers
;************************************************************

              .public AVAILMEM
              .section BoostCode
              .name   "AVAIL"
AVAILMEM:     gosub   MEMLFT     ; Fetch # of free regs
              acex
              goto    AXtoX

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
              gonc    AXtoX         ; no
              a=a+1   x             ; yes, increment counter
              c=0     wpt           ; reset this one
              ?c#0                  ; any more in this register?
              goc     10$           ; yes, keep going
              bcex                  ; B=0, C=second register of returns
              rcr     -2
              goto    10$           ; take care of second return register

;;; **********************************************************************
;;;
;;; AXtoX - convert small binary number to floating point in X
;;;
;;; IN: A[2:0] - binary number
;;; OUT: X - floating point number
;;;
;;; **********************************************************************

;;; **********************************************************************
;;;
;;; AXtoX - convert A from binary integer to floating point number
;;; AtoXDrop - same as AtoX, but DROPST into X rather than RCL
;;; AtoXFill - same as AtoX, but FILLXL into X rather than RCL
;;;
;;; The converted binary number is saved in X. The 3 different main
;;; entry points correspond to push value (AtoX), update X after unary
;;; operation (AtoXFill) and update X after binary operation (AtoXDrop).
;;; The two latter also update L.
;;;
;;; IN: A - binary integer (all bits)
;;;     S0 -
;;; OUT: X - floating point number
;;; ASSUME: DADD 0 selected
;;;
;;; **********************************************************************

              .public AXtoX, AtoX, AtoX10, AtoXDrop, AtoXFill

AtoXDrop:     s0=0                  ; Use DROPST
              goto    AtoX10
AtoXFill:     s0=1                  ; Use FILLXL
              goto    AtoX05
AXtoX:        a=0     m
              a=0     s
AtoX:         s0=0                  ; RCL to X
AtoX05:       s1=0
AtoX10:       pt=     13            ; digit counter
              setdec
              acex
              m=c                   ; M= number to convert
              clrabc
              n=c                   ; N= 0

10$:          c=m                   ; loop start, get input
              a=0
              a=c     s             ; get next nibble from left side
              rcr     13
              m=c                   ; save input back for next iteration
              acex
              rcr     13            ; C[0]= current nibble
              acex                  ; A[0]= current nibble
              a=a+b                 ; add with zero to convert it to BCD
              c=n
              c=c+c                 ; multiply it with 16 (decimal mode)
              c=c+c
              c=c+c
              c=c+c
              c=c+a
              n=c                   ; N= accumulated mantissa so far
              ?pt=    0             ; have we visited all digits?
              goc     20$           ; yes
              decpt                 ; no
              goto     10$

; BCD mantissa is now in C and N
20$:          a=0     x             ; A.X= 0 (exponent)
              rcr     -3            ; C.M= right justified mantissa
              c=0     x
              c=0     s
              ?c#0    m             ; check for zero mantissa
              gonc    40$           ; zero mantissa
25$:          rcr     -1            ; left shift mantissa to left align it
              ?c#0    s             ; did we get a digit?
              goc     30$           ; yes
              a=a+1   x             ; no, increment exponent and loop over
              goto    25$
30$:          rcr     1             ; shift right one digit to get the
                                    ; final left justified mantissa in C
              acex    x             ; get exponent
              c=-c-1  pt            ; fix exponent
40$:          bcex                  ; move result to B for RCL/DROPST
              sethex                ; needed if we have a printer connected
              ?s1=1
              golc    DROPST
              ?s0=1
              golc    FILLXL
              golong  RCL

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
