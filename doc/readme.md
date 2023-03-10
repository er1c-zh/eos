# 开发参考的资料

# 大纲

- [osdev wiki](https://wiki.osdev.org) 一个开发os的wiki

# asm and x86

- [x86 and amd64 instruction reference](https://www.felixcloutier.com/x86/) 指令速查的html
- [x86的开发手册.pdf](https://software.intel.com/en-us/download/intel-64-and-ia-32-architectures-sdm-combined-volumes-1-2a-2b-2c-2d-3a-3b-3c-3d-and-4)
- [nasm document](https://www.nasm.us/docs.php)
- [eflags](https://en.wikipedia.org/wiki/FLAGS_register)

# mbr and fat12

- [wikipedia-mbr](https://zh.wikipedia.org/zh-hans/%E4%B8%BB%E5%BC%95%E5%AF%BC%E8%AE%B0%E5%BD%95)
- [wikipedia-FAT](https://zh.wikipedia.org/wiki/%E6%AA%94%E6%A1%88%E9%85%8D%E7%BD%AE%E8%A1%A8)
    - [wikipedia FAT的保留扇区格式](https://zh.wikipedia.org/wiki/%E6%AA%94%E6%A1%88%E9%85%8D%E7%BD%AE%E8%A1%A8#%E5%90%AF%E5%8A%A8%E6%89%87%E5%8C%BA)

# BIOS

- [mbr-boot-process](https://neosmart.net/wiki/mbr-boot-process/)
- [BIOS启动的过程](https://en.wikipedia.org/wiki/BIOS#Boot_process)
    - [BIOS将控制权传给boot sector时的CPU状态](https://en.wikipedia.org/wiki/BIOS#Boot_environment)
- [BIOS中断](https://en.wikipedia.org/wiki/BIOS_interrupt_call)   
    - [BIOS中断表](https://en.wikipedia.org/wiki/BIOS_interrupt_call#Interrupt_table)
    - [INT 15h EAX=0E820h](https://wiki.osdev.org/Detecting_Memory_(x86)#BIOS_Function:_INT_0x15.2C_EAX_.3D_0xE820)

# Toolchains

- [ld manual](https://linux.die.net/man/1/ld)

# 编译产物

- [Object File](https://en.wikipedia.org/wiki/Object_file)
- [ELF](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)
