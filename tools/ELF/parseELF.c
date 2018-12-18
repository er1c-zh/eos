#define DEBUG

#include <stdio.h>
#include <string.h>
#include <elf.h>

/**
 * parse elf file
 * default to elf32
 */
int main(int argc, char* argv[]) {
        if(argc != 2) {
                printf("usage: parseELF {file-path}\n");
                return -1;
        }
        FILE *t = fopen(argv[1], "rb");
        
        if(t == NULL) {
                printf("file not exist!\n");
                return -1;
        }

        Elf32_Ehdr elf_header;      // /usr/include/elf.h

        // read file to elf_header
        fread(&elf_header, sizeof(Elf32_Ehdr), 1, t);

        // check is elf file;
        char elf_buf[3];
        memcpy(elf_buf, elf_header.e_ident + 1, 3);
        if(strcmp(elf_buf, "ELF") != 0) {
                printf("file is not a elf file!\n");
        }

        // output elf header info
        printf("========= ELF header ===========\n");
        printf("ELF file type\t\t%hx\n", elf_header.e_type);
        printf("entry point addr\t\t0x%x\n", elf_header.e_entry);
        printf("program header offset\t\t0x%x\n", elf_header.e_phoff);
        printf("program header count\t\t0x%x\n", elf_header.e_phnum);
        printf("section header offset\t\t0x%x\n", elf_header.e_shoff);
        printf("section header count\t\t0x%x\n", elf_header.e_shnum);
        printf("ELF header size\t\t\t0x%hx\n", elf_header.e_ehsize);


        // output elf programm header info
        printf("========= program header ===========\n");
        fseek(t, elf_header.e_phoff, SEEK_SET);
        int ph_c = 0;
        while(ph_c++ < elf_header.e_phnum) {
                Elf32_Phdr phdr;
                fread(&phdr, sizeof(Elf32_Phdr), 1, t);
                printf("===program header %d===\n", ph_c);
                printf("segment type\t\t%d\n", phdr.p_type);
                printf("virtual address\t\t0x%x\n", phdr.p_vaddr);
                printf("physical address\t\t0x%x\n", phdr.p_paddr);
                printf("file offset\t\t0x%x\n", phdr.p_offset);
        }

        // output elf section info
        printf("========= section header ===========\n");
        fseek(t, elf_header.e_shoff, SEEK_SET);
        int sh_c = 0;
        while(sh_c++ < elf_header.e_shnum) {
                Elf32_Shdr shdr;
                fread(&shdr, sizeof(Elf32_Shdr), 1, t);
                printf("===section header %d===\n", sh_c);
                printf("name\t\t%d\n", shdr.sh_name);
                printf("v addr\t\t\t0x%x\n", shdr.sh_addr);
                printf("f offset\t\t0x%x\n", shdr.sh_offset);
        }

        return 0;
}
