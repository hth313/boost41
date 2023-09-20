.. index:: stack buffer, buffer stack
.. _stack:

************
Buffer stack
************

The RPN stack is central in the HP-41. However, it is very short and
mostly suitable for intermediate values in calculations. Boost
provides a dynamic stack that can be used to tuck away values and
contexts, and later restore them. This allows RPN program or routines
to have a cleaner interface, not messing things up inside a
subroutine.

The buffer stack provided here aims to solve this problem. Functions
to push and pop values to and from a dynamic stack are provided. The
actual storage for the stack is buffer number 3. Space is dynamically
allocated and returned from the free memory pool as needed.


.. hint::

   To make the buffer stack work well you should keep some free
   registers around that can be used for the dynamic stack. This means
   that you should not fill your entire memory to the brim with
   programs or set data register size much larger than you actually
   need.


Stack limitations
=================

The buffer stack is mainly limited to available free memory, but there
is also a hard limit to 253 registers of dynamic stack space due to a
buffer being limited to maximum 255 registers (two registers are used
for overhead).

The registers needed to push the Alpha register varies from zero to
four registers. In order to keep track of the number of registers used
to represent the Alpha register, the count 0--4 is stored in the
buffer trailer register. This limits the push depth of the Alpha
register to 13.

Buffer keeping
==============

The stack is created as needed and will remain until you have popped
all  values from it or explicitly delete it. The buffer will be
deleted at power on if the stack is empty. This will reclaim the two
remaining registers (header and trailer).

.. note::

   If you abort a calculation so that things are left on the stack,
   they are not reclaimed and will continue to occupy memory. If you have done
   this and you know that you will never need those pushed items anymore,
   you may want to explicitly remove the stack buffer (``CLSTBUF``).
   The easiest way to see if you have a stack buffer left behind is to
   run ``CAT 07`` and look for buffer number 3 in it. If it exists,
   you can use the ``C`` key to erase the buffer when the catalog is
   stopped and showing buffer 3.

Sanity checking
===============

There are no actual tagging of elements on the stack like you have on
an RPL machine. It is assumed that you write programs that pair stack
pushes with pops properly.

However, some elements on the stack do have tags (magic numbers) to
detect bad stack use. When you push and pop the flag register, the
system flags are not affected. That unused area is also used for a magic
number to detect mismatched stack operations.

Return stack extension
======================

Extending the return stack also includes some extra sanity checking
where the (unused) PC field of the record in the buffer stack is used
to tell if the top element on the stack is a return stack push.
This is useful as you may need multiple return stack extensions to
hold the recursion depth.
In such case you can push something else on the stack before deep
recursion and use inspection of the top of stack (``TOPRTN?``) to see
if it is a return stack entry to control up-recursion. An alternative
way would be to keep track of the number of return stacks pushed in
some data register.

The return stack extension is not transparent in that you cannot
blindly use ``XEQ`` and ``RTN`` to arbitrary depth.
You will need to use ``PUSHRST`` and ``POPRST`` at appropriate times
and provide your own logic for controlling this. You can use the other
return stack utilities like ``RTN?`` and ``RTNS`` to manage the call
stack extension.

Error messages
==============

The following error messages are possible:

``NO ROOM``
   no more space in the free memory area, or buffer cannot be grown
   due to size and representation contraints

``STACK ERR``
   this is given if you try to pop from an empty stack, or it is
   determined that you tried to pop something that is not the expected
   top stack element

Functions
=========

PUSH _ _
--------

.. index:: push; register

Push a single register to the stack. This function takes a single
postfix argument which allows for data registers and RPN stack
registers to be pushed.

POP _ _
-------

.. index:: pop; register

Pop a single register from the stack. This function takes a single
postfix argument which allows for data registers and RPN stack
registers to be popped.

.. note::

   A ``POP X`` will replace the value in ``X`` register without
   having any other affect on the stack. Thus, ``POP`` is more like
   ``STO`` to the given location than a ``RCL`` of a value.

PUSHA
-----

.. index:: push; Alpha register

Push the Alpha register on the buffer stack. You can have a maximum of
13 Alpha registers on the stack at any time. Trying to push more will
result in a ``NO ROOM`` error message. The actual register consumption
depends on how long the string in the Alpha register is. Pushing an
empty Alpha register costs nothing, apart from using up one of the 13
levels.

POPA
----

