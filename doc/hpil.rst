.. index:: HP-IL functions

***************
HP-IL functions
***************

This chapter describes functions related to the HP-IL module. To use
these functions you need to have an HP82160A HP-IL module.


HP-41CL ROM page functions
==========================

These functions allow for reading or writing 4K RAM pages from the
HP-41CL to an HP-IL mass storage device.

The page address range allowed is ``0x807`` to ``0x87f``. This can be
expressed as a 12-bit right aligned binary number in the ``X``
register. Use the ``CODE`` function or the Ladybug module to enter the
address. If the address only uses decimal digits, e.g. ``0x809`` you
can enter it as the (floating point) decimal number ``809``.

The filename is taken from the Alpha register.

RDROM16
-------

This function reads a 4K module page from an HP-IL mass storage device
into a HP-41CL 4K RAM page. Data is read with 16-bit with speed
annotations.


WRROM16
-------

This function writes 4K module page from an HP-41CL 4K RAM page to a
file on the HP-IL mass storage. Data is written with 16-bit with speed
annotations.
