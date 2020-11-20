********
Catalogs
********

Boost provides an extension mechanism to the catalog function. Once
Boost is inserted it installs a system shell that replaces a couple of
keys and ``CAT`` is one of them.


Overview
========

The new ``CAT`` function prompts for a 2-digit catalog number to
show. Once entered, the notification mechanism of OS4 is used to find
a module that implements the entered catalog.

If there is no module that overrides the entered catalog it falls back
to the normal system catalogs. If there is a module that implements the
entered catalog it is handled by that module. Boost itself implements
a buffer catalog with number 7 (more are planned in future updates).

.. note::

   The catalogs provided by Boost are built on top of mechanisms in
   OS4 that gives them very similar behavior compared to the original
   catalog 1--3. Once stopped the calculator goes to
   light sleep, saving power. If a key that is not implemented by the
   catalog is pressed, the catalog is terminated and the key action is
   performed. This is different from catalogs 4--6 in the HP-41CX
   which are busy waiting programs that needs to be explicitly exited
   before normal key pressed can be accepted.


Buffer catalog
==============

The buffer catalog displays the buffers in normal buffer area. Each
buffer is shown together with its address and size. A typical line can
look as follows:

.. image:: _static/cat-7.*

The first number is the buffer number (0--15), followed by the size
and then the start address. All numbers are decimal.

When the catalog is running you can stop it with the ``R/S`` key. The
``ON`` key will turn the HP-41 off and any other key will speed up the
display.

When stopped the following keys are active:

``SST``
    step to the next entry in the catalog.

``BST``
    step to the previous entry in the catalog.

``<-``
    terminate the catalog.

``R/S``
    continue running through the catalog.

``C``
    erase the buffer shown.

When stopped the shift and user keys are active and toggle the state
as usual. Any other key press will terminate the catalog shown and
the function bound to that key will be executed.
