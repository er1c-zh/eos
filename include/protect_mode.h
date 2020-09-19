#ifndef _EOS_PROTECT_MODE_H
#define _EOS_PROTECT_MODE_H

#include <type.h>

typedef struct e_descriptor {
        u16     limit_low;
        u16     base_low;
        u8      base_mid;
        u8      attr1;
        u8      attr2_limit_high;
        u8      base_high;
} DESCRIPTOR;

typedef struct e_gates {
        u16     offset_low;
        u16     selector;
        u8      dcount;
        u8      attr;
        u16     offset_high;
} GATE;

typedef struct e_tss {
        u32     pre_tss;
        u32     esp0;
        u32     ss0;
        u32     esp1;
        u32     ss1;
        u32     esp2;
        u32     ss2;
        u32     cr3;
        u32     eip;
        u32     eflags;
        u32     eax;
        u32     ecx;
        u32     edx;
        u32     ebx;
        u32     esp;
        u32     ebp;
        u32     esi;
        u32     edi;
        u32     es;
        u32     cs;
        u32     ss;
        u32     ds;
        u32     fs;
        u32     gs;
        u32     ldtr;
        u16     trap;   u16     iomap_base;
} TSS;

PUBLIC u32 get_var_phy_addr(u16 selector, u32 ptr_2_var);

PUBLIC void* ptr_to_gdt_base();
PUBLIC u16 gdt_len();
PUBLIC void set_gdt(void* ptr_to_base, u16 size);
PUBLIC void set_idt(void* ptr_to_base, u16 size);

PUBLIC void task0();

PUBLIC void init_8259A();
PUBLIC void spurious_irq(int irq);
PUBLIC void init_protect_mode();
PRIVATE void init_idt_desc(unsigned char vector, u8 desc_type, int_handler handler, unsigned char privilege);
PRIVATE void init_stack_desc();
PRIVATE void init_tss();
PRIVATE void init_gdt_desc(u32 idx, u32 base, u32 limit, u32 attrs);

/* GDT */
/* 描述符索引 */
#define	INDEX_DUMMY     0	// ┓
#define	INDEX_FLAT_C    1	// ┣ LOADER 里面已经确定了的.
#define	INDEX_FLAT_RW   2	// ┃
#define	INDEX_VIDEO     3	// ┛
#define INDEX_STACK0    4
#define INDEX_STACK3    5
#define INDEX_TSS_TASK0 6   // TASK0的tss描述符
#define INDEX_TSS_TASK1 7   // TASK1的tss描述符
#define INDEX_CODE_3    8   // RING3 的代码段
#define INDEX_DATA_3    9   // RING3 的数据段
/* 选择子 */
#define	SELECTOR_DUMMY      0
#define	SELECTOR_FLAT_C     0x08
#define	SELECTOR_FLAT_RW    0x10
#define	SELECTOR_VIDEO      (0x18+3)
#define SELECTOR_STACK0     0x20
#define SELECTOR_STACK3     0x2B
#define SELECTOR_TSS0       0x33
#define SELECTOR_TSS1       0x38
#define SELECTOR_C3         0x43
#define SELECTOR_D3         0x4B

#define	SELECTOR_KERNEL_CS	SELECTOR_FLAT_C
#define	SELECTOR_KERNEL_DS	SELECTOR_FLAT_RW


/* 描述符类型值说明 */
#define	DA_32			0x4000	/* 32 位段				*/
#define	DA_LIMIT_4K		0x8000	/* 段界限粒度为 4K 字节			*/
#define	DA_DPL0			0x00	/* DPL = 0				*/
#define	DA_DPL1			0x20	/* DPL = 1				*/
#define	DA_DPL2			0x40	/* DPL = 2				*/
#define	DA_DPL3			0x60	/* DPL = 3				*/
/* 存储段描述符类型值说明 */
#define	DA_DR			0x90	/* 存在的只读数据段类型值		*/
#define	DA_DRW			0x92	/* 存在的可读写数据段属性值		*/
#define	DA_DRWA			0x93	/* 存在的已访问可读写数据段类型值	*/
#define	DA_C			0x98	/* 存在的只执行代码段属性值		*/
#define	DA_CR			0x9A	/* 存在的可执行可读代码段属性值		*/
#define	DA_CCO			0x9C	/* 存在的只执行一致代码段属性值		*/
#define	DA_CCOR			0x9E	/* 存在的可执行可读一致代码段属性值	*/
/* 系统段描述符类型值说明 */
#define	DA_LDT			0x82	/* 局部描述符表段类型值			*/
#define	DA_TaskGate		0x85	/* 任务门类型值				*/
#define	DA_386TSS		0x89	/* 可用 386 任务状态段类型值		*/
#define	DA_386CGate		0x8C	/* 386 调用门类型值			*/
#define	DA_386IGate		0x8E	/* 386 中断门类型值			*/
#define	DA_386TGate		0x8F	/* 386 陷阱门类型值			*/

/* 中断向量 */
#define	INT_VECTOR_DIVIDE       0x0
#define	INT_VECTOR_DEBUG        0x1
#define	INT_VECTOR_NMI          0x2
#define	INT_VECTOR_BREAKPOINT   0x3
#define	INT_VECTOR_OVERFLOW     0x4
#define	INT_VECTOR_BOUNDS       0x5
#define	INT_VECTOR_INVAL_OP     0x6
#define	INT_VECTOR_COPROC_NOT   0x7
#define	INT_VECTOR_DOUBLE_FAULT 0x8
#define	INT_VECTOR_COPROC_SEG   0x9
#define	INT_VECTOR_INVAL_TSS    0xA
#define	INT_VECTOR_SEG_NOT      0xB
#define	INT_VECTOR_STACK_FAULT  0xC
#define	INT_VECTOR_PROTECTION   0xD
#define	INT_VECTOR_PAGE_FAULT   0xE
#define	INT_VECTOR_COPROC_ERR   0x10


// 8259a
#define INT_VECTOR_IRQ0     0x20
#define INT_VECTOR_IRQ8     0x28

#define INT_VECTOR_SYS_CALL 0x30

#endif
