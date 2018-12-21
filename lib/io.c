#include "global.h"
#include "io.h"
#include "utils.h"

/**
 * print int
 * ==== arg:
 * num : int to print
 */
PUBLIC void disp_int(int num)
{
        char buffer[16];
        itoa(buffer, num);
        disp_str(buffer);
}

/**
 * clean screen
 */
PUBLIC void clear()
{
        int i;
        disp_pos = 0;
        for(i = 0; i < 25 * 80; i++) {
                disp_str(" ");
        }
        disp_pos = 0;
}
