Boost module for the HP-41
==========================

The Boost module is a companion module to my OS4 module. It aims to
provide a lot of useful functionality to any user of the
HP-41.

Highlights
----------

1. Generalized compare functions which takes two arguments, making it
   possible to combine any two registers in a compare operation.

2. Generalized exchange of two registers, direct or indirect.

3. Enhanched catalogs, currently providing a buffer catalog (7).

4. Enhanced assign functionality, assign secondary functions by name,
   XROM by numbers, or any two-bytes sequence to a key.

5. `XEQ` function that allows for transparent access to secondary
   functions.

6. Random access to indivisual registers current extended memory data
   file, making it possible to treat them much the same way as
   ordinary data registers.

7. Dynamic stack to allow for preserving a previous state, which can
   be used to make RPN programs appear more friendly (not clobbering
   unrelated resources). Also allows for writing recursive RPN
   programs beyond the built in six level limit.

8. Lots of more.
