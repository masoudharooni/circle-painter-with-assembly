; Project: Circle Drawing based on Name
; پروژه: رسم دایره بر اساس نام
; توضیحات:
; 1. دریافت نام از کاربر
; 2. اگر نام "masoud" بود، خروج از برنامه
; 3. اگر نام "mehdi" بود، نمایش اطلاعات گروه و رسم دایره ها
; 4. رسم 5 دایره (به تعداد حروف mehdi)
; 5. شعاع اول از ورودی، شعاع های بعدی 2 واحد کمتر
; 6. دایره آخر قرمز و توپر

.MODEL SMALL
.STACK 100h

.DATA
    ; پیام ها
    msgName       DB 'Enter Name: $'
    msgRadius     DB 13, 10, 'Enter Radius (e.g. 50): $'
    msgGroup      DB 13, 10, 'Group Name: group3', 13, 10, 'Group Number: 3', 13, 10, '$'
    msgNewline    DB 13, 10, '$'
    
    ; نام ها برای مقایسه
    strMehdi      DB 'mehdi'
    strMasoud     DB 'masoud'
    
    ; بافرهای ورودی
    ; فرمت وقفه 21h تابع 0Ah: حداکثر طول، طول واقعی، بافر...
    nameBuffer    DB 20, ?, 20 DUP(?)
    
    ; متغیرها
    radius        DW ?                                                                       ; متغیر کلمه ای برای شعاع
    currentRadius DW ?
    centerX       DW 160
    centerY       DW 100
    color         DB 15                                                                      ; رنگ پیش فرض سفید
    
    ; متغیرهای کمکی برای خواندن عدد
    numInput      DW 0
    ten           DW 10

.CODE
MAIN PROC
                          MOV  AX, @DATA
                          MOV  DS, AX

    START_PROGRAM:        
    ; چاپ پیام "نام را وارد کنید"
                          LEA  DX, msgName
                          MOV  AH, 09h
                          INT  21h

    ; دریافت نام از کاربر
                          LEA  DX, nameBuffer
                          MOV  AH, 0Ah
                          INT  21h

    ; رفتن به خط بعد برای زیبایی خروجی
                          LEA  DX, msgNewline
                          MOV  AH, 09h
                          INT  21h

    ; بررسی اینکه آیا نام "masoud" است؟
                          LEA  SI, nameBuffer+2         ; شروع رشته وارد شده
                          MOV  CL, [nameBuffer+1]       ; طول واقعی رشته
                          CMP  CL, 6                    ; طول masoud به صورت ثابت
                          JNE  CHECK_MEHDI              ; اگر طول برابر نبود، مهدی را چک کن
    
                          LEA  DI, strMasoud
                          MOV  CH, 0
                          MOV  CL, 6                    ; طول masoud
                          CALL STR_COMPARE
                          CMP  AL, 1
                          JE   EXIT_APP                 ; اگر برابر بود، خروج

    CHECK_MEHDI:          
    ; بررسی اینکه آیا نام "mehdi" است؟
                          LEA  SI, nameBuffer+2
                          MOV  CL, [nameBuffer+1]
                          CMP  CL, 5                    ; طول mehdi به صورت ثابت
                          JNE  EXIT_APP                 ; اگر مهدی نبود، خروج
    
                          LEA  DI, strMehdi
                          MOV  CH, 0
                          MOV  CL, 5                    ; طول mehdi
                          CALL STR_COMPARE
                          CMP  AL, 1
                          JNE  EXIT_APP                 ; اگر برابر نبود، خروج

    ; اگر مهدی بود، اطلاعات گروه را نمایش بده
                          LEA  DX, msgGroup
                          MOV  AH, 09h
                          INT  21h

    ASK_RADIUS_GENERIC:   
    ; چاپ پیام "شعاع را وارد کنید"
                          LEA  DX, msgRadius
                          MOV  AH, 09h
                          INT  21h

    ; دریافت شعاع (عدد دهدهی)
                          CALL READ_DECIMAL
                          MOV  radius, AX

    ; تنظیم حالت گرافیکی (320x200 با 256 رنگ)
                          MOV  AX, 0013h
                          INT  10h

    ; تنظیم حلقه رسم
                          MOV  CX, 5                    ; تعداد حروف "mehdi" -> 5 دایره
                          MOV  AX, radius
                          MOV  currentRadius, AX

    DRAW_LOOP:            
                          PUSH CX                       ; ذخیره شمارنده حلقه

    ; بررسی اینکه آیا دایره آخر است؟ (CX=1)
                          CMP  CX, 1
                          JNE  DRAW_NORMAL

    ; دایره آخر: قرمز و توپر
                          MOV  color, 4                 ; رنگ قرمز
                          CALL DRAW_FILLED_CIRCLE
                          JMP  PREPARE_NEXT

    DRAW_NORMAL:          
                          MOV  color, 15                ; رنگ سفید
                          CALL DRAW_CIRCLE_BRESENHAM

    PREPARE_NEXT:         
    ; کاهش شعاع به اندازه 10 واحد (برای فاصله بیشتر)
                          SUB  currentRadius, 5
    
                          POP  CX                       ; بازیابی شمارنده حلقه
                          LOOP DRAW_LOOP

    ; منتظر فشردن کلید
                          MOV  AH, 00h
                          INT  16h

    ; بازگشت به حالت متنی
                          MOV  AX, 0003h
                          INT  10h

    EXIT_APP:             
                          MOV  AH, 4Ch
                          INT  21h
MAIN ENDP

    ; -----------------------------------------------------
    ; روال: STR_COMPARE
    ; ورودی: SI = رشته اول, DI = رشته دوم, CX = طول
    ; خروجی: AL = 1 اگر برابر باشند, 0 اگر نباشند
    ; (پیاده سازی ساده با حلقه برای درک بهتر)
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

END MAIN
