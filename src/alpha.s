#include "mainframe.h"
#include "OS4.h"
#include "boostInternals.h"

;;; **********************************************************************
;;;
;;; ARCLINT - append X to alpha as integer number
;;;
;;; **********************************************************************

              .public ARCLINT
              .section BoostCode

              .name   "ARCLINT"
ARCLINT:      nop
              nop
              gosub   argument
              .con    OperandX
              gosub   ADRFCH        ; fetch value first to take care of
              m=c                   ; an errors

              c=regn  14
              n=c                   ; N= flag register
              c=0                   ; FIX 0, CF 29
              pt=     3             ; (no alpha mode - return before ARGOUT)
              lc      8
              regn=c  14

              c=m
              a=c
              a=a-1   s             ; check alpha data
              a=a-1   s
              goc     10$
              s5=1
              gosub   INTFRC        ; get integer part
10$:          bcex
              gosub   XARCL         ; append to alpha
              c=n                   ; restore flag register
              regn=c  14
              golong  NFRPU

;;; **********************************************************************
;;;
;;; ATOXR - rightmost character from alpha register to X
;;;
;;; Similar to ATOX in Extended Functions, but takes the rightmost
;;; character and return its numeric code to X.
;;;
;;; **********************************************************************

              .public ATOXR
              .section BoostCode

              .name   "ATOXR"
ATOXR:        c=regn  M
              c=0     xs
              bcex                  ; B.X= rightmost char
              c=regn  M             ; shift alpha register 1 char right
              pt=     1
              a=c
              c=regn  N
              acex    wpt
              acex
              rcr     2
              regn=c  M
              c=regn  O
              acex    wpt
              acex
              rcr     2
              regn=c  N
              c=regn  P
              acex    wpt
              acex
              rcr     2
              regn=c  O
              c=regn  P
              rcr     6
              c=0     wpt
              rcr     10
              regn=c  P
              abex                  ; A.X= rightmost char
              golp    AXtoX

;;; **********************************************************************
;;;
;;; XTOAL  - take character code from X and prepend to alpha register
;;;
;;; If alpha is full, this will shift alpha one position to the right.
;;;
;;; **********************************************************************

              .public XTOAL

              .section BoostCode
              .name   "XTOAL"
XTOAL:        gsbp    `getX<256`
              m=c                   ; M= character
              pt=     3             ; set up first address
              lc      6             ; for alpha   0x6008
              LDI     8
              a=c                   ; A= address
              ldi     24            ; C.X= max alpha length
              n=c
              pt=     3
              s0=0
10$:          c=n
              c=c-1   x
              goc     20$           ; alpha empty!!
              n=c
              gosub   NXBYTA        ; get next char
              c=0     xs
              ?c#0    x             ; null?
              goc     15$           ; no, leave loop
              s0=1                  ; yes, alpha not full
              goto    10$
15$:          ?s0=1
              gsubc   DECADA

;;; A[3:0] points to where we will PUT THE NEW CHARACTER.
              ?s0=1                 ; alpha full?
              goc     20$           ; no

;;; Alpha register is full, address to first position in alpha is in A[3:0]
;;; and M[1:0] contains the character to be inserted at the left end.
;;; Now shift alpha right one position.
              b=a                   ; save A
              ?s13=1
              gosub   TONE7X        ; give warning if not running
              abex                  ; restore A
              c=regn  P             ; shift alpha right
              pt=     1
              bcex    wpt
              rcr     2
              regn=c  P
              c=regn  O
              bcex    wpt
              rcr     2
              regn=c  O
              c=regn  N
              bcex    wpt
              rcr     2
              regn=c  N
              c=regn  M
              bcex    wpt
              rcr     2
              regn=c  M
              pt=     3
20$:          c=m
              golong  PTBYTA        ; store new character
