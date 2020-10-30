#include "mainframe.h"
#include "OS4.h"
#include "boostInternals.h"

              .section BoostFAT
              .extern RAMED, COMPILE, APX
              .extern SEED, RNDM, `2D6`, KILLBUF, `F/E`
              .extern `Y/N?`, `LUHN?`, VMANT
              .extern XRCL, XSTO, XXVIEW, XXARCL, WORKFL, RENFL
              .extern myCAT, myASN, myXEQ
              .extern EQ, NE, LT, LE
              .extern DELAY, KEY
              .extern `XEQ>GTO`, `PC<>RTN`, `RTN?`, RTNS, GE, AVAILMEM
              .extern ARCLINT, ATOXR, XTOAL
XROMno:       .equ    6

              .con    XROMno        ; XROM number
              .con    (FatEnd - FatStart) / 2 ; number of entry points
FatStart:
              .fat    BoostHeader   ; ROM header
              .fat    Prefix2
              FAT     myCAT
              FAT     myASN
              .fat    PAUSE
              .fat    EQ
              .fat    NE
              .fat    LT
              .fat    LE
              .fat    XRCL
              .fat    XSTO
              .fat    XXVIEW
              .fat    XXARCL
              .fat    EXCHANGE
              .fat    EXITAPP
              .fat    DELAY
              .fat    KEY
              .fat    RNDM
              .fat    `2D6`
              .fat    WORKFL
; These are not fixed and can be considered preliminary
              .fat    ARCLINT
              .fat    ATOXR
              .fat    XTOAL
              .fat    `Y/N?`
FatEnd:       .con    0,0

;;; ************************************************************
;;;
;;; ROM header.
;;;
;;; ************************************************************

              .section BoostCode

              .name   "-BOOST 0B"   ; The name of the module
BoostHeader:  gosub   runSecondary  ; Must be first!
              .con    0             ; I am secondary prefix XROM 6,0
              ;; pops return address and never comes back

              .section BoostCode
              .name   "(BPFX2)"     ; short name for prefix function
Prefix2:      gosub   runSecondary  ; Must be first!
              .con    1             ; I am secondary prefix XROM 6,1
              ;; pops return address and never comes back

;;; **********************************************************************
;;;
;;; System shell sparse keyboard definition.
;;;
;;; **********************************************************************

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

xeqSecondary: .con    0      ; secondary
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

              .section ExtensionHandlers, rodata
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
;;; Secondary FATs
;;;
;;; **********************************************************************

              .section BoostFC2
              .con    .low12 secondary1 ; Root pointer for secondary FAT headers

;;; * First secondary FAT header, serving bank 1
              .section BoostSecondary1, reorder
              .align  4
secondary1:   .con    .low12 secondary2 ; pointer to next table
              .con    (FAT1End - FAT1Start) / 2
              .con    0             ; prefix XROM (XROM 6,0 - ROM header)
              .con    0             ; start index
              .con    .low12 FAT1Start
              rtn                   ; this one is in bank 1,
                                    ; no need to switch bank

              .section BoostSecondary1, reorder
              .extern CLKYSEC, readRom16, writeRom16
              .align  4
FAT1Start:    .fat    SEED
fatXEQ:       .fat    myXEQ
              .fat    CLKYSEC
              .fat    readRom16
              .fat    writeRom16
              .fat    `XEQ>GTO`
              .fat    `PC<>RTN`
              .fat    `RTN?`
              .fat    `RTNS`
              .fat    GE
              .fat    VMANT
              .fat    `F/E`
              .fat    AVAILMEM
FAT1End:      .con    0,0

;;; * Second secondary FAT header, serving bank 2

              .section BoostSecondary1, reorder
              .align  4
secondary2:   .con    0             ; no next table
              .con    (FAT2End - FAT2Start) / 2
              .con    1             ; prefix XROM (XROM 6,1 - (BPFX2))
              .con    256           ; start index
              .con    .low12 FAT2Start
              switchBank 2          ; this one is in bank 2
              rtn

              .section BoostSecondary2
              .align  4
FAT2Start:    .fat    COMPILE
              .fat    RAMED
              .fat    RENFL
              .fat    `LUHN?`
              .fat    APX
FAT2End:      .con    0,0

;;; **********************************************************************
;;;
;;; Pause function that works with OS4 shells
;;;
;;; **********************************************************************

              .section BoostCode1
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

              .name   "EXITAPP"
EXITAPP:      golong  exitApp

;;; **********************************************************************
;;;
;;; Header for bank 2, just make it look empty in case the bank is
;;; left enabled.
;;;
;;; **********************************************************************

              .section BoostHeader2
              nop
              nop

;;; ----------------------------------------------------------------------
;;;
;;; Bank switchers allow external code to turn on specific banks.
;;;
;;; ----------------------------------------------------------------------

BankSwitchers: .macro
              rtn                   ; not using bank 3
              rtn
              rtn                   ; not using bank 4
              rtn
              enrom1
              rtn
              enrom2
              rtn
              .endm

              .section BoostBankSwitchers1
             BankSwitchers

              .section BoostBankSwitchers2
             BankSwitchers

;;; ----------------------------------------------------------------------
;;;
;;; This NOP placed on address XCDD will allow the module to be used
;;; in page 7.
;;;
;;; 7CDD is the address that is called to see if there is an HPIL
;;; module in place.
;;;
;;; This is how Extended Function/HP41CX checks it, so it is assumed
;;; it is the way to do it. By putting a NOP there, the probe call will
;;; return and it will seem as the is no HP-IL module in place in the
;;; case we are compiled to page 7.
;;;
;;; ----------------------------------------------------------------------

              .section BoostLegal7
              nop
