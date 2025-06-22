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
#RVTYPE=64
RVTYPE=32

AS = riscv$(RVTYPE)-unknown-elf-as
CC = riscv$(RVTYPE)-unknown-elf-gcc
#LD = riscv$(RVTYPE)-unknown-elf-ld
LD = riscv$(RVTYPE)-unknown-elf-gcc
OBJCOPY = riscv$(RVTYPE)-unknown-elf-objcopy
OBJDUMP=riscv$(RVTYPE)-unknown-elf-objdump
READELF=riscv$(RVTYPE)-unknown-elf-readelf
GDB=riscv$(RVTYPE)-unknown-elf-gdb
#GDB=riscv64-unknown-elf-gdb
##DBG=-O2
ifeq ($(NDEBUG),1)
DBG=-O3 -DNDEBUG=1
else
DBG=-g
endif

EXTRA_FLAGS =
ifeq ($(BAREMETAL),1)
EXTRA_FLAGS = -DBAREMETAL
endif

OPT_FLAGS= -ffunction-sections -fdata-sections $(DBG)


ifeq ($(RVTYPE), 64)
ASFLAGS = -march=rv$(RVTYPE)ima_zicsr -mabi=lp64
RISCV_FLAGS =  -mcmodel=large $(ASFLAGS)
else
ASFLAGS = -march=rv$(RVTYPE)ima_zicsr -mabi=ilp32
RISCV_FLAGS = -mcmodel=medlow $(ASFLAGS)
endif

# Flags to pass to the compiler for release builds
#CFLAGS = -fdump-rtl-expand -Wall $(EXTRA_FLAGS) $(RISCV_FLAGS) $(OPT_FLAGS)  -fstrict-aliasing -D_POSIX_C_SOURCE=199309L -MD -Wstrict-aliasing -DQLIST_D_HANDLING
CFLAGS = $(DBG) -ffreestanding -nostartfiles -fdump-rtl-expand -Wall $(EXTRA_FLAGS) $(RISCV_FLAGS) $(OPT_FLAGS)  -fstrict-aliasing -D_POSIX_C_SOURCE=199309L -MD -Wstrict-aliasing -DQLIST_D_HANDLING

# Flags to pass to the linker
#LFLAGS ?= -lm  
UNUSED_LFLAGS = -Wl,--gc-sections -Wl,-Map=output.map
LFLAGS = $(UNUSED_LFLAGS) $(ASFLAGS) -L$(GEM5_PATH)/util/m5/build/riscv/out -nostartfiles
# Output directories
OUTPUT_PATH := $(RISCV_PATH)/../quarks
OBJ_DIR := $(OUTPUT_PATH)
BIN_DIR := $(OUTPUT_PATH)
OBJ_EXT ?= .o
