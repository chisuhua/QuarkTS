####
#### Generic Makefile only for C projects
####
#### This file is public domain.
#### J. Camilo Gomez C.
####
include build_options.mk
###################################################################################################
### Do NOT touch the lines below , use the build_options.mk file to change the compile behavior ###
###################################################################################################
INC 	:= 	$(sort -I. $(addprefix -I./,$(dir  $(wildcard *.h */*.h */*/*.h */*/*/*.h)   )) )
SRC 	:= 	$(wildcard src/os/qfsm.c \
										 src/os/qkernel.c \
										 src/os/qqueues.c \
										 src/os/qstimers.c \
										 src/os/qlists.c \
										 src/os/q*.c \
										 mytest/*.c)
OBJ 	:= 	$(addprefix $(OBJ_DIR)/,$(SRC:.c=$(OBJ_EXT)))
TARGET 	= 	$(BIN_DIR)/kernel
OUT 	= 	$(TARGET).elf
BIN 	= 	$(TARGET).bin

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
	$(GDB) $<

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
