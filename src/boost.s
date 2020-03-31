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
              .extern EQ, NE, LT, LE
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
              .fat    RNDM
              .fat    `2D6`
;              .fat    KILLBUF
              .fat    `F/E`
              .fat    `Y/N?`
              .fat    `LUHN?`
              FAT     myCAT
              FAT     myASN
              .fat    PAUSE
              .fat    EQ
;              .fat    XRCL
              .fat    XSTO
              .fat    XXVIEW
              .fat    XXARCL
              .fat    EXCHANGE
              .fat    EXITSH
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

              .section BoostFC2
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

              .section BoostSecondary1
              .extern CLKYSEC, readRom16, writeRom16
              .align  4
FAT1Start:    .fat    COMPILE
fatXEQ:       .fat    myXEQ
              .fat    CLKYSEC
              .fat    readRom16
              .fat    writeRom16
              .fat    SEED
              .fat    XRCL
              .fat    NE
              .fat    LT
              .fat    LE
FAT1End:


              .name "PAUSE"
PAUSE:        ?s13=1                ; running?
              rtnnc                 ; no
              gosub   activeApp
              goto    normalPSE     ; (P+1) no active application
              gosub   shellKeyboard
              cxisa
              ?c#0    x
              gonc    normalPSE     ; no keyboard override
              gosub   unpack
              c=c+1   m             ; step to clear digit entry handler
              c=c+1   m
              c=c+1   m
              c=c+1   m
              cxisa                 ; fetch handler address (packed)
              ?c#0    x             ; does it have digit entry?
              gonc    normalPSE     ; no
              c=b     x
              dadd=c                ; select buffer header
              c=data
              cstex
              st=1    Flag_Pause
              cstex
              data=c
              s13=0                 ; clear running flag
              rtn
normalPSE:    gosub   LDSST0
              golong  PSE

;;; **********************************************************************
;;;
;;; Generic register exchange
;;;
;;; Swap two register operands. This is very much like the X<> function,
;;; but takes two arbitrary postfix register operands.
;;;
;;; **********************************************************************

              .name   "<>"
EXCHANGE:     nop
              nop
              gosub   dualArgument
              .con    0
              acex
              pt=     2
              g=c                   ; save first argument in G
              st=c                  ; ST= second argument
              gosub   ADRFCH
              pt=     0
              c=g
              st=c                  ; ST= first argument
              c=n
              rcr     -3
              stk=c                 ; save register argument on stack
              gosub   ADRFCH
              a=c                   ; A= register contents
              c=stk
              rcr     3
              dadd=c                ; select second register
              c=data                ; read it
              acex
              data=c                ; write first value
              c=n
              dadd=c                ; select first register
              acex
              data=c                ; write second value
              rtn

;;; **********************************************************************
;;;
;;; Exit the current application shell
;;;
;;; If no active application or no system buffer exists, this function
;;; has no effect.
;;;
;;; **********************************************************************

              .name   "EXITSH"
EXITSH:       gosub   topShell
              goto    100$          ; (P+1) no buffer
              goto    100$          ; (P+2) no shells
              ?s9=1                 ; (P+3) application shell found?
              gonc    100$          ; no
              c=m                   ; get scan state
              ?c#0    s             ; shell desriptor in upper half?
              gonc    10$           ; no, lower
              pt=     13
10$:          c=data
              c=0     pt            ; deactivate shell
              data=c
100$:         golong  NFRC          ; done, neutral on stack lift

