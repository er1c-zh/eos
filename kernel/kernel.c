#include "kernel.h"

#include "global.h"
#include "io.h"
#include "proc.h"

PUBLIC void kernel_main()
{
    disp_str("kernel_main\n");
    proc_ready = init(0, task0);
    disp_str("init task0 finish!\n");
    switch_to();
    while(1) {
        disp_str("m");
    }
}
