.. index:: extended memory

***************
Extended memory
***************

Boost provides some additional instructions related to extended memory
as implemented on the HP-41CX and HP-41CL. Currently the separate
82180A Extended Functions as used by the HP-41C and HP-41CV is not
supported.

.. note::

   Large extended memory as optionally available on the HP-41CL using
   a custom firmare is fully supported by all these functions as they
   go through the entry points provided by the mainframe firmware.


Random data file access
=======================

These functions make it possible to treat data files in extended
memory much like ordinary registers. A set of functions corresponding
to the existing ones such as ``RCL`` and ``STO`` are provided. These
are prefixed with an ``X`` and prompts for the register to access.
Indirection is also possible, but the indirection register act on the
ordinary data registers, or stack registers.

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
takes the name from the alpha register and the pointer to set
from X. When using these function you are bypassing the pointer
mechanism and instead access arbitrary registers just as you would do
with ordinary data storage registers.


XRCL _ _
---------
.. index:: XRCL, data file access; XRCL

Prompting function that reads directly from a data file. ``XRCL 03``
will recall the fourth register in the current data file to X.
``XRCL IND 04`` will read data register 04 (the normal data register,
not register 04 in the data file), the value in that data file register
tells which register to recall from the current data file to the X
register.

XSTO _ _
---------
.. index:: XSTO, data file access; XSTO

Prompting function that writes directly to a data file. ``XSTO 03``
will store the contents in the X register in the fourth register in the
current data file.
``STO IND Z`` will store the value in the X register into the current
data file, the register number that is written to is in stack register
Z. If the indirect register number is numeric, i.e. ``STO IND 10`` the
register number used is in that data register (not the data file).

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
the value in the alpha register.
``XARCL IND 04`` will read data register 04 (the normal data register,
not register 04 in the data file), the value in that data file register
tells which register to recall from the current data file and append
the value in the alpha register.

Other functions
===============

WORKFL
-------
.. index:: filename; active, name of active file

This function appends the name of the current active file to the alpha
register.

Possible errors are:

``NO 41CX OS``
   if there is no 41CX style operating system provided by the calculator.

``FL NOT FOUND``
   if there is no active file.
