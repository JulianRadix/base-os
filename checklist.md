# MS-DOS-like Operating System Development Checklist

## 1. Setup Development Environment
- [X] Install development tools
  - [X] Install NASM (Netwide Assembler)
  - [X] Install QEMU for system emulation
  - [X] Install a hex editor (e.g., HxD)
  - [X] Install a text editor or IDE (Visual Studio Code, Sublime Text, etc.)
- [X] Configure build environment
  - [X] Create a project directory structure
  - [X] Set up a build script or Makefile
  - [X] Configure version control (Git)

## 2. Bootloader Development
- [X] Create basic boot sector
  - [X] Write initial 16-bit real mode assembly code
  - [X] Ensure code fits within 512 bytes
  - [X] Add boot signature (0xAA55)
  - [X] Test basic bootloader with QEMU
- [X] Implement disk I/O routines
  - [X] Add BIOS disk read functionality
  - [X] Implement disk sector loading
  - [X] Create error handling for disk operations
- [ ] Extend bootloader capabilities
  - [ ] Implement multi-stage bootloader
  - [ ] Load kernel from disk to memory
  - [ ] Set up stack and registers properly
  - [ ] Transition to protected mode (optional)

## 3. Kernel Basics
- [ ] Create core kernel structure
  - [ ] Set up kernel entry point
  - [ ] Implement basic kernel initialization
  - [ ] Create segmentation setup
- [ ] Implement basic I/O routines
  - [ ] Screen output functions
    - [ ] Text mode display control
    - [ ] Cursor positioning
    - [ ] Color text support
  - [ ] Keyboard input functions
    - [ ] Character input
    - [ ] Scancode processing
- [ ] Set up interrupt handlers
  - [ ] Create Interrupt Vector Table (IVT)
  - [ ] Implement basic hardware interrupt handlers
  - [ ] Create software interrupt system

## 4. Memory Management
- [ ] Implement memory detection
  - [ ] Detect available memory
  - [ ] Create memory map
- [ ] Set up memory allocation system
  - [ ] Implement basic memory manager
  - [ ] Create memory allocation functions (malloc/free equivalent)
  - [ ] Add memory protection mechanisms
- [ ] Implement segmentation and paging (if using protected mode)
  - [ ] Configure Global Descriptor Table (GDT)
  - [ ] Set up paging structures if needed

## 5. File System Implementation
- [ ] Design file system structure
  - [ ] Define on-disk layout (FAT12/16 compatible)
  - [ ] Create file system data structures
- [ ] Implement core file system functionality
  - [ ] Read from disk to memory
  - [ ] Write from memory to disk
  - [ ] Create directories
  - [ ] Delete files and directories
- [ ] Create file system API
  - [ ] Open/close files
  - [ ] Read/write operations
  - [ ] Directory operations
  - [ ] File attribute manipulation

## 6. Command Line Interface
- [ ] Create command prompt
  - [ ] Implement command line input
  - [ ] Add command history
  - [ ] Create command parsing logic
- [ ] Implement basic shell commands
  - [ ] DIR (directory listing)
  - [ ] TYPE (file viewing)
  - [ ] COPY (file copying)
  - [ ] DEL (file deletion)
  - [ ] CLS (clear screen)
  - [ ] HELP (command information)
  - [ ] CD (change directory)
  - [ ] DATE/TIME (system date/time)
- [ ] Add command execution framework
  - [ ] Support for external commands
  - [ ] Implement batch file processing

## 7. Process Management
- [ ] Create process structures
  - [ ] Define Process Control Block (PCB)
  - [ ] Implement process creation/termination
- [ ] Implement basic scheduling
  - [ ] Design simple scheduler
  - [ ] Implement context switching
- [ ] Set up program loading
  - [ ] Create executable format
  - [ ] Load programs into memory
  - [ ] Execute programs from disk

## 8. Device Drivers
- [ ] Implement disk driver
  - [ ] Support for floppy disks
  - [ ] Support for hard disks
- [ ] Create display driver
  - [ ] Text mode operations
  - [ ] Basic graphics mode (optional)
- [ ] Add keyboard driver
  - [ ] Scancode processing
  - [ ] Keyboard buffer management
- [ ] Implement timer driver
  - [ ] System clock
  - [ ] Timer interrupts

## 9. Advanced Features
- [ ] Add environment variables
  - [ ] Store and retrieve environment variables
  - [ ] Implement PATH handling
- [ ] Implement pipes and redirection
  - [ ] Input/output redirection
  - [ ] Simple pipe mechanism
- [ ] Create TSR (Terminate and Stay Resident) support
  - [ ] Memory resident programs
  - [ ] Interrupt hooking
- [ ] Add support for CONFIG.SYS and AUTOEXEC.BAT
  - [ ] System configuration
  - [ ] Startup commands

## 10. Testing and Debugging
- [ ] Create debugging infrastructure
  - [ ] Add logging system
  - [ ] Implement debug commands
  - [ ] Create memory dumping tools
- [ ] Perform system testing
  - [ ] Test in QEMU/Bochs
  - [ ] Create test suites for components
  - [ ] Test on real hardware (optional)
- [ ] Fix bugs and optimize
  - [ ] Performance optimization
  - [ ] Memory usage optimization
  - [ ] Boot time improvements

## 11. Documentation
- [ ] Create system documentation
  - [ ] Architecture overview
  - [ ] API documentation
  - [ ] File format specifications
- [ ] Write user manual
  - [ ] Installation instructions
  - [ ] Command reference
  - [ ] Troubleshooting guide
- [ ] Document development process
  - [ ] Design decisions
  - [ ] Lessons learned
  - [ ] Future improvement plans

