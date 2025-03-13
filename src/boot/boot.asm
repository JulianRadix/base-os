[org 0x7C00]
[bits 16]

;=============================================================================
; BOOT ENTRY POINT
;=============================================================================
boot_start:
    ; Setup segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Clear screen
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Display boot message
    mov si, boot_message
    call print_string

    ; Jump to infinite loop
    jmp halt

;=============================================================================
; FUNCTIONS
;=============================================================================
print_string:
    push ax
    push bx

    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07

.print_loop:    
    lodsb
    test al, al
    jz .print_done
    int 0x10
    jmp .print_loop

.print_done:
    pop bx
    pop ax
    ret

halt:
    cli 
    hlt
    jmp halt

;=============================================================================
; DISK FUNCTIONS
;=============================================================================
disk_reset:
    push ax
    xor ax, ax
    int 13h
    jc disk_error
    pop ax
    ret

disk_read:
    push ax
    push cs
    push dx
    push bx

    mov ah, 02h
    int 13h
    jc disk_error

    pop bx
    pop dx
    pop cx
    pop ax
    ret

disk_error:
    mov si, disk_error_message
    call print_string
    jmp halt

;=============================================================================
; DATA SECTION
;=============================================================================
boot_message db "Base OS Booting...", 0
disk_error_message db "Disk read error!", 0

times 510-($-$$) db 0
dw 0xAA55