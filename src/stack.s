#include "mainframe.h"
#include "OS4.h"
#include "boostInternals.h"

#define ReturnMagicNumber 0x2ac
#define FlagsMagicNumber 0x1fe

;;; **********************************************************************
;;;
;;; Stack handling functions.
;;;
;;; A stack is set up in the free area in buffer #7. This stack can be
;;; used to store various things, such as alpha register, flags or data.
;;; The idea is to help RPN program writers to preserve certain data to
;;; make programs less intrusive. A typical case is to restore flags to
;;; a previous state, but this can also be useful for the alpha register,
;;; mimic normal stack behavior for one or two argument functions and
;;; even data registers. It also provides for saving the return stack
;;; registers, allowing for deeper subroutine nesting.
;;;
;;; The buffer has a simple header using buffer 3. There is also a trailer
;;; register which keeps track of the alpha register pushes. It keeps
;;; track of the size of the alpha registers pushed, including empty
;;; alpha register which takes no extra space! The disadvantage of this
;;; approach is that we are limited to 14 levels of alpha register push.
;;;
;;;
;;; **********************************************************************

              .public PUSH, POP
              .public PUSHA, POPA
              .public PUSHFLG, POPFLG
              .public PUSHST, POPST
              .public POPDRXL, POPFLXL
              .public PUSHRST, POPRST
              .public pushDataX, popDataX

;;; **********************************************************************
;;;
;;; PUSHFLG - push the flag register
;;;
;;; **********************************************************************

              .section BoostCode
              .name   "PUSHFLG"
PUSHFLG:      c=regn  14
              ldi     FlagsMagicNumber
              goto    push1

;;; **********************************************************************
;;;
;;; PUSH - postfix operand function to push any data register
;;;
;;; **********************************************************************

              .name   "PUSH"
PUSH:         nop
              nop
              gosub   argument
              .con    0x73          ; X register default, allow ST
              gosub   ADRFCH

push1:        n=c
              rxq     reserve1
              c=b     x
push20:       dadd=c
              c=n
              data=c
              rtn

;;; **********************************************************************
;;;
;;; PUSHRST - push the RPN return stack
;;;
;;; **********************************************************************

              .name   "PUSHRST"
PUSHRST:      ldi     2
              a=c     x
              rxq     reserve
              c=0
              dadd=c
              c=regn  12            ; PC and first levels
              a=c
              ldi     ReturnMagicNumber
              n=c                   ; N= value to write to buffer stack
              pt=     3
              c=0
              acex    wpt           ; reset return stack levels
              regn=c  12            ; write back
              c=regn  11
              m=c                   ; M= rest of levels
              c=0
              regn=c  11            ; reset return stack levels
              c=m
              bcex
              dadd=c                ; select first stack register
              bcex
              data=c
              bcex
              c=c+1   x
              goto    push20

;;; **********************************************************************
;;;
;;; reserve - allocate room in stack buffer
;;; reserve1 - allocate one register in stack buffer.
;;;
;;; Allocate room in the stack buffer. Buffer is created if needed and
;;; grown to accomodate the space needed.
;;;
;;; In: A.X= number of registers to allocate
;;; Out: B.X= the location of the newly added space
;;;      A.X= buffer header address
;;;      DADD= chip 0 selected
;;; Uses: A, B, C, G, DADD, S7, active PT, +2 sub levels
;;;
;;; **********************************************************************

reserve1:     a=0     x
              a=a+1   x
reserve:      pt=     0
              acex    x
              g=c                   ; G= number of registers to add
              ?c#0    xs
              goc     100$
              ldi     StackBuffer
              gosub   ensureBufferWithTrailer
              goto    100$          ; (P+1) not enough room
              c=data
              rcr     10            ; C[1:0]= buffer size
              c=0     xs            ; C.X= buffer size
              c=c-1   x             ; C.X= offset to insert point
              gosub   growBuffer
              goto    100$          ; (P+1) not enough room
              golong  ENCP00

100$:         golong  noRoom

;;; **********************************************************************
;;;
;;; POPA - pop alpha register
;;;
;;; **********************************************************************

              .name   "POPA"
