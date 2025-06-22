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
    $(mkfile_dir)src/os/include/*.h \
    $(mkfile_dir)src/unity/*.h \
)))
INC += 	$(addprefix -I, $(all_h_files))
SRC += 	$(wildcard $(mkfile_dir)/src/os/q*.c)
SRC += 	$(wildcard $(mkfile_dir)/src/unity/*.c)
OBJ := $(patsubst %.c,$(OBJ_DIR)/%.o,$(SRC))
OBJ += $(BIN_DIR)/start.o
OBJ += $(BIN_DIR)/loop.o
TARGET = $(BIN_DIR)/kernel
ELF = $(TARGET).elf
BIN = $(TARGET).bin
LINKER = linker.ld


EMU_TYPE?=se
EMU_EXT?=elf
ifeq ($(GDB), 1)
EMU_GDB?=-gdb tcp::7000 -S
EMU_SE_GDB=-g 7000
GEM5_GDB=-g
else
EMU_GDB?=
EMU_SE_GDB=
GEM5_GDB=
endif
#EMU_GDB?=

QEMU_SYSTEM=-machine virt -nographic -bios none -serial mon:stdio $(EMU_GDB)
#QEMU_SYSTEM=-machine virt -nographic -bios none $(EMU_GDB)
#QEMU_OPTION=-no-reboot $(EMU_GDB)
#NO_REBOOT=

.SUFFIXES:
.PHONY: all clean show rebuild

all: $(LINKER) $(ELF)

$(LINKER): $(LINKER_SRC)
	$(CC) -E -P -x c $< -o $@

$(ELF): $(OBJ)
	@mkdir -p $(dir $@)
	$(LD) $^ $(LFLAGS) -T $(LINKER) -o $@
	size $(ELF)

$(BIN_DIR)/start.o: $(mkfile_dir)/src/os/start.S
	$(CC) -E -P -x c $< -o start.s
	$(AS) $(ASFLAGS) start.s -o $@

$(BIN_DIR)/loop.o: $(mkfile_dir)/src/os/loop.s
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
ifeq ($(EMU_TYPE),fs)
	@echo "Running system emu on $(ELF)..."
	qemu-system-riscv32 $(QEMU_SYSTEM) -kernel $(ELF)
else
	@echo "Running process emu on $(ELF) $(EMU_SE_GDB)..."
	qemu-riscv32 $(EMU_SE_GDB) $(ELF)
endif

baremetal: $(BIN)
	@echo "Todo to add Running system emu on $(ELF)..."
	cd $(GEM5_PATH) && ./build/RISCV/gem5.debug $(GEM5_EXT_PATH)/configs/corerunner/riscv_baremetal.py $(GEM5_GDB) --cores=2

gem5: $(BIN)
ifeq ($(EMU_TYPE),fs)
	@echo "Todo to add Running system emu on $(ELF)..."
	cd $(GEM5_PATH) && ./build/RISCV/gem5.debug $(GEM5_EXT_PATH)/configs/corerunner/riscv_baremetal.py $(GEM5_GDB) --cores=2
else
	@echo "Running process emu on $(ELF)..."
	cd $(GEM5_PATH) && ./build/RISCV/gem5.debug $(GEM5_EXT_PATH)/configs/corerunner/riscv_simple.py $(GEM5_GDB)
endif


	#@./$(ELF)
gdb: $(ELF)
	$(GDB) $< -ex "target remote localhost:7000" -ex "break _start" -ex "break main"

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
	@$(RM) -f $(LINKER)
	@$(RM) -f start.s
show:
	@echo INC =  $(INC)
	@echo SRC =  $(SRC)

-include $(OBJ:.o=.d)	
