#include "mainframe.i"
#include "OS4.h"
#include "lib41.h"

              .section BoostFAT
              .extern RAMED, COMPILE, APX, ASHFX, MKXYZ, `RTN?`
              .extern ARCLINT, SEED, RNDM, `2D6`, KILLBUF, `F/E`
              .extern `Y/N?`
              .extern XRCL, XSTO, XXVIEW, XXARCL
              .extern N, I, PV, PMT, FV, TVM, TVMEXIT
              .extern myCAT, myASN
XROMno:       .equ    6

              .con    XROMno        ; XROM number
              .con    (FatEnd - FatStart) / 2 ; number of entry points
FatStart:
              .fat    Header        ; ROM header
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
              FAT     myASN
              .fat    XRCL
              .fat    XSTO
              .fat    XXVIEW
              .fat    XXARCL
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




;;; **********************************************************************
;;;
;;; TVM sparse keyboard definition.
;;;
;;; **********************************************************************

              .section BoostTable, rodata
              .align  4
              .public keyTableTVM
keyTableTVM:  .con    0             ; SIGMA+
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
              .con    26            ; ASN key
              KeyEntry myASN
              .con    0x100         ; end of table

;;; **********************************************************************
;;;
;;; CAT 07 sparse keyboard definition.
;;;
;;; **********************************************************************

              .section BoostTable, rodata
              .align  4
              .public keyTableCAT7
keyTableCAT7: .con    40            ; SQRT
              .con    KeyXKD
              .con    66            ; SST
              .con    KeyXKD
              .con    74            ; BST
              .con    KeyXKD
              .con    67            ; <-
              .con    KeyXKD
              .con    55            ; R/S
              .con    KeyXKD
              .con    2             ; Shift
              .con    0x30e
              .con    10            ; Shifted shift
              .con    0x30e
              .con    70            ; User
              .con    0x30c
              .con    78            ; Shifted user
              .con    0x30c
              .con    0x100         ; end of table

              ;; The XKD pointers
              .extern CAT7_Clear, CAT7_SST, CAT7_BST, CAT7_BACKARROW, CAT7_RUN
              .con    .low12 CAT7_Clear
              .con    .low12 CAT7_SST
              .con    .low12 CAT7_BST
              .con    .low12 CAT7_BACKARROW
              .con    .low12 CAT7_RUN


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
              .con    GenericExtension
              .con    ExtensionCAT
              .con    .low12 catHandler
              .con    ExtensionListEnd


;;; **********************************************************************
;;;
;;; Secondary FAT
;;;
;;; **********************************************************************

              .section BoostFC6
              .con    .low12 secondary1 ; Root pointer for secondary FAT headers

              .section BoostSecondary ; First secondary FAT header
              .align  4
secondary1:   .con    0             ; pointer to next table
              .con    (FAT1End - FAT1Start) / 2
              .con    0             ; TBD
              .con    0             ; start index
              .con    .low12 FAT1Start
              enrom1                ; This one is in bank 1
              rtn

              .section BoostSecondary
              .align  4
FAT1Start:    .fat    COMPILE
FAT1End:
