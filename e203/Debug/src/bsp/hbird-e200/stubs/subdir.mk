################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/bsp/hbird-e200/stubs/_exit.c \
../src/bsp/hbird-e200/stubs/close.c \
../src/bsp/hbird-e200/stubs/fstat.c \
../src/bsp/hbird-e200/stubs/isatty.c \
../src/bsp/hbird-e200/stubs/lseek.c \
../src/bsp/hbird-e200/stubs/malloc.c \
../src/bsp/hbird-e200/stubs/printf.c \
../src/bsp/hbird-e200/stubs/read.c \
../src/bsp/hbird-e200/stubs/sbrk.c \
../src/bsp/hbird-e200/stubs/write.c \
../src/bsp/hbird-e200/stubs/write_hex.c 

O_SRCS += \
../src/bsp/hbird-e200/stubs/malloc.o \
../src/bsp/hbird-e200/stubs/printf.o 

OBJS += \
./src/bsp/hbird-e200/stubs/_exit.o \
./src/bsp/hbird-e200/stubs/close.o \
./src/bsp/hbird-e200/stubs/fstat.o \
./src/bsp/hbird-e200/stubs/isatty.o \
./src/bsp/hbird-e200/stubs/lseek.o \
./src/bsp/hbird-e200/stubs/malloc.o \
./src/bsp/hbird-e200/stubs/printf.o \
./src/bsp/hbird-e200/stubs/read.o \
./src/bsp/hbird-e200/stubs/sbrk.o \
./src/bsp/hbird-e200/stubs/write.o \
./src/bsp/hbird-e200/stubs/write_hex.o 

C_DEPS += \
./src/bsp/hbird-e200/stubs/_exit.d \
./src/bsp/hbird-e200/stubs/close.d \
./src/bsp/hbird-e200/stubs/fstat.d \
./src/bsp/hbird-e200/stubs/isatty.d \
./src/bsp/hbird-e200/stubs/lseek.d \
./src/bsp/hbird-e200/stubs/malloc.d \
./src/bsp/hbird-e200/stubs/printf.d \
./src/bsp/hbird-e200/stubs/read.d \
./src/bsp/hbird-e200/stubs/sbrk.d \
./src/bsp/hbird-e200/stubs/write.d \
./src/bsp/hbird-e200/stubs/write_hex.d 


# Each subdirectory must supply rules for building sources it contributes
src/bsp/hbird-e200/stubs/%.o: ../src/bsp/hbird-e200/stubs/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	-$(PREFIX)$(CC) -march=$(ARCH) -mabi=ilp32 -mcmodel=medlow -msmall-data-limit=8 -mdiv -O2 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common  -g3 -I"../src" -I"../src/bsp" -I"../src/bsp/hbird-e200" -I"../src/bsp/hbird-e200/drivers" -I"../src/bsp/hbird-e200/drivers/hclkgen" -I"../src/bsp/hbird-e200/drivers/plic" -I"../src/bsp/hbird-e200/env" -I"../src/bsp/hbird-e200/include" -I"../src/bsp/hbird-e200/include/headers" -I"../src/bsp/hbird-e200/include/headers/devices" -I"../src/bsp/hbird-e200/stubs" -I"../src/bsp/hbird-e200/tools" -includesys/cdefs.h -std=gnu11 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


