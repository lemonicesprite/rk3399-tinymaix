# ------------------------------------------------
# Generic Makefile (based on gcc)
#
# ChangeLog :
#   2022-08-16 - first version
# ------------------------------------------------

######################################
# target
######################################
TARGET = tinymaix


######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization
OPT = -O2


#######################################
# paths
#######################################
# Build path
BUILD_DIR = build

# Runcode path
RUNCODE_DIR = run

######################################
# source
######################################
# C sources
C_SOURCES =  \
main.c \
Components/TinyMaix/src/tm_layers.c \
Components/TinyMaix/src/tm_layers_O1.c \
Components/TinyMaix/src/tm_stat.c \
Components/TinyMaix/src/tm_layers_fp8.c \
Components/TinyMaix/src/tm_model.c \
TinyMaix/src/mbnet/label.c \
TinyMaix/src/mbnet/mbnet.c \
TinyMaix/src/vww.c \
TinyMaix/src/cifar.c \
TinyMaix/src/mnist.c \

# ASM sources
ASM_SOURCES =  


#######################################
# binaries
#######################################
PREFIX ?= 
# The gcc compiler bin path can be either defined in make command via GCC_PATH variable (> make GCC_PATH=xxx)
# either it can be added to the PATH environment variable.
ifdef GCC_PATH
CC = $(GCC_PATH)/$(PREFIX)gcc
AS = $(GCC_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
else
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

 #######################################
# CFLAGS
#######################################
# macros for gcc
# AS defines
AS_DEFS = 

# C defines
C_DEFS =  

# AS includes
AS_INCLUDES = 

# C includes
C_INCLUDES =  \
-IComponents/TinyMaix/src \
-IComponents/TinyMaix/tools/tmdl \
-IComponents/TinyMaix/examples/vww/pic \
-IComponents/TinyMaix/examples/cifar10/pic \
-ITinyMaix/include \

# compile gcc flags
ASFLAGS = $(AS_DEFS) $(AS_INCLUDES) $(OPT) -fdata-sections -ffunction-sections  

CFLAGS += $(C_DEFS) $(C_INCLUDES) $(OPT) -fdata-sections -ffunction-sections 


ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif


# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


#######################################
# LDFLAGS
#######################################
# libraries
LIBS = -lc -lm
LIBDIR = 
LDFLAGS = $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf
	

#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))

#list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@
	
$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@
	
$(BUILD_DIR):
	mkdir $@

#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD_DIR) ${RUNCODE_DIR}

#######################################
# run
#######################################
run: all
	@ echo 
	@ echo "******************************"	
	@ echo "********** Run Code **********"
	@ echo "******************************"
	@ echo 
	@ mkdir -p $(RUNCODE_DIR)
	@ cp ./$(BUILD_DIR)/$(TARGET).elf ${RUNCODE_DIR}
	@ cd ${RUNCODE_DIR} && ./$(TARGET).elf
	@ echo 
	@ echo "******************************"	
	@ echo "**********   End    **********"
	@ echo "******************************"
	@ echo 

#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)

# *** EOF ***
#######################################
