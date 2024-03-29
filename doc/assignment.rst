***********
Assignments
***********

In this chapter we look at various enhancements made to key assignment
mechanism.

Improved ASN
============

.. index:: assignment; by name, assignment; of function code, assignment; XROM identity

The ``ASN`` key is replaced by a function ``ASN'`` which allows you to
make assignments in three ways:

By name

   Assignments can be made by name in the same way as before. Simply
   press the ``ALPHA`` key and spell out the name of the function to
   assign. This will search for the function in the usual way
   and also search for a matching secondary function.

By decimal function code

   It is possible to assign any two-bytes function code to a key by
   filling in the decimal values of the function code.

By XROM code

   If you first press ``ASN`` followed by the ``XEQ`` key, that is
   ``SHIFT``-``XEQ``-``XEQ``, the ``ASN'`` function will prompt you
   for a numeric ``XROM`` function code and assign it to a key.

When ``ASN'`` is activated it shows the following:

.. image:: _static/asn-1.*

You can now press the ``ALPHA`` key (as you would normally do) and
spell out the function name, or you can press the ``XEQ`` key and fill
in the prompt for an ``XROM``:

.. image:: _static/asn-xrom-1.*

.. image:: _static/asn-xrom-2.*

.. image:: _static/asn-xrom-3.*

.. image:: _static/asn-xrom-4.*

.. image:: _static/asn-xrom-5.*


Functions
=========

.. index:: CLKYSEC, assignments; loading

CLKYSEC
-------

This will delete all secondary function assignments. This is
intended to be used when you load a large set of key assignments from
some storage media and want them to replace all existing
assignments. Devices like the card reader provide two functions, one
to load key assignments and one to merge them with the existing ones.

As existing storage media code is unaware of secondary assignments.
``CLKYSEC`` provides a means of replacing keys as it will wipe the
existing secondary key assignments, which is what a load and replace
key assignments is intended to do. Not calling ``CLKYSEC`` means that
loading keys acts as merging them with respect to existing secondary
assignments.

.. note::

   This is simpler than it sounds. If you want to replace key
   assignments, first execute ``CLKYSEC``. The reason why this function is
   needed is that all the old ways of loading key assignments from
   external storage media uses firmware which is totally unaware
   of secondary assignments.

.. index:: LKAOFF, auto-assignments, assignment; auto

LKAOFF
------

Disable assignments made on the top row keys. This is useful if you
have assignments on the top row keys and want to use an RPN program
that makes use of the auto-assignment feature of the top row keys.

Assignments on the top row keys remain inactive until you reactivate
them again using ``LKAON``.

.. index:: LKAON, auto-assignments, assignment; auto

LKAON
-----

Enable the auto-assignments on the top row keys. This is the default
behavior unless you have executed ``LKAOFF``.

.. note::

   Some application shells like Ladybug will disable top row
   auto-assignments completely when activated. This is done by a
   setting in its shell descriptor and in such cases ``LKAOFF`` has no
   effect (as long as that shell is active). In such case you need to
   deactivate the application shell in order to use the top row
   auto-assignments.


MAPKEYS
-------

.. index:: MAPKEYS, assignment; rebuild bitmaps

This function rebuilds the key assignment bitmap registers for both
primary and secondary assignments. You should not normally need to use
this. It can be useful if you have managed to corrupt the bitmap
registers, or have used some function that adjusts key assignments
without properly updating the key assignment bitmap bits.
