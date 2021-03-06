#include "mainframe.h"

              .section ID
              .con    18            ; XROM
              .con    .fatsize FatEnd ; number of entry points
              .fat    Header

              .section FATEND
FatEnd:       .con    0, 0


              .section Code
              .name "-TEST BT 1A"
Header:       rtn


              .section TAIL
              .con    0             ; Pause
              .con    0             ; Running
              .con    0             ; Wake w/o key
              .con    0             ; Powoff
              .con    0             ; I/O
              .con    0             ; Deep wake-up
              .con    0             ; Memory lost
              .text   "A1TB"        ; Identifier LT-1A
              .con    0             ; checksum position
