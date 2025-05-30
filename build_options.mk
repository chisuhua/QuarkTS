####
#### Generic Makefile only for C projects
####
#### This file is public domain.
#### J. Camilo Gomez C.
####
##############################
### Configurable variables ###
##############################
# The compiler
AS = riscv32-unknown-elf-as
CC = riscv32-unknown-elf-gcc
#LD = riscv32-unknown-elf-ld
LD = riscv32-unknown-elf-gcc
OBJCOPY = riscv32-unknown-elf-objcopy
OBJDUMP=riscv32-unknown-elf-objdump
READELF=riscv32-unknown-elf-readelf
GDB=riscv32-unknown-elf-gdb
#DBG=-O2
ifeq ($(NDEBUG),1)
DBG=-O3 -DNDEBUG=1
else
DBG=-g
endif

#EXTRA_FLAGS = -flto -Wextra -Wimplicit-fallthrough=0 -Wformat-security -Wduplicated-cond -Wfloat-equal -Wshadow -Wconversion -Wsign-conversion -Wjump-misses-init -Wlogical-not-parentheses -Wnull-dereference  -Wnull-dereference -Wstringop-overflow 
EXTRA_FLAGS =
ifeq ($(BAREMETAL),1)
EXTRA_FLAGS = -DBAREMETAL=1
endif

OPT_FLAGS= -ffunction-sections -fdata-sections $(DBG)


ASFLAGS = -march=rv32imc_zicsr -mabi=ilp32

# Flags to pass to the compiler for release builds
RISCV_FLAGS = $(DBG) -ffreestanding -nostartfiles -mcmodel=medlow -march=rv32imc_zicsr -mabi=ilp32
#RISCV_FLAGS = $(DBG) -ffreestanding -mcmodel=medlow -march=rv32imc -mabi=ilp32
CFLAGS = -fdump-rtl-expand -Wall $(EXTRA_FLAGS) $(RISCV_FLAGS) $(OPT_FLAGS)  -fstrict-aliasing -D_POSIX_C_SOURCE=199309L -MD -Wstrict-aliasing -DQLIST_D_HANDLING
#CFLAGS = -Wall $(RISCV_FLAGS)  -fstrict-aliasing -O2 -std=c99 -D_POSIX_C_SOURCE=199309L -MD -Wstrict-aliasing -DQLIST_D_HANDLING

# Flags to pass to the linker
#LFLAGS ?= -lm  
UNUSED_LFLAGS = -Wl,--gc-sections -Wl,-Map=output.map
#LFLAGS = -m elf32lriscv  -T linker.ld
#LFLAGS = -m elf32lriscv
#LFLAGS = -mabi=ilp32 -march=rv32imc -T linker.ld
LFLAGS = $(UNUSED_LFLAGS) -nostartfiles -T $(LINKER)
#LFLAGS = $(UNUSED_LFLAGS) -T $(LINKER)
# Output directories
OUTPUT_PATH := $(RISCV_PATH)/../quarks
OBJ_DIR := $(OUTPUT_PATH)
BIN_DIR := $(OUTPUT_PATH)
OBJ_EXT ?= .o