POPA:         c=0     x             ; assume zero register for a start
              rxq     pop
              rxq     trailer
              c=c-1   s             ; decrement alpha push counter
              ?c#0    s             ; did we go too far?
              gonc    toStackError2 ; yes, STACK ERROR
              a=c
              asl                   ; A.S= alpha block size
                                    ; A[12:0]= updated remainging alpha push counts
              acex    m
              acex    x
              data=c                ; write out updated trailer
              acex    s
              c=0     x
              rcr     -1            ; C.X= number of registers to pop
              ?c#0    x             ; are we popping empty alpha?
              gonc    10$           ; yes, clear alpha
              a=c     x             ; A.X= number of registers to pop
              rxq     pop           ; prepare for pop of the alpha block
              ldi     5             ; point to first alpha register
              n=c
              goto    popDataX10

10$:          dadd=c                ; select chip 0
              golong  CLA           ; go and clear alpha

toStackError2:
              rgo     stackError

;;; **********************************************************************
;;;
;;; POPFLG - pop the flag register
;;;
;;; **********************************************************************

              .name   "POPFLG"
POPFLG:       rxq     pop1
              a=c                   ; A= popped value
              ldi     FlagsMagicNumber
              ?a#c    x             ; magic number good?
              goc     toStackError2 ; no
              c=0                   ; yes
              dadd=c
              c=regn  14            ; use existing flags 44-55
              acex    m
              acex    s
              regn=c  14
              goto    shrinkStackBuffer

;;; **********************************************************************
;;;
;;; POPBYX - pop a data block by specification in X register
;;;
;;; **********************************************************************

              .name   "POPBYX"
popDataX:     rxq     dataRange
              rxq     pop
popDataX10:   c=0     m
              pt=     3
              c=g
              a=c     m             ; A.M= number of registers
              goto    20$
10$:          cmex
              dadd=c                ; select a data register
              c=c+1   x
              cmex
              c=data                ; read data register
              cnex
              dadd=c
              c=c+1   x
              cnex
              data=c
20$:          a=a-1   m
              gonc    10$
              goto    toPOPRST10

;;; **********************************************************************
;;;
;;; POP - postfix operand function to pop any data register
;;;
;;; **********************************************************************

              .name   "POP"
POP:          nop
              nop
              gosub   argument
              .con    0x73          ; X register default, allow ST
              gosub   ADRFCH
              rxq     pop1          ; get pointer to stack block
              cnex
              dadd=c                ; select destination
              cnex
              data=c                ; write to destination

;;; * Fall into shrinkStackBuffer

;;; **********************************************************************
;;;
;;; shrinkStackBuffer - final step after popping, actually shrink buffer
;;;
;;; **********************************************************************

shrinkStackBuffer:
              c=m                   ; C.X= offset to first register
              golong  shrinkBuffer

toPOPRST10:   goto    POPRST10      ; relay

;;; **********************************************************************
;;;
;;; POPST - pop the RPN stack
;;;
;;; **********************************************************************

              .name   "POPST"
POPST:        ldi     5
              a=c     x
              rxq     pop
              ldi     4
              a=c     x             ; A.X= pointer to stack registers
10$:          c=m
              dadd=c                ; select stack register
              c=c+1   x             ; step pointer
              m=c
              c=data                ; read it
              acex    x
              dadd=c                ; select RPN stack register
              acex    x
              data=c                ; write it
              a=a-1   x
              gonc    10$
              goto    POPRST10

;;; **********************************************************************
;;;
;;; POPRST - pop the RPN return stack
;;;
;;; **********************************************************************

              .name   "POPRST"
POPRST:       ldi     2
              a=c     x
              rxq     pop
              n=c                   ; N= upper return stack registers
              c=m
              c=c+1   x
              dadd=c                ; select next stack buffer register
              c=data                ; read it
              a=c
              ldi     ReturnMagicNumber
              ?a#c    x             ; correct?
              goc     toStackError  ; no
              c=0
              dadd=c                ; select chip 0
              c=n
              regn=c  11            ; write to upper return stack register
              c=regn  12            ; C[3:0]= RPN program pointer
              pt=     3
              a=c     wpt
              acex
              regn=c  12            ; write lower return levels with current PC
POPRST10:     abex    x
POPRST20:     goto    shrinkStackBuffer

;;; **********************************************************************
;;;
;;; POPDRXL - pop the RPN stack, behave as DRop and fill XL
;;;
;;; This will pop the entire stack, but the current X register is
;;; treated as a result and kept. The old X (from the push stack)
;;; is moved to L. This mimics an RPN function with two arguments
;;; that has a polite stack behavior (dropping the stack, duplicating
;;; T, saving last X).
;;;
;;; **********************************************************************

              .name   "POPDRXL"
