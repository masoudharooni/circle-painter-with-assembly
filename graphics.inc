; -----------------------------------------------------
; فایل کتابخانه: توابع گرافیکی (GRAPHICS.INC)
; شامل توابع رسم دایره و پیکسل
; -----------------------------------------------------

; -----------------------------------------------------
; روال: DRAW_CIRCLE_BRESENHAM
; رسم دایره توخالی با الگوریتم برزنهام
; ورودی ها: currentRadius, centerX, centerY, color
; -----------------------------------------------------
DRAW_CIRCLE_BRESENHAM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; x = 0, y = radius
    MOV  BX, 0                    ; X
    MOV  DX, currentRadius        ; Y
    
    ; پارامتر تصمیم d = 3 - 2 * r
    MOV  SI, 3
    MOV  AX, currentRadius
    SHL  AX, 1                    ; 2 * r
    SUB  SI, AX                   ; d = 3 - 2*r

CIRCLE_LOOP:
    CMP  BX, DX                   ; تا زمانی که x <= y
    JG   CIRCLE_DONE

    ; رسم 8 نقطه قرینه
    CALL PLOT_OCTANTS

    ; افزایش x
    INC  BX

    ; بروزرسانی d
    CMP  SI, 0
    JL   D_LESS_0

    ; d >= 0: y--, d = d + 4(x-y) + 10
    DEC  DX
    
    MOV  AX, BX
    SUB  AX, DX                   ; x - y
    SHL  AX, 1                    ; 2(x-y)
    SHL  AX, 1                    ; 4(x-y)
    ADD  SI, AX
    ADD  SI, 10
    JMP  CIRCLE_LOOP

D_LESS_0:
    ; d < 0: d = d + 4x + 6
    MOV  AX, BX
    SHL  AX, 1                    ; 2x
    SHL  AX, 1                    ; 4x
    ADD  SI, AX
    ADD  SI, 6
    JMP  CIRCLE_LOOP

CIRCLE_DONE:
    POP  DI
    POP  SI
    POP  DX
    POP  CX
    POP  BX
    POP  AX
    RET
DRAW_CIRCLE_BRESENHAM ENDP

; -----------------------------------------------------
; روال: PLOT_OCTANTS
; رسم نقاط قرینه (x,y), (y,x), (-x,y), ...
; ورودی: BX = x, DX = y (نسبت به مرکز)
; -----------------------------------------------------
PLOT_OCTANTS PROC
    ; (xc+x, yc+y)
    MOV  CX, centerX
    ADD  CX, BX
    MOV  DI, centerY
    ADD  DI, DX
    CALL PUT_PIXEL

    ; (xc-x, yc+y)
    MOV  CX, centerX
    SUB  CX, BX
    MOV  DI, centerY
    ADD  DI, DX
    CALL PUT_PIXEL

    ; (xc+x, yc-y)
    MOV  CX, centerX
    ADD  CX, BX
    MOV  DI, centerY
    SUB  DI, DX
    CALL PUT_PIXEL

    ; (xc-x, yc-y)
    MOV  CX, centerX
    SUB  CX, BX
    MOV  DI, centerY
    SUB  DI, DX
    CALL PUT_PIXEL

    ; (xc+y, yc+x)
    MOV  CX, centerX
    ADD  CX, DX
    MOV  DI, centerY
    ADD  DI, BX
    CALL PUT_PIXEL

    ; (xc-y, yc+x)
    MOV  CX, centerX
    SUB  CX, DX
    MOV  DI, centerY
    ADD  DI, BX
    CALL PUT_PIXEL

    ; (xc+y, yc-x)
    MOV  CX, centerX
    ADD  CX, DX
    MOV  DI, centerY
    SUB  DI, BX
    CALL PUT_PIXEL

    ; (xc-y, yc-x)
    MOV  CX, centerX
    SUB  CX, DX
    MOV  DI, centerY
    SUB  DI, BX
    CALL PUT_PIXEL

    RET
PLOT_OCTANTS ENDP

; -----------------------------------------------------
; روال: DRAW_FILLED_CIRCLE
; رسم دایره توپر با رسم دایره های تو در تو
; ورودی ها: currentRadius, centerX, centerY, color
; -----------------------------------------------------
DRAW_FILLED_CIRCLE PROC
    PUSH AX
    PUSH currentRadius            ; ذخیره شعاع اصلی

FILL_LOOP:
    MOV  AX, currentRadius
    CMP  AX, 0
    JL   FILL_DONE
    
    CALL DRAW_CIRCLE_BRESENHAM
    
    DEC  currentRadius
    JMP  FILL_LOOP

FILL_DONE:
    POP  currentRadius            ; بازیابی شعاع اصلی
    POP  AX
    RET
DRAW_FILLED_CIRCLE ENDP

; -----------------------------------------------------
; روال: PUT_PIXEL
; روشن کردن پیکسل در مختصات (CX, DI) با رنگ 'color'
; مد 13h: حافظه از آدرس A000:0000 شروع می شود
; آفست = 320 * y + x
; -----------------------------------------------------
PUT_PIXEL PROC
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH ES
    PUSH DI

    ; بررسی محدوده صفحه (اختیاری ولی خوب برای اطمینان)
    CMP  CX, 0
    JL   SKIP_PIXEL
    CMP  CX, 319
    JG   SKIP_PIXEL
    CMP  DI, 0
    JL   SKIP_PIXEL
    CMP  DI, 199
    JG   SKIP_PIXEL

    MOV  AX, 0A000h
    MOV  ES, AX
    
    ; محاسبه آفست: DI * 320 + CX
    ; 320 = 256 + 64 = (y << 8) + (y << 6)
    MOV  AX, DI
    SHL  AX, 8                    ; y * 256
    MOV  BX, DI
    SHL  BX, 6                    ; y * 64
    ADD  AX, BX                   ; y * 320
    ADD  AX, CX                   ; + x
    
    MOV  DI, AX
    MOV  AL, color
    MOV  ES:[DI], AL

SKIP_PIXEL:
    POP  DI
    POP  ES
    POP  DX
    POP  BX
    POP  AX
    RET
PUT_PIXEL ENDP
