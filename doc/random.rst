.. index random numbers, pseudo random numbers

*********************
Pseudo random numbers
*********************

The base operating system in the HP-41 lacks a pseudo random number
generator. The Boost module provides an MCODE version of the one that
is available in the Game application module.

The seed is stored in a hosted buffer offered by OS4, not competing
with any other I/O buffer. The hosted buffer number used is 0.

Initialization of the seed is based on the current time offered
by the Time module, if present.

Functions
=========

.. index:: random number

RNDM
----

Provide a pseudo random number in the range 0 to 0.999999.

.. index:: random mnumber; seed

SEED
----

Use the fractional part of the value in X as the seed for the random
number generator. This is useful to get a predictable range of pseudo random
numbers, e.g. useful for test or demo purposes.

.. index:: 2D6 function

2D6
---

Simulate rolling two common six sided dices, giving a value 2-12 with
a distribution that corresponds to rolling two six sides dices. The value 7
will the most common result, while 2 and 12 are the most uncommon
outcomes.
