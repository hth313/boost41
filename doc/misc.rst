*************
Miscellaneous
*************

In this chapter various functions that do not belong to any particular
category are documented.

COMPILE
-------
.. index:: COMPILE, program memory; compile

Compile all branches in the entire program memory. This
non-programmable function will walk through all programs and compile
all local ``GTO`` and ``XEQ`` instructions. A short ``GTO`` that is
out of range will get converted to the corresponding long version so
that it can be compiled.

While scanning for ``GTO`` and ``XEQ`` and their destination ``LBL``
the display shows ``WORKING``. If a short ``GTO`` is converted to a
long version, the insertion will cause nulls to be inserted. To get
rid of these the program memory is immediately packed. Thus, during
operation you will see the display alternating between ``WORKING`` and
``PACKING``.

If ``COMPILE`` runs out of memory, the usual ``TRY AGAIN`` message is
shown.

Execution time varies wildly for this function. For a very large
single program that takes up almost all memory, it may take 10 minutes
to complete the compilation.

The main purpose of ``COMPILE`` is to avoid the initial slow execution
of programs that are not compiled. That is, you have a situation where
you have time in advance and want to invest that in making your
programs run as fast as possible when you later use them. A typical use
is you load up your calculator with software prior to an an exam which is
time constrained.

RAMED
-----
.. index:: RAMED, edit memory

This is a RAM editor which allows you to examine and alter bytes
(actually hex digits) in the RAM memory of your calculator. It does
not take any structure of data in account, you need to be very sure
what you are doing as you may corrupt the memory structure otherwise.

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
   terminates ``RAMED``.

ON
   turns the HP-41 off.

``+``
   moves to next register.

``-``
   moves to previous register.

PRGM
   moves cursor right.

USER
   moves cursor left.

0-F
   alter the digit where the cursor are.

.
   toggle cursor field between the address and the data.

The HP-41 will give a short beep if you move to cursor so that it
wraps around between the last and first digit in the register.

``RAMED`` is non-programmable and if invoked in program mode it will
use the current program location as the start address.

When started outside program mode the start address is taken from the
X register. This can either be a decimal address or a right justified
binary value (non-normalized number) in X.

.. note::

   When used together with the Ladybug module, simply enter the
   address in X and start ``RAMED``. An integer value is actually just
   right justified binary value (non-normalized number).

.. note::

   The reason for ``RAMED`` to be non-programmable is that is natural
   to start editing program memory at the current location when inside
   program mode. If you place ``RAMED`` inside a program (there are
   several ways of how this can be done), then ``RAMED`` will start
   from the address in the X register. When the user press ``R/S`` to
   leave ``RAMED``, program execution resumes.

APX
---
.. index:: APX, append to X


This function that makes it possible to append to the number in X register.
You can see this as a counterpart of the append function in alpha
mode.

In the book "Extend your HP-41" there is a discussion of this
function and some motivation of why it is useful on page 541, followed
by a synthetic program on page 542. The ``APX`` function provided here
is an MCODE version of this program and works mostly the same.

Somewhat simplified, ``APX`` takes the number in X and feeds it into
the digit entry mechanism, then tells the system that we are still
doing numeric entry.

It can be used quite naturally if assigned to the same place as alpha
append (shifted ``ASN`` key), making it appear on the corresponding
place on the user keyboard. This means you can only reach the ``ASN``
function outside USER mode.

``APX`` also works from inside a program. However, it needs to be
followed by ``STOP`` or ``PSE`` in order to let the user append to the
number. When stopped from a program with ALPHA on, it acts as alpha
append instead. Thus, ``APX`` gives you a programmable alpha append as
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
is probably easiest to just key it in using the Ladybug module, with a
setting of 56-bits word size and hex mode:

.. code-block:: ca65

  WSIZE 56
  HEX
  343232_ H
  LUHN?

``LUHN?`` will skip next line if the Luhn checksum is not correct. In
keyboard mode it will display ``YES`` for a correct Luhn number and
``NO`` otherwise.

Reference: https://en.wikipedia.org/wiki/Luhn_algorithm