POPDRXL:      s8=0
              goto POPFLXL10

;;; **********************************************************************
;;;
;;; POPFLXL - pop the RPN stack, behave as fill XL instruction
;;;
;;; This will pop the entire stack, but the current X register is
;;; treated as a result and kept. The old X (from the push stack)
;;; is moved to L. This mimics an RPN function with one argument
;;; that has a polite stack behavior (preserving YZT, saving last X).
;;;
;;; **********************************************************************

toStackError: goto    stackError    ; relay
toPOPRST20:   goto    POPRST20      ; relay

              .name   "POPFLXL"
POPFLXL:      s8=1
POPFLXL10:    ldi     5
              a=c     x
              rxq     pop
              acex    x             ; C.X= buffer header
              n=c                   ; N.X= buffer header
              c=m                   ; C.X= address of first register in stack block
              c=c+1   x             ; point to old X
              dadd=c
              a=c     x
              c=data                ; C= old X
              bcex                  ; B= old X
              c=0
              dadd=c
              bcex
              regn=c  4             ; write old X to L
              a=a+1   x             ; A.X= points to old Y
              ?s8=1                 ; dropping stack?
              goc     10$           ; no
              a=a+1   x             ; yes point to old Z
10$:          ldi     2             ; point to Y register
              bcex                  ; B.X= write pointer
20$:          acex    x
              dadd=c                ; select next register in push stack
              acex    x
              a=a+1   x
              c=data                ; read it
              bcex                  ; C.X= where to write in stack
              dadd=c
              c=c-1   x             ; step to next register
              goc     30$           ; this is the last one
              bcex
              data=c                ; write to stack
              ?s8=1
              goc     20$
              ?b#0    x
              goc     20$
              a=a-1   x             ; duplicate T when dropping
              goto    20$

30$:          bcex
              data=c                ; write to stack
              c=n
              a=c     x             ; A.X= buffer header
              goto    toPOPRST20

stackError:   gosub   errorMessage
              .messl  "STACK ERR"
              golong  errorExit

;;; **********************************************************************
;;;
;;; pop - prepare for popping stack
;;;
;;; This routine finds the location of the topmost stack block of a given
;;; size. It does not actually pop the stack as the caller needs to move
;;; the data before it can be removed from the stack.
;;; If you actually just want to pop and discard the given entity on the
;;; stack, simply call shrinkBuffer with the current setup.
;;;
;;; Note: If stack underflows this function will exit with STACK ERR
;;;       error message.
;;;
;;; In: A[1:0]= size of topmost stack block
;;; Out: B.X= buffer header address
;;;      A.X= buffer header address
;;;      C= contents of first register in stack block
;;;      M.X= address of first register in stack block (selected)
;;;      DADD= first register in stack block
;;;      G= size of topmost stack block
;;; Uses: A, C, B.X, M, PT, DADD, +1 sub level
;;;
;;; **********************************************************************

pop1:         a=0     x
              a=a+1   x
pop:          pt=     0
              acex    x
              g=c                   ; G= number of registers to remove later
              ldi     StackBuffer
              gosub   findBuffer
              goto    stackError    ; (P+1) no stack
              b=a     x             ; B.X= buffer header address
              rcr     10
              c=0     xs
              a=c     x             ; A.X= buffer size
              pt=     0
              c=g                   ; C.X= number of registers to pop
              c=a-c   x             ; C.X= offset to first register in stack block
              goc     stackError
              ?c#0    x
              gonc    stackError

              m=c                   ; M.X= offset to first register in lock
              a=b     x             ; A.X= buffer header address
              c=a+c   x             ; C.X= address of first register in block
              dadd=c                ; select it
              rtn

;;; **********************************************************************
;;;
;;; PUSHST - push the RPN stack
;;;
;;; **********************************************************************

              .name   "PUSHST"
PUSHST:       ldi     5
              a=c     x
              rxq     reserve
              ldi     4             ; pointer to L register
              a=c     x
10$:          acex    x
              dadd=c                ; select an RPN stack register
              acex    x
              c=data                ; read it
              bcex    x
              dadd=c                ; select location in push stack
              c=c+1   x             ; point to next register
              bcex    x
              data=c                ; write to stack
              a=a-1   x             ; decrement RPN stack pointer
              gonc    10$           ; not done
              rtn

