#include "mainframe.h"
#include "OS4.h"
#include "boostInternals.h"

;;; **********************************************************************
;;;
;;; Poll vectors and identification for bank 2.
;;;
;;; **********************************************************************

              .section BoostTail2
              goto    setBank1Poll  ; Pause
              goto    setBank1Poll  ; Running
              goto    setBank1Poll  ; Wake w/o key
              goto    setBank1Poll  ; Powoff
              goto    setBank1Poll  ; I/O
              goto    deepWake2     ; Deep wake-up
              goto    deepWake2     ; Memory lost
              .con    2             ; B
              .con    '0'           ; 0
              .con    0x20f         ; O (tagged for having banks)
              .con    0x002         ; B (no secondaries,
                                    ;    those are in the primary bank)
              .con    0             ; checksum position

;;; ----------------------------------------------------------------------
;;;
;;; Reset the bank and go back to poll vector.
;;; Used for safety if we left another bank enabled by accident.
;;;
;;; ----------------------------------------------------------------------

              .section BoostCode2
              .shadow XRMCK10 - 1
setBank1Poll: enrom1


;;; ----------------------------------------------------------------------
;;;
;;; Switch back to bank 1 and fall into deepWake
;;;
;;; ----------------------------------------------------------------------

              .section BoostCode2
              .shadow deepWake - 1
deepWake2:    enrom1

              .section BoostPollPart2
doStackBuffer:
              ldi     StackBuffer
              gosub   findBuffer
              goto    pollReturn    ; (P+1) no stack buffer
              rcr     10            ; check for size 2
              c=0     xs
              c=c-1   x
              c=c-1   x
              ?c#0    x
              goc     reclaimStackBuffer ; not size 2, we reclaim it
              goto    doStackBuffer2

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

              .section BoostPoll
              .extern catShell, extensionHandlers
doStackBuffer2:
              acex    x             ; has size 2
              a=c     x
              c=c+1   x
              dadd=c
              c=data                ; read trailer register
              c=c-1   s
              ?c#0    s
              gonc    pollReturn    ; it is really empty, do not reclaim it
reclaimStackBuffer:
              acex    x             ; reclaim the stack buffer
              dadd=c
              c=data
              c=c+1   s
              data=c
pollReturn:   gosub   LDSST0
              c=n
XRMCK10:      golong  RMCK10

deepWake:     n=c
              ldi     0x001         ; Use at least major version 0 and API 1
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
              goto    doStackBuffer

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
              .con    2             ; B
              .con    '0'           ; 0
              .con    0x20f         ; O (tagged for having banks)
              .con    0x202         ; B (tagged as having secondaries)
              .con    0             ; checksum position
