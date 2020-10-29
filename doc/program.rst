***************
Program related
***************

Functions related to program control.

.. index:: program control; XEQ>GTO

XEQ>GTO
=======

Drop one level from the return stack, essentially it converts the
last ``XEQ`` to be a ``GTO`` instead.

.. index:: program control; RTN?

RTN?
====

Test if there is at least one level of return address on the call
stack. Executes the next instructions if there is, otherwise the next
instruction is skipped. In keyboard mode it displays ``YES`` or ``NO``.

.. index:: program control; PC<>RTN

PC<>RTN
=======

Swap the current location counter with the top of the return address
stack. Essentially making a return, but setting up for a bounce back
to the next line when that code returns.

GE
==

Go to the permanent ``.END.`` instruction. This puts the program
location counter at the last address in the last program, which is
similar to pressing ``GTO ..``, but it will not pack program memory
and it will not insert any ``END`` as is done in some situations.
