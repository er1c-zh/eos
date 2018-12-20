#ifndef _EOS_CONST_H_
#define _EOS_CONST_H_

#define PUBLIC
#define PRIVATE static

/* gdt */
#define GDT_SIZE 128

/* idt */
#define IDT_SIZE 256

/* privilege */
#define PRIVILEGE_KERNEL 0
#define PRIVILEGE_TASK 1
#define PRIVILEGE_USER 3

/* 8259A port */
#define INT_MASTER_CTL      0X20
#define INT_MASTER_CTL_MASK 0x21
#define INT_SLAVE_CTL       0xA0
#define INT_SLAVE_CTL_MASK  0xA1

#endif
