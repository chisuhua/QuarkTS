####
#### Generic Makefile only for C projects
####
#### This file is public domain.
#### J. Camilo Gomez C.
####
mkfile_abs_dir := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_abs_dir))
include $(mkfile_dir)/build_options.mk
###################################################################################################
### Do NOT touch the lines below , use the build_options.mk file to change the compile behavior ###
###################################################################################################
OBJ_EXT = .o
# 收集头文件（递归查找多级子目录）
all_h_files := $(sort $(dir $(wildcard \
    $(mkfile_dir)*.h \
    $(mkfile_dir)*/*.h \
    $(mkfile_dir)*/*/*.h \
    $(mkfile_dir)*/*/*/*.h \
)))
INC := 	$(addprefix -I, $(all_h_files))
SRC += 	$(wildcard $(mkfile_dir)/src/os/q*.c)
OBJ := $(patsubst %.c,$(OBJ_DIR)/%.o,$(SRC))
OBJ += $(BIN_DIR)/start.o
TARGET = $(BIN_DIR)/kernel
ELF = $(TARGET).elf
BIN = $(TARGET).bin


EMU_TYPE?=se
EMU_EXT?=elf
ifeq ($(GDB), 1)
EMU_GDB?=-s -S
else
EMU_GDB?=
endif
#EMU_GDB?=

QEMU_SYSTEM=-machine virt -nographic -bios none -serial mon:stdio -append "console=ttyS0" $(EMU_GDB)
QEMU_SYSTEM=-machine virt -nographic $(EMU_GDB)
#QEMU_OPTION=-no-reboot $(EMU_GDB)
#NO_REBOOT=

.SUFFIXES:
.PHONY: all clean show rebuild

$(ELF): $(OBJ)
	@mkdir -p $(dir $@)
	$(LD) $^ $(LFLAGS) -o $@
	size $(ELF)

$(BIN_DIR)/start.o: $(mkfile_dir)/src/os/start.s
	$(AS) $(ASFLAGS) $< -o $@

$(OBJ_DIR)/%$(OBJ_EXT): %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INC)  -c $< -o $@ 
	
rebuild:
	$(MAKE) clean
	$(MAKE) all

all: $(ELF)

#qemu: $(BIN)
#ifeq ($(EMU_EXT),bin)
#	@echo "Running $(BIN)..."
#	qemu-system-riscv32 -nographic $(QEMU_OPTION) -device loader,addr=0x80000000,file=$(BIN),cpu-num=0
#else
#	@echo "Running $(ELF)..."
#	qemu-system-riscv32 -nographic $(QEMU_OPTION) -kernel $(ELF)
#endif
qemu: $(BIN)
ifeq ($(EMU_TYPE),system)
	@echo "Running system emu on $(ELF)..."
	qemu-system-riscv32 $(QEMU_SYSTEM) -kernel $(ELF)
else
	@echo "Running process emu on $(ELF)..."
	qemu-riscv32 $(ELF)
endif


	#@./$(ELF)
gdb: $(ELF)
	#$(GDB) $< -ex "target remote localhost:1234" -ex "break start" -ex "continue"
	#$(GDB) $< -ex "target remote localhost:1234" -ex "break _start" -ex "break main" -ex "break *0x80000000"
	$(GDB) $< -ex "target remote localhost:1234" -ex "break _start" -ex "break main"

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

bin: $(BIN)

dump: $(ELF)
	$(OBJDUMP) -d $<

readelf: $(ELF)
	$(READELF) -l $<

test: run
clean:
	@$(RM) -rf $(ELF) $(OBJ_DIR) $(BIN_DIR)
show:
	@echo INC =  $(INC)
	@echo SRC =  $(SRC)

-include $(OBJ:.o=.d)	
