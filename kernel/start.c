#include "type.h"
#include "const.h"
#include "protect_mode.h"
#include "string.h"
#include "io.h"
#include "global.h"

PUBLIC void cstart()
{
        disp_str("\n");
        disp_str("kernel init\n");

        disp_str("page direcotry base: ");
        disp_int(page_directory);
        disp_str("\n");

        disp_str("stack_base: ");
        disp_int(stack_base);
        disp_str(" stack_top: ");
        disp_int(stack_top);
        disp_str("\n");
        disp_str("stack_base3: ");
        disp_int(stack_base3);
        disp_str(" stack_top3: ");
        disp_int(stack_top3);
        disp_str("\n");

        disp_str(" csinit addr: ");
        disp_int(addr_csinit);
        disp_str("\n");

        // copy old gdt to new gdt
        mem_cpy(&gdt, ptr_to_gdt_base(), gdt_len() + 1);

        // setup new gdt
        set_gdt(&gdt, GDT_SIZE * sizeof(DESCRIPTOR) - 1);
        // setup idt
        set_idt(&idt, IDT_SIZE * sizeof(GATE) - 1);

        init_protect_mode();

        disp_str("kernel cstart end\n");
}
