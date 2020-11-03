#ifndef __BOOST_INTERNALS_H__
#define __BOOST_INTERNALS_H__

// Macro to switch to given bank on the fly.
switchBank:   .macro  n
              enrom\n
10$:
              .section BoostCode\n
              .shadow 10$
              .endm

// Operands
#define OperandX    115

// Support routines
              .extern `getX<256`, `getX<999`, `getA<999`

;;; **********************************************************************
;;;
;;; Key sequence parsing.
;;;
;;; **********************************************************************

acceptAllValues: .equlab xargumentEntry

// Flag number to permit EEX key, use ParseNumber_AllowEEX below in your code.
#define Flag_ParseNumber_AllowEEX  0

// Helper macros
#define OffsetParseNumberFlag 4
#define _ParseNumberMask(flag) (1 << (flag + OffsetParseNumberFlag))

// Mask bit for permitting EEX key
#define ParseNumber_AllowEEX  _ParseNumberMask(Flag_ParseNumber_AllowEEX)

#endif // __BOOST_INTERNALS_H__
