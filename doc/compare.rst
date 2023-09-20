.. index:: compare functions

.. _compare:

*****************
Compare functions
*****************

The original HP-41 provides a set of compare functions that compares
the X and Y register, as well as some to compare X with zero.

The HP-41CX adds additional compare functions such as ``X<NN?`` which
compares X to a register pointed to be the Y register, essentially
``X < IND Y?``.

The Boost module provides four prompting generic compare functions
``=``, ``≠``, ``<`` and ``<=``.  It should be fairly obvious what they
do. They take two arguments and will prompt for them, one at a time.
With these you can create any compare you like, e.g. ``X < 10?``
would test if the value in the X register is less than the value in
register ``10``.

``IND Z = IND 01?`` would take one register number from stack register
Z and one from register ``01``. These two values point to two registers
that are read and compared if they are equal.

When executed the generic compare functions behave as other compare
functions work. In a program they will skip the next program line if
the test is false. If executed from the keyboard they will display
``YES`` or ``NO``.

Prefix entry
============

As any prompting function you start with the function name. To key in
``Z = IND L`` you need to type ``XEQ`` ALPHA ``=`` ALPHA:

.. image:: _static/compare-1.*

This will show a prompt for the first argument (the one that goes to
the left of the equal sign). You can now press the dot key
followed by ``Z``:

.. image:: _static/compare-2.*

.. image:: _static/compare-3.*

Once the first argument is entered, the calculator will prompt for the
second argument. Complete the entry by filling in the second argument:

.. image:: _static/compare-4.*

.. image:: _static/compare-5.*

.. image:: _static/compare-6.*

In program memory the OS4 module will display such function with
the function name between the two arguments. It will also append the
question mark for these functions, which means that once both
arguments have been entered you
will see ``Z = IND L?`` when you step to such line. As that program
line is a bit too long for the display, it will scroll partially off
leaving you with something like:

.. image:: _static/compare-7.*

A shorter compare function that fits in the display will show
together with its line number:

.. image:: _static/compare-8.*



The missing compares
====================

What if you want to compare if X is greater than register ``05``? There
is no compare greater-than provided, instead you need to use less-than
and swap the arguments, i.e. ``05 < X?``.

Compare to constant
===================

What if you want to compare to zero (or another constant)? In this case
you would need to keep zero in a register or load a zero at some point
so that it is in a known location in the stack, then compare towards
that constant by its register location. One way of seeing it is
that you use a constant register. Simply put the desired constant into
a register and keep it there. Doing it this way means that you are not
limited to zero, you can use any desired constant compare.
