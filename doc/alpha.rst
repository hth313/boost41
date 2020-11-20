.. index:: alpha functions

**************
Alpha register
**************

Functions related to the alpha register and strings.

Functions
==========

.. index:: ATOXR

ATOXR
-----

Remove the rightmost character from alpha register and push its
character code on the stack. This is similar to ``ATOX`` in the
Extended Functions module, but works on the opposite side of the
string in alpha register.

.. index:: XTOAL

XTOAL
-----

Take the character code from ``X`` register and append that character
to the left side of the string in the alpha register. This is similar
to ``XTOA`` in the Extended Functions module, but works on the
opposite side of the string in alpha register.

.. index:: ARCLINT

ARCLINT _ _
-----------

Prompting function like ``ARCL``, but returns the integer part only of
the value.
