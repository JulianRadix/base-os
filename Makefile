# Makefile for assembly OS

# Configuration
NASM = nasm
QEMU = qemu-system-x86_64
BUILD_DIR = build
IMG_FILE = $(BUILD_DIR)/os.img
IMG_SIZE = 1440k  # 1.44MB floppy

# Source files
BOOT_SRC = src/boot/boot.asm
FAT_SRC = src/filesystem/fat.asm
KERNEL_SRC = src/kernel/kernel.asm
IO_SRC = src/kernel/io.asm

# Object files
BOOT_OBJ = $(BUILD_DIR)/boot.bin
FAT_OBJ = $(BUILD_DIR)/fat.bin
KERNEL_OBJ = $(BUILD_DIR)/kernel.bin
IO_OBJ = $(BUILD_DIR)/io.bin

# Flags
NASM_FLAGS = -f bin

.PHONY: all clean run img

# Default target
all: img

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile boot sector
$(BOOT_OBJ): $(BOOT_SRC) | $(BUILD_DIR)
	$(NASM) $(NASM_FLAGS) -o $@ $<

# Compile FAT implementation
$(FAT_OBJ): $(FAT_SRC) | $(BUILD_DIR)
	$(NASM) $(NASM_FLAGS) -o $@ $<

# Compile kernel
$(KERNEL_OBJ): $(KERNEL_SRC) | $(BUILD_DIR)
	$(NASM) $(NASM_FLAGS) -o $@ $<

# Compile I/O routines
$(IO_OBJ): $(IO_SRC) | $(BUILD_DIR)
	$(NASM) $(NASM_FLAGS) -o $@ $<

# Create disk image
img: $(BOOT_OBJ) $(FAT_OBJ) $(KERNEL_OBJ) $(IO_OBJ)
	dd if=/dev/zero of=$(IMG_FILE) bs=1k count=1440
	dd if=$(BOOT_OBJ) of=$(IMG_FILE) conv=notrunc
	@echo "Disk image created: $(IMG_FILE)"

# Run OS in QEMU
run: img
	$(QEMU) -fda $(IMG_FILE)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)

