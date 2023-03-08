BaseOfLoader            equ 09000h
OffsetOfLoader          equ 0100h
BaseOfLoaderPhyAddr     equ BaseOfLoader * 10h

BaseOfKernel            equ 08000h
OffsetOfKernel          equ 0h
BaseOfKernelPhyAddr     equ BaseOfKernel * 10h
KernelEntryPointPhyAddr equ 30400h ; 链接的时候，指定了text段的开始的位置
