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
