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
TARGET = $(BIN_DIR)/kernel
OUT = $(TARGET).elf
BIN = $(TARGET).bin

NO_REBOOT=-no-reboot
#NO_REBOOT=

.SUFFIXES:
.PHONY: all clean show rebuild

$(OUT): $(OBJ)
	@mkdir -p $(dir $@)
	$(LD) $^ $(LFLAGS) -o $@
	size $(OUT)

$(OBJ_DIR)/%$(OBJ_EXT): %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INC)  -c $< -o $@ 
	
rebuild:
	$(MAKE) clean
	$(MAKE) all

all: $(OUT)	
run: $(BIN)
	qemu-system-riscv32 -nographic $(NO_REBOOT) -kernel $(BIN) -s -S

	#@./$(OUT)
gdb: $(OUT)
	$(GDB) $< -ex "target remote localhost:1234" -ex "break start" -ex "continue"

$(BIN): $(OUT)
	$(OBJCOPY) -O binary $< $@

bin: $(BIN)

dump: $(OUT)
	$(OBJDUMP) -d $<

test: run
clean:
	@$(RM) -rf $(OUT) $(OBJ_DIR) $(BIN_DIR)
show:
	@echo INC =  $(INC)
	@echo SRC =  $(SRC)

-include $(OBJ:.o=.d)	
