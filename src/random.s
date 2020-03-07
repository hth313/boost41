#include "mainframe.h"
#include "time.h"
#include "OS4.h"

;;; **********************************************************************
;;;
;;; RNDM - produce a random number
;;; RNDM0 - same as RNDM, but returns value in A (see RNDMA below)
;;;
;;; Seed (last pseudo random number) is kept inside buffer 6.
;;; If no buffer exists it will be created and the initial pseudo random
;;; number will be taken from time information in the time module.
;;; If there is no time module present, a zero will be stored as initial
;;; seed.
;;;
;;; Buffer is written as:
;;; 6601SSSSSS0EEE
;;; in other words, it is a single register buffer with a 6-digit
;;; (fractional) decimal number where the mantissa is right
;;; justified 3 position during storage.
;;;
;;; Note: The two entry points RNDM and SEED are ready to be installed
;;;       in a FAT.
;;;       In addition, it is possible to use some additional routines
;;;       from inside MCODE, see comments about RNDM0, RNDMA StoreSeed
;;;       below.
;;;
;;; **********************************************************************

              .public RNDM, SEED
              .public RNDM0, RNDMA, StoreSeed
              .section BoostCode, reorder

              .name   "RNDM"
RNDM:         s9=1
RNDM0:        c=0     x             ; buffer 0
              gosub   chkbufHosted  ; seek seed buffer
              goto    createSeedBuffer ; (P+1) no buffer
              c=data
              acex                  ; move packed seed to A

              a=0     s             ; unpack seed
              asl     m
              asl     m
              asl     m

;;; **********************************************************************
;;;
;;; RNDM0 - entry point from MCODE for first number
;;; RNDMA - entry point from MCODE for successive numbers
;;;
;;; Callable routines to generate next pseudo random number.
;;;
;;; NOTE!!! Both need to be called with S9 set to 0 !!!!!!
;;;
;;; These two routines make it possible to use RNDM from MCODE without
;;; having the value returned to X register (on the stack).
;;; Instead the number is returned to register A (and C).
;;;
;;; RNDM0 produces the first number, using the value stored in the buffer
;;; as the previous pseudo random number.
;;; RNDMA produces the next pseudo random number based on the value given
;;; in A. It is meant to be used to get successive numbers.
;;; When you are done you may want to call StoreSeed to write the final
;;; pseudo random number to buffer.
;;;
;;; If you find it fishy to keep track of the first call, simply make a
;;; call to RNDM0 to get a value and tuck it away. Then see RNDMA as the
;;; way to get all pseudo random numbers.
;;;
;;; IN: A= fractional seed (RNDMA)
;;;     S9= set to 0 before calling
;;;
;;; OUT: A= next pseudo random number
;;;      C= same as A
;;;      hex mode
;;;
;;; Uses: A, B, C, M
;;;       N, DADD, PFAD, +3 sub levels (RNDM0)
;;;                      +2 sub levels (RNDMA)
;;;
;;; **********************************************************************

RNDMA:        setdec
              c=0                   ; 9821
              ldi     3
              pt=     12
              lc      9
              lc      8
              lc      2
              lc      1
              gosub   MP2_10        ; multiply
              a=c
              c=0                   ; .211327
              c=c-1   x             ; exponent: 999
              pt=     12
              lc      2
              lc      1
              lc      1
              lc      3
              lc      2
              lc      7
              gosub   AD2_10        ; add

              s5=0
              gosub   INTFRC        ; get fractional part
              a=c                   ; seed to A
              sethex
              ?s9=1
              rtnnc                 ; return if RNDMA used with S9=0
              b=a                   ; result to B

              asr     m             ; pack seed
              asr     m
              asr     m

              c=data                ; read buffer header
              pt=     9             ; build new buffer header using new
                                    ; seed
              acex    wpt
              data=c                ; write updated buffer back

              golong  RCL           ; recall random number to x

RNDM00:       goto    RNDM0
createSeedBuffer:
              c=0     x
              n=c                   ; N[1:0]= buffer number
              c=c+1   x             ; request one register
              gosub   newHostedBuffer
              goto    toNoRoom      ; no room
              c=0                   ; invent a new seed
              gosub   IGDHMS        ; init and get hms (uses 3 sub levels!)
              ?c#0
              gonc    1$            ; no time module, store 0

              rcr     9             ; make use of time
              c=0     s             ; C= 0HHMMSSCCDDDDD
              c=0     x
              setdec
              c=c-1   x             ; C= DHHMMSSCCDD999
              sethex
1$:           n=c                   ; N= seed
              gsbp    store_seed
              goto    RNDM00        ; go back

;;; **********************************************************************
;;;
;;; SEED - initialize with specific seed
;;;
;;; Takes the seed value from X and stores it in the buffer.
;;;
;;; **********************************************************************

              .name   "SEED"
SEED:         c=regn  x             ; entry for SEED
              n=c

store_seed:   c=n                   ; C= new seed
              setdec                ; take fractional part of seed
              s5=0
              gosub   INTFRC
              sethex
              n=c                   ; save in N

;;; **********************************************************************
;;;
;;; StoreSeed - save seed to buffer
;;;
;;; Callable routine to save seed to the seed buffer.
;;; This routine assumes that the seed buffer already exists. This is true
;;; if a call has been made to RNDM0.
;;;
;;; IN: N= fractional seed
;;; OUT: C= buffer header register
;;;      Seed buffer register selected.
;;;
;;; Uses: A, B.X, C, G, DADD, +3 sub levels
;;;
;;; **********************************************************************

StoreSeed:    c=0     x
              gosub   chkbufHosted  ; find seed buffer
              goto    toERRNE       ; (this should not happen, prior call to
                                    ;  RNDM0 assumed)
              c=data                ; C= buffer header
              acex                  ; buffer header to A
              c=n                   ; get new seed
              acex                  ; seed to A
              asr     m             ; pack seed
              asr     m
              asr     m
              pt=     9             ; build new header
              acex    wpt
              data=c                ; write back updated header
              rtn

toNoRoom:     golong  noRoom
toERRNE:      golong  ERRNE
