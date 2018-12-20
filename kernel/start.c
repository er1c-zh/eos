#include "type.h"
#include "const.h"
#include "protect-mode.h"
#include "string.h"
#include "io.h"
#include "global.h"

PUBLIC void cstart()
{
        disp_str("cstart\n");
        mem_cpy(&gdt,
                        (void*)(*((u32*)(&gdt_ptr[2]))),
                        *((u16*)(&gdt_ptr[0])) + 1
              );

        // init gdt
        u16* p_gdt_limit = (u16*) (&gdt_ptr[0]);
        u32* p_gdt_base = (u32*) (&gdt_ptr[2]);
        *p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR) - 1;
        *p_gdt_base = (u32) &gdt;

        // init idt
        u16* p_idt_limit = (u16*) (&idt_ptr[0]);
        u32* p_idt_base = (u32*) (&idt_ptr[2]);
        *p_idt_limit = IDT_SIZE * sizeof(GATE) - 1;
        *p_idt_base = (u32) &idt;
        init_protect_mode();

        disp_str("cstart end\n");
}
