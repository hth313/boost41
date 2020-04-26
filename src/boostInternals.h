#ifndef __BOOST_INTERNALS_H__
#define __BOOST_INTERNALS_H__

// Macro to switch to given bank on the fly.
switchBank:   .macro  n
              enrom\n
10$:
              .section BoostCode\n
              .shadow 10$
              .endm

#endif // __BOOST_INTERNALS_H__
