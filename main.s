.intel_syntax noprefix

.section .rodata

.align 16
.half:
    .float 0.5, 0.5, 0.5, 0.5

.FLAG_WINDOW_RESIZABLE:
    .int 0x00000004

.print_launch_args_1:
    .string "Running with %d arg(s):\n"
.print_launch_args_2:
    .string "| %s\n"

.window_title:
    .string "rayasm"
.window_min_size:
    .int 640, 480

.font_measurements:
    .float 32.0, 3.0

.section .data

.align 8
.default_font:
    .zero 48

.window_size:
    .int 1280, 720
.clear_color:
    .byte 63, 127, 255, 255
.hello_message:
    .string "Hello there!"
.message_color:
    .byte 240, 240, 240, 255

.section .text

.global main
main:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    xor eax, eax
    /* char** argv */
    mov QWORD PTR [rbp-8], rsi
    /* int argc */
    mov DWORD PTR [rbp-12], edi

    lea rdi, BYTE PTR .print_launch_args_1[rip]
    mov esi, DWORD PTR [rbp-12]
    xor eax, eax
    call printf

    xor r12d, r12d
    mov r13d, DWORD PTR [rbp-12]
    mov r14, QWORD PTR [rbp-8]
    print_launch_args:
        cmp r12d, r13d
        jge init_window

        lea rdi, BYTE PTR .print_launch_args_2[rip]
        mov rsi, QWORD PTR [r14+r12*8]
        xor eax, eax
        call printf

        inc r12d
        jmp print_launch_args

init_window:
    /* void InitWindow(int width, int height, const char* title) */
    mov edi, DWORD PTR .window_size[rip]
    mov esi, DWORD PTR .window_size[rip+4]
    lea rdx, BYTE PTR .window_title[rip]
    call InitWindow
    /* void SetWindowState(uint flags) */
    mov edi, DWORD PTR .FLAG_WINDOW_RESIZABLE[rip]
    call SetWindowState
    /* void SetWindowMinSize(int width, int height) */
    mov edi, DWORD PTR .window_min_size[rip]
    mov esi, DWORD PTR .window_min_size[rip+4]
    call SetWindowMinSize
    /* void SetTargetFPS(int fps) */
    mov edi, 60
    call SetTargetFPS

    /* Font GetFontDefault() */
    lea rdi, .default_font[rip]
    call GetFontDefault

    main_loop:
        /* bool WindowShouldClose() */
        call WindowShouldClose
        test eax, eax
        jnz close_window

        /* Keep our cached window size up to date each frame. */
        call GetScreenWidth
        mov DWORD PTR .window_size[rip], eax
        call GetScreenHeight
        mov DWORD PTR .window_size[rip+4], eax

        call BeginDrawing

        /* void ClearBackground(Color color) */
        mov edi, DWORD PTR .clear_color[rip]
        call ClearBackground

        /*
         * This one is awkward for a number of reasons:
         *  - font is 48 bytes and passed by value, so need to push onto stack
         *  - fontSize and spacing are both floats (only for this overload and despite internally being used as ints)
         *  - result is packed into first qword of xmm0
         */
        /* Vector2 MeasureTextEx(Font font, const char* text, float fontSize, float spacing) */
        sub rsp, 48
        lea rdi, QWORD PTR [rsp]
        lea rsi, .default_font[rip]
        mov ecx, 6
        rep movsq
        lea rdi, BYTE PTR .hello_message[rip]
        movd xmm0, DWORD PTR .font_measurements[rip]
        movd xmm1, DWORD PTR .font_measurements[rip+4]
        call MeasureTextEx
        add rsp, 48

        /* Draw message at centre of window. */
        /* void DrawText(const char* text, int x, int y, int size, Color color) */
        movq xmm1, QWORD PTR .window_size[rip]
        cvtdq2ps xmm1, xmm1
        subps xmm1, xmm0
        mulps xmm1, XMMWORD PTR .half[rip]
        /* Convert position back to int[2] and unpack into [esi, edx]. */
        cvtps2dq xmm1, xmm1
        movq rsi, xmm1
        mov rdx, rsi
        shr rdx, 32
        lea rdi, BYTE PTR .hello_message[rip]
        mov ecx, 32
        mov r8d, DWORD PTR .message_color[rip]
        call DrawText

        call EndDrawing

        jmp main_loop

close_window:
    call CloseWindow

    mov eax, 0
    leave
    ret
