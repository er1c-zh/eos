# build os

# vars
ASM						= nasm
ASMFLAGS				= -I $(BOOTLOADER_HEADER_PATH)
ASMFLAGS_BUILD_COM		= -I $(BOOTLOADER_HEADER_PATH) -D _BUILD_COM_
ASM_KERNEL_FLAGS		= -f elf

GCC						= gcc
GCC_KERNEL_FLAGS		= -c -I $(KERNEL_HEADER_PATH) -m32

LINK					= ld
LINK_FLAGS				= -m elf_i386 -Ttext 0x30400

BOOTLOADER_HEADER_PATH	= ./boot/include/
KERNEL_PATH				= ./kernel
KERNEL_HEADER_PATH		= ./include
KERNEL_LIB_PATH			= ./lib
OUTPUT_PATH				= ./build

TARGET					= os.img
KERNEL_MODS_OUTPUT		= $(OUTPUT_PATH)/kernel.o $(OUTPUT_PATH)/start.o
LIBS_OUTPUT				= $(OUTPUT_PATH)/string.o $(OUTPUT_PATH)/io.o
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
$(OUTPUT_PATH)/kernel.o : $(KERNEL_PATH)/kernel.asm
	$(ASM) $(ASM_KERNEL_FLAGS) -o $@ $<

$(OUTPUT_PATH)/start.o : $(KERNEL_PATH)/start.c
	$(GCC) $(GCC_KERNEL_FLAGS) -o $@ $<

# libs
$(OUTPUT_PATH)/string.o : $(KERNEL_LIB_PATH)/string.asm
	$(ASM) $(ASM_KERNEL_FLAGS) -o $@ $<

$(OUTPUT_PATH)/io.o : $(KERNEL_LIB_PATH)/io.asm
	$(ASM) $(ASM_KERNEL_FLAGS) -o $@ $<

# image
os.img : $(IMGS_MODS_OUTPUT)
	bximage -mode=create -fd=1.44M -q $(OUTPUT_PATH)/$@
	dd if=$(OUTPUT_PATH)/boot.bin of=$(OUTPUT_PATH)/$@ bs=512 count=1 conv=notrunc
	sudo mount $(OUTPUT_PATH)/$@ /mnt/floppy
	sudo cp $(OUTPUT_PATH)/loader.bin /mnt/floppy/
	sudo cp $(OUTPUT_PATH)/kernel.bin /mnt/floppy/
	sudo umount /mnt/floppy
