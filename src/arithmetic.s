#include "mainframe.h"
#include "OS4.h"
#include "boostInternals.h"

;;; **********************************************************************
;;;
;;; INC - increment value in register
;;; DEC - decrement value in register
;;;
;;; This function add or subtract one from the specified registers, stack
;;; lift is enabled, but L register is not affected (as
;;;
;;; **********************************************************************

              .public increment, decrement
              .section BoostCode

              .name   "INC"
increment:    nop
              nop
              gosub   argument
              .con    OperandX
              gosub   ADRFCH
              s8=1
              goto    incdec

              .name   "DEC"
decrement:    nop
              nop
              gosub   argument
              .con    OperandX
              gosub   ADRFCH
              s8=0
incdec:       gosub   CHK_NO_S      ; check that it is a number
              a=c
              c=0
              ?s8=1
              goc     10$
              c=c-1   s             ; make negative
10$:          pt=     12
              lc      1             ; load "1"
              gosub   AD2_10
              sethex
              cnex
              dadd=c
              cnex
              data=c
              rtn
