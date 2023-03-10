#ifndef _EOS_GLOBAL_H_
#define _EOS_GLOBAL_H_
#define EXTERN extern

#include "const.h"
#include "type.h"
#include "protect_mode.h"
#include "proc.h"

#ifdef GLOBAL_VARIABLES_HERE
#undef EXTERN
#define EXTERN
#else
#undef EXTERN
#define EXTERN extern
#endif  /* GLOBAL_VARIABLES_HERE */


EXTERN  int         disp_pos;
EXTERN  u8          gdt_ptr[6]; // 32bit gdt_addr and 16bit gdt_len
EXTERN  DESCRIPTOR  gdt[GDT_SIZE];
EXTERN  u8          idt_ptr[6];
EXTERN  GATE        idt[IDT_SIZE];

EXTERN  TSS         tss[2]; // 两个tss

EXTERN  u32         page_directory; // 页目录表

EXTERN  u32         addr_csinit;

EXTERN  u32         stack_top;
EXTERN  u32         stack_base;
EXTERN  u32         stack_top3;
EXTERN  u32         stack_base3;

EXTERN  u16         can_preempt;
EXTERN  PCB*        proc_ready;
EXTERN  u32         proc_cur_idx;
EXTERN  PCB         proc_list[];
EXTERN  char        task_stack[];

#endif  /* _EOS_GLOBAL_H_ */
