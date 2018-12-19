# build ELF tools

OUTPUT_PATH	= ./build

TARGET		= parseELF

everything : clean $(OUTPUT_PATH) $(TARGET)

parseELF : parseELF.c
	gcc -o $(OUTPUT_PATH)/$@ $<

$(OUTPUT_PATH) :
	mkdir -p $(OUTPUT_PATH)

clean :
	rm -rf $(OUTPUT_PATH)
