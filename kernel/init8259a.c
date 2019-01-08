#include "io.h"
#include "const.h"
#include "protect-mode.h"

PUBLIC void init_8259A()
{
        out_byte(INT_MASTER_CTL,        0X11);
        out_byte(INT_SLAVE_CTL,         0X11);
        out_byte(INT_MASTER_CTL_MASK,   INT_VECTOR_IRQ0);
        out_byte(INT_SLAVE_CTL_MASK,    INT_VECTOR_IRQ8);
        out_byte(INT_MASTER_CTL_MASK,   0x4);
        out_byte(INT_SLAVE_CTL_MASK,    0x2);
        out_byte(INT_MASTER_CTL_MASK,   0x1);
        out_byte(INT_SLAVE_CTL_MASK,    0x1);
        out_byte(INT_MASTER_CTL_MASK,   0xFF);
        out_byte(INT_SLAVE_CTL_MASK,    0xFF);
}