#ifndef _EOS_PROTECT_MODE_H
#define _EOS_PROTECT_MODE_H

#include <type.h>

typedef struct e_descriptor {
        u16     limit_low;
        u16     base_low;
        u8      base_mid;
        u8      attr1;
        u8      attr2_limit_high;
        u8      base_high;
} DESCRIPTOR;

#endif
