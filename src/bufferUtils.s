#include "mainframe.h"
#include "OS4.h"
#include "boostInternals.h"

              .section BoostCode2

;;; **********************************************************************
;;;
;;; CLSTBUF - remove stack buffer
;;;
;;; **********************************************************************

              .public CLSTBUF
              .name   "CLSTBUF"
CLSTBUF:      ldi     StackBuffer
              goto    CLBUF10


;;; **********************************************************************
;;;
;;; CLBUF - remove a buffer
;;;
;;; **********************************************************************

              .public CLBUF
              .name   "CLBUF"
CLBUF:        rxq     BCDBIN1
CLBUF10:      gosub   findBuffer
              goto    toERRNE20     ; (P+1) does not exist
              c=0     s             ; mark for removal
              data=c
              c=0     x
              dadd=c                ; select chip 0
              gosub   PKIOAS
CLBUF20:      gosub   resetMyBank   ; return

;;; **********************************************************************
;;;
;;; CLHBUF - remove a hosted buffer
;;;
;;; **********************************************************************

              .public CLHBUF
              .name   "CLHBUF"
CLHBUF:       c=regn  X
              gosub   BCDBIN
              ?c#0    xs
              goto    toERRNE10
              gosub   findBufferHosted
toERRNE20:    goto    toERRNE10     ; (P+1) does not exist
              c=0
              pt=     13
              lc      8
              a=c                   ; A= 0x8000000...
              c=data                ; C= buffer header
              c=c|a                 ; set deletion bit
              data=c
              gosub   packHostedBuffers
              goto    CLBUF20

;;; **********************************************************************
;;;
;;; BUF? - does a buffer exist?
;;;
;;; **********************************************************************

              .public `BUF?`
              .name   "BUF?"
`BUF?`:       rxq     BCDBIN1
              gosub   findBuffer
              goto    toSKP         ; (P+1) does not exist, skip next line
toNOSKP:      s7=0
              gosub   NOSKP_resetMyBank
toSKP:        s7=0
              gosub   SKP_resetMyBank

;;; **********************************************************************
;;;
;;; HBUF? - does a hosted buffer exist?
;;;
;;; **********************************************************************

              .public `HBUF?`
              .name   "HBUF?"
`HBUF?`:      c=regn  X
              gosub   BCDBIN
              ?c#0    xs
              goc     toSKP
              gosub   findBufferHosted
              goto    toSKP
              goto    toNOSKP

;;; * Support routine for getting a normal buffer number
BCDBIN1:      c=regn  X
              gosub   BCDBIN
              pt=     0
              a=0     x
              a=c     pt
              ?a#c    x
              rtnnc
toERRNE10:    goto    toERRNE

;;; **********************************************************************
;;;
;;; HBUFSZ - get the size of a hosted buffer
;;;
;;; **********************************************************************

              .public HBUFSZ
              .name   "HBUFSZ"
HBUFSZ:       c=regn  X
              gosub   BCDBIN
              ?c#0    xs
              goc     toERRNE
              gosub   findBufferHosted
              goto    toERRNE
              goto    BUFSZ10

toERRNE:      gosub   ERRNE_resetMyBank

;;; **********************************************************************
;;;
;;; BUFSZ - get the size of a buffer
;;;
;;; **********************************************************************

              .public BUFSZ
              .name   "BUFSZ"
BUFSZ:        rxq     BCDBIN1
              gosub   findBuffer
              goto    toERRNE       ; (P+1) does not exist
BUFSZ10:      rcr     10
              c=0     s
              c=0     m
              c=0     xs
              switchBank 1
              golong  CtoXFill
