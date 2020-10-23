#include "mainframe.h"
#include "mainframe_cx.h"
#include "OS4.h"
#include "boostInternals.h"

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
XXARCL:       nop
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


;;; **********************************************************************
;;;
;;; WORKFL - append active active filename to alpha register
;;;
;;; **********************************************************************

              .section BoostCode
              .public WORKFL
              .name   "WORKFL"
WORKFL:       gosub   ensure41CX
              s0=0
              gosub   FLSHAP        ; locate current file
              ?s0=1                 ; file found?
              golnc   FLNOFN        ; no -> "FL NOT FOUND"
              ldi     0x20          ; space
              acex                  ; A.X= space
              rcr     8             ; C.X= address of filename
              dadd=c
              c=data                ; C= filename
              pt=     1
10$:          ?a#c    wpt           ; trim off trailing spaces
              goc     20$
              c=0     wpt
              rcr     2
              goto    10$

20$:          bcex                  ; B=filename, right justified
              c=0
              dadd=c                ; select chip 0
              goto    40$

25$:          bcex
              pt=     1
30$:          rcr     -2
              ?c#0    wpt           ; found next character?
              gonc    30$           ; no
              pt=     0
              g=c                   ; G= next character
              pt=     1
              c=0     wpt
              bcex
              gosub   APNDNW
40$:          ?b#0                  ; done?
              goc     25$           ; no
              rtn                   ; yes


;;; **********************************************************************
;;;
;;; RENFL - rename a file
;;;
;;; **********************************************************************

              .section BoostCode2
              .public RENFL
              .name   "RENFL"
RENFL:        gosub   ensure41CX
              s0=1
              gosub   FLSHAP        ; locate named file
              ?s0=1                 ; file found?
              golnc   FLNOFN        ; no -> "FL NOT FOUND"
              ?s6=1                 ; comma seen?
              golnc   ERRDE         ; no, "DATA ERROR"
              gosub   ALNAM2        ; M= name after comma
              acex
              rcr     8
              dadd=c                ; select filename register
              c=m
              data=c
;;              golong  resetMyBank  ; new entry, use later
              switchBank 1          ; temporary
              rtn
