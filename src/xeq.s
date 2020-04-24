#include "mainframe.h"
#include "OS4.h"

XASN05:       .equlab 0x27ad       ; internal undefined entry

;;; **********************************************************************
;;;
;;; ASN' - Replacement for assign (ASN)
;;;
;;; Works like ASN but provides additional features, such as handling
;;; of secondary functions.
;;;
;;; **********************************************************************

              .section BoostCode
              .public myASN
              .extern parseNumber, parseNumberInput
assign:       rgo     xassign
ASNCODE0:     rgo     ASNCODE
toASNXROM:    rgo     ASNXROM
abortASN:     golong  XABTSEQ
              .con    '\'' + 0x80   ; '
              .con    0x0e          ; N
              .con    0x100 + 19    ; S
              .con    0x101         ; A
myASN:        nop                   ; non-programmable
              gosub   partialKey    ; marker partial key takeover
              goto    assign        ; when executed, argument is done and we will
                                    ;   perform the actual assignment
              goto    abortASN      ; <-
5$:           ?s5=1                 ; alpha pressed?
              goc     alpha         ; yes
              c=n                   ; no, C[2:1]= logical keycode
              a=c     x
              ldi     18 << 4       ; XEQ keycode
              ?a#c    x
              gonc    toASNXROM
              ?s4=1
              goc     ASNCODE0      ; A..J
              ?s3=1
              goc     ASNCODE0      ; digit

              gosub   BLINK         ; no, blink and try again!
              gosub   NEXT3
              goto    abortASN
              goto    5$

alpha:        gosub   ENCP00
              c=regn  14
              cstex
              s7=     1             ; set alpha mode
              cstex
              regn=c  14
              c=0                   ; initialize alpha operand
              regn=c  9

nextChar:     gosub   ENLCD         ; request next character
nextChar2:    gosub   NEXT1
              goto    delChar       ; backspace
              ?s6=1                 ; shift key?
              gonc    notShift
              gosub   TOGSHF        ; toggle shift key
              goto    nextChar

delChar:      gosub   ENCP00
              c=regn  9
              ?c#0                  ; any chars to delete?
              gonc    10$           ; no
              rcr     12            ; yes, delete one char
              c=0     wpt
              regn=c  9
              gosub   OFSHFT
              gosub   ENLCD
              rabcr                 ; shift off one character
              goto    nextChar2
10$:          gosub   LDSST0
              s7=     0             ; clear alpha mode
              c=st
              regn=c  14
              golong  XABTSEQ

nextChar2_2:  goto    nextChar2     ; relay
nextChar_2:   goto    nextChar      ; relay

notShift:     gosub   ENCP00
              ?s5=1                 ; ALPHA key?
              gonc    charInput     ; no
              pt=     1
              c=regn  9
              ?c#0                  ; any chars in operand?
              gonc    22$           ; no
              gosub   RTJLBL        ; right-justify operand
22$:          regn=c  9             ; put back right-justified
                                    ; operand
              c=regn  14            ; put up SS0
              st=c
              s7=     0             ; clear alpha mode
              c=st
              gosub   ANN_14        ; store status sets and
                                    ; update ALPHA annunciator
              rxq     isXeq
              goto    30$           ; XEQ
              goto    40$           ; ASN
30$:          ldi     0x1e          ; function code for AXEQ
              bcex    x             ; B.X= function code for AXEQ
              c=regn  10            ; also store in REGN10[4:3]
              rcr     3
              c=b     x
              rcr     -3
              regn=c  10
              c=regn  9             ; XEQ
              ?c#0                  ; empty alpha?
              gonc    noAccept_1    ; yes, not accepted
              sel q
              pt=     13
              sel p
              pt=     2
              ?c#0    pq            ; more than 1 char in label?
              goc     40$           ; yes
              gsubnc  ALCL00        ; no, test for local ALPHA LBL
40$:          c=regn  10            ; set REG10[0]=1 to indicate that we
              pt=     0             ;   have ALPHA input
              lc      1
              regn=c  10
              rgo     toKEYOP

nextChar2_1:  goto    nextChar2_2   ; relay
nextChar_1:   goto    nextChar_2    ; relay

charInput:    gosub   GTACOD
              a=c     x             ; copy character to A.X
              gosub   OFSHFT
              a=a-1   xs            ; is it a character?
