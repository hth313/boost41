#include "mainframe.h"
#include "OS4.h"


;;; **********************************************************************
;;;
;;; XRCL - RCL on a register in extended memory
;;;
;;; Prompting instruction to access a given register in the current
;;; data file in extended memory and behave as RCL on the value.
;;;
;;; **********************************************************************

              .section BoostCode
              .public  XRCL
              .name   "XRCL"
XRCL:         nop
              nop
              gosub   argument
              .con    00 + SEMI_MERGED_NO_STACK
              s8=0
              gosub   TONSTF
              gosub   getXAdr
              acex    x
              dadd=c
              c=data
              bcex
              golong  RCL           ; goes to NFRPR


;;; **********************************************************************
;;;
;;; XSTO - STO on a register in extended memory
;;;
;;; Prompting instruction to access a given register in the current
;;; data file in extended memory and behave as STO on the value.
;;;
;;; **********************************************************************

              .section BoostCode
              .public  XSTO
              .name   "XSTO"
XSTO:         nop
              nop
              gosub   argument
              .con    00 + SEMI_MERGED_NO_STACK
              s8=0
              gosub   TONSTF
              gosub   getXAdr
              c=0     x
              dadd=c
              c=regn  X
              acex    x
              dadd=c
              acex    x
              data=c
              golong  NFRPU         ; needed as we are XKD


;;; **********************************************************************
;;;
;;; XVIEW - VIEW on a register in extended memory
;;;
;;; Prompting instruction to access a given register in the current
;;; data file in extended memory and behave as VIEW on the value.
;;;
;;; **********************************************************************

              .section BoostCode
              .public  XXVIEW
              .name   "XVIEW"
XXVIEW:       nop
              nop
              gosub   argument
              .con    00 + SEMI_MERGED_NO_STACK
              s8=0
              gosub   TONSTF
              gosub   getXAdr
              acex    x
              dadd=c
              c=data
              bcex
              gosub   XVIEW
              golong  NFRPU         ; needed as we are XKD


;;; **********************************************************************
;;;
;;; XARCL - ARCL on a register in extended memory
;;;
;;; Prompting instruction to access a given register in the current
;;; data file in extended memory and behave as ARCL on the value.
;;;
;;; **********************************************************************

              .section BoostCode
              .public  XXARCL
              .name   "XARCL"
XXARCL:        nop
              nop
              gosub   argument
              .con    00 + SEMI_MERGED_NO_STACK
              s8=0
              gosub   TONSTF
              gosub   getXAdr
              acex    x
              dadd=c
              c=data
              bcex
              gosub   XARCL
              golong  NFRPU         ; needed as we are XKD
