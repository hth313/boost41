.. index:: stack buffer, buffer stack
.. _stack:

************
Buffer stack
************

While the RPN stack is very central in the HP-41, it is very short and
mostly suitable for intermediate values in calculations. A dynamic
stack that can be used to tuck away values and contexts to make it
possible to later restore it and appear as we did not actually mess up
a lot of things in a subroutine is sorely missing.

The buffer stack in the Boost module aims to solve this problem. It
uses one of those buffers that allocate space in the free area to
implement a dynamic stack. Buffer number 7 is used for this.

.. hint::

   To make the buffer stack work well you should keep some free
   registers around that can be used for dynamic behavior. This means
   that you should not fill your entire memory to brim with programs
   or a too large register data area. This is easier today as you can
   normally create a module image or two with your most used RPN
   programs.


Stack limitations
=================

The buffer stack is mainly limited to available free memory, but there
is also a hard limit to 253 registers of dynamic stack space due to
buffers being limited to maximum 255 registers (two registers are used
for overhead).

The registers needed to push the alpha register varies from zero to
four registers. Thus, the minimal number of needed registers are used
to represent it. The trailer register in the buffer is used to keep
track of the pushed alpha sizes, which means that there can be up to
13 levels of alpha registers on the stack.

Buffer keeping
==============

The stack is created as needed and will remain until you pop values
from it or explicitly delete it. The buffer will be deleted at power
on if the stack is empty. This reclaims the two registers used for
it.

.. note::

   If you abort a calculation so that things are left on the stack,
   they are not reclaimed and continue to occupy memory. If you done
   this and you know you will never need those pushed items anymore
   you must explicitly remove the stack buffer (``CLSTBUF``).
   The easiest way to see if you have a stack buffer left behind is to
   run ```CAT 07`` and look for buffer number 7 in it. If it exists,
   you can use the ``C`` key to erase the buffer when the catalog is
   stopped and showing that buffer.

Sanity checking
===============

There is no actual tagging of elements on the stack like you have on
an RPL machine. It is assumed that you write programs that pair stack
pushes with pops properly.

However, some elements on the stack have tags (magic numbers) to
detect bad stack use. When you push and pop the flag register, the
system flags are not affected and that area is used for a magic number
to detect if you mismatched stack operations. This is because randomly
changing system flags may put your calculator in a weird state that
may require power cycling to restore proper operation.

Return stack extension
======================

Extending the return stack also includes some extra sanity checking
where the PC field of the record on the buffer stack is used to tell
if the top element on the stack is actually a return stack
extension. This is useful because the nature of a return stack is such
that we may want to implement recursion. With recursion we may need
multiple return stack stores and it depends on the recursion depth.
In such case you can push something else at start and use inspection
of the top of stack (``TOPRTN?``) to control recursion. An alternative
way would be to keep track of the number of such push elements in some
register.

The return stack extension is not transparent in that you can just
blindly ``XEQ`` and ``RTN``. You will need to use ``PUSHRST`` and
``POPRST`` at appropriate times and provide your own logic for
this. You can use the other return stack utilities like `` RTN?``
and ``RTNS`` to assist with this.

Error messages
==============

The following error message are possible:

``NO ROOM``
   no more space in the free memory area, or buffer cannot be grown
   due to size and representation contraints

``STACK ERR``
   this is given if you try to pop from an empty stack, or it is
   determined that you tried to pop something that is not the top
   stack element

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

.. index:: push; alpha register

Push the alpha register to the buffer stack. You can have a maximum of
13 alpha registers on the stack at any time, trying to push more will
result in a ``NO ROOM`` error message. The actual register consumption
depends on how long string in the alpha register. Pushing an empty alpha
register costs nothing, apart from using up one of the 13 levels.

POPA
----

.. index:: pop; alpha register

Pop the alpha register from the buffer stack.

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

Push the RPN return stack on the buffer stack. This also clears
all stack levels as the buffer stack can be seen as an extension of
the RPN return stack.

POPRST
------

.. index:: pop; return stack

Pop the RPN return stack from the buffer stack.

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

This is useful when you write a routine that takes a single operand
from ``X``, performs some calculations that disrupts the stack and
leaves a result in ``X``. Now with ``POPFLXL`` you can restore the
other stack register and as a bonus have a proper last ``X`` value, so
that your RPN program behaves as a normal single argument function,
i.e. like ``SIN``.

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
``X`` and ``Y`` , performs some calculations that disrupts the stack
and leaves a result in ``X``. Now with ``POPDRXL`` you can restore the
other stack registers (``T`` and ``Z``) and as a bonus have a proper
last ``X`` value, so that your RPN program behaves as a normal two
operand function, i.e. like ``+``.

PUSHBYX
-------

.. index:: push; data registers

Push a range of data registers. Takes a register range ``RRR.BBB``
in the ``X`` registers. ``RRR`` is the first register in the range and
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
anything on the stack will increase this number. Removing something
from the stack will make this number return to the same it was
before. Thus, this number can be used as a gauge to see if we are back
to a previous point. It can also be used to see if things have been
added to the stack or removed below a current point.

The actual number is the sum of the stack registers used by the buffer and
the number of alpha register entities that are on the stack. The two
register buffer overhead is not included in this count. The means that
an empty stack and a non-existing buffer stack both return 0.

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

   There are two way this function can fail to work as intended. If
   the next record on the stack is the alpha register, it may be empty
   in which case this function will actually look at the next thing
   on the stack. Also, the test for whether the top element is a
   return stack record checks a magic number (``0x2ac`` in the
   rightmost part). There is a (very) minor risk that what is pushed
   happens to contain that pattern and being something else. However,
   no normalized number has bits like this and ``0xac`` is not a
   normal letter.

CLSTBUF
-------

Remove the stack buffer.
