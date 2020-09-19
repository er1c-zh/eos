#include "global.h"
#include "const.h"
#include "type.h"
#include "protect_mode.h"
#include "io.h"
#include "string.h"

/**
 * 获得某个变量的物理地址
 */
PUBLIC u32 get_var_phy_addr(u16 selector, u32 ptr_2_var)
{
        DESCRIPTOR* d = &gdt[selector >> 3];
        return (u32)(d->base_high << 24 | d->base_mid << 16 | d->base_low) + (u32)(ptr_2_var);
}

/* Descriptor Table tools */
/**
 * 获得当前gdt的基地址
 */
PUBLIC void* ptr_to_gdt_base()
{
        u32* ptr_to_gdt_base_addr = (u32*) (&gdt_ptr[2]);
        return (void*) (*ptr_to_gdt_base_addr);
}
/**
 * 获取当前gdt的长度 字节数
 */
PUBLIC u16 gdt_len()
{
        u16* ptr_to_gdt_len = (u16*) (&gdt_ptr[0]);
        return *ptr_to_gdt_len;
}
/**
 * 设置gdt
 */
PUBLIC void set_gdt(void* ptr_to_base, u16 size)
{
        // set gdt address
        u32* ptr_to_gdt_base_addr = (u32*) (&gdt_ptr[2]);
        *ptr_to_gdt_base_addr = (u32) ptr_to_base;
        // set gdt size
        u16* ptr_to_gdt_len = (u16*) (&gdt_ptr[0]);
        *ptr_to_gdt_len = size;
}
/**
 * 设置idt
 */
PUBLIC void set_idt(void* ptr_to_base, u16 size)
{
        // set idt address
        u32* ptr_to_idt_base_addr = (u32*) (&idt_ptr[2]);
        *ptr_to_idt_base_addr = (u32) ptr_to_base;
        // set idt size
        u16* ptr_to_idt_len = (u16*) (&idt_ptr[0]);
        *ptr_to_idt_len = size;
}

/* interrupt handler */
void divide_error();
void single_step_exception();
void nmi();
void breakpoint_exception();
void overflow();
void bounds_check();
void inval_opcode();
void copr_not_available();
void double_fault();
void copr_seg_overrun();
void inval_tss();
void segment_not_present();
void stack_exception();
void general_protection();
void page_fault();
void copr_error();
void system_call();

void hwint00();
void hwint01();
void hwint02();
void hwint03();
void hwint04();
void hwint05();
void hwint06();
void hwint07();
void hwint08();
void hwint09();
void hwint10();
void hwint11();
void hwint12();
void hwint13();
void hwint14();
void hwint15();
/* interrupt handler end */

PUBLIC void task0()
{
        disp_str("==task0==");
        while(1) {
                for (int i = 0; i < 1000000; i++) {}
                disp_str("-");
        };
}

PUBLIC void task1()
{
        disp_str("==task1==");
        while(1) {
                for (int i = 0; i < 1000000; i++) {}
                disp_str("_");
        };
}

PUBLIC void init_protect_mode()
{
        init_gdt_desc(INDEX_CODE_3, 0x0, 0xFFFFF, DA_CR+DA_32+DA_LIMIT_4K+DA_DPL3);
        init_gdt_desc(INDEX_DATA_3, 0x0, 0xFFFFF, DA_DRW+DA_32+DA_LIMIT_4K+DA_DPL3);
        init_gdt_desc(INDEX_TSS_TASK0,
                get_var_phy_addr(SELECTOR_FLAT_RW, (u32) &tss[0]),
                sizeof(TSS) - 1, DA_386TSS+DA_DPL3);
        init_stack_desc();
        init_tss();

        init_8259A();

        init_idt_desc(INT_VECTOR_DIVIDE      , DA_386IGate, divide_error, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_DEBUG       , DA_386IGate, single_step_exception, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_NMI         , DA_386IGate, nmi, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_BREAKPOINT  , DA_386IGate, breakpoint_exception, PRIVILEGE_USER);
        init_idt_desc(INT_VECTOR_OVERFLOW    , DA_386IGate, overflow, PRIVILEGE_USER);
        init_idt_desc(INT_VECTOR_BOUNDS      , DA_386IGate, bounds_check, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_INVAL_OP    , DA_386IGate, inval_opcode, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_COPROC_NOT  , DA_386IGate, copr_not_available, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_DOUBLE_FAULT, DA_386IGate, double_fault, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_COPROC_SEG  , DA_386IGate, copr_seg_overrun, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_INVAL_TSS   , DA_386IGate, inval_tss, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_SEG_NOT     , DA_386IGate, segment_not_present, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_STACK_FAULT , DA_386IGate, stack_exception, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_PROTECTION  , DA_386IGate, general_protection, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_PAGE_FAULT  , DA_386IGate, page_fault, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_COPROC_ERR  , DA_386IGate, copr_error, PRIVILEGE_KERNEL);

        init_idt_desc(INT_VECTOR_IRQ0 + 0, DA_386IGate, hwint00, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ0 + 1, DA_386IGate, hwint01, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ0 + 2, DA_386IGate, hwint02, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ0 + 3, DA_386IGate, hwint03, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ0 + 4, DA_386IGate, hwint04, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ0 + 5, DA_386IGate, hwint05, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ0 + 6, DA_386IGate, hwint06, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ0 + 7, DA_386IGate, hwint07, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ8 + 0, DA_386IGate, hwint08, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ8 + 1, DA_386IGate, hwint09, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ8 + 2, DA_386IGate, hwint10, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ8 + 3, DA_386IGate, hwint11, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ8 + 4, DA_386IGate, hwint12, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ8 + 5, DA_386IGate, hwint13, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ8 + 6, DA_386IGate, hwint14, PRIVILEGE_KERNEL);
        init_idt_desc(INT_VECTOR_IRQ8 + 7, DA_386IGate, hwint15, PRIVILEGE_KERNEL);

        init_idt_desc(INT_VECTOR_SYS_CALL, DA_386IGate, system_call, PRIVILEGE_KERNEL);
}


