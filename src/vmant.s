#include "mainframe.h"

;;; **********************************************************************
;;;
;;; VMANT - View mantissa of X
;;;
;;; **********************************************************************

              .public VMANT

              .section BoostCode
              .name   "VMANT"
VMANT:        c=regn  X
              gosub   CHK_NO_S      ; check ALPHA DATA
              sethex
              c=regn  d
              m=c
              pt=     4             ; FIX 9
              lc      9
              lc      8
              regn=c  d
              c=regn  X
              c=0     x             ; get mantissa
              gosub   DSPCRG        ; display
              c=m                   ; restore display status
              regn=c  d
              st=1    8
              golong  MSG105        ; set message flag