noAccept_1:   gonc    noAccept      ; no (also relay)
              pt=     1
              ldi     127           ; lazy "T"
              ?a#c    wpt
              gonc    noAccept
              ldi     58            ; colon
              ?a#c    wpt
              gonc    noAccept
              ldi     46            ; D.P.
              ?a#c    wpt
              gonc    noAccept
              ldi     44            ; comma
              ?a#c    wpt
              gonc    noAccept
              c=regn  9
              ?c#0    wpt           ; full already?
              goc     noAccept      ; full
              acex    wpt           ; add character to REG 9
              a=c     wpt           ; restore character to A.X
              rcr     2             ; -
              regn=c  9             ; -
                                    ; add char to display
              bcex                  ; save operand in B
              gosub   ENLCD
              gosub   MASK          ; transliterate char and
                                    ; send to display
                                    ; note mask decrements B.S
              goto    nextChar2_1

abortASN_1:   golong  XABTSEQ        ; relay

noAccept:     gosub   BLINK
              goto    nextChar_1

ASNXROM:      gosub   MESSL         ; request XROM number (1-31)
              .messl  "XR "
              gsbp    parseNumber
              .con    .low12 accept_1_31
              .con    2             ; request 2 digits
              goto    abortASN_1
              asl     x             ; *16
              acex    x
              c=c+c   x             ; *32
              c=c+c   x             ; *64
              rcr     4             ;
              regn=c  9             ; REG9[12:10] holds lower 3 nibbles of XROM
              gosub   ENLCD
              rxq     appendComma
              gsbp    parseNumber   ; request XROM function (0-63)
              .con    .low12 accept_0_63
              .con    2             ; request 2 digits
              goto    abortASN_1
              c=regn  9
              rcr     10
              c=a+c   x
              pt=     3
              lc      0xa           ; C[3:0]= XROM function code
asnCode10:    regn=c  9             ; REG9[3:0]= XROM function code to assign
              c=regn  10            ; set REG10[0]=0 to indicate XROM assignment
              pt=     0
              lc      0
              regn=c  10
toKEYOP:      rxq     isXeq
              goto    100$          ; (P+1) do not ask for key if XEQ
              golong  KEYOP         ; request key to assign to, after which we
                                    ;   should be invoked in our run vector!
100$:         acex
              rcr     -3            ; C[6:3]= XADR of XEQ'
              gotoc                 ; go and do it

;;; * Assign based on numeric codes, we have already the first digit (or A..J)
;;; * pressed.
ASNCODE:      gsbp    parseNumberInput
              .con    .low12 accept_0_255
              .con    3             ; request 3 digits
abortASN_2:   goto    abortASN_1
              acex
              rcr     3
              regn=c  9             ; REG9[12:11] holds first byte
              rxq     appendComma
              gsbp    parseNumber
              .con    .low12 accept_0_255
              .con    3             ; request 3 digits
              goto    abortASN_2
              c=regn  9
              rcr     9             ; C[3:2]= high byte
              pt=     1
              acex    wpt           ; C[1:0]= low byte
              goto    asnCode10

appendComma:  gosub   ENLCD
              frsabc
              cstex
              s6=1                  ; set comma after it
              s7=1
              cstex
              slsabc                ; put back (with comma)
              rtn

;;; * Here we get called to actually perform the assignment, above is just to handle the input.
              .section BoostCode
xassign:      c=regn  10            ; which variant of assignment is this?
              pt=     0
              c=c-1   pt            ; XROM?
              goc     10$           ; yes
              c=regn  9             ; remove assignment?
              m=c
              ?c#0
              golnc   clearAssignment ; yes
              c=regn  10            ; save keycode in reg 10
              acex    x
              regn=c  10
              gosub   XASRCH        ; C[3:0]_ALBL addr
              ?s6=1                 ; found secondary?
              golnc   XASN+10       ; no, use mainframe code
              c=regn  10            ; get keycode
              bcex    x             ; B[1:0]= keycode
              c=0     x
              pt=     2
              lc      8             ; 0x800
              ?a<c    x             ; below 0x800?
              golnc   ERROF         ; no, out of range, cannot be assigned
              c=b     m             ; C[6:3]= start address of page
              cxisa                 ; C.X= XROM Id
              rcr     -3            ; C[4:3]= XROM Id
              a=c     m             ; A[3:2]= XROM Id
                                    ; A[2:0]= secondary function number
              abex                  ; A[1:0]= keycode
                                    ; B[4:0]= XR-FFF, combined XROM and function Ids
              golong  assignSecondary

