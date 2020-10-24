************
Introduction
************

Welcome to the Boost module for the HP-41 calculator. Boost is system
extensions module, but can also be seen as a companion module to the
OS4 module.

Plug-in module
==============

Boost is a module image that needs to be put in some programmable
plug-in module hardware. This can be a Clonix module, an MLDL or some
kind of ROM emulator. You need to consult the documentation of ROM
emulation hardware for this.

It is also possible to use Boost on HP-41 emulators.

The Boost image is a 2x4K module. Two banks occupies a single 4K
page in the normal memory expansion space (page 7--F).

You must also load the separate OS4 module in page 4 for Boost to work.

This release
============

This version, 0B is a work in progress module. The existing functions
have been tested and are believed to work, however, the module is
incomplete in that more functions are planned to be included.

Note that XROM number assignment may change in the future. This is
because a lot of functions are planned and they are not implemented
yet. As banks are not equal, there may be a need to move functions
around in order to make everything fit and that may have effects on
XROM versus secondary XXROM function allocation. The initial decision
on whether a function is primary or secondary may also need to be
reconsidered due to available empty XROM slots, or lack of it.

.. index:: buffer, I/O buffer, XROM number

Resource requirements
=====================

Boost will allocate one register from the free memory pool when first
powered on. Additional use of Boost may allocate further memory,
i.e. using the pseudo random number generator will need one additional
register.

Apart from this, it does not impose any restrictions on the
environment and will run comfortable on any HP-41C, HP-41CV, HP-41CX
or HP-41CL.

The XROM number used by this module is 6.


Using this guide
================

This guide assumes that you have a working knowledge about:

* The HP-41 calculator, especially its RPN system.


Further reading
===============

If you feel that you need to brush up your background knowledge, here are some suggested reading:

* The *Owner's Manuals* supplied with the HP-41, Hewlett Packard Company.
* *Extend your HP-41*, W Mier-Jedrzejowicz, 1985.
* The *OS4* Documentation, Håkan Thörngren if you want to study the
  internals of the user OS4 module.

License
=======

The Boost software and its manual is copyright by Håkan Thörngren.

MIT License

Copyright (c) 2020 Håkan Thörngren

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

The name
========

The Boost name was picked as it is meant to provide a good amount of
power up for the HP-41, to give it a boost.


Feedback
========

Feedback and suggestions are welcome, the author can be contacted at
hth313@gmail.com.

The source code and releases can be found at
https://github.com/hth313/boost41.
