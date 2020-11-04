#include "mainframe.h"
#include "OS4.h"
#include "boostInternals.h"

;;; **********************************************************************
;;;
;;; CLKYSEC - Clear all secondary key assignments
;;;
;;; **********************************************************************

              .section BoostCode2
              .public CLKYSEC, LKAON, LKAOFF, MAPKEYS
              .name   "CLKYSEC"
CLKYSEC:      gosub   clearSecondaryAssignments
              goto    done

;;; **********************************************************************
;;;
;;; CLKYSEC - Rebuild all key assignment bitmaps
;;;
;;; **********************************************************************

              .name "MAPKEYS"
MAPKEYS:      s2=0                  ; favor program assignments
              gosub   mapAssignments
              goto    done

              .name   "LKAON"
LKAON:        s8=1
              goto    KAONOFF
              .name   "LKAOFF"
LKAOFF:       s8=0
KAONOFF:      ldi     15
              gosub   findBuffer
              goto    done          ; (P+1) system buffer does not exist
                                    ;       this is not really possible
                                    ;       as we have install a system shell,
                                    ;       unless out of memory
              c=data                ; C= buffer header
              cstex
              ?s8=1                 ; enable it?
              goc     10$           ; yes
              st=1    Flag_HideTopKeyAssign
              goto    20$
10$:          st=0    Flag_HideTopKeyAssign
20$:          cstex
              data=c                ; write updated buffer header back
done:         switchBank 1          ; cannot use resetMyBank as all stack
                                    ;   level used up
              golong  NFRPU
