#include "mainframe.i"
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
assign:       rgo     xassign
ASNCODE0:     rgo     ASNCODE
toASNXROM:    rgo     ASNXROM
abortASN:     golong  ABTSEQ
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
              goc     8$            ; yes
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

8$:           gosub   ENCP00
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
              goto    nextChar2

delChar:      gosub   ENCP00
              c=regn  9
              ?c#0                  ; any chars to delete?
              gonc    10$           ; no
              rcr     12            ; yes. delete one char
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
              golong  ABTSEQ

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
              c=regn  10            ; set REG10[0]=0 to indicate that we
              pt=     0             ;   are doing ALPHA assign
              lc      1
              regn=c  10

              c=regn  14            ; put up SS0
              st=c
              s7=     0             ; clear alpha mode
              c=st
              gosub   ANN_14        ; store status sets and
                                    ; update ALPHA annunciator
              golong  KEYOP

nextChar2_1:  goto    nextChar2     ; relay
nextChar_1:   goto    nextChar      ; relay

charInput:    gosub   GTACOD
              a=c     x             ; copy character to A.X
              gosub   OFSHFT
              a=a-1   xs            ; is it a character?
              gonc    noAccept      ; no
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

abortASN_1:   golong  ABTSEQ        ; relay

noAccept:     gosub   BLINK
              goto    nextChar_1

ASNXROM:      gosub   MESSL         ; request XROM number (1-31)
              .messl  "XR "
              gosub   parseNumber
              .con    .low12 accept_1_31
              .con    0x200         ; request 2 digits
              goto    abortASN_1
              asl     x             ; *16
              acex    x
              c=c+c   x             ; *32
              c=c+c   x             ; *64
              rcr     4             ;
              regn=c  9             ; REG9[12:10] holds lower 3 nibbles of XROM
              gosub   ENLCD
              rxq     appendComma
              gosub   parseNumber   ; request XROM function (0-63)
              .con    .low12 accept_0_63
              .con    0x200         ; request 2 digits
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
toKEYOP:      golong  KEYOP     ; request key to assign to, after which we
                                    ;   should be invoked in our run vector!

;;; * Assign based on numeric codes, we have already the first digit (or A..J)
;;; * pressed.
ASNCODE:      gosub   parseNumberInput
              .con    .low12 accept_0_255
              .con    0x300         ; request 3 digits
              goto    abortASN_1
              acex
              rcr     3
              regn=c  9             ; REG9[12:11] holds first byte
              rxq     appendComma
              gosub   parseNumber
              .con    .low12 accept_0_255
              .con    0x300         ; request 3 digits
              goto    abortASN_1
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
              golong  XASN          ; no, alpha assignment

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
accept_1_31:  ?a#0    x
              rtnnc                 ; zero not accepted
              ldi     32
accept10:     ?a<c    x             ; in range?
              golc    RTNP2         ; yes
              rtn                   ; no
              .align  4
accept_0_63:  ldi     65
              goto    accept10
              .align  4
accept_0_255: ldi     256
              goto    accept10

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
              .con    '\'' + 0x80   ; '
              .con    0x11          ; Q
              .con    0x105         ; E
              .con    0x318         ; X
myXEQ:        nop                   ; non-programmable
