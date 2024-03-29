***************
Program related
***************

Functions related to program control.

Functions
==========

.. index:: program control; XEQ>GTO

XEQ>GTO
-------

Drop one level from the return stack, essentially it converts the
last ``XEQ`` to be a ``GTO`` instead.

.. index:: program control; RTN?

RTN?
----

Test if there is at least one level of return address on the call
stack. Executes the next program line if there is, otherwise the next
program line is skipped. In keyboard mode it displays ``YES`` or ``NO``.

.. index:: program control; RTNS

RTNS
----

Return the number of pending return levels to ``X`` register. This will be
a number 0--6.

.. index:: program control; PC<>RTN

PC<>RTN
-------

Swap the current location counter with the top of the return address
stack. Essentially making a return, but setting up for a bounce back
to the next program line when that code returns.

GE
---

Go to the permanent ``.END.``. This puts the program
location counter at the last address in the last program, which is
similar to pressing ``GTO ..``, but it will not pack program memory
and it will not insert any new ``END`` which is done in some situations.