PUBLIC void exception_handler(int vec_no, int err_code, int eip, int cs, int eflags)
{
        int i;
        int text_color = 0x74;

        char * err_msg[] = {
                "#DE Divide Error",
			    "#DB RESERVED",
			    "--  NMI Interrupt",
			    "#BP Breakpoint",
			    "#OF Overflow",
			    "#BR BOUND Range Exceeded",
			    "#UD Invalid Opcode (Undefined Opcode)",
			    "#NM Device Not Available (No Math Coprocessor)",
			    "#DF Double Fault",
			    "    Coprocessor Segment Overrun (reserved)",
			    "#TS Invalid TSS",
			    "#NP Segment Not Present",
			    "#SS Stack-Segment Fault",
			    "#GP General Protection",
			    "#PF Page Fault",
			    "--  (Intel reserved. Do not use.)",
			    "#MF x87 FPU Floating-Point Error (Math Fault)",
			    "#AC Alignment Check",
			    "#MC Machine Check",
			    "#XF SIMD Floating-Point Exception"
        };

        int stash_pos = disp_pos;
        disp_pos = 48 * 80;
        // clear screen
        for(i = 0; i < 80; i++) {
                disp_str(" ");
        }
        disp_pos = 48 * 80;

        // print exception info
        disp_int(vec_no);
        disp_str("    ");
        disp_color_str(err_msg[vec_no], 0x74);
        
        disp_pos = stash_pos;
}

PUBLIC void system_call(int eip, int cs, int eflags)
{
        disp_str("\n\n system_call \n\n");
}

PRIVATE void init_idt_desc(unsigned char vector, u8 desc_type, int_handler handler, unsigned char privilege)
{
        GATE* p_gate = &idt[vector];
        u32 base = (u32) handler;
        p_gate->offset_low = base & 0xFFFF;
        p_gate->selector = SELECTOR_KERNEL_CS;
        p_gate->dcount = 0;
        p_gate->attr = desc_type | (privilege << 5);
        p_gate->offset_high = (base >> 16) & 0xFFFF;
}

PRIVATE void init_stack_desc()
{
        // init_gdt_desc(INDEX_STACK0, stack_base, stack_top - stack_base, DA_DRWA+DA_32);
        // init_gdt_desc(INDEX_STACK3, stack_base3, stack_top3 - stack_base3, DA_DRWA+DA_32+DA_DPL3);
        init_gdt_desc(INDEX_STACK0, 
                // 0x0,
                stack_base,
                0xFFFFF, DA_DRWA+DA_32);
                // get_var_phy_addr(SELECTOR_FLAT_RW, stack_base),
                // stack_top - stack_base, DA_DRWA+DA_32);
        disp_int(stack_base);
        disp_int(get_var_phy_addr(SELECTOR_FLAT_RW, stack_base));
        init_gdt_desc(INDEX_STACK3,
                get_var_phy_addr(SELECTOR_FLAT_RW, stack_base3),
                stack_top3 - stack_base3, DA_DRWA+DA_32+DA_DPL3);
        /*
        DESCRIPTOR* p_desc_stack0 = &gdt[INDEX_STACK0];
        p_desc_stack0->limit_low = stack_top & 0xFFFF;
        p_desc_stack0->base_low = stack_base & 0xFFFF;
        p_desc_stack0->base_mid = (stack_base >> 16) & 0xFF;
        u16* attr_and_offset = (u16*) &(p_desc_stack0->attr1);
        *(attr_and_offset) = ((stack_top >> 8) & 0x0F00) | ((DA_DRWA+DA_32) & 0xF0FF);
        p_desc_stack0->base_high = (stack_base >> 24) & 0xFF;

        DESCRIPTOR* p_desc_stack3 = &gdt[INDEX_STACK3];
        p_desc_stack3->limit_low = stack_top3 & 0xFFFF;
        p_desc_stack3->base_low = stack_base3 & 0xFFFF;
        p_desc_stack3->base_mid = (stack_base3 >> 16) & 0xFF;
        u16* attr_and_offset3 = (u16*) &(p_desc_stack3->attr1);
        *(attr_and_offset3) = ((stack_top3 >> 8) & 0x0F00) | ((DA_DRWA+DA_32+DA_DPL3) & 0xF0FF);
        p_desc_stack3->base_high = (stack_base3 >> 24) & 0xFF;
        */
}

PRIVATE void init_gdt_desc(u32 idx, u32 base, u32 limit, u32 attrs)
{
        if (idx >= GDT_SIZE) {
                // todo throw err
                return;
        }
        DESCRIPTOR* p = &gdt[idx];
        p->limit_low = limit & 0xFFFF;
        p->base_low = base & 0xFFFF;
        p->base_mid = (base >> 16) & 0xFF;
        u16* attr_and_offset = (u16*) &(p->attr1);
        *(attr_and_offset) = ((limit >> 8) & 0x0F00) | (attrs & 0xF0FF);
        p->base_high = (base >> 24) & 0xFF;
}

PRIVATE void init_tss()
{
        TSS* p_tss0 = &tss[0];
        mem_set(p_tss0, 0, sizeof(p_tss0));
        p_tss0->pre_tss = 0;
        p_tss0->esp0 = stack_top;
        p_tss0->ss0 = SELECTOR_STACK0;
        p_tss0->esp2 = stack_top3;
        p_tss0->ss2 = SELECTOR_STACK3;
}
