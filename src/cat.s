#include "mainframe.h"
#include "OS4.h"

PRT12:        .equlab 0X6FD7

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
              .extern sysKeyTable
keyHandler:   gosub   keyKeyboard   ; does not return
              .con    (1 << KeyFlagSparseTable) ; flags
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
;;; CAT' - A catalog replacement.
;;;
;;; Provide a 2-digit prompt and use the extension notification mechanism
;;; in OS4 to let any plug-in dynamically handle the catalog.
;;;
;;; **********************************************************************

              .section BoostCode
              .public myCAT
              .con    '\'' + 0x80   ; '
              .con    0x14          ; T
              .con    0x201         ; A
              .con    0x203         ; C 2-digit prompt
myCAT:        nop                   ; non-programmable
              acex    x
              st=c
              s8=0
              gosub   TONSTF
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
;;; Displays buffers as: 'AA LLL  @BBB'
;;;   where
;;;      AA - buffer number (decimal)
;;;      LLL - buffer length (decimal)
;;;      BBB - register address of header
;;;
;;; **********************************************************************

              .section BoostCode

CAT7:         spopnd                ; drop return addresses
              spopnd
              c=0                   ; start with buffer 0
CAT7main:     n=c                   ; main loop
              pt=     12
              c=0     s
              c=0     x
              rcr     -2
              gosub   chkbuf
              goto    step00        ; (P+1) not found, try step to next
CAT7found:    c=data                ; (P+2) this one exists, read header
              acex    x
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
              gosub   ENCP00
              c=regn  8
              c=0     s             ; just say it is not CAT 1
              regn=c  8
              c=n
              m=c                   ; M= state
              gosub   PRT12         ; send LCD to printer
              c=m
              n=c                   ; N= state

              gosub   hasActiveTransientApp
              goto    CAT7wait      ; (P+1) no
              goto    CATreturn     ; (P+2) yes

CAT7main0:    goto    CAT7main      ; relay
CAT7found0:   goto    CAT7found     ; relay
step00:       goto    step          ; relay

CAT7wait:     ldi     1000          ; inner delay counter (goes up)
CAT7loop:     rstkb
              chkkb
              goc     CAT7key       ; some key is down
              c=c-1   x
              gonc    CAT7loop
              goto    step          ; step to next

              .align  4
              .public CAT7_SST
CAT7_SST:
              gosub   scratchArea   ; bring state back
              c=data
              n=c
step:         c=n                   ; step to next buffer
              pt=     12
              c=c+1   pt
              goc     CATend
              goto    CAT7main0

              .align  4
              .public CAT7_BST
CAT7_BST:     s9=1                  ; ordinary BST
              gosub   scratchArea   ; bring state back
              c=data
              n=c
back:         c=n                   ; search backwards
              pt=     12
              c=c-1   pt
              goc     10$           ; no previous buffer
              n=c
              c=0     s
              c=0     x
              rcr     -2
              gosub   chkbuf
              goto    back          ; (P+1) no such buffer
              goto    CAT7found0    ; (P+2) exists
10$:          ?s9=1
              goc     CAT7blink     ; real BST and no previous buffer
              goto    step          ; after clear buffer, no previous
                                    ;  step forward instead

CAT7blink:    gosub   BLINK         ; blink LCD
CATreturn:    gosub   scratchArea   ; save state and return to OS
              c=n
              data=c
              gosub   STMSGF        ; set message flag
              golong  NFRKB         ; give control back to OS

CAT7loop0:    goto    CAT7loop     ; relay

;;; Handle key while running
CAT7key:      m=c                   ; save delay counters
              ldi     2
              gosub   keyDispatch
              .con    0x18,0x87,0
              goto    CAT7off       ; ON
              goto    CAT7stop      ; R/S
              c=m                   ; undefined key, speed up
              a=c     x             ; shave some delay off
              ldi     10
              c=a-c   x
              goc     step
              goto    CAT7loop0

back0:        goto    back          ; relay
step0:        goto    step          ; relay

              .align  4
              .public CAT7_BACKARROW
CAT7_BACKARROW:
CATend:       gosub   exitTransientApp
              gosub   ENCP00
              golong  QUTCAT

CAT7off:      golong  OFF

CAT7stop:     ldi     .low12 cat7Shell
              gosub   activateShell
              goto    10$           ; (P+1) no room for a shell
              ldi     1             ; (P+2) need one scratch register
              gosub   allocScratch
              goto    10$           ; (P+1) no room for scratch
              goto    CATreturn     ; give control back
10$:          gosub   exitTransientApp
              golong  noRoom        ; NO ROOM error

              .public CAT7_Clear    ; clear buffer
              .align  4
CAT7_Clear:   gosub   scratchArea   ; bring state back
              c=data
              dadd=c
              c=data                ; read buffer header
              c=0     s             ; mark it as deleted
              data=c
              c=0     x             ; select chip 0
              dadd=c
              gosub   OFSHFT
              gosub   PKIOAS        ; pack I/O area
              gosub   scratchArea
              c=data
              n=c
              gosub   RSTKB
              s9=0                  ; BST after delete
              goto    back0         ; try to show previous buffer

              .align  4
              .public CAT7_RUN
CAT7_RUN:     gosub   scratchArea   ; bring state back
              c=data
              n=c
              gosub   exitTransientApp
              gosub   RSTKB
              goto    step0         ; continue with next entry


;;; **********************************************************************
;;;
;;; The transient CAT 07 application definition.
;;;
;;; **********************************************************************

              .section BoostTable, rodata
              .align  4
cat7Shell:    .con    TransAppShell
              .con    0             ; no display handler defined
              .con    .low12 cat7Handler ; standard keys
              .con    .low12 cat7Handler ; user keys
              .con    0             ; alpha keys not needed
              .con    .low12 myName
              .con    0             ; no timeouts

              .section BoostCode
              .align  4
myName:       .messl  "CAT-7"


;;; **********************************************************************
;;;
;;; The keyboard while stopped.
;;;
;;; **********************************************************************

              .section BoostCode
              .align  4
              .extern keyTableCAT7
cat7Handler:  gosub   keyKeyboard   ; does not return
              .con    (1 << KeyFlagSparseTable) ; flags
              .con    0             ; handle a digit
              .con    0             ; end digit entry
              .con    .low12 keyTableCAT7
                                    ; no transient termination entry needed
                                    ; we do not have keyboard secondaries
