#include "global.h"
#include "const.h"
#include "type.h"
#include "protect-mode.h"
#include "io.h"

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

PUBLIC void init_protect_mode()
{
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
}


PUBLIC void exception_handler(int vec_no, int err_code, int eip, int cs, int eflags)
{
        int i;
        int text_color = 0x74;

        char * err_msg[] = {
        };
        disp_pos = 0;
        for(i = 0; i < 80 * 5; i++) {
                disp_str(" ");
        }
        disp_pos = 0;

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
