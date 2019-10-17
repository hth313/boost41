#include "mainframe.i"

BSTEP3:       .equlab 0x28e5        ; non-public entry point

;;; **********************************************************************
;;;
;;; COMPILE - Compile all user programs.
;;;
;;; Algorithm used:
;;;
;;; 1. Put an END after last program (as GTO ..)
;;; 2. Pack memory.
;;; 3. Compile one user program after another, stop when last program
;;;    has been compiled and set PC at .END.
;;; 4. If a too long jump is found, try to insert a 3-byte jump instead,
;;;    then Pack memory and start over again with the program we worked
;;;    on.
;;;
;;; Possible errors:
;;; NONEXISTENT Jump to a label that does not exist
;;; TRY AGAIN   If not enough memory space left
;;;
;;; Execution time varies from a few seconds to several minutes.
;;;
;;; **********************************************************************

              .section BoostCode
              .public COMPILE
              .name   "COMPILE"
COMPILE:      nop                   ; non programmable
              s13=1
              c=regn  13            ; get chain head
              pt=     3
              lc      4
              pt=     3
              a=c     wpt
              n=c
              gosub   GTLINK
              ?c#0    x             ; top of memory?
              gonc    1$            ; yes
              gosub   UPLINK        ; get link before
              c=c+1   s             ; at ALPHA label?
              goc     2$            ; yes, create a new END
              gosub   INCAD2
3$:           gosub   NXBYTA        ; find next line
              rcr     12
              ?c#0    pt
              goc     .+3
              ?c#0    xs
              gonc    3$            ; NULL
              c=n                   ; compare addresses
              ?a#c    wpt           ; same as final end
              gonc    1$            ; yes, no need for a new END

;;; ----------------------------------------
;;;
;;; Create a new END after the last program.
;;;
;;; ----------------------------------------

2$:           gosub   AVAIL         ; is there room?
              ?c#0
              golc    PACKE         ; no, pack and ask user to TRY AGAIN
              pt=     5             ; make new final END
              lc      12
              pt=     3
              ldi     0x120         ; link is 1 register
              data=c
              c=n                   ; fix old END
              dadd=c
              c=data                ; get old END
              cstex
              s5=0                  ; make a normal END
              s2=1                  ; set PACK bit
              cstex
              data=c
              c=0                   ; fix chain head
              dadd=c
              c=regn  13
              c=c-1   x
              regn=c  13

;;; ----------------------------------------
;;;
;;; Go to the first program in memory
;;;
;;; ----------------------------------------

1$:           pt=     3
              gosub   FSTIN
              s10=0
              gosub   PUTPCF
4$:           gosub   XPACK         ; pack memory
              gosub   ENLCD         ; replace "PACKING"
              gosub   MESSL         ; with    "WORKING"
              .messl  "WORK"
              fllabc
              fllabc
              gosub   ENCP00

;;; ----------------------------------------
;;;
;;; Main loop, look for the following
;;; functions:
;;; GTO, XEQ and END
;;;
;;; Uncompiled ENDs are now compiled.
;;;
;;; ----------------------------------------

5$:           gosub   GETPC
6$:           gosub   NXBYTA
              c=0     xs
              ?c#0    x             ; NULL?
              gonc    6$            ; yes, skip it
              b=a                   ; keep address
              a=c     x
              pt=     1
              lc      0xb
              pt=     1
              ?a#c    pt
              gonc    7$            ; 2-byte GTO
              c=c+1   pt
              ?a#c    pt
              goc     .+4
              rgo     8$            ; possible global
              c=c+1   pt
              ?a#c    x
              gonc    9$            ; 3-byte GTO
              c=c+1   pt
              ?a#c    x
              gonc    9$            ; 3-byte XEQ
10$:          gosub   GETPC         ; single step to next line
              gosub   SKPLIN
              gosub   PUTPC
55$:          gonc    5$
9$:           rgo     11$

;;; ----------------------------------------
;;;
;;; Handle 2-byte GTOs, code somewhat stolen
;;; from the internal code if the HP41
;;;
;;; ----------------------------------------

