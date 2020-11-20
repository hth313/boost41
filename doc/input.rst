
.. index:: input functions

***************
Input functions
***************

The standard HP-41 OS provides ``PSE`` as a way to wait for input and
resume if not input is entered for about a second.

The Extended functions module added ``GETKEY`` that will busy wait for
up to 10 seconds and finally the HP-41CX offers ``GETKEYX`` that is
similar to ``GETKEY``, but provides more control.

Both these functions keeps the calculator at full power consumption
while running.

The Boost module offers a couple of alternatives that makes it
possible wait or look for key input while the processor is powered
down. The interval timer of the Time module is used for this, which
means that they require the Time module to be present.

The interval timer is normally used to provide the ticking clock
display, but here we borrow it and use it as a time out.

Functions
=========

PAUSE
-----

This function works as the built-in ``PSE``, but it is aware of OS4
application shells and will properly display the correct X register
view as defined by the active shell. The built-in ``PSE`` does not do this
and revert to showing X the old way, which may not be what you want
when an application is active as it may alter the default view of the
X register.

One example if the Ladybug module which replaces the standard view of
X with integer values shown in the selected numeric base. The default
way of showing such numbers are as non-normalized numbers, which are
close to garbage. Using ``PAUSE`` when Ladybug may be active provides
a pause function that works the correct way.

Timed wait
==========

``DELAY`` and ``KEY`` are prompting functions with a value range of 1
to 10000, which corresponds to 0.1 to 1000 seconds. You will need to
use register indirect arguments to access anything past about 10
seconds (postfix argument 99).

.. index:: DELAY function

DELAY _ _
---------

The argument is the number of tenths of a second to wait. Example,
``DELAY 15`` will wait for 1.5 seconds. Pressing a key while waiting
will terminate the timer and execution resumes on key release. The key
press is otherwise ignored.

This also accept indirect arguments, i.e. ``DELAY IND X`` will read a
value from the X register, divide by ``10`` and wait for that number of
seconds.

.. index:: KEY function

KEY _ _
--------

Works similar as ``DELAY``, but will also return the key code of the
pressed key to X. Returns ``0`` if no key is pressed.

.. index:: Yes/no input

Y/N?
----

Simple test for yes or no input. Beeps and waits for up to 25 seconds
for input. Executes the next line if ``Y`` is pressed, skips the next
line in ``N`` is pressed.

Active keys are:

``ON``
    turns the calculator off.

``Y``
    resumes program execution at next program line.

``N``
    skips one program line and resumes execution.

``R/S``
    stops the program.

``<-``
    stops the program.
