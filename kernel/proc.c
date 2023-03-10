#include "global.h"
#include "proc.h"

PUBLIC PCB* init(u32 pid, void* func)
{
    if (pid >= NR_PROCS) {
        return 0 /* nil */;
    }
    PCB* pcb = &proc_list[pid];

    pcb->pid = pid;
    pcb->state = 1;

    pcb->func_addr = (u32) func;

    pcb->regs.cs = SELECTOR_C3;
    pcb->regs.ds = SELECTOR_D3;
    pcb->regs.es = SELECTOR_D3;
    pcb->regs.fs = SELECTOR_D3;
    pcb->regs.gs = SELECTOR_VIDEO;
    pcb->regs.ss = SELECTOR_D3;

    pcb->regs.eip = (u32) func;
    pcb->regs.esp = (u32) pcb->stack + 1024;
    pcb->regs.eflags = 0x1202;

    return pcb;
} 

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