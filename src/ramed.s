#include "mainframe.i"

;;; **********************************************************************
;;;
;;; RAMED a RAM editor.  Allows easy editing of the RAM memory.
;;;
;;; It can be started in 3 ways:
;;; 1. In program mode it will show the current program location.
;;; 2. In run mode with a decimal address in X.
;;; 3. In runmode with a right justified binary address in X.
;;;
;;; Active keys:
;;; 0-F Digit entry at cursor position
;;; ON  Turns the HP41 off
;;; R/S Leave RAMED
;;; +   Go to next register
;;; -   Go to previous register
;;; PRGM        Move cursor right
;;; USER        Move cursor left
;;; .   Toggle cursor field
;;;
;;; **********************************************************************

              .section BoostCode
              .public RAMED
              .extern KEYFC
              .name   "RAMED"
RAMED:        nop                   ; non-programmable
              ?s3=1                 ; program mode?
              goc     1$            ; yes
              c=regn  X             ; no, read X register
              pt=     12
              ?c#0    pt            ; BCD data?
              gonc    2$            ; no
              gosub   BCDBIN        ; yes, decode BCD number
              pt=     3
              lc      13            ; point to leftmost digit
              goto    2$

1$:           gosub   GETPC
4$:           gosub   NXBYTA        ; find first non-NULL byte
              c=0     xs
              ?c#0    x
              gonc    4$

              acex                  ; NXBYTA points at 2nd digit while
              c=c+1   pt            ;  RAMED points at first..

2$:           s8=0                  ; start with cursor in data word
              pt=     13
              lc      9             ; start cursor position in data
              lc      2             ; start cursor position in address
              m=c

;;; Start of main loop
5$:           gosub   RSTKB
              c=m                   ; get current register
              dadd=c                ; select it
              c=data                ; and read it
              n=c                   ; keep contents in N
              gosub   ENLCD         ; enable LCD
              c=m                   ; fetch address
              rcr     4             ; left justify
              ldi     4             ; 4 hex digits
              a=c
              rxq     outputHex     ; write hex digits to LCD
              ldi     ' '           ; add a blank
              slsabc
              c=m                   ; digit# - NOT(cursor) + 4
              c=-c-1  s
              a=c     s
              pt=     13
              lc      4
              a=a+c   s
              rcr     4
              acex    s
              a=a-c   s
              gonc    6$
              a=a-1   s             ; adjust 15 -> 13
              a=a-1   s
6$:           c=n

;;; A.X is the number of left rotates necessary to left justify word
7$:           a=a-1   s
              goc     8$
              rcr     1
              goto    7$
8$:           ldi     7
              a=c
              rxq     outputHex     ; output data word
              s6=0                  ; read character under cursor
              c=m
              ?s8=1
              gonc    9$            ; normal cursor
              rcr     13            ; cursor in address
9$:           a=c     s             ; for use when restoring LCD
              b=a     s
10$:          a=a-1   s             ; rotate LCD left
              goc     11$
              rabcl
              goto    10$

;;; Character under cursor is now in C<2:0>
11$:          a=c     x             ; store it in M<11:9>
              c=m
              rcr     9
              acex    x
              rcr     5
              m=c
              abex    s

12$:          a=a-1   s             ; restore LCD
              goc     14$
              rabcr
              goto    12$
14$:

;;; Handle keyboard and cursor blinking
              c=0     m             ; timeout counter
              pt=     7
              lc      2
15$:          ldi     0x200         ; cursor blink counter
              a=c
16$:          chk kb
              goc     17$           ; key down
              ?lld                  ; low battery?
              gonc    18$           ; no
              a=a-1   m             ; yes, timeout twice as fast
              gonc    18$

19$:          gosub   ENCP00        ; leave RAMED
              gosub   RSTKB
              golong  CLDSP         ; put up goose

18$:          a=a-1   m
              goc     19$           ; timeout
              a=a-1   x             ; decrement cursor blink counter
              gonc    16$

;;; Blink cursor, set underscore or character at cursor position in LCD
              c=m
              ?s8=1                 ; cursor in address field?
              gonc    20$           ; no
              rcr     13            ; yes
20$:          a=c     s
              ldi     31            ; underscore
              ?s6=1                 ; display underscore?
              gonc    21$           ; yes
              c=m                   ; no, display character under cursor
              rcr     9
              s6=0                  ; toggle flag 6
              goto    22$
21$:          s6=1                  ; toggle flag 6
22$:          a=c     x             ; character to print to A.X
              b=a     s
23$:          a=a-1   s             ; rotate LCD
              goc     24$
              rabcl
              goto    23$
24$:          srsabc                ; delete rightmost character in LCD
              acex    x
              slsabc                ; write what we want to have there now
              abex    s
25$:          a=a-1   s             ; restore LCD
              goc     26$
              rabcr
              gonc    25$
26$:          acex    m
              goto    15$           ; start over

