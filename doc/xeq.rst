*******
Execute
*******

The ``XEQ`` key is very fundamental for the HP-41 as not only does it
act as a goto subroutine, it also allows functions that are not on the
keyboard to be invoked. The catalogs are searched in order, first
catalog 1 which contains user programs, then 2 which are the plug-in
modules and finally 3 which are the built-in functions.

The Boost module provides enhanced functionality over the usual
``XEQ``. Once Boost is plugged in the ``XEQ`` changes to ``XEQ'``
which allows the following alternatives:

By name

   Press the ``ALPHA`` key and spell out the name of the function you
   want to execute. This will search for the function in the usual way
   and also search for a matching secondary function.

By local label

   This is numeric and top row keys single Alpha letter labels, as
   before.

By XROM code

   If you press the ``XEQ`` key a second time you can key in an
   ``XROM`` function number.

When ``XEQ'`` is activated it shows the following:

.. image:: _static/xeq-1.*

You can now enter a local label number, press the ``ALPHA`` key to
spell out the function name, or you can press the ``XEQ`` key again
and fill in the prompt for an ``XROM``:

.. image:: _static/xeq-xrom-1.*

.. image:: _static/xeq-xrom-2.*

.. image:: _static/xeq-xrom-3.*

.. image:: _static/xeq-xrom-4.*

.. image:: _static/xeq-xrom-5.*

.. note::

   When the ``XROM`` number is complete and you hold the last key down
   the display changes to show the name of the function.
