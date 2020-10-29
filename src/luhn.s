#include "mainframe.h"
#include "boostInternals.h"

;;; **********************************************************************
;;;
;;; LUHN? - the Luhn algorithm as used by credit card numbers
;;;
;;; IN: Y - upper part of the number as BCD encoded NNN
;;;     X - lower 14 digits of the number as BCD encoded NNN
;;;
;;; Out: In run mode, display YES or NO
;;;      In program, skip next line if checksum does not match
;;;
;;; This routine expects the number to be entered as BCD digits into
;;; Y and X. 14 digits fit into a register, so any digits above need
;;; to go to Y.
;;;
;;; Entering a number can be done in Alpha register and use CODE,
;;; or use Ladybug module. Set word size to 56 and hex mode, then
;;; just entered the BCD digits:
;;;     WSIZE 56
;;;     HEX
;;;     343232_ H
;;;     LUHN?
;;;
;;; Reference: https://en.wikipedia.org/wiki/Luhn_algorithm
;;;
;;; **********************************************************************

              .public `LUHN?`

              .section BoostCode2
              .name "LUHN?"
`LUHN?`:      c=regn  X
              setdec
              s7=1                  ; doing X
              a=0                   ; clear sum
              pt=     0
              c=0     pt            ; ignore checksum digit

5$:           bcex                  ; B= digits
              c=0                   ; no double next time
10$:          bcex    pt            ; take next digit
              bsr
              ?c#0    s             ; double?
              gonc    15$           ; no
              c=c+c   x             ; yes
15$:          c=-c-1  s             ; toggle double flag
              a=a+c   x             ; add to sum
              csr     x             ; compensate for 10-digit
              c=-c    pt
              a=a-c   x
              ?b#0                  ; more digits?
              goc     10$           ; yes

              ?s7=1
              gonc    30$
              s7=0                  ; doing Y (also needed by SKP/NOSKP)
              c=regn  Y
              goto    5$

30$:          b=a                   ; multiply by 9
              asl
              a=a-b
              c=regn  X             ; get original input
              switchBank 1
              ?a#c    pt            ; checksum OK?
              golnc   NOSKP
              golong  SKP
