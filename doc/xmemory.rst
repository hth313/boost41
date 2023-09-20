.. index:: Extended memory

***************
Extended memory
***************

Boost provides some additional functions related to Extended Memory
as implemented in the HP-41CX, HP-41CL and DM41X. Currently the separate
82180A Extended Functions as used by the HP-41C and HP-41CV is not
supported.

.. note::

   Large Extended Memory as optionally available on the HP-41CL using
   a custom firmare is fully supported by all these functions, as they
   use the official 41CX entry points.


Random data file access
=======================

These functions make it possible to treat data files in Extended
Memory much like ordinary registers. A set of functions corresponding
to the existing ones such as ``RCL`` and ``STO`` are provided. The
names start with an ``X`` and they prompt for the register to access.
Indirection is also possible, but the indirection register is an
ordinary data or stack register.

Possible errors when using these functions are:

``NO 41CX OS``
    if there is no 41CX style operating system provided by the calculator.

``FL NOT FOUND``
    if not current file is selected.

``FL TYPE ERR``
    if current file exists, but is not a data file.

``NONEXISTENT``
    if attempt is made to access a register beyond the end of file.

Selecting a file can be done using the ``SEEKPTA`` function which
takes the name from the Alpha register and the pointer to set
from X. When using these function you are bypassing the pointer
mechanism and instead access arbitrary registers just as you would do
with ordinary data storage registers.


XRCL _ _
---------
.. index:: XRCL, data file access; XRCL

Prompting function that reads directly from a data file. ``XRCL 03``
will recall the fourth register in the current data file to X.
``XRCL IND 04`` will read data register 04 (the normal data register,
not register 04 in the data file). The value found in that data file register
tells which register to recall from the current data file to the X
register.

XSTO _ _
---------
.. index:: XSTO, data file access; XSTO

Prompting function that writes directly to a data file. ``XSTO 03``
will store the contents in the X register in the fourth register in the
current data file.
``STO IND Z`` will store the value in the X register into the current
data file. The register number that is written to is the value in stack register
Z. If the indirect register number is numeric, e.g. ``STO IND 10``, the
indirection register is the normal data register (not the data file
register).

XVIEW _ _
-----------
.. index:: XVIEW, data file access; XVIEW

Prompting function that reads directly from a data file. ``XVIEW 03``
will read the fourth register in the current data file and show it in
the display.
``XVIEW IND 04`` will read data register 04 (the normal data register,
not register 04 in the data file). The value in that register tells
which register number to fetch read the current data file and show in
the display.

XARCL _ _
----------
.. index:: XARCL, data file access; XARCL

Prompting function that reads directly from a data file. ``XARCL 03``
will recall the fourth register in the current data file and append
the value in the Alpha register.

<>X _ _
--------
.. index:: <>X, data file access; <>X

Dual prompting function that takes one normal register argument and a
register value for Extended Memory. Swaps the two values between the two
indicated registers.

Register indirect arguments are permitted on both sides. A stack
argument is permitted for the left hand side, but not for right hand
side as it is in Extended Memory.

.. note::

   The name here is selected so that the ``X`` appears after the
   exchange name. This is for two reasons. First, there is already a
   built-in function ``X<>`` which takes one argument and exchanges
   between the X register and the argument. Second, the ``X`` appears
   after the ``<>`` to indicate that the Extended Memory register
   comes from the second operand\.


File operations
===============

Function related to files in Extended Memory.

WORKFL
-------
.. index:: filename; active, name of active file

This function appends the name of the current active file to the Alpha
register.

Possible errors are:

``NO 41CX OS``
   if there is no 41CX style operating system provided by the calculator.

``FL NOT FOUND``
   if there is no active file.

RENFL
-----
.. index:: rename file

Rename a file in Extended Memory. The file to be renamed are in the
Alpha register followed by a comma and then the new name.

Possible errors are:

``NO 41CX OS``
   If there is no 41CX style operating system provided by the calculator.

``FL NOT FOUND``
   If the file does not exist.

``DATA ERROR``
   If there is no comma in the Alpha register.
