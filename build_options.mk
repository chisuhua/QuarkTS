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
CC = riscv32-unknown-elf-gcc
#LD = riscv32-unknown-elf-ld
LD = riscv32-unknown-elf-gcc
OBJCOPY = riscv32-unknown-elf-objcopy
OBJDUMP=riscv32-unknown-elf-objdump
READELF=riscv32-unknown-elf-readelf
GDB=riscv32-unknown-elf-gdb
#DBG=-O2
DBG=-g
OPT_FLAGS= -ffunction-sections -fdata-sections $(DBG)

# Flags to pass to the compiler for release builds
RISCV_FLAGS = $(DBG) -ffreestanding -nostdlib -nostartfiles -mcmodel=medlow -march=rv32imc -mabi=ilp32
EXTRA_FLAGS = -flto -Wextra -Wimplicit-fallthrough=0 -Wformat-security -Wduplicated-cond -Wfloat-equal -Wshadow -Wconversion -Wsign-conversion -Wjump-misses-init -Wlogical-not-parentheses -Wnull-dereference  -Wnull-dereference -Wstringop-overflow 
EXTRA_FLAGS =
CFLAGS = -fdump-rtl-expand -Wall $(EXTRA_FLAGS) $(RISCV_FLAGS) $(OPT_FLAGS)  -fstrict-aliasing -std=c99 -D_POSIX_C_SOURCE=199309L -MD -Wstrict-aliasing -DQLIST_D_HANDLING
#CFLAGS = -Wall $(RISCV_FLAGS)  -fstrict-aliasing -O2 -std=c99 -D_POSIX_C_SOURCE=199309L -MD -Wstrict-aliasing -DQLIST_D_HANDLING

# Flags to pass to the linker
#LFLAGS ?= -lm  
UNUSED_LFLAGS = -Wl,--gc-sections -Wl,-Map=output.map
#LFLAGS = -m elf32lriscv  -T linker.ld
#LFLAGS = -m elf32lriscv
#LFLAGS = -mabi=ilp32 -march=rv32imc -T linker.ld
LFLAGS = $(UNUSED_LFLAGS) -T linker.ld
# Output directories
OBJ_DIR := obj
BIN_DIR := bin
OBJ_EXT ?= .o
