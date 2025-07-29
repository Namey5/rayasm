.intel_syntax noprefix

.section .rodata

.print_launch_args_1:
    .string "Running with %d arg(s):\n"
.print_launch_args_2:
    .string "| %s\n"

.section .data

.section .text

.global main
main:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    /* char** argv */
    mov QWORD PTR [rbp-8], rsi
    /* int argc */
    mov DWORD PTR [rbp-12], edi

    lea rdi, .print_launch_args_1[rip]
    mov esi, DWORD PTR [rbp-12]
    xor eax, eax
    call printf

    xor r12d, r12d
    mov r13d, DWORD PTR [rbp-12]
    mov r14, QWORD PTR [rbp-8]
    print_launch_args:
        cmp r12d, r13d
        jge end_print_launch_args

        lea rdi, .print_launch_args_2[rip]
        mov rsi, QWORD PTR [r14+r12*8]
        xor eax, eax
        call printf

        inc r12d
        jmp print_launch_args
    end_print_launch_args:

    mov eax, 0
    leave
    ret
