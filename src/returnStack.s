#include "mainframe.h"

;;; **********************************************************************
;;;
;;; XEQ>GTO - kill first return address (convert XEQ to GTO)
;;;
;;; **********************************************************************

              .public `XEQ>GTO`
              .section BoostCode
              .name   "XEQ>GTO"
`XEQ>GTO`:    c=regn  a
              pt=     3
              a=c     wpt
              c=0     wpt
              rcr     4
              regn=c  a
              c=regn  b
              acex    wpt
              rcr     4
              acex    wpt
              regn=c  b
              rtn


;;; **********************************************************************
;;;
;;; PC<>RTN - swap PC and first return address.
;;;
;;; **********************************************************************

              .public `PC<>RTN`
              .section BoostCode
              .name   "PC<>RTN"
`PC<>RTN`:    c=regn  b             ; check whether return exists
              rcr     4
              ?c#0    x
              rtnnc                 ; no rtn
              bcex                  ; B[13:10]= PC
              gosub   XRTN
              pt=     3
              c=b
              rcr     10
              a=c     wpt
              ?s10=1                ; rom?
              goc     1$            ; yes
              c=c+c   pt            ; no, pack ram address
              c=0     x
              csr     wpt
              a=a+c   x
              a=0     pt
1$:           c=regn  b             ; push stack
              acex    wpt
              rcr     10
              acex    wpt
              regn=c  b
              c=regn  a
              rcr     10
              acex    wpt
              regn=c  a
              rtn


;;; **********************************************************************
;;;
;;; RTN? - test if inside a subroutine (have pending returns)
;;;
;;; **********************************************************************

              .public `RTN?`
              .section BoostCode
              .name   "RTN?"
`RTN?`:       c=regn  b
              rcr     4
              pt=     3
              s7=0
              ?c#0    wpt
              golc    NOSKP
              golong  SKP


;;; **********************************************************************
;;;
;;; GE - go to end of program memory
;;;
;;; **********************************************************************

              .public GE
              .section BoostCode
              .name   "GE"
GE:           nop                   ; non-programmable
              c=regn  c             ; get .END. pointer
              c=0     m
              pt=     3
              lc      3
              s10=0                 ; we are in RAM now
              s13=1                 ; execute .END.
              regn=c  b
              rtn
