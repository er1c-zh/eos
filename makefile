# build os

# vars
ASM		= nasm
ASMFLAGS	= -I include/ -I boot/include/
ASMFLAGS_BUILD_COM		= -I include/ -I boot/include/ -D _BUILD_COM_
OUTPUT_PATH	= ./build

TARGET		= boot.bin os.img

everything : rm_img $(OUTPUT_PATH) $(TARGET)

boot.com : ./boot/boot.asm
	rm -rf $(OUTPUT_PATH)/$@
	$(ASM) $(ASMFLAGS_BUILD_COM) -o $(OUTPUT_PATH)/$@ $<

rm_img :
	rm -f $(OUTPUT_PATH)/os.img

clean : 
	rm -f $(OUTPUT_PATH)/*

all : clean everything

$(OUTPUT_PATH) :
	mkdir -p $(OUTPUT_PATH)

boot.bin : ./boot/boot.asm 
	$(ASM) $(ASMFLAGS) -o $(OUTPUT_PATH)/$@ $<

os.img : boot.bin
	bximage -fd -size=1.44 -q $(OUTPUT_PATH)/$@
	dd if=$(OUTPUT_PATH)/$< of=$(OUTPUT_PATH)/$@ bs=512 count=1 conv=notrunc
