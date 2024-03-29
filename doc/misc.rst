***********************
Miscellaneous functions
***********************

This chapter describes various functions that either are system
related or did not really belong to the other chapters.

Functions
=========

AVAIL
-----
.. index:: free memory, available memory, memory; available

This function returns the number of free registers to the X
register. This is the same number that you would see when standing at
end of program memory. In the past this function has sometimes been
called ``FREE?``, but it has been renamed here to make it less
confusing. The question mark often means that we optionally skip a
program step.

COMPILE
-------
.. index:: COMPILE, program memory; compile

Compile all branches in the entire program memory. This
non-programmable function will walk through all programs and compile
all local ``GTO`` and ``XEQ`` functions. A short ``GTO`` that is
out of range will get converted to the corresponding long version to
allow the branch to be compiled.

While scanning for ``GTO`` and ``XEQ`` and their destination ``LBL``
the display shows ``WORKING``. If a short ``GTO`` is converted to a
long version, the insertion will cause nulls to be inserted. To get
rid of these the program memory is packed. Thus, during
operation you will see the display alternating between ``WORKING`` and
``PACKING``.

If ``COMPILE`` runs out of memory, a ``TRY AGAIN`` message is
displayed.


Execution time varies wildly for this function. For a very large
single program that takes up almost all memory, it may take 10 minutes
to complete the compilation.

The main purpose of ``COMPILE`` is to avoid the initial slow execution
of programs that are not compiled. Typically useful in situation where
you have time in advance and want to invest that in making your
programs run as fast as possible when you use them later.

RAMED
-----
.. index:: RAMED, edit memory

This is a RAM editor which allows you to examine and alter bytes
(actually hex digits) in the RAM memory of your calculator.

.. warning::

   This RAM editor allows you to edit any RAM memory as you
   wish. Be very sure that you understand what you are doing as doing
   it wrong can compromise the memory structure and lead to a ``MEMORY
   LOST``.

Once started you may see a display like the following:

.. image:: _static/ramed-1.*

As there is a blinking cursor it will alternate with the following
view:

.. image:: _static/ramed-2.*

The leftmost digit is the digit position in the current register,
which range from 0 to 13 (shown in hex as ``0``--``D``).
The digit position in the example is ``4`` and is followed by the
current address which in the example is ``19B`` (hex). Part of the
register is shown to the right with the current digit position
highlighted with a blinking cursor.

Keys of operation are as follows:

R/S
   terminate ``RAMED``.

ON
   turn the HP-41 off.

``+``
   move to next register.

``-``
   move to previous register.

PRGM
   move cursor right.

USER
   move cursor left.

0-F
   alter the digit where the cursor is.

.
   toggle cursor field between the address and the data.

The HP-41 will give a short beep if you move to cursor so that it
wraps around between the last and first digit in the register.

``RAMED`` is non-programmable and when invoked in program mode it will
use the current program location as the start address.

When started outside program mode the start address is taken from the
``X`` register. This can either be a decimal address or a right justified
binary value (non-normalized number) in ``X``.

.. note::

   When used together with the Ladybug module, simply enter the
   address in ``X`` and start ``RAMED``. An integer value is actually just
   right justified binary value (non-normalized number).

.. note::

   The reason for ``RAMED`` to be non-programmable is that is useful
   to start editing program memory at the current location when inside
   program mode. If you place ``RAMED`` inside a program (there are
   several ways of how this can be done), then ``RAMED`` will start
   from the address in the X register. Program execution resumes when
   ``R/S`` is pressed to leave ``RAMED``.

APX
---
.. index:: APX, append to X


This function makes it possible to append to the number in ``X`` register.
You can see this as a counterpart of the append function in Alpha
mode.

In the book *Extend your HP-41* there is a discussion of this
function and some motivation of why it is useful on page 541, followed
by a synthetic program on page 542. The ``APX`` function provided here
is an MCODE version of this program and works mostly the same.

Somewhat simplified, ``APX`` takes the number in X and feeds it into
the digit entry mechanism, then tells the system that we are still
doing numeric entry.

It can be used quite naturally if assigned to the same place as Alpha
append (shifted ``ASN`` key), making it appear on the corresponding
place on the user keyboard. This has the downside that you can only
reach the ``ASN`` function outside USER mode.

``APX`` also works from inside a program. However, it needs to be
followed by ``STOP`` or ``PSE`` in order to let the user append to the
number. When stopped from a program with ALPHA on, it acts as Alpha
append instead. Thus, ``APX`` gives you a programmable Alpha append as
a bonus.

``APX`` favors editing the mantissa. When given a very large or small
number ``APX``  will attempt to bring the number into what can be
shown without an exponent. Well behaved numbers will have the correct
sign and decimal point in the correct location.


.. index:: Luhn checksum, checksum; Luhs

LUHN?
-----

Implements the Luhn algorithm as used by credit card numbers. Accepts
a two-part BCD number in Y and X. The lower 14 digits are expected in
X and any upper digits are in Y. A typical credit card number uses 16
digits.

To enter the number, you can use the usual ``CODE`` function, but it
is probably easiest to just key it in using the Ladybug module
configured with 56-bit word size and hex mode:

.. code-block:: ca65

  WSIZE 56
  HEX
  3432_ H
  ENTER
  5422395239434_ H
  LUHN?

``LUHN?`` will skip next line if the Luhn checksum is not correct. In
keyboard mode it will display ``YES`` for a correct Luhn number and
``NO`` otherwise.

Reference: https://en.wikipedia.org/wiki/Luhn_algorithm

.. index:: encode NNN, CODE

CODE
----

This is the ubiquitous ``CODE`` function used to encode a
non-normalized number based on a hexadecimal value in the Alpha
register.  The resulting value is put in the X register.

.. index:: Half-nut display; contrast, display; contrast

.. index:: decode NNN

DECODE
------

This is the ubiquitous ``DECODE`` function used to decode the number
in ``X`` and put its hexadecimal value in the Alpha register. This was often
used in the days of synthetic programming to make sense of the
non-normalized numbers that often resulted.

When used from a running program mode the hexadecimal string is
appended to the Alpha register. When used from the keyboard the alpha
register is cleared first.

.. note::

   If you are into fiddling with register values, it can be
   worth checking out the Ladybug module which makes working with such
   numbers as easy as working with normal decimal numbers. Just
   configure it in hex mode with word size 56 for the ultimate way of
   working with binary (non-normalized) numbers on the HP-41. In
   addition Ladybug is a great replacement for an HP-16C.

CTRST
-----

Sets the contrast value for the later Half-nut style displays. Takes a
value 0--15 from the ``X`` register.

CTRST?
------

Reads the current contrast value 0--15 and puts it in the ``X``
register. This works for later Half-nut style displays.
