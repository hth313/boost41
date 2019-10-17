#include "mainframe.i"
#include "OS4.h"

              .section BoostTable, rodata
              .align  4
              .public catShell
catShell:     .con    SysShell
              .con    0             ; no display handler defined
              .con    .low12 keyHandler ; standard keys
              .con    .low12 keyHandler ; user keys
              .con    0                 ; alpha keys, use default
              .con    .low12 catName

              .section BoostCode
              .align  4
keyHandler:   gosub   keyKeyboard   ; does not return
              .con    .low12 sysKeyboard ; argument to keyKeyboard

              .section BoostCode
              .extern sysKeyTable
              .align  4
sysKeyboard:  .con    (1 << KeyFlagSparseTable) ; flags
              .con    0             ; handle a digit
              .con    0             ; end digit entry
              .con    .low12 sysKeyTable

;;; Name of the shell
              .section BoostCode
              .align  4
catName:      .messl  "CAT"

;;; Handler of catalogs
              .section BoostCode
              .public catHandler
              .align  4
catHandler:   c=n
              ?c#0    x             ; CAT 0?
              gonc    0$            ; yes
              a=c     x
              ldi     7
              ?a#c    x
              rtnc                  ;  not one of mine
              rgo     CAT7
0$:           rtn


;;; **********************************************************************
;;;
;;; CAT - A catalog replacement.
;;;
;;; Provide a 2-digit prompt and use the extension notification mechanism
;;; in OS4 to let any plug-in dynamically handle the catalog.
;;;
;;; **********************************************************************

              .section BoostCode
              .public myCAT
              .con    0x94          ; T
              .con    0x201         ; A
              .con    0x203         ; C 2-digit prompt
myCAT:        nop                   ; non-programmable
              acex    x
              st=c
              ?s7=1                 ; indirect?
              gonc    10$           ; no
              gosub   ADRFCH        ; get reg
              gosub   BCDBIN        ; convert to binary
              st=c
10$:          c=0
              c=st
              n=c                   ; N.X= catalog number
              ldi     ExtensionCAT
              gosub   extensionHandler
              gosub   ENCP00        ; no takers
              c=n
              st=c
              golong  XCAT+4


;;; **********************************************************************
;;;
;;; CAT7 - buffer catalog extension
;;;
;;; Displays buffers as: AA LLL BBB
;;;   where
;;;      AA - buffer number (decimal)
;;;      LLL - buffer length (decimal)
;;;      BBB - register address of header
;;;
;;; **********************************************************************

              .section BoostCode
CAT7:         spopnd                ; drop return addresses
              spopnd
              s8=1                  ; set running flag
              c=0     s             ; start with buffer 0
CAT7main:     m=c                   ; main loop
              c=0     x
              rcr     -1
              gosub   chkbuf
              goto    CAT7step      ; (P+1) not found, try step to next
CAT7found:    c=data                ; (P+2) this one exists, read header
              acex    x             ; C.X= buffer address
              n=c                   ; N= buffer header and address
              gosub   CLLCDE
              c=n
              c=0     s
              rcr     12
              c=0     xs            ; C.X= buffer number
              pt=     13
              lc      2             ; 2 digits
              a=c
              gosub   GENNUM        ; output buffer number
              ldi     ' '
              slsabc
              c=n                   ; register count
              rcr     10
              c=0     xs
              pt=     13
              lc      3             ; Use 3 digits here
              a=c
              gosub   GENNUM
              ldi     ' '
              slsabc
              slsabc
              c=0     x             ; @ address, also 3 decimal digits
              slsabc
              c=n
              pt=     13
              lc      3
              a=c
              gosub   GENNUM
              readen
              st=c                  ; ST= annunciators

CAT7delay:    c=0     x             ; delay counter
CAT7loop:     chkkb
              goc     CAT7key       ; some key went down
              c=c+1   x
              gonc    CAT7loop

              ?s8=1                 ; timed out
              gonc    CAT7delay     ; not running, loop again
                                    ; running, step to next entry
CAT7step:     gosub   ENCP00
              c=m                   ; step to next buffer
              c=c+1   s
              goc     CATend
              goto    CAT7main

CAT7found0:   goto    CAT7found     ; relay
CATend:       golong  CLDSP

CAT7SST:      ?s7=1                 ; shift?
CAT7step0:    gonc    CAT7step      ; no, SST (also used as relay)
              gosub   ENCP00        ; yes, BST
10$:          c=m                   ; search backwards
              c=c-1   s
              goc     CAT7blink     ; no previous buffer
              m=c
              c=0     x
              rcr     -1
              gosub   chkbuf
              goto    10$           ; (P+1) no such buffer
              goto    CAT7found0    ; (P+2) this one exists

CAT7key:      n=c                   ; save delay counter
              ldi     6
              gosub   keyDispatch
              .con    0x18,0x87,0xc3,0xc2,0x70,0x12,0
;;; Valid keys:
;;; ON    turn hp41 off
;;; R/S   start/stop catalog
;;; <-    exit if not running
;;; SST   single step
;;; BST   back step
;;; C     delete current buffer (shifted)
;;; SHIFT toggle shift flag
              goto    CAT7off       ; ON
              goto    CAT7RS        ; R/S
              goto    CATend        ; <-
              goto    CAT7SST       ; SST
              goto    CAT7Clear     ; C
              goto    CAT7Shift     ; SHIFT
              ?s8=1                 ; undefined, running?
              goc     CAT7speedUp   ; yes, speedup
CAT7blink:    gosub   BLINK         ; no, blink LCD
CAT7rstkb:    gosub   RSTKB
              goto    CAT7delay

CAT7speedUp:  a=c     x             ; shave some delay off
              ldi     400
              c=a-c   x
              goc     CAT7delay     ; start a new delay cycle
              c=n                   ; use existing loop counter
              goto    CAT7loop

CAT7Clear:    ?s8=1
              goc     CAT7speedUp   ; running
              ?s7=1                 ; shift?
              gonc    CAT7blink     ; no
              gosub   ENCP00        ; yes, clear buffer
              c=n
              dadd=c
              c=data
              c=0     s             ; mark buffer deleted
              data=c
              c=0
              dadd=c
              gosub   PKIOAS        ; pack I/O area
              gosub   RSTKB
              goto    CAT7step0     ; show previous buffer

CAT7off:      golong  OFF

CAT7RS:       ?s8=1
              goc     10$
              s8=1
              goto    CAT7rstkb
10$:          s8=0
              goto    CAT7rstkb

CAT7Shift:    ?s8=1
              goc     CAT7speedUp
              ?s7=1
              goc     10$
              s7=1
5$:           cstex
              wrten
              goto    CAT7rstkb
10$:          s7=0
              goto    5$