;;; Key down, decode the key and branch to the desired handler
17$:          gosub   ENCP00        ; select RAM, deselect LCD
              c=m                   ; select current address
              dadd=c
              ldi     24            ; number of keys
              a=c     x
              rxq     KEYFC
              .con    0x11, 0xc0, 0x80, 0x70, 0x30, 0x10
              .con    0x84, 0x74, 0x34, 0x85, 0x75, 0x35
              .con    0x86, 0x76, 0x36, 0x37, 0x87, 0xc3
              .con    0x18, 0x15, 0x14, 0xc5, 0xc6, 0x77
              nop
              c=c+1   x             ; F
              c=c+1   x             ; E
              c=c+1   x             ; D
              c=c+1   x             ; C
              c=c+1   x             ; B
              c=c+1   x             ; A
              c=c+1   x             ; 9
              c=c+1   x             ; 8
              c=c+1   x             ; 7
              c=c+1   x             ; 6
              c=c+1   x             ; 5
              c=c+1   x             ; 4
              c=c+1   x             ; 3
              c=c+1   x             ; 2
              c=c+1   x             ; 1
              goto    30$           ; 0
              goto    31$           ; R/S
              goto    31$           ; <-
              goto    33$           ; ON
              goto    34$           ; next address
              goto    35$           ; previous address
              goto    36$           ; next digit
              goto    37$           ; previous digit
              goto    38$           ; toggle cursor position
              goto    51$           ; illegal key

33$:          golong  OFF           ; turn HP-41 off

31$:          rgo     19$           ; leave RAMED

;;; Digit entered
30$:          a=c     x
              rgo     40$           ; go to handler

;;; Next address
34$:          c=m                   ; increment address
              c=c+1   x
54$:          m=c
51$:          rgo     5$            ; go to main loop

;;; Previous address
35$:          c=m                   ; decrement address
              c=c-1   x
              m=c                   ; save (and reset carry)
              goto    51$

;;; Next digit
36$:          c=m                   ; move cursor right
              pt=     3
              ?s8=1                 ; in address field?
              goc     52$           ; yes
              c=c-1   pt            ; no, wrap around?
              gonc    53$           ; no
              gosub   ENCP00        ; yes
              gosub   TONE7X        ; wrap around tone
              c=m
              lc      13
53$:          a=c     s
              pt=     13
              lc      11            ; max to the right
              acex    s
              ?a#c    s
              gonc    54$
              c=c+1   s             ; move cursor too
59$:          gonc    54$

52$:          rcr     13            ; move in address field
              c=c+1   s
              pt=     13
              a=c     s
              lc      5
              acex    s
              inc pt
              ?a#c    s
              goc     55$
              lc      2             ; wrap to leftmost position
55$:          rcr     1
              goto    54$

;;; Toggle cursor field
38$:          ?s8=1
              goc     56$
              s8=1
              gonc    51$
56$:          s8=0
              gonc    51$

;;; Previuos digit
37$:          c=m
              ?s8=1
              goc     57$           ; cursor in address
              pt=     3             ; cursor in data
              a=c     pt
              lc      14
              pt=     3
              acex    pt
              c=c+1   pt
              ?a#c    pt
              goc     58$
              gosub   ENCP00        ; wrap around in data field
              gosub   TONE7X
              c=m
              lc      0
58$:          a=c     s
              pt=     13
              lc      7
              acex    s
              ?a#c    s
              gonc    59$
              c=c-1   s             ; move cursor left
              gonc    59$

57$:          rcr     13            ; move cursor in address
              a=c     s
              pt=     13
              lc      1
              pt=     13
              acex    s
              c=c-1   s
              ?a#c    s
              goc     61$
              lc      4             ; wrap around cursor
61$:          rcr     1
              goto    59$

;;; Digit entry routine
40$:          c=m
              ?s8=1
              goc     41$           ; cursor in address
              rcr     1             ; cursor in data field
              pt=     0
              acex
42$:          a=a-1   xs
              goc     43$
              rcr     13
              inc pt
              gonc    42$
43$:          a=c
              c=n
              acex    pt            ; store new digit
              data=c
              gonc    44$           ; done, move cursor right
41$:          rcr     13
              a=c     s
              pt=     13
              lc      4             ; convert cursor position to
              c=a-c   s             ; pointer position
              gonc    45$
              c=-c    s
45$:          pt=     0
46$:          c=c-1   s
              goc     47$
              asl     x
              inc pt
              goto    46$
47$:          c=m
              acex    pt
              m=c
44$:          rgo     36$           ; move cursor right


;;; ************************************************************
;;;
;;; outputHex - output hex digit to LCD
;;;
;;; In: A.X - number of digits
;;;     A   - digits left justified in A
;;;
;;; Assume: LCD enabled
;;;
;;; Uses: A, B, C, active pointer
;;;
;;; ************************************************************

outputHex:    a=a-1   x
              rtn     c
              b=a                   ; convert to LCD code
              pt=     13
              c=0     x
              lc      9
              acex    s
              ?a<c    s
              goc     1$
              ldi     3
              goto    2$
1$:           acex    s
              c=a-c   s
2$:           rcr     -1
              slsabc                ; write digit to LCD
              c=b
              rcr     -1
              a=c
              abex    x
              goto    outputHex