;;; * XROM assignment
10$:          acex    x             ; save keycode in REGN10
              regn=c  10
              a=c     x
              gosub   TBITMA
              ?c#0                  ; is assigned?
              gonc    20$           ; no
              c=regn  10            ; clear keycode entry
              a=c
              s1=     1
              gosub   GCPKC
              goto    21$
20$:          gosub   SRBMAP        ; set bit
21$:          c=regn  10            ; A[3:2]_K.C.  A[1:0]_0
              a=c     x
              asl
              asl
              c=regn  9
              bcex                  ; B[3:0]= XROM function code
              golong  XASN05        ; join forces with XASN


;;; * Acceptor routines for XROM numbers
              .section BoostCode
              .align  4
accept_1_31:  ?s8=1                 ; incomplete input?
              goc     10$           ; yes, we accept 0
              ?a#0    x
              rtnnc                 ; zero not accepted
10$:          ldi     32
accept10:     ?a<c    x             ; in range?
              golc    RTNP2         ; yes
              rtn                   ; no
              .align  4
accept_0_63:  ldi     65
              goto    accept10
              .align  4
accept_0_255: ldi     256
              goto    accept10

              .section BoostCode
isXeq:        c=regn  8             ; return to (P+1) if XEQ
              rcr     -4
              a=c
              pt=     2
              lc      .nib2 myXEQ
              lc      .nib1 myXEQ
              lc      .nib0 myXEQ
              ?a#c    x
              rtnnc
              golong  RTNP2

;;; **********************************************************************
;;;
;;; XEQ' - Replacement for assign (XEQ)
;;;
;;; Works like XEQ but provides additional features, such as handling
;;; of secondary functions.
;;;
;;; **********************************************************************

              .section BoostCode
              .public myXEQ
abortXEQ:     golong  XABTSEQ
xeq0:         rgo     xeq
toXROM:       rgo     ASNXROM
              .con    '\'' + 0x80   ; '
              .con    0x11          ; Q
              .con    0x105         ; E
              .con    0x318         ; X
myXEQ:        gosub   partialKey    ; marker partial key takeover
              goto    xeq0          ; when executed, argument is done and we will
                                    ;   perform the command
              goto    abortXEQ
              pt=     0
              cgex
              cstex
              s5=0                  ; reset XROM bit, we are really XEQ
              cstex
              cgex
              pt=     1
5$:           ?s5=1                 ; alpha pressed?
              gonc    8$
              rgo     alpha
8$:           c=n                   ; no, C[2:1]= logical keycode
              a=c     x
              ldi     18 << 4       ; XEQ keycode
              ?a#c    x
              gonc    toXROM
              gosub   ENCP00
              c=regn  10
              rcr     3
              ldi     0xe0          ; function code for XEQ
              a=c     x
              rcr     -3
              regn=c  10
              gosub   ENLCD
              ?s4=1                 ; A..J?
              goc     xeqAJ         ; yes
              ?s3=1                 ; digit?
              gonc    10$           ; no
              gosub   FDIGIT
9$:           gosub   BLINK         ; blink and try again!
              gosub   NEXT2
              goto    abortXEQ
              goto    5$

10$:          ?s6=1                 ; SHIFT?
              gonc    9$            ; no
              gosub   ENCP00
              golong  0x0d89        ; yes, join forces with XEQ/IND

xeqAJ:        golong  AJ2


xeq:          c=regn  10            ; which variant is this?
              pt=     0
              c=c-1   pt            ; XROM?
              goc     10$           ; yes
              c=regn  9             ; C= alpha string
              m=c
              gosub   XASRCH        ; C[3:0]_ALBL addr
              ?s6=1                 ; found secondary?
              golnc   0x0f66        ; no
              c=b     m             ; C[6]= page address
              golong  invokeSecondary

10$:          c=regn  9             ; C[3:0]= XROM function code
              golong  RAK70
