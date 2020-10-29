#include "mainframe.h"
#include "boostInternals.h"

;;; **********************************************************************
;;;
;;; APX  - append to value in X
;;;
;;; This works somewhat like the alpha append facility, but on a number
;;; in X. It takes the number in X and feeds it into the digit entry
;;; mechanism so that it is in the entry buffer, then tells the system
;;; that we are still doing numeric entry.
;;; It can be used quite naturally if assigned to the same place as alpha
;;; append, making it appear on the corresponding place on the user keyboard.
;;;
;;; Works from a program too! But you need to use STOP or PSE in order to
;;; let the user append to the number.
;;; If stopped from a program with ALPHA on, acts as alpha append instead.
;;;
;;; It favors editing of mantissas. Having very large or small number will
;;; attempt to bring the number into what can be shown without an exponent.
;;; Well behaved numbers are displayed with proper sign and decimal point
;;; handling.
;;;
;;; **********************************************************************

              .public APX
              .section BoostCode2

              .name   "APX"
APX:          c=regn  14            ; check if alpha mode
              st=c
              ?s7=1                 ; alpha mode?
              goc     300$          ; yes

              c=0                   ; initialize REG.9 for DIGENT
              c=c-1
              c=0     xs
              pt=     13
              lc      10            ; initial D.P. position
              regn=c  9
              gosub   STBT10        ; copy status bits for DIGENT
              ldi     9
              a=c     x
              c=regn  X
              switchBank 1
              gosub   CHK_NO_S      ; check ALPHA DATA
              switchBank 2
              sethex
              s9=0                  ; not looking for mantissa 0
              ?c#0    xs            ; negative exponent?
              goc     10$           ; yes
              ?a<c    x             ; check for large exponent
              gonc    10$           ; no
              s9=1                  ; remember large exponent
10$:          bcex    x             ; B.X= exponent
              bcex    m             ; B.M= mantissa
              ?c#0    s             ; negative?
              gonc    12$           ; no
              ldi     28            ; fcn code for minus sign
              s8=1
11$:          pt=     0
              g=c
              gosub   DIGENT
12$:          ?s9=1                 ; have emitted fractional separator?
              goc     20$           ; yes
              ?b#0    xs            ; fractional number?
              gonc    22$           ; no

              c=b                   ; yes, align fractional mantissa
              setdec
              pt=     4
15$:          c=c+1   x
              ?c#0    xs
              gonc    16$
              ?c#0    pt            ; valid digit about to be shifted to last pos?
              goc     16$           ; yes, stop here
              csr     m
              goto    15$

300$:         goto    30$           ; relay

16$:          ldi     12            ; set large exponent counter
              bcex
              sethex
              goto    27$           ; emit fractional separator

20$:          ?s9=1                 ; looking for mantissa = 0?
              gonc    22$           ; no
21$:          ?b#0    m             ; mantissa = 0?
              gonc    40$           ; yes, we are done

22$:          abex    m             ; emit next digit
              a=0     x
              asl
              abex    m
              c=0     x
              c=c+1   x
              acex    s
              rcr     -1
              pt=     0
              g=c
              gosub   DIGENT
              gosub   NOREG9        ; normalize and move to X
              bcex    x             ; decrement exponent
              c=c-1   x
              ?c#0    xs            ; negative (hit fractional part?)
              goc     25$           ; yes
              bcex    x             ; no
              goto    20$

25$:          ?b#0    m             ; zero fractional part?
              gonc    40$           ; yes
27$:          s9=1                  ; in fractional part
              ldi     26            ; no, insert a decimal point
              goto    11$

30$:          s8=1                  ; no scroll and prompt
              gosub   ARGOUT        ; append to alpha register

40$:          c=regn  14            ; exit routine
              rcr     2
              cstex
              s2=1                  ; set data entry
              cstex
              rcr     -2
              st=c
              s5=1                  ; set message flag
              c=st
              regn=c  14
              switchBank 1
              ?s7=1                 ; alpha mode?
              rtnc                  ; yes
              gosub   RG9LCD        ; construct digit entry display
              golong  RFDS55        ; send it to LCD
