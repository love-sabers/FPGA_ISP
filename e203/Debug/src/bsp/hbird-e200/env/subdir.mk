################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/bsp/hbird-e200/env/init.c 

S_UPPER_SRCS += \
../src/bsp/hbird-e200/env/entry.S \
../src/bsp/hbird-e200/env/start.S 

OBJS += \
./src/bsp/hbird-e200/env/entry.o \
./src/bsp/hbird-e200/env/init.o \
./src/bsp/hbird-e200/env/start.o 

S_UPPER_DEPS += \
./src/bsp/hbird-e200/env/entry.d \
./src/bsp/hbird-e200/env/start.d 

C_DEPS += \
./src/bsp/hbird-e200/env/init.d 


# Each subdirectory must supply rules for building sources it contributes
src/bsp/hbird-e200/env/%.o: ../src/bsp/hbird-e200/env/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross Assembler'
	-$(PREFIX)$(CC) -march=$(ARCH) -mabi=ilp32 -mcmodel=medlow -msmall-data-limit=8 -mdiv -O2 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common  -g3 -x assembler-with-cpp -I"../src" -I"../src/bsp" -I"../src/bsp/hbird-e200" -I"../src/bsp/hbird-e200/drivers" -I"../src/bsp/hbird-e200/drivers/hclkgen" -I"../src/bsp/hbird-e200/drivers/plic" -I"../src/bsp/hbird-e200/env" -I"../src/bsp/hbird-e200/include" -I"../src/bsp/hbird-e200/include/headers" -I"../src/bsp/hbird-e200/include/headers/devices" -I"../src/bsp/hbird-e200/stubs" -I"../src/bsp/hbird-e200/tools" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/bsp/hbird-e200/env/%.o: ../src/bsp/hbird-e200/env/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	-$(PREFIX)$(CC) -march=$(ARCH) -mabi=ilp32 -mcmodel=medlow -msmall-data-limit=8 -mdiv -O2 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common  -g3 -I"../src" -I"../src/bsp" -I"../src/bsp/hbird-e200" -I"../src/bsp/hbird-e200/drivers" -I"../src/bsp/hbird-e200/drivers/hclkgen" -I"../src/bsp/hbird-e200/drivers/plic" -I"../src/bsp/hbird-e200/env" -I"../src/bsp/hbird-e200/include" -I"../src/bsp/hbird-e200/include/headers" -I"../src/bsp/hbird-e200/include/headers/devices" -I"../src/bsp/hbird-e200/stubs" -I"../src/bsp/hbird-e200/tools" -includesys/cdefs.h -std=gnu11 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


