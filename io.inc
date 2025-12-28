; -----------------------------------------------------
; فایل کتابخانه: توابع ورودی/خروجی و کمکی (IO.INC)
; شامل توابع مقایسه رشته و خواندن عدد
; -----------------------------------------------------

; -----------------------------------------------------
; روال: STR_COMPARE
; ورودی: SI = رشته اول, DI = رشته دوم, CX = طول
; خروجی: AL = 1 اگر برابر باشند, 0 اگر نباشند
; -----------------------------------------------------
STR_COMPARE PROC
    PUSH SI
    PUSH DI
    PUSH CX
    PUSH BX

COMPARE_LOOP:
    MOV  AL, [SI]                 ; خواندن کاراکتر از رشته اول
    MOV  BL, [DI]                 ; خواندن کاراکتر از رشته دوم
    CMP  AL, BL                   ; مقایسه دو کاراکتر
    JNE  STR_NOT_EQUAL            ; اگر برابر نبودند، پرش
    
    INC  SI                       ; کاراکتر بعدی
    INC  DI                       ; کاراکتر بعدی
    LOOP COMPARE_LOOP             ; تکرار به تعداد طول رشته

STR_EQUAL:
    MOV  AL, 1                    ; رشته ها برابرند
    JMP  STR_DONE

STR_NOT_EQUAL:
    MOV  AL, 0                    ; رشته ها برابر نیستند

STR_DONE:
    POP  BX
    POP  CX
    POP  DI
    POP  SI
    RET
STR_COMPARE ENDP

; -----------------------------------------------------
; روال: READ_DECIMAL
; خروجی: AX = عدد خوانده شده
; -----------------------------------------------------
READ_DECIMAL PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV  BX, 0                    ; نتیجه نهایی
    
READ_CHAR:
    MOV  AH, 01h
    INT  21h
    
    CMP  AL, 13                   ; بررسی کلید Enter
    JE   READ_DONE
    
    SUB  AL, '0'                  ; تبدیل کد اسکی به عدد
    MOV  AH, 0
    MOV  CX, AX                   ; ذخیره رقم در CX
    
    MOV  AX, BX                   ; AX = نتیجه فعلی
    MUL  ten                      ; AX = AX * 10
    ADD  AX, CX                   ; AX = AX + رقم جدید
    MOV  BX, AX                   ; بروزرسانی نتیجه
    
    JMP  READ_CHAR

READ_DONE:
    MOV  AX, BX
    
    POP  DX
    POP  CX
    POP  BX
    RET
READ_DECIMAL ENDP
