#include "mainframe.h"
#include "OS4.h"

;;; **********************************************************************
;;;
;;; Generic two argument compare instructions.
;;;
;;; These are dual argument semi-merged instructions. For variants are
;;; provided: Equal, not-equal, less-than and less-than-or-equal.
;;; We can get away with having only these four as it is easy to swap
;;; the operands.
;;; No compares to zero (or other constant) are provided, but they can
;;; done by storing a constant in a data register, or taking advantage
;;; of that 0 might be in some stack register or in one of the synthetic
;;; direct access alpha registers if it is known to contain 0.
;;;
;;; **********************************************************************

              .section BoostCode, reorder
              .public EQ, NE, LT, LE
              .name   "="
EQ:           nop
              nop
              gosub   dualArgument
              .con    '?'
              rxq     fetchArguments
              ?a#c
              golc    SKP
              golong  NOSKP


              .name   "≠"
NE:           nop
              nop
              gosub   dualArgument
              .con    '?'
              rxq     fetchArguments
              ?a#c
              golc    NOSKP
              golong  SKP

              .section BoostCode, reorder
              .name   "<"
LT:           nop
              nop
              gosub   dualArgument
              .con    '?'
              rxq     fetchArguments ; save a sub level
              rxq     checkArguments
              ?a<c
              golc    NOSKP
              golong  SKP

              .section BoostCode, reorder
              .name   "<="
LE:           nop
              nop
              gosub   dualArgument
              .con    '?'
              rxq     fetchArguments ; save a sub level
              rxq     checkArguments
              ?a<c
              golc    SKP
              golong  NOSKP

;;; Macro to shift digits in a number around suitable for comparing
compareOrdering: .macro
              c=-c-1  s             ; negate signs
              c=-c-1  xs
              b=c
              rcr     -1            ; MMMMMMMMMMXXX-
              c=b     x             ; MMMMMMMMMM-XXX
              rcr     4             ; -XXXMMMMMMMMMM
              c=b     s             ; SXXXMMMMMMMMMM
              .endm

checkArguments:
              c=c-1   s             ; check for alpha data
              goc     21$
              a=a-1   s
              goc     20$
              ?a#c    s
              gonc    10$           ; they are the same
              ?a#0    s             ; different, is it mixed alpha/numeric?
40$:          golnc   ERRDE         ; if yes, send to DATA ERROR
              ?c#0    s
              gonc    40$

20$:          a=a+1   s             ; restore signs
21$:          c=c+1   s

              setdec
              compareOrdering
              acex
              compareOrdering
              acex
              sethex
              rtn

10$:          ?a#0    s             ; both alpha data?
              goc     20$           ; no
              rtn                   ; yes


fetchArguments:
              acex
              pt=     2
              g=c                   ; G= first argument
              st=c                  ; ST= second argument
              gosub   ADRFCH
              a=c
              c=0
              dadd=c
              acex
              regn=c  Q
              pt=     0
              c=g
              st=c
              gosub   ADRFCH
              a=c
              c=0
              dadd=c
              c=regn  Q
              rtn
