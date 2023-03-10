#include "kernel.h"

#include "global.h"
#include "io.h"
#include "proc.h"
#include "shell.h"

PUBLIC void kernel_main()
{
    disp_str("kernel_main\n");
    PCB* proot = init(0, task_bg);
    proc_ready = proot;
    proc_cur_idx = 0;

    // 初始化
    init(1, shell);
}

PUBLIC void task_bg()
{
    can_preempt = 1;
    while(1) {
        // TODO hold
    };
}

PUBLIC void process_scheduler()
{
    while (1) {
        proc_cur_idx += 1;
        if (proc_cur_idx >= NR_PROCS) {
            proc_cur_idx = 0;
        }
        if (proc_list[proc_cur_idx].state == PROC_STAT_READY) {
            break;
        }
    }

    proc_ready = &proc_list[proc_cur_idx];
}
