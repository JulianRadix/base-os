# PowerShell build script for assembly OS

# Parse command line arguments
param(
    [Parameter(Position=0)]
    [string]$Command = "build"
)

# Use script root to ensure all paths are relative to the script location
$SCRIPT_ROOT = $PSScriptRoot

# Configuration
$NASM = "nasm"
$QEMU = "qemu-system-x86_64"
$BUILD_DIR = Join-Path -Path $SCRIPT_ROOT -ChildPath "build"
$IMG_FILE = Join-Path -Path $BUILD_DIR -ChildPath "os.img"
$IMG_SIZE = 1440 # 1.44MB floppy in KB

# Source files
$BOOT_SRC = Join-Path -Path $SCRIPT_ROOT -ChildPath "src\boot\boot.asm"
$FAT_SRC = Join-Path -Path $SCRIPT_ROOT -ChildPath "src\filesystem\fat.asm"
$KERNEL_SRC = Join-Path -Path $SCRIPT_ROOT -ChildPath "src\kernel\kernel.asm"
$IO_SRC = Join-Path -Path $SCRIPT_ROOT -ChildPath "src\kernel\io.asm"

# Object files
$BOOT_OBJ = Join-Path -Path $BUILD_DIR -ChildPath "boot.bin"
$FAT_OBJ = Join-Path -Path $BUILD_DIR -ChildPath "fat.bin"
$KERNEL_OBJ = Join-Path -Path $BUILD_DIR -ChildPath "kernel.bin"
$IO_OBJ = Join-Path -Path $BUILD_DIR -ChildPath "io.bin"

# NASM flags
$NASM_FLAGS = "-f bin"

# Function to create empty file of specific size
function Create-EmptyFile {
    param(
        [string]$Path,
        [int]$SizeInKB
    )
    
    try {
        # Ensure parent directory exists
        $parentDir = Split-Path -Path $Path -Parent
        if (-not (Test-Path -Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            Write-Host "Created directory: $parentDir"
        }
        
        $buffer = New-Object byte[] ($SizeInKB * 1024)
        [System.IO.File]::WriteAllBytes($Path, $buffer)
        Write-Host "Created empty file: $Path ($SizeInKB KB)"
    }
    catch {
        Write-Error "Failed to create empty file at $Path : $_"
        exit 1
    }
}

# Function to write binary file at specific offset
function Write-BinaryToOffset {
    param(
        [string]$SourceFile,
        [string]$DestinationFile,
        [int]$Offset = 0
    )
    
    try {
        if (-not (Test-Path -Path $SourceFile)) {
            Write-Error "Source file not found: $SourceFile"
            exit 1
        }
        
        if (-not (Test-Path -Path $DestinationFile)) {
            Write-Error "Destination file not found: $DestinationFile"
            exit 1
        }
        
        $source = [System.IO.File]::ReadAllBytes($SourceFile)
        $dest = [System.IO.File]::ReadAllBytes($DestinationFile)
        
        [Array]::Copy($source, 0, $dest, $Offset, $source.Length)
        [System.IO.File]::WriteAllBytes($DestinationFile, $dest)
        Write-Host "Written $SourceFile to $DestinationFile at offset $Offset"
    }
    catch {
        Write-Error "Failed to write binary to offset: $_"
        exit 1
    }
}

# Create build directory if it doesn't exist
function Ensure-BuildDir {
    try {
        if (-not (Test-Path $BUILD_DIR)) {
            New-Item -ItemType Directory -Path $BUILD_DIR -Force | Out-Null
            Write-Host "Created build directory: $BUILD_DIR"
        }
    }
    catch {
        Write-Error "Failed to create build directory: $_"
        exit 1
    }
}

# Compile an assembly file
function Compile-AsmFile {
    param(
        [string]$Source,
        [string]$Output
    )
    
    try {
        if (-not (Test-Path -Path $Source)) {
            Write-Error "Source file not found: $Source"
            exit 1
        }
        
        # Ensure output directory exists
        $outputDir = Split-Path -Path $Output -Parent
        if (-not (Test-Path -Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        
        & $NASM $NASM_FLAGS -o $Output $Source
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to compile $Source"
            exit 1
        }
        Write-Host "Compiled $Source -> $Output"
    }
    catch {
        Write-Error "Failed to compile file: $_"
        exit 1
    }
}

# Create disk image
function Create-DiskImage {
    try {
        Create-EmptyFile -Path $IMG_FILE -SizeInKB $IMG_SIZE
        Write-BinaryToOffset -SourceFile $BOOT_OBJ -DestinationFile $IMG_FILE -Offset 0
        Write-Host "Disk image created: $IMG_FILE"
    }
    catch {
        Write-Error "Failed to create disk image: $_"
        exit 1
    }
}

# Clean build artifacts
function Clean-Build {
    try {
        if (Test-Path $BUILD_DIR) {
            Remove-Item -Path $BUILD_DIR -Recurse -Force
            Write-Host "Cleaned build directory"
        } else {
            Write-Host "Build directory doesn't exist, nothing to clean"
        }
    }
    catch {
        Write-Error "Failed to clean build directory: $_"
        exit 1
    }
}

# Run OS in QEMU
function Run-OS {
    try {
        if (Test-Path $IMG_FILE) {
            Write-Host "Starting QEMU with disk image: $IMG_FILE"
            & $QEMU -fda $IMG_FILE
            if ($LASTEXITCODE -ne 0) {
                Write-Error "QEMU exited with error code $LASTEXITCODE"
                exit 1
            }
        } else {
            Write-Error "Disk image not found at $IMG_FILE. Build the OS first."
            exit 1
        }
    }
    catch {
        Write-Error "Failed to run QEMU: $_"
        exit 1
    }
}

# Main build function
function Build-All {
    try {
        Ensure-BuildDir
        
        # Check source files exist
        $srcFiles = @($BOOT_SRC, $FAT_SRC, $KERNEL_SRC, $IO_SRC)
        foreach ($file in $srcFiles) {
            if (-not (Test-Path -Path $file -PathType Leaf)) {
                Write-Warning "Source file not found: $file (will be skipped)"
            }
        }
        
        # Compile files that exist
        if (Test-Path -Path $BOOT_SRC -PathType Leaf) {
            Compile-AsmFile -Source $BOOT_SRC -Output $BOOT_OBJ
        }
        
        if (Test-Path -Path $FAT_SRC -PathType Leaf) {
            Compile-AsmFile -Source $FAT_SRC -Output $FAT_OBJ
        }
        
        if (Test-Path -Path $KERNEL_SRC -PathType Leaf) {
            Compile-AsmFile -Source $KERNEL_SRC -Output $KERNEL_OBJ
        }
        
        if (Test-Path -Path $IO_SRC -PathType Leaf) {
            Compile-AsmFile -Source $IO_SRC -Output $IO_OBJ
        }
        
        Create-DiskImage
        Write-Host "Build complete!"
    }
    catch {
        Write-Error "Build failed: $_"
        exit 1
    }
}

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

