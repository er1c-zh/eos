#include "io.h"
#include "const.h"
#include "protect_mode.h"

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

        out_byte(INT_MASTER_CTL_MASK, 0xFD);
        out_byte(INT_SLAVE_CTL_MASK, 0xFF);
}

PUBLIC void spurious_irq(int irq)
{
        disp_str("spurious_irq irq=");
        disp_int(irq);
        disp_str("\n");
}