;;; **********************************************************************
;;;
;;; PUSHA - push alpha register
;;;
;;; **********************************************************************

              .name   "PUSHA"
PUSHA:        pt=     13
              lc      4             ; assume we need 4 registers
              ldi     8
              a=c
              c=regn  8             ; upper 4 character register
              pt=     5
              c=0     wpt
              ?c#0                  ; non-empty?
              goc     20$           ; yes

10$:          a=a-1   s             ; step counter
              ?a#0    s
              gonc    20$           ; empty alpha register
              a=a-1   x
              acex    x
              dadd=c
              acex    x
              c=data
              ?c#0                  ; this register empty?
              gonc    10$           ; yes, keep looking

20$:          acex
              rcr     -1
              acex                  ; A.X= registers needed
              rxq     reserve       ; prepare
              rxq     trailer
              c=c+1   s
              c=c+1   s
              golc    noRoom        ; no space in trailer for another alpha push
              c=c-1   s             ; adjust counter
              a=c                   ; A[13]= adjusted counter
              csr                   ; C[11:0]= right shifted alpha push counts
              a=c     m
              a=c     x             ; A[13], A[11:0]= updated trailer
              pt=     12
              c=g                   ; C[12]= this push count
              a=c     pt            ; A= updated trailer register
              acex
              data=c                ; write back
              ldi     5
              n=c
              goto    pushBlock

;;; **********************************************************************
;;;
;;; PUSHBYX - push a data block by specification in X register
;;;
;;; **********************************************************************

              .name   "PUSHBYX"
pushDataX:    rxq     dataRange
              rxq     reserve
pushBlock:    c=0     m
              pt=     3
              c=g
              a=c     m             ; A.M= number of registers
              goto    20$
10$:          cnex
              dadd=c                ; select a data register
              c=c+1   x
              cnex
              c=data                ; read data register
              bcex
              dadd=c
              c=c+1   x
              bcex
              data=c
20$:          a=a-1   m
              gonc    10$
              rtn

dataRange:    s5=1
              gosub   getIndexX
              c=n
              a=c     x
              rcr     3
              n=c
              a=a-c   x
              golc    ERRDE         ; start > end
              ?a#0    xs            ; > 255 ?
              golc    ERRDE         ; yes
              a=a+1   x             ; A.X= number of registers needed
              rtn

trailer:      acex    x
              dadd=c                ; select buffer header
              acex
              c=data
              rcr     10
              c=0     xs
              c=c-1   x
              c=a+c   x
              dadd=c
              acex    x
              c=data
              rtn

;;; **********************************************************************
;;;
;;; STACKSZ - get a mesaurement of size of the stack buffer
;;;
;;; **********************************************************************

              .public STACKSZ
              .name   "STACKSZ"
STACKSZ:      ldi     StackBuffer
              gosub   findBuffer
              goto    20$           ; (P+1) no stack buffer
              a=c     m             ; A[11:10]= buffer size
              rxq     trailer
              c=0     x
              rcr     -1
              c=c-1   x             ; C.X= number of alpha pushes
              acex                  ; A.X= number of alpha pushes
              rcr     10
              c=0     xs            ; C.X= buffer size
              c=a+c   x             ; C.X= size of buffer plus number of alpha push
              c=c-1   x             ; compenstate for header and trailer register
              c=c-1   x
10$:          golong  CXtoX
20$:          c=0     x
              goto    10$

;;; **********************************************************************
;;;
;;; `TOPRTN?` - test if top element is a stack return record.
;;;
;;; **********************************************************************

              .public `TOPRTN?`
              .name   "TOPRTN?"
`TOPRTN?`:    ldi     StackBuffer
              gosub   findBuffer
              goto    10$           ; (P+1) negative
              ldi     3
              a=c     x
              rcr     10
              c=0     xs
              ?a<c    x             ; at least 4 buffer registers? (2 for header
                                    ;   and 2 for return stack record)
10$:          golnc   SKP           ; no
              c=m
              c=c+1   x             ; point to second register in record
              dadd=c
              c=data
              a=c
              ldi     ReturnMagicNumber
              ?a#c    x             ; magic number good?
              goc     10$           ; no
              golong  NOSKP         ; yes, return record appears to be at top
                                    ;   of stack
