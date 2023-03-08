# build os

# vars
ASM						= nasm
ASMFLAGS				= -I $(BOOTLOADER_HEADER_PATH)
ASMFLAGS_BUILD_COM		= -I $(BOOTLOADER_HEADER_PATH) -D _BUILD_COM_
ASM_KERNEL_FLAGS		= -f elf -I $(KERNEL_HEADER_ASM_PATH)

CC						= gcc
CC_KERNEL_FLAGS			= -c -I $(KERNEL_HEADER_PATH) -m32 -fno-stack-protector
CC_DEPENDENCY_FLAGS		= -M -I $(KERNEL_HEADER_PATH)

LINK					= ld
LINK_FLAGS				= -m elf_i386 -Ttext 0x30400

BOOTLOADER_HEADER_PATH	= ./boot/include/
KERNEL_PATH				= ./kernel
KERNEL_HEADER_PATH		= ./include
KERNEL_HEADER_ASM_PATH	= ./include/
KERNEL_LIB_PATH			= ./lib
OUTPUT_PATH				= ./build
MOUNT_POINT				= $(OUTPUT_PATH)/mount_point/
BOCHS_CFG				= ./boot.bxrc
BOCHS					= bochs

TARGET					= os.img
DEPENDENCY_SRC			= $(KERNEL_PATH)/start.c $(KERNEL_PATH)/init8259a.c $(KERNEL_PATH)/global.c $(KERNEL_PATH)/kernel.c \
						  $(KERNEL_PATH)/protect_mode.c $(KERNEL_LIB_PATH)/io.c $(KERNEL_LIB_PATH)/proc.c $(KERNEL_LIB_PATH)/utils.c
KERNEL_MODS_OUTPUT		= $(OUTPUT_PATH)/kernel.o $(OUTPUT_PATH)/start.o $(OUTPUT_PATH)/init8259a.o $(OUTPUT_PATH)/global.o \
						  $(OUTPUT_PATH)/protect_mode.o $(OUTPUT_PATH)/proc.o $(OUTPUT_PATH)/kernel_main.o
LIBS_OUTPUT				= $(OUTPUT_PATH)/string.o $(OUTPUT_PATH)/ioa.o $(OUTPUT_PATH)/io.o $(OUTPUT_PATH)/utils.o
IMGS_MODS_OUTPUT		= $(OUTPUT_PATH)/boot.bin $(OUTPUT_PATH)/loader.bin $(OUTPUT_PATH)/kernel.bin

everything : rm_img $(OUTPUT_PATH) $(TARGET)

boot.com : ./boot/boot.asm
	rm -rf $(OUTPUT_PATH)/$@
	$(ASM) $(ASMFLAGS_BUILD_COM) -o $(OUTPUT_PATH)/$@ $<

rm_img :
	rm -f $(OUTPUT_PATH)/os.img

clean : 
	rm -rf $(OUTPUT_PATH)

all : clean everything

run : boot_bochs

boot_bochs : everything
	type $(BOCHS) >/dev/null 2>&1 || { echo "bochs not found"; exit 1; }
	$(BOCHS) -f $(BOCHS_CFG)

dependency : $(DEPENDENCY_SRC)
	$(CC) $(CC_DEPENDENCY_FLAGS) $^

$(OUTPUT_PATH) :
	mkdir -p $(OUTPUT_PATH)

# img mods
$(OUTPUT_PATH)/boot.bin : ./boot/boot.asm 
	$(ASM) $(ASMFLAGS) -o $@ $<

$(OUTPUT_PATH)/loader.bin : ./boot/loader.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

$(OUTPUT_PATH)/kernel.bin : $(KERNEL_MODS_OUTPUT) $(LIBS_OUTPUT)
	$(LINK) $(LINK_FLAGS) -o $@ $^

# kernel mods
$(OUTPUT_PATH)/kernel.o : $(KERNEL_PATH)/kernel.asm $(KERNEL_HEADER_ASM_PATH)/utils.inc.asm $(KERNEL_HEADER_ASM_PATH)/sconst.inc.asm
	$(ASM) $(ASM_KERNEL_FLAGS) -o $@ $<

$(OUTPUT_PATH)/start.o : kernel/start.c include/type.h \
 include/const.h include/protect_mode.h include/string.h include/type.h \
 include/const.h include/io.h include/global.h include/protect_mode.h
	$(CC) $(CC_KERNEL_FLAGS) -o $@ $<

$(OUTPUT_PATH)/init8259a.o : kernel/init8259a.c include/io.h \
 include/const.h include/type.h include/const.h include/protect_mode.h \
 include/type.h
	$(CC) $(CC_KERNEL_FLAGS) -o $@ $<

$(OUTPUT_PATH)/global.o : kernel/global.c include/global.h \
 include/const.h include/type.h include/protect_mode.h include/type.h
	$(CC) $(CC_KERNEL_FLAGS) -o $@ $<

$(OUTPUT_PATH)/protect_mode.o : kernel/protect_mode.c \
 include/global.h include/const.h include/type.h include/protect_mode.h \
 include/type.h
	$(CC) $(CC_KERNEL_FLAGS) -o $@ $<

$(OUTPUT_PATH)/proc.o : kernel/proc.c \
	include/global.h include/type.h include/proc.h
	$(CC) $(CC_KERNEL_FLAGS) -o $@ $<	

$(OUTPUT_PATH)/kernel_main.o : kernel/kernel.c \
	include/kernel.h include/global.h include/io.h include/proc.h
	$(CC) $(CC_KERNEL_FLAGS) -o $@ $<

# libs
$(OUTPUT_PATH)/string.o : $(KERNEL_LIB_PATH)/string.asm
	$(ASM) $(ASM_KERNEL_FLAGS) -o $@ $<

$(OUTPUT_PATH)/ioa.o : $(KERNEL_LIB_PATH)/io.asm
	$(ASM) $(ASM_KERNEL_FLAGS) -o $@ $<

$(OUTPUT_PATH)/io.o : lib/io.c /usr/include/stdc-predef.h include/global.h \
 include/const.h include/type.h include/protect_mode.h include/type.h \
 include/io.h include/utils.h
	$(CC) $(CC_KERNEL_FLAGS) -o $@ $<

$(OUTPUT_PATH)/utils.o : lib/utils.c /usr/include/stdc-predef.h include/global.h \
 include/const.h include/type.h include/protect_mode.h include/type.h \
 include/io.h
	$(CC) $(CC_KERNEL_FLAGS) -o $@ $<

# image
# 1. create a floppy disk image.
# 2. write boot.bin as MBR.
# 3. mount the floppy disk image to MOUNT_POINT
# 4. copy loader.bin and kernel.bin into image
# 5. unmount
os.img : $(IMGS_MODS_OUTPUT)
	bximage -func=create -fd=1.44M -q $(OUTPUT_PATH)/$@
	dd if=$(OUTPUT_PATH)/boot.bin of=$(OUTPUT_PATH)/$@ bs=512 count=1 conv=notrunc
	[ -f $(MOUNT_POINT) ] || mkdir -p $(MOUNT_POINT)
	sudo mount $(OUTPUT_PATH)/$@ $(MOUNT_POINT)
	sudo cp $(OUTPUT_PATH)/loader.bin $(MOUNT_POINT)
	sudo cp $(OUTPUT_PATH)/kernel.bin $(MOUNT_POINT)
	sudo umount $(MOUNT_POINT)
