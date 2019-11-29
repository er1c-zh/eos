#ifndef _EOS_GLOBAL_H_
#define _EOS_GLOBAL_H_
#define EXTERN extern

#include "const.h"
#include "type.h"
#include "protect-mode.h"

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

#endif  /* _EOS_GLOBAL_H_ */
