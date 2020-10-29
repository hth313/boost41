#include "mainframe.h"
#include "OS4.h"
#include "boostInternals.h"

PRT12:        .equlab 0X6FD7

              .section CatShell, rodata
              .align  4
              .public catShell
catShell:     .con    SysShell
              .con    0                 ; no display handler defined
              .con    .low12 keyHandler ; standard keys
              .con    .low12 keyHandler ; user keys
              .con    0                 ; alpha keys, use default
              .con    .low12 catName
                                        ; no timeout handler needed as
                                        ; this is a system shell

              .section BoostCode1
              .align  4
              .extern sysKeyTable
keyHandler:   gosub   keyKeyboard   ; does not return
              .con    (1 << KeyFlagSparseTable) ; flags
              .con    0             ; handle a digit
              .con    0             ; end digit entry
              .con    .low12 sysKeyTable

;;; Name of the shell
              .section BoostCode1
              .align  4
catName:      .messl  "CAT"

;;; Handler of catalogs
              .section BoostCode1
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

              .section BoostCode1
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
              gosub   sendMessage
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

              .section BoostCode1
CAT7:         ldi     .low12 catalogDescriptor7
              gosub   catalog

              .section BoostCode1
              .public CAT7_Clear    ; clear buffer
              .align  4
CAT7_Clear:   switchBank 2
              c=regn  Q             ; bring state back
              dadd=c
              c=data                ; read buffer header
              c=0     s             ; mark it as deleted
              data=c
              c=0     x             ; select chip 0
              dadd=c
              gosub   OFSHFT
              gosub   PKIOAS        ; pack I/O area
              c=0
              dadd=c
              c=regn  Q
              n=c
              gosub   RSTKB
              s9=0                  ; back step after delete
              goto    back10

;;; !!!!! This entry must be aligned of 4, add NOPs here if needed.
;;;       Currently the tools are not smart enough to calculate shadowed
;;;       alignments as the above align by 4 and relatative placement
;;;       in theory could be supported. As it is now the tools detect
;;;       that it cannot do this properly and bails out, so we have
;;;       to align the next line by code size above.
;;;       At the moment it happens to get the right alignment without
;;;       any NOPs.
              nop
              nop
              nop
back:         s9=1                  ; ordinary back step
back10:       c=n                   ; search backwards
              pt=     12
              c=c-1   pt
              goc     10$           ; no previous buffer
              n=c
              c=0     s
              c=0     x
              rcr     -2
              gosub   findBuffer
              goto    back10        ; (P+1) no such buffer
              goto    found         ; (P+2) exists
10$:          ?s9=1
              rtnc                  ; real BST and no previous buffer,
                                    ;   return to blink and sleep

                                    ; after clear buffer, no previous
                                    ;  step forward instead

;;; !!!!! This entry must be aligned of 4, add NOPs here if needed.
              nop
              nop
              nop
step:         c=n                   ; step to next buffer
              pt=     12
              c=c+1   pt
              rtnc                  ; nothing more
              goto    next


;;; !!!!! This entry must be aligned of 4, add NOPs here if needed.
              nop
              nop
              nop
prepare:      c=0                   ; start with buffer 0
next:         n=c
              pt=     12
              c=0     s
              c=0     x
              rcr     -2
              gosub   findBuffer
              goto    step          ; (P+1) not found, try step to next
              s9=1                  ; (P+2) we have return address on stack
                                    ;   (S9=0 means we are coming from backstep
                                    ;         after CAT7_Clear and we do not have
                                    ;         a valid return address in that case
found:        c=data                ; (P+2) this one exists, read header
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
              ?s9=1                 ; do we have return address?
              golc    RTNP2         ; yes
              gosub   catalogReturn ; no, enter to display entry

              .section BoostCode1
              .align  4
              .public CAT7_RUN
CAT7_RUN:     ldi     .low12 catalogDescriptor7
              gosub   catalogRun

              .section BoostCode1
              .align  4
              .public CAT7_BACKARROW
CAT7_BACKARROW:
              gosub catalogEnd

              .section BoostCode1
              .public CAT7_SST
              .align  4
CAT7_SST:     ldi     .low12 catalogDescriptor7
              gosub   catalogStep

              .section BoostCode1
              .public CAT7_BST
              .align  4
CAT7_BST:     ldi     .low12 catalogDescriptor7
              gosub   catalogBack

;;; **********************************************************************
;;;
;;; The transient CAT 07 application definition.
;;;
;;; **********************************************************************

              .section CAT7Shell, rodata
              .align  4
cat7Shell:    .con    TransAppShell
              .con    0             ; no display handler defined
              .con    .low12 cat7Handler ; standard keys
              .con    .low12 cat7Handler ; user keys
              .con    0             ; alpha keys not needed
              .con    .low12 myName
              .con    0             ; no timeouts

              .section BoostCode1
              .align  4
myName:       .messl  "CAT-7"

              .section BoostCode1
              .align  4
catalogDescriptor7:
              .con    .low12 prepare
              .con    .low12 step
              .con    .low12 back
              .con    .low12 cat7Shell
              switchBank 2          ; bank switcher


;;; **********************************************************************
;;;
;;; The keyboard while stopped.
;;;
;;; **********************************************************************

              .section BoostCode1
              .align  4
              .extern keyTableCAT7
cat7Handler:  gosub   keyKeyboard   ; does not return
              .con    (1 << KeyFlagSparseTable) | (1 << KeyFlagTransientApp) ; flags
              .con    0             ; handle a digit
              .con    0             ; end digit entry
              .con    .low12 keyTableCAT7
              .con    0             ; no transient termination entry needed
