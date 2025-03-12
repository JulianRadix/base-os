# PowerShell build script for assembly OS

# Configuration
$NASM = "nasm"
$QEMU = "qemu-system-x86_64"
$BUILD_DIR = "build"
$IMG_FILE = "$BUILD_DIR\os.img"
$IMG_SIZE = 1440 # 1.44MB floppy in KB

# Source files
$BOOT_SRC = "src\boot\boot.asm"
$FAT_SRC = "src\filesystem\fat.asm"
$KERNEL_SRC = "src\kernel\kernel.asm"
$IO_SRC = "src\kernel\io.asm"

# Object files
$BOOT_OBJ = "$BUILD_DIR\boot.bin"
$FAT_OBJ = "$BUILD_DIR\fat.bin"
$KERNEL_OBJ = "$BUILD_DIR\kernel.bin"
$IO_OBJ = "$BUILD_DIR\io.bin"

# NASM flags
$NASM_FLAGS = "-f bin"

# Function to create empty file of specific size
function Create-EmptyFile {
    param(
        [string]$Path,
        [int]$SizeInKB
    )
    
    $buffer = New-Object byte[] ($SizeInKB * 1024)
    [System.IO.File]::WriteAllBytes($Path, $buffer)
}

# Function to write binary file at specific offset
function Write-BinaryToOffset {
    param(
        [string]$SourceFile,
        [string]$DestinationFile,
        [int]$Offset = 0
    )
    
    $source = [System.IO.File]::ReadAllBytes($SourceFile)
    $dest = [System.IO.File]::ReadAllBytes($DestinationFile)
    
    [Array]::Copy($source, 0, $dest, $Offset, $source.Length)
    [System.IO.File]::WriteAllBytes($DestinationFile, $dest)
}

# Create build directory if it doesn't exist
function Ensure-BuildDir {
    if (-not (Test-Path $BUILD_DIR)) {
        New-Item -ItemType Directory -Path $BUILD_DIR | Out-Null
        Write-Host "Created build directory: $BUILD_DIR"
    }
}

# Compile an assembly file
function Compile-AsmFile {
    param(
        [string]$Source,
        [string]$Output
    )
    
    & $NASM $NASM_FLAGS -o $Output $Source
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to compile $Source"
        exit 1
    }
    Write-Host "Compiled $Source -> $Output"
}

# Create disk image
function Create-DiskImage {
    Create-EmptyFile -Path $IMG_FILE -SizeInKB $IMG_SIZE
    Write-BinaryToOffset -SourceFile $BOOT_OBJ -DestinationFile $IMG_FILE -Offset 0
    Write-Host "Disk image created: $IMG_FILE"
}

# Clean build artifacts
function Clean-Build {
    if (Test-Path $BUILD_DIR) {
        Remove-Item -Path $BUILD_DIR -Recurse -Force
        Write-Host "Cleaned build directory"
    } else {
        Write-Host "Build directory doesn't exist, nothing to clean"
    }
}

# Run OS in QEMU
function Run-OS {
    if (Test-Path $IMG_FILE) {
        & $QEMU -fda $IMG_FILE
    } else {
        Write-Error "Disk image not found. Build the OS first."
        exit 1
    }
}

# Main build function
function Build-All {
    Ensure-BuildDir
    
    Compile-AsmFile -Source $BOOT_SRC -Output $BOOT_OBJ
    Compile-AsmFile -Source $FAT_SRC -Output $FAT_OBJ
    Compile-AsmFile -Source $KERNEL_SRC -Output $KERNEL_OBJ
    Compile-AsmFile -Source $IO_SRC -Output $IO_OBJ
    
    Create-DiskImage
    Write-Host "Build complete!"
}

# Parse command line arguments
param(
    [Parameter(Position=0)]
    [string]$Command = "build"
)

switch ($Command.ToLower()) {
    "build" {
        Build-All
    }
    "run" {
        Build-All
        Run-OS
    }
    "clean" {
        Clean-Build
    }
    default {
        Write-Host "Usage: .\build.ps1 [build|run|clean]"
        Write-Host "  build - Compile and create disk image (default)"
        Write-Host "  run   - Build and run in QEMU"
        Write-Host "  clean - Remove build artifacts"
    }
}

