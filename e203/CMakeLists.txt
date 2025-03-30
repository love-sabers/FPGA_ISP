cmake_minimum_required(VERSION 3.10)

# Set the project name
project(hello_world C)

# Specify the cross-compiler
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_C_COMPILER riscv-none-elf-gcc)

# Specify the source files
file(GLOB SOURCES "src/*.c" "src/bsp/hbird-e200/*.c")

# Add the executable
add_executable(${PROJECT_NAME} ${SOURCES})

# Specify the target properties
set_target_properties(${PROJECT_NAME} PROPERTIES
    LINKER_LANGUAGE C
)
