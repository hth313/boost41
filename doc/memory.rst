****************
Stack and memory
****************

Functions related to stack and memory values are documented here.


Generic exchange
================

The ``<>`` genereric exchange function takes two arguments and swaps
the values between those two registers. This is a generalization of
the built-in ``X<>`` function, but as ``<>`` takes two arguments ut
can exchange values between two arbitrary registers, either or both
also support register indirect.

To enter the function you call it by name in the usual way. It will
resond by requesting the first register:

.. image:: _static/exchange-1.*

Press the dot key if you want to specify a status register:

.. image:: _static/exchange-2.*

Select the Z register which completes the first argument, you are now
prompted for the second argument:

.. image:: _static/exchange-3.*

Press the shift key to enter a register indirect argument

.. image:: _static/exchange-4.*

And finally enter the register to complete the instruction which is
executed once you release the key:

.. image:: _static/exchange-5.*

In program memory the ``<>`` function is displayed infix:

.. image:: _static/exchange-6.*

.. index:: VMANT function, mantissa; view

VMANT
=====

View the mantissa of the value in X. This displays all digits of the X
register, stripping off any exponent. The actual value in X is not
affected. The get back to the normal display, press the back arrow key
as usual.

.. index:: fix/end mode

F/E
===

Enable a hybrid ``FIX`` and ``ENG`` mode. Normally when in ``FIX``
mode the calculator will switch to ``SCI`` mode when the number cannot
be properly shown in ``FIX`` mode. The ``F/E/`` mode changes this so
that it will switch to ``ENG`` mode in that situation instead.