7$:           abex
              b=a
              pt=     3
              gosub   NXBYTA
              c=0     xs
              ?c#0    x             ; already compiled?
              goc     10$           ; yes
              gosub   PUTPC
              abex                  ; no
              gosub   GTBYTA
              pt=     2
              lc      0
              lc      0
              c=c-1   x
              goc     10$           ; spare
              n=c
              a=c     x
              s8=0                  ; A[2:0]= label number
              pt=     3
              gosub   DOSRC1        ; search label
              m=c
              gosub   GETPC
              cmex
              ?a#c    x
              goc      12$
              ?a<c    pt
              gonc    14$
              goto    15$
12$:          ?a<c    x
              gonc    .+3
15$:          s8=1
              acex    wpt
14$:          gosub   CALDSP        ; calculate displacement
              ?a#0    xs            ; >= max ?
              goc     16$           ; yes
              asl     x             ; pack relative address
              ?a#0    xs            ; >= max ?
              goc     16$           ; yes
              asl     x
              asr     wpt
              c=m
              acex    wpt
              ?st=1   8
              gonc    .+2
              c=c+1   pt
              c=c+c   wpt
              c=c+c   wpt
              c=c+c   wpt
              c=c+c   x
              rcr     2
              gosub   PTBYTA
              goto     55$

;;; ----------------------------------------
;;;
;;; Too long jump, try to insert a 3-byte
;;; GTO and then delete old 2-byte GTO.
;;;
;;; ----------------------------------------

16$:          gosub   GETPC
              a=0     s
              ldi     0xd0
              gosub   INBYTC
              gosub   INBYT0
              c=n
              gosub   INBYTC
              gosub   BSTEP3
              gosub   GETPC
              gosub   DELLIN        ; delete old 2-byte GTO
              gosub   FLINKP
              gosub   CPGM10        ; go to start of program
              gosub   PUTPC
              rgo     4$            ; PACK and start over

;;; ----------------------------------------
;;;
;;; Compile 3-byte GTO and XEQ, code
;;; borrowed from HP41 quad 9.
;;;
;;; ----------------------------------------

11$:          c=b
              m=c
              a=c
              pt=     3
              gosub   PUTPC
              s8=1
              gosub   NXBYTA
              c=0     xs
              ?c#0    x             ; compiled?
              gonc    .+4           ; no
              rgo     10$           ; yes
              gosub   NXBYTA        ; get label number
              cstex                 ; clear direction bit
              s7=0
              cstex
              a=c     x
              s6=1                  ; program pointer at first byte
              gosub   DOSRCH        ; search for label
              a=c     wpt           ; calculate displacement
              cmex                  ; M= label address
              ?a#c    x
              goc     17$
              ?a<c    pt
              gonc    19$
              goto    18$
17$:          ?a<c    x
              gonc    .+3
18$:          s8=0
              acex    wpt
19$:          c=a-c   x             ; number of registers
              c=a-c   pt            ; number of bytes
              gonc    .+4
              c=c-1   x
              c=c-1   pt
              c=c-1   pt
              c=c+c   x
              c=c+c   x
              c=c+c   x
              c=c+c   x
              gonc    .+2
              c=c+1   pt
              csr     wpt
              bcex    x             ; relative address displacement
              gosub   GETPC
              gosub   GTBYTA
              rcr     12
              c=b     x
              rcr     2
              bcex    m
              bcex    s
              gosub   PTBYTA
              gosub   INCADA
              c=b
              rcr     12
              gosub   PTBYTA
              gosub   NXBYTA        ; set bit 7 of label byte
              cstex
              s7=0
              ?st=1   8
              gonc    .+2
              s7=1
              cstex
              gosub   PTBYTA
              gosub   PUTPC
              rgo     5$
20$:          rgo     10$           ; next line

;;; ----------------------------------------
;;;
;;; Possible END.  If END, say program
;;; packed and compiled, then move to
;;; next program.  If .END. then finish.
;;;
;;; ----------------------------------------

8$:           pt=     3
              ldi     0xcd
              ?a<c    x
              gonc    20$           ; not global
              abex
              gosub   INCAD2
              gosub   GTBYTA
              pt=     1
              c=c+1   pt
              goc     20$           ; global label
              c=c-1   pt
              cstex
              ?st=1   5
              golc    NFRPU         ; .END. found, return to mainframe
              pt=     3
              gosub   PUTPC
              rgo     5$            ; go to next program
