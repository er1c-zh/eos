# 内存分配情况

_按照分配的顺序_

## boot.asm 

0x07c00开始，BIOS从MBR移动的。

## loader.bin

0x090000 

实模式的stack。

0x090100 

loader.bin从这里开始，boot.asm写入的，定义在`boot/include/load.inc.asm`中。

GDT

LABEL_START 

...

1024 byte 保护模式的栈。

TopOfStack

0x100000

PDE 4KB <==> 一页 <==> 1000个页表 <==> 1000 * 4MB 内存 <==> 4GB 内存

0x101000

PTE

## kernel.bin

0x080000 loader.bin/定义在`boot/include/load.inc.asm`。

# 分页机制线性映射
