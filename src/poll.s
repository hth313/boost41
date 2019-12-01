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
              goto    pollReturn    ; (P+1) failed, not enough memory
                                    ; (P+2) success
              ldi     .low12 extensionHandlers
              gosub   activateShell
              goto    pollReturn    ; (P+1) failed, not enough memory
                                    ; (P+2) success
pollReturn:   gosub   LDSST0
              c=n
              golong  RMCK10


;;; **********************************************************************
;;;
;;; Poll vectors, module identifier and checksum
;;;
;;; **********************************************************************

              .con    0             ; Pause
              .con    0             ; Running
              .con    0             ; Wake w/o key
              .con    0             ; Powoff
              .con    0             ; I/O
              goto    deepWake      ; Deep wake-up
              goto    deepWake      ; Memory lost
              .con    1             ; A
              .con    '1'           ; 1
              .con    0x0f          ; O (not tagged for banks)
              .con    0x202         ; B (tagged as having secondaries)
              .con    0             ; checksum position