.. index:: pop; Alpha register

Pop the Alpha register from the buffer stack.

PUSHFLG
-------

.. index:: push; flags

Push the flag register.

POPFLG
------

.. index:: pop; flags

Pop the flag register.

PUSHRST
-------

.. index:: push; return stack

Push the call stack on the buffer stack. This also clears all
current stack levels as the  buffer stack can be seen as an extension
to the call stack.

POPRST
------

.. index:: pop; return stack

Pop the call stack from the buffer stack.

PUSHST
------

.. index:: push; RPN stack

Push the entire RPN ``XYZTL`` stack (five registers) to the buffer
stack.

POPST
-----

.. index:: pop; RPN stack

Pop the entire RPN ``XYZTL`` stack from the buffer
stack.

POPFLXL
-------

.. index:: pop; RPN stack

POP and fill ``X`` and ``L`` registers. This function pops the entire
RPN ``XYZTL`` stack from the buffer stack, but keeps the current value
in the ``X`` register. The popped ``X`` value is moved to the ``L``
(last ``X``) register.

This is useful when you write a RPN program that takes a single operand
from ``X``, performs some calculations that disrupts the stack and
leaves a result in ``X``. Now with ``POPFLXL`` you can restore the
other stack registers and as a bonus have a proper last ``X`` value, so
that your RPN program behaves as a normal single argument function,
e.g. like ``SIN``.

POPDRXL
-------

.. index:: pop; RPN stack

POP, drop and fill ``X`` and ``L`` registers. This function pops the
entire RPN ``XYZTL`` stack from the buffer stack, but keeps the
current value in the ``X`` register. The popped ``X`` value is moved
to the ``L`` (last ``X``) register. This also drops the RPN stack to
simulate that it was dropped, meaning the old ``T`` register is
duplicated to ``Z``, and the old ``Z`` is dropped to ``Y`` while the
old ``Y`` value is discarded.

This is useful when you write a routine that takes two operands from
``X`` and ``Y``, performs some calculations that disrupts the stack
and leaves a result in ``X``. Now with ``POPDRXL`` you can restore the
other stack registers and as a bonus have a proper
last ``X`` value, so that your RPN program behaves as a normal two
arguments function, e.g. like ``+``.

PUSHBYX
-------

.. index:: push; data registers

Push a range of data registers. Takes a register range ``RRR.BBB``
in the ``X`` register. ``RRR`` is the first register in the range and
``BBB`` is the last register to push.

POPBYX
-------

.. index:: pop; data registers

Pop a range of data registers. Takes a register range ``RRR.BBB``
in the ``X`` registers. ``RRR`` is the first register in the range and
``BBB`` is the last register to pop.

STACKSZ
-------

.. index:: buffer stack; depth, stack buffer; depth

This returns the size of buffer stack to the ``X`` register. Pushing
anything on the stack will increase this number. Popping something
from the stack will make this number return to the same value as it was
before the push-pop operation.
Thus, this number can be used as a gauge to see if we are back
to a previous point. It can also be used to see if things have been
added to the stack or removed below a given point.

The actual number returned is the sum of the stack registers used by
the buffer and the number of Alpha register pushes that are on the
stack. The two register buffer overhead is not included in this
count. The means that an empty stack and a non-existing buffer stack
both will return 0.

TOPRTN?
-------

Test if the top level record on the buffer stack is a return stack
record. This can be used to control recursion to see when you have
exhausted the return stacks pushed on the buffer stack.

To make this work in a reliable way, you should start by pushing
something else on the stack first before you start recursion. If you
have nothing you already pushed, you can push the ``X`` register using
``PUSH X`` to serve as a marker. When you are done, simply pop it off
the stack. If you do not want to clobber ``X`` doing that, you can for
example pop it to the ``T`` register instead (or the ``Q`` register if
you are into synthetic programming and do not want to even disturb
``T``).

.. note::

   There are two ways this function can fail to work as intended. If
   the next record on the stack is the Alpha register, it may be empty
   in which case this function will actually look at the next thing
   on the stack. Also, the test for whether the top element is a
   return stack record checks a magic number (``0x2ac`` in the
   rightmost part). There is a (very) minor risk that what is pushed
   happens to contain that pattern and being something else. However,
   no normalized number has a bit pattern like this and ``0xac`` is not a
   normal letter.

CLSTBUF
-------

Remove the stack buffer.
