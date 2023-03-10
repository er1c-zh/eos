#ifndef _EOS_IO_H_
#define _EOS_IO_H_

#include "const.h"
#include "type.h"

PUBLIC  void    clear();
PUBLIC  void    disp_str(char* str);
PUBLIC  void    disp_int(int num);
PUBLIC  void    disp_color_str(char* str, int color);
PUBLIC  u8      in_byte(u16 port);
PUBLIC  void    out_byte(u16 port, u8 val);

#endif  /* _EOS_IO_H_ */
