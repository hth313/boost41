#include "mainframe.h"
#include "OS4.h"

              .section BoostPoll
;;; **********************************************************************
;;;
;;; deepWake - poll vector called at power on
;;;
;;; Here we check whether we have OS4 installed and complain if
;;; it is not present. We wait a while and force the calculator OFF
;;; again.
;;; If Ratatosk is present, we reclaim our hosted SEED buffer.
;;;
;;; **********************************************************************

              .extern catShell, extensionHandlers
deepWake:     n=c
              ldi     .low12 catShell ; activate CAT replacement
              gosub   activateShell
              goto    10$           ; (P+1) failed, not enough memory
                                    ; (P+2) success
              ldi     .low12 extensionHandlers
              gosub   activateShell
              goto    10$           ; (P+1) failed, not enough memory
                                    ; (P+2) success
10$:          gosub   LDSST0
              c=n
              golong  RMCK10


;;; **********************************************************************
;;;
;;; powerOff - poll vector called at power off
;;;
;;; As we are a user of direct X-memory data operations, we log out that
;;; system to ensure the proper integrity of the system. What happens is
;;; that we restore the '169' cold start constant that may be off due to
;;; being used for caching the current file. As mainframe will call MEMCHK
;;; after this poll vector, we do not want anything but '169' in that slot.
;;; This also ensures that the cold start constant is in place in case
;;; Ratatosk is unplugged while power down and acts as the intended safe
;;; guard to detect memory loss during power off.
;;;
;;; **********************************************************************

powerOff:  ;   gosub   logoutXMem
              golong  RMCK10

;;; **********************************************************************
;;;
;;; Poll vectors, module identifier and checksum
;;;
;;; **********************************************************************

              .con    0             ; Pause
              .con    0             ; Running
              .con    0             ; Wake w/o key
              goto    powerOff      ; Powoff
              .con    0             ; I/O
              goto    deepWake      ; Deep wake-up
              goto    deepWake      ; Memory lost
              .text   "A1OB"        ; Identifier BO-1A
              .con    0             ; checksum position
