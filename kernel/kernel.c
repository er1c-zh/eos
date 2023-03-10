#include "kernel.h"

#include "global.h"
#include "io.h"
#include "proc.h"

PUBLIC void kernel_main()
{
    disp_str("kernel_main\n");
    PCB* proot = init(0, task_bg);
    proc_ready = proot;
    proc_cur_idx = 0;

    init(1, task0);
    init(2, task1);
}

PUBLIC void task_bg()
{
    can_preempt = 1;
    disp_str("__task_bg__\n");
    while(1) {
        for (int i = 0; i < 1000000; i++) {}
        disp_str("~");
    };
}

PUBLIC void process_scheduler()
{
    while (1) {
        proc_cur_idx += 1;
        if (proc_cur_idx >= NR_PROCS) {
            proc_cur_idx = 0;
        }
        if (proc_list[proc_cur_idx].state != 0) {
            break;
        }
    }

    proc_ready = &proc_list[proc_cur_idx];
}
