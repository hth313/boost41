#include "mainframe.h"
#include "OS4.h"
#include "lib41.h"

              .section BoostFAT
              .extern RAMED, COMPILE, APX, ASHFX, MKXYZ, `RTN?`
              .extern ARCLINT, SEED, RNDM, `2D6`, KILLBUF, `F/E`
              .extern `Y/N?`
              .extern XRCL, XSTO, XXVIEW, XXARCL
              .extern N, I, PV, PMT, FV, TVM, TVMEXIT
              .extern myCAT, myASN, myXEQ
XROMno:       .equ    6

              .con    XROMno        ; XROM number
              .con    (FatEnd - FatStart) / 2 ; number of entry points
FatStart:
              .fat    BoostHeader   ; ROM header
              .fat    RAMED
              .fat    APX
              .fat    ASHFX
;              .fat    MKXYZ
              .fat    `RTN?`
              .fat    ARCLINT
              .fat    SEED
              .fat    RNDM
              .fat    `2D6`
;              .fat    KILLBUF
              .fat    `F/E`
              .fat    `Y/N?`
              .fat    `LUHN?`
              FAT     myCAT
              FAT     myASN
;              .fat    XRCL
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
BoostHeader:  gosub   runSecondary  ; Must be first!
              .con    0             ; I am secondary prefix XROM 6,0
              ;; pops return address and never comes back

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
              .con    18            ; XEQ key
              .con    64 + xeqSecondary - .
              .con    26            ; ASN key
              KeyEntry myASN
              .con    0x100         ; end of table

xeqSecondary: .con    0             ; secondary
              .con    (fatXEQ - FAT1Start) >> 1

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
              .con    0             ; prefix XROM (XROM 6,0 - ROM header)
              .con    0             ; start index
              .con    .low12 FAT1Start
              enrom1                ; This one is in bank 1
              rtn

              .section BoostSecondary
              .extern CLKYSEC, readRom16, writeRom16
              .align  4
FAT1Start:    .fat    COMPILE
fatXEQ:       .fat    myXEQ
              .fat    CLKYSEC
              .fat    readRom16
              .fat    writeRom16
              .fat    XRCL
FAT1End:
