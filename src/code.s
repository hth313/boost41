#include "mainframe.h"
#include "boostInternals.h"

;;; **********************************************************************
;;;
;;; CODE - encode hex number in ALPHA as value in X
;;;
;;; This is the well known conversion routine that allows you to create
;;; any binary 56-bit number to X.
;;;
;;; Written by Ken Emery.
;;;
;;; ************************************************************

              .public CODE
              .section BoostCode2
              .name   "CODE"
CODE:         ldi     0x049         ; B[13]= 4 and B[12]= 9
              rcr     2             ;  4 is for testing 0-9 versus A-F
              bcex                  ;  9 is for converting low nibble
                                    ; ASCII A-F
              pt=     12            ;  to binary value
              c=regn  N             ; read second ALPHA register
5$:           acex                  ; string to A
6$:           ?a<b    s             ; 0-9?
              goc     1$            ; yes
              a=a+b   pt            ; no, adjust ASCII A-F (low digit)
                                    ; to binary
                                    ; value
1$:           asl                   ; shift ASCII string
              acex    s             ; move result digit to C<13>
              asl                   ; keep shifting ASCII string
              rcr     13            ; prepare for next result digit
              ?a#0                  ; exhausted input?
              goc     6$            ; no
              ?s1=1                 ; first time?
              goc     2$            ; no, we are done
              s1=1                  ; mark second time
              a=c
              c=regn  M             ; read first ALPHA register
              gonc    5$            ; loop over

2$:           bcex                  ; recall result to X
              switchBank 1
              golong  RCL
