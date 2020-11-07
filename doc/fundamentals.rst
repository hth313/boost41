************
Fundamentals
************

The chapter gives some basic background of how Boost works and how it
differs from many other modules.

OS4
===

Boost is a companion module for the OS4 extension module. OS4 provides
a lot of ground breaking new features for the HP-41 and Boost is
intended to unlock a lot of it to the user.

Another module that uses OS4 is Ladybug, which provides an integer
mode, much like the HP-16C. In addition to the obvious applications of
such module, it can also be used as a system programming module for
the HP-41 as it makes it a lot easier to work with non-normalized numbers.

.. index:: secondary functions

Secondary functions
===================

Boost make use of secondary functions. Secondary functions can be
entered by name, assigned to keys and stored in programs. The only
downside is that when stored in a program they occupy a little bit
more space, typically 4 bytes instead of 2. For functions with a
postfix operand (semi-merged instruction), they cost one byte extra
compare to a corresponding XROM function.

The main advantage of secondary functions is that they allow a 4K
module page to have virtually unlimited number of functions.

Seldom used functions and functions that are not expected to be used
in programs are prime candidates when deciding if a function should be
primary or secondary.

At the moment it is not possible to display secondary functions in
catalog 2. Such feature is planned, but not currently provided. You
need to consult the manual as the functions are there are can be
reached from the the ``XEQ`` and ``ASN`` keys.

.. index:: system shell

Altered keys
============

Boost makes use a of a sparse system shell. When the calculator is
turned on with Boost plugged in, a system shell is added that replaces
the ``XEQ``, ``ASN`` and ``CAT`` keys with custom versions.
You can see that the custom version is active as it displays the name
followed by a tick. If you press the catalog key, you will see:

.. image:: _static/catprompt.*

In addition to having the tick, you can also see that it has two
underscores. The catalog mechanism is extensible in that it will
actually allow other aware plug-in modules to listen to the catalog
function and provide catalogs of their own. Even if Boost does not
implement a given catalog, it is possible that another plug-in module
may provide it and they are all reachable from the same catalog key.

The modified keyboard becomes available when the HP-41 is powered on
and is also installed at a master clear (MEMORY LOST).

Some hardware allows for inserting modules by software means while
power is on. One example is the ``PLUG`` functions in the 41CL. Once
the module is "inserted" by software means, you need to turn the power
off and then back on to properly initialize Boost. For the original
HP-41, you plug in physical modules while powered off.

.. note::

   When the 41CL does a master clear it disables the MMU which causes
   any module you may have plugged in to be removed. Thus, after you
   enable the MMU again, you will need to cycle power to properly
   initialize Boost.
