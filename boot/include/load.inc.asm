BaseOfLoader            equ 09000h
OffsetOfLoader          equ 0100h
BaseOfLoaderPhyAddr     equ BaseOfLoader * 10h

BaseOfKernel            equ 08000h
OffsetOfKernel          equ 0h
BaseOfKernelPhyAddr     equ BaseOfKernel * 10h
KernelEntryPointPhyAddr equ 30400h
