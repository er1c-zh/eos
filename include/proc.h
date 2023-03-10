#ifndef _EOS_PROC_H_
#define _EOS_PROC_H_

#include "type.h"

typedef struct e_stackframe {
        u32	gs;             /* \                                    */
        u32	fs;             /* |                                    */
        u32	es;             /* |                                    */
        u32	ds;             /* |                                    */

        u32	edi;            /* |                                    */
        u32	esi;            /* | pushed by save()                   */
        u32	ebp;            /* |                                    */
        u32	kernel_esp;     /* <- 'popad' will ignore it            */

        u32	ebx;            /* |                                    */
        u32	edx;            /* |                                    */
        u32	ecx;            /* |                                    */
        u32	eax;            /* /                                    */

        u32	retaddr;        /* return addr for kernel.asm::save()   */
        u32	eip;            /* \                                    */
        u32	cs;             /* |                                    */
        u32	eflags;         /* | pushed by CPU during interrupt     */

        u32	esp;            /* |                                    */
        u32	ss;             /* /                                    */
} STACK_FRAME;

#define PROC_STAT_READY 1
#define PROC_STAT_HANG  2

typedef struct e_pcb {
        STACK_FRAME regs;
        char stack[1024];
        u32 pid;
        u32 func_addr;
        u32 state;
} PCB;

PUBLIC PCB* init(u32 pid, void* func);

// process_scheduler发起一次调度
PUBLIC void process_scheduler();
PUBLIC void task_bg();

PUBLIC void task0();
PUBLIC void task1();

/* kernel.asm */
void save();
void switch_to();
void task_bg();

#define NR_PROCS 3 /* count of procs */

#endif /* _EOS_PROC_H_ */