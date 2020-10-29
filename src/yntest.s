#include "mainframe.h"
#include "OS4.h"

;;; **********************************************************************
;;;
;;; Y/N? - simple test for Y/N input
;;;
;;; Beeps and waits for up to 25 seconds for input.
;;; Executes next line if Y, skips next line if N.
;;;
;;; Original idea from PANAME ROM, here modified a bit and with a time out
;;; counter.
;;;
;;; **********************************************************************

              .public `Y/N?`
              .section BoostCode

              .name   "Y/N?"
`Y/N?`:       s8=0
              s9=1
              gosub   ARGOUT        ; show alpha

              gosub   ENLCD
              ldi     0x3f          ; ?
              srsabc
              ldi     0x00e         ; N
              srsabc
              ldi     0x02f         ; /
              srsabc
              ldi     0x019         ; Y
              srsabc
              fllabc                ; rotate display
              gosub   ENCP00

5$:           ldi     12            ; outer counter (wait 25 seconds)
                                    ; A.X= inner counter, do not care what it
                                    ;      starts with
10$:          a=a+1   x
              gonc    11$
              c=c-1   x
              goc     35$           ; time out, do N alternative
11$:          chkkb
              gonc    10$           ; wait for key

              ldi     5             ; # of entries
              a=c     x
              gosub   keyDispatch
              .con    0x018         ; ON
              .con    0x016         ; Y
              .con    0x013         ; N
              .con    0x087         ; R/S
              .con    0x0c3         ; <-
              .con    0             ; end marker
              goto    40$           ; OFF
              goto    30$           ; Y
              goto    35$           ; N
              goto    20$           ; R/S
              goto    20$           ; <-

              gosub   BLINK1
              gosub   RSTKB         ; wait for key to release
              goto    5$            ; try again

20$:          golong  ERR110        ; stop and back step

30$:          s8=1                  ; Y
35$:          gosub   CLLCDE
              ldi     0x2e          ; east goose
              srsabc
              gosub   RSTMS0        ; enable chip 0, reset message flag
              ?s8=1
              golc    NOSKP         ; Y, execute next line
              golong  SKP           ; N, skip next line

40$:          golong  OFF
