#ifndef _UTIL_H_
#define _UTIL_H_

#define SET_BITS(data, bits) (data | bits)

#define CLEAR_BITS(data, bits) (data & ~bits)

#define TOGGLE_BITS(data, bits) (data ^ bits)

#define SELECT_BITS(data, bits) (data & bits)

#endif
