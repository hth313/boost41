****************
Stack and memory
****************

Functions related to stack and memory values are documented here.
You may also want to consult the sections about compares and stack as
they also operate on stack an memory values. See
:ref:`compare` and :ref:`stack`.

Functions
=========


Generic exchange
-----------------

The ``<>`` genereric exchange function takes two arguments and swaps
the values described by the arguments. This is a generalization of
the built-in ``X<>`` function. As ``<>`` takes two arguments it
can exchange values between two arbitrary registers, either or both
may be register indirect.

To enter the function you call it by name in the usual way. It will
resond by prompting for the first argument:

.. image:: _static/exchange-1.*

Press the dot key if you want to specify a status register:

.. image:: _static/exchange-2.*

Select the Z register which completes the first argument, you are now
prompted for the second argument:

.. image:: _static/exchange-3.*

Press the shift key to enter a register indirect argument.

.. image:: _static/exchange-4.*

And finally enter the register to complete the function, which is
executed when you release the key:

.. image:: _static/exchange-5.*

In program memory the ``<>`` function is displayed infix:

.. image:: _static/exchange-6.*

In this example the ``IND`` variant was omitted to make the complete
function fit on the display together with the line number.
You can of course enter indirect arguments in program mode, however,
the line becomes so long that it scrolls horizontally.


.. index:: VMANT function, mantissa; view

VMANT
-----

View the mantissa of the value in X. This displays all digits of the X
register, stripping off any exponent. The actual value in X is not
affected. The bring back to the normal display, press the back arrow key
as usual.

.. index:: fix/end mode

F/E
---

Enables the hybrid ``FIX`` with ``ENG`` mode. Normally when using ``FIX``
mode and the number needs to be shown with an exponent, the HP-41
switches to ``SCI`` mode. The ``F/E`` mode changes this so
that the HP-41 instead will switch to ``ENG`` mode in such situation.
