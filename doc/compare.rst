.. index:: compare functions

.. _compare:

*****************
Compare functions
*****************

The original HP-41 provides a set of compare functions which compare
the X and Y register, as well as some to compare X with 0.

The HP-41CX adds additional compare functions such as ``X<NN?`` which
compares X to a register pointed to be the Y register, essentially
``X < IND Y?``.

The Boost module provides four prompting generic compare functions
``=``, ``≠``, ``<`` and ``<=``.  It should be fairly obvious what they
do. They take two arguments and will prompt for its two arguments.
With these you can create any compare you like, i.e. ``X < 10?``
would test if X is less that the value in register ``10``.

``IND Z = IND 01?`` would take one register number from stack register
Z and one from register ``01``. These two values point to two registers
that are read and compared if they are equal.

When executed the generic compare functions works the usual way. In a
program they will skip the next program line if the test is false. If
executed from the keyboard they will display ``YES`` or ``NO``.

Prefix entry
============

As any prompting function you start with the function name. To key in
``Z = IND L`` you need to type ``XEQ`` ALPHA ``=`` ALPHA. This will
show a prompt for the first argument (the one that goes to the left of
the equal sign). Once the first argument is entered, the calculator
will prompt for the second argument.

In program memory the OS4 module will display such instruction with
the function name between the two arguments. It will also append the
question mark for these functions, which means that once entered you
will see ``Z = IND L?`` in the program memory if you step to this
line.

The missing compares
====================

What if you want to compare if X is greater than register ``05``? There
is not compare greater than so you would need to swap the operands and
use ``05 < X?``.

Compare to constant
===================

What if you want to compare to zero or another constant? In this case
you would need to keep zero in a register or load a zero at some point
so that it is in a known location in the stack. One way of seeing is
that you use a constant register, simply put the desired constant into
a register and keep it there. Doing this way means that you are not
limited to zero, you can store any suitable constant in a register.
