#include "type.h"
#include "const.h"
#include "protect-mode.h"
#include "string.h"
#include "io.h"
#include "global.h"

PUBLIC void cstart()
{
        disp_str("\n");
        disp_str("kernel init\n");

        // copy old gdt to new gdt
        mem_cpy(&gdt, ptr_to_gdt_base(), gdt_len() + 1);

        // setup new gdt
        set_gdt(&gdt, GDT_SIZE * sizeof(DESCRIPTOR) - 1);
        // setup idt
        set_idt(&idt, IDT_SIZE * sizeof(GATE) - 1);

        init_protect_mode();

        disp_str("kernel cstart end\n");
}
