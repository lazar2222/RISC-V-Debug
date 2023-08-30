PROGRAM = program
BUILD_DIR = build
DEBUG = 1
MAP = 1

S_FILES = $(wildcard src/*.s)
C_FILES = $(wildcard src/*.c)

INC_FILES = -Iinc

LINKER_SCRIPT = linker-script.ld

OBJECT_TARGETS = 
OBJECT_TARGETS += $(addprefix $(BUILD_DIR)/, $(notdir $(S_FILES:.s=.o)))
OBJECT_TARGETS += $(addprefix $(BUILD_DIR)/, $(notdir $(C_FILES:.c=.o)))

vpath %.s $(sort $(dir $(S_FILES))) 
vpath %.c $(sort $(dir $(C_FILES)))

CC = riscv-none-elf-gcc
AS = riscv-none-elf-as
LD = riscv-none-elf-ld
OC = riscv-none-elf-objcopy
OD = riscv-none-elf-objdump
SZ = riscv-none-elf-size
SC = srec_cat
MPP = python ../util/mif_pp.py

CORE = -march=rv32i_zicsr -mabi=ilp32 

CC_FLAGS = -c
CC_FLAGS += -Wall -Wextra
CC_FLAGS += -MMD -MP
CC_FLAGS += $(CORE) -mstrict-align -nostdlib -ffreestanding
CC_FLAGS += $(INC_FILES)

AS_FLAGS = 
AS_FLAGS += $(CORE)

LD_FLAGS =
LD_FLAGS += -T $(LINKER_SCRIPT)
LD_FLAGS += --no-warn-rwx-segment

OC_FLAGS =
OC_FLAGS += --output-target ihex

OD_FLAGS = 
OD_FLAGS += -xsD

SZ_FLAGS = 
SZ_FLAGS += -A -d

SC_FLAGS_A =
SC_FLAGS_A += -intel
SC_FLAGS_B =
SC_FLAGS_B += -fill 0x00 -within
SC_FLAGS_C =
SC_FLAGS_C += -range-padding 4 --byte-swap 4 -output
SC_FLAGS_D =
SC_FLAGS_D += -Memory_Initialization_File 32

DBG_FLAGS = -g -gdwarf-2
MAP_FLAGS = -Map=$(BUILD_DIR)/$(PROGRAM).map

ifeq ($(DEBUG), 1)
	AS_FLAGS+= $(DBG_FLAGS)
	CC_FLAGS+= $(DBG_FLAGS)
else
	CC_FLAGS+= -O3
endif

ifeq ($(MAP), 1)
	LD_FLAGS+= $(MAP_FLAGS)
endif

all: $(BUILD_DIR)/$(PROGRAM).dump $(PROGRAM).mif

$(BUILD_DIR)/$(PROGRAM).dump : $(BUILD_DIR)/$(PROGRAM).elf
	$(SZ) $(SZ_FLAGS) $(<)
	$(OD) $(OD_FLAGS) $(<) > $(@)

$(PROGRAM).mif : $(BUILD_DIR)/$(PROGRAM).mif
	$(MPP) $(<) $(@)

$(BUILD_DIR)/$(PROGRAM).mif : $(BUILD_DIR)/$(PROGRAM).hex
	$(SC) $(<) $(SC_FLAGS_A) $(SC_FLAGS_B) $(<) $(SC_FLAGS_A) $(SC_FLAGS_C) $(@) $(SC_FLAGS_D)

$(BUILD_DIR)/$(PROGRAM).hex : $(BUILD_DIR)/$(PROGRAM).elf
	$(OC) $(OC_FLAGS) $(<) $(@)

$(BUILD_DIR)/$(PROGRAM).elf : $(OBJECT_TARGETS) Makefile $(LINKER_SCRIPT)
	$(LD) $(LD_FLAGS) -o $(@) $(OBJECT_TARGETS)

$(BUILD_DIR)/%.o : %.s Makefile | $(BUILD_DIR)
	$(AS) $(AS_FLAGS) -o $(@) $(<)

$(BUILD_DIR)/%.o : %.c Makefile | $(BUILD_DIR)
	$(CC) $(CC_FLAGS) -o $(@) $(<)

$(BUILD_DIR) :
	mkdir $(@)

clean: 
	rm -r $(BUILD_DIR)

-include $(wildcard $(BUILD_DIR)/*.d)
