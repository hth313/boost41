#include "mainframe.i"
#include "OS4.h"
#include "lib41.h"

              .section BoostFAT
              .extern RAMED, COMPILE, APX, ASHFX, MKXYZ, `RTN?`
              .extern ARCLINT, SEED, RNDM, `2D6`, KILLBUF, `F/E`
              .extern `Y/N?`
              .extern N, I, PV, PMT, FV, TVM, TVMEXIT
              .extern myCAT
XROMno:       .equ    15

              .con    XROMno        ; XROM number
              .con    (FatEnd - FatStart) / 2 ; number of entry points
FatStart:
              .fat    Header        ; ROM header
              .fat    COMPILE
              .fat    RAMED
              .fat    APX
              .fat    ASHFX
              .fat    MKXYZ
              .fat    `RTN?`
              .fat    ARCLINT
;              .fat    SEED
;              .fat    RNDM
              .fat    `2D6`
;              .fat    KILLBUF
              .fat    `F/E`
              .fat    `Y/N?`
              .fat    `LUHN?`
              FAT     myCAT
              .fat    TVM
              FAT     TVMEXIT
              FAT     N
              FAT     I
              FAT     PV
              FAT     PMT
              FAT     FV
FatEnd:       .con    0,0


;;; ************************************************************
;;;
;;; ROM header.
;;;
;;; ************************************************************

              .section BoostCode

              .name   "-BOOST 1A"   ; The name of the module
Header:       rtn


#if 0
;;; ************************************************************
;;;
;;; KEYFC - Read the keycode and jump to the corresponding
;;;       handler using a jump table.  Similar to KEY-FC in
;;;       the TIME module.
;;; IN: Key down, A[1:0] holds table length minus 1
;;;     S12 1= Long jump within same 1K
;;;       0= Short jump to table after
;;;     Last entry in table must be 000
;;;
;;; OUT: C.X=0 For digit entry
;;;
;;; USED: A(X&M), C(X&M), S12
;;;
;;; ************************************************************

              .section BoostCode
              .public KEYFCN
KEYFCN:       s12=0                 ; normal KEYFC
KEYFC:        acex    x             ; get table length
              c=0     m
              rcr     11            ; adjust to address field
              a=c     m             ; keep in A.M
              c=keys                ; read key
              rcr     3
              a=c     x
              c=stk                 ; get table address
1$:           cxisa                 ; read next keycode from table
              c=c+1   m             ; point to next entry
              ?c#0    x             ; end of table?
              gonc    2$            ; yes
              ?a#c    x             ; no, equal to key down?
              goc     1$            ; no
              c=0     x             ; yes
2$:           c=c+a   m             ; point to address
              ?s12=1                ; long jump ?
              goc     3$            ; yes
              gotoc                 ; no
3$:           s12=0                 ; get rid of private flag
              golong  GOLONG+1      ; do longjmp
#endif




              .section BoostTable, rodata
              .align  4
;;; **********************************************************************
;;;
;;; Sparse keyboard definitions, the key here is the index it would be
;;; in a key table.
;;;
;;; **********************************************************************

              .public keyTable
keyTable:     .con    0             ; SIGMA+
              KeyEntry N
              .con    16            ; 1/X
              KeyEntry I
              .con    32            ; SQRT
              KeyEntry PV
              .con    48            ; LOG
              KeyEntry PMT
              .con    64            ; LN
              KeyEntry FV
              .con    31            ; PI
              KeyEntry TVMEXIT
              .con    0x100         ; end of table

              .section BoostTable, rodata
              .align  4
              .public  sysKeyTable
sysKeyTable:  .con    11            ; CAT key
              KeyEntry myCAT
              .con    0x100         ; end of table

;;; **********************************************************************
;;;
;;; Extension notifications we are listening to.
;;;
;;; **********************************************************************

              .section BoostTable, rodata
              .public extensionHandlers
              .extern catHandler
              .align  4
extensionHandlers:
              .con    ExtensionCAT
              .con    .low12 catHandler
              .con    0             ; the end
