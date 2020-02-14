#include "mainframe.h"
#include "OS4.h"

;;; **********************************************************************
;;;
;;; CLKYSEC - Clear all secondary key assignments
;;;
;;; **********************************************************************

              .section BoostCode
              .public CLKYSEC
              .name   "CLKYSEC"
CLKYSEC:      golong  clearSecondaryAssignments
