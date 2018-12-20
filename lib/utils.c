#include "global.h"
#include "io.h"

/**
 * convert 32bit int to string
 * ==== args:
 * str : string to recv result
 * num : integer to convert
 */
PUBLIC char* itoa(char* str, int num)
{
        char* p = str;
        char ch;
        int i;
        int flag = 0;

        // prefix
        *p++ = '0';
        *p++ = 'x';

        if(num == 0) {
                *p++ = '0';
        } else {
                // 32 bit
                for(i = 28; i >= 0; i -= 4) {
                        ch = (num >> i) & 0xF;
                        if(flag || (ch > 0)) {
                                flag = 1;
                                ch += '0';
                                if(ch > '9') {
                                        ch += 7;
                                }
                                *p++ = ch;
                        }
                }
        }
        
        // the \0 in the end of string
        *p = 0;

        return str;
}

