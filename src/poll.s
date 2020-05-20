#include "mainframe.h"
#include "OS4.h"

;;; **********************************************************************
;;;
;;; Poll vectors and identification for bank 2.
;;;
;;; **********************************************************************

              .section BoostTail2
              nop                   ; Pause
              nop                   ; Running
              nop                   ; Wake w/o key
              nop                   ; Powoff
              nop                   ; I/O
              goto    deepWake2     ; Deep wake-up
              nop                   ; Memory lost
              .con    1             ; A
              .con    '0'           ; 0
              .con    0x20f         ; O (tagged for having banks)
              .con    0x002         ; B (no secondaries,
                                    ;    those are in the primary bank)
              .con    0             ; checksum position

;;; ----------------------------------------------------------------------
;;;
;;; Switch back to bank 1 and fall into deepWake
;;;
;;; ----------------------------------------------------------------------

              .section BoostCode2
              .shadow deepWake - 1
deepWake2:    enrom1

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
              ldi     0x000         ; I need major version 0 at least
              gosub   checkApiVersionOS4
              ldi     .low12 catShell ; activate CAT replacement
              gosub   activateShell
              goto    pollReturn    ; (P+1) failed, not enough memory
                                    ; (P+2) success
              ldi     .low12 extensionHandlers
              gosub   activateShell
              goto    pollReturn    ; (P+1) failed, not enough memory
                                    ; (P+2) success
              ldi     0 | 128       ; hosted buffer 0
              gosub   reclaimHostedBuffer
pollReturn:   gosub   LDSST0
              c=n
              golong  RMCK10


;;; **********************************************************************
;;;
;;; Poll vectors, module identifier and checksum for primary bank
;;;
;;; **********************************************************************

              nop                   ; Pause
              nop                   ; Running
              nop                   ; Wake w/o key
              nop                   ; Powoff
              nop                   ; I/O
              goto    deepWake      ; Deep wake-up
              goto    deepWake      ; Memory lost
              .con    1             ; A
              .con    '0'           ; 0
              .con    0x20f         ; O (tagged for having banks)
              .con    0x202         ; B (tagged as having secondaries)
              .con    0             ; checksum position
