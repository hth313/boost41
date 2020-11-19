.. index:: buffers, I/O buffers

*******
Buffers
*******

Buffers are blocks of private memory that modules can allocate for
various purposes. Buffers are allocated from the free memory poll and
are located after key assignments registers. A buffer can be 1-255
registers in size. There are 16 buffers possible in the HP-41 design
(0-15).

In addition to ordinary buffers, the OS4 module allows for a concept
of hosted buffers. A hosted buffer resides inside the OS4 maintained
system buffer (buffer number 15) using an unrelated number range
(0-127).

The Boost module provides functions related to both ordinary buffers
as well as hosted buffers.

.. node::

   Originally the buffers were designed with I/O in mind and were
   often called I/O buffers. Later they were used for Time module
   alarms and the name generalized to "buffers".

Functions
=========

If the buffer number specified is outside valid numeric range, 0-15
for normal buffers and 0-127 for hosted buffer, a ``DATA ERROR``
message is returned.

CLBUF
-----

Removes a buffer specified by the X register (0-15).

CLHBUF
------

Removes a hosted buffer specified by the X register (0-127).

BUF?
----

Does the buffer (0-15) specified in the ``X`` register exist? If it
does not exist, the next program line is skipped. In run-mode ``YES``
or ``NO`` is displayed.

HBUF?
-----

Does the hosted buffer (0-127) specified in the ``X`` register exist?
If it does not exist, the next program line is skipped. In run-mode
``YES`` or ``NO`` is displayed.

BUFSZ
-----

Gives the size of the buffer (0-15) specified in the ``X``
register. The buffer number is saved in the ``L`` register and the
size replaces the value in ``X`` register.

HBUFSZ
------

Gives the size of the hosted buffer (0-127) specified in the ``X``
register. The buffer number is saved in the ``L`` register and the
size replaces the value in ``X`` register.