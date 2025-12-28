; پروژه درس اسمبلی
; موضوع: رسم دایره با گرفتن اسم
; کاری که برنامه انجام میده:
; اول اسم رو میگیره، اگه masoud بود که هیچی، میاد بیرون.
; اگه mehdi بود، مشخصات گروه رو مینویسه و میره سراغ رسم دایره.
; 5 تا دایره میکشه (چون mehdi پنج حرفه).
; شعاع اولی رو از ما میگیره، بعدی ها رو هی کوچیکتر میکنه.
; دایره آخری هم قراره قرمز و توپر باشه.

.MODEL SMALL
.STACK 100h

.DATA
    ; متن هایی که قراره چاپ بشه
    msgName       DB 'Enter Name: $'
    msgRadius     DB 13, 10, 'Enter Radius (e.g. 50): $'
    msgGroup      DB 13, 10, 'Group Name: group3', 13, 10, '$'
    msgNewline    DB 13, 10, '$'
    
    ; اسم هایی که باید چک کنیم
    strMehdi      DB 'mehdi'
    
    ; اینجا اسم ورودی رو ذخیره میکنیم
    ; ساختارش اینطوریه: اول حداکثر طول، بعد طول واقعی که کاربر وارد کرده، بعد خود کاراکترها
    nameBuffer    DB 20, ?, 20 DUP(?)
    
    ; متغیرهای برنامه
    radius        DW ?                                            ; شعاعی که کاربر میده
    currentRadius DW ?                                            ; شعاع فعلی برای کشیدن دایره ها
    centerX       DW 160                                          ; مرکز صفحه (X)
    centerY       DW 100                                          ; مرکز صفحه (Y)
    color         DB 15                                           ; رنگ قلم (اولش سفیده)
    
    ; اینا برای تبدیل رشته به عدد لازمه
    numInput      DW 0
    ten           DW 10

.CODE
MAIN PROC
                          MOV  AX, @DATA
                          MOV  DS, AX

    START_PROGRAM:        
    ; اول میگیم "اسم رو وارد کن"
                          LEA  DX, msgName
                          MOV  AH, 09h
                          INT  21h

    ; حالا اسم رو از کاربر میگیریم
                          LEA  DX, nameBuffer
                          MOV  AH, 0Ah
                          INT  21h

    ; یه اینتر میزنیم که بره خط بعد تمیز بشه
                          LEA  DX, msgNewline
                          MOV  AH, 09h
                          INT  21h

    ; چک میکنیم ببینیم اسمش mehdi هست یا نه؟
    ; اگر mehdi بود میریم سراغ رسم، وگرنه میایم بیرون (برای هر اسم دیگه ای مثل masoud)
    ; بایت اول طول بافر رو نگه میداره، باید دوم طول رشته ای که کاربر وارد کرده، از بایت سوم میشه خود رشته
                          LEA  SI, nameBuffer+2         ; آدرس جایی که اسم وارد شده
                          MOV  CL, [nameBuffer+1]       ; طول اسمی که وارد کرده
                          CMP  CL, 5                    ; طول mehdi پنج حرفه
                          JNE  EXIT_APP                 ; اگه 5 حرف نبود پس مهدی نیست، خداحافظ
    
                          LEA  DI, strMehdi
                          MOV  CH, 0
                          MOV  CL, 5                    ; طول رو میدیم برای مقایسه
                          CALL STR_COMPARE
                          CMP  AL, 1
                          JNE  EXIT_APP                 ; اگه مهدی نبود خارج شو

    ; اگه رسیدیم اینجا یعنی مهدی بوده، پس اسم گروه رو چاپ کن
                          LEA  DX, msgGroup
                          MOV  AH, 09h
                          INT  21h

    ASK_RADIUS_GENERIC:   
    ; میگیم شعاع رو وارد کن
                          LEA  DX, msgRadius
                          MOV  AH, 09h
                          INT  21h

    ; عدد شعاع رو میخونیم (چون رشته میاد باید تبدیل به عدد بشه)
                          CALL READ_DECIMAL
                          MOV  radius, AX

    ; میریم تو حالت گرافیکی 
                          MOV  AX, 0013h
                          INT  10h

    ; کشیدن دایره ها
                          MOV  CX, 5                    ; چون mehdi پنج حرفه، 5 بار تکرار میکنیم
                          MOV  AX, radius
                          MOV  currentRadius, AX        ; شعاع اولیه رو میذاریم تو متغیر

    DRAW_LOOP:            
                          PUSH CX                       ; شمارنده رو نگه میداریم که خراب نشه

    ; چک میکنیم دایره آخریه یا نه؟ (وقتی CX میشه 1)
                          CMP  CX, 1
                          JNE  DRAW_NORMAL

    ; اگه آخری بود، رنگش رو قرمز میکنیم و توپر میکشیم
                          MOV  color, 4                 ; کد رنگ قرمز
                          CALL DRAW_FILLED_CIRCLE
                          JMP  PREPARE_NEXT

    DRAW_NORMAL:          
    ; اگه دایره معمولی بود، سفید و توخالی میکشیم
                          MOV  color, 15                ; کد رنگ سفید
                          CALL DRAW_CIRCLE_BRESENHAM

    PREPARE_NEXT:         
    ; شعاع رو برای دایره بعدی کم میکنیم (5 تا کم میکنیم که فاصله بیفته بین دایره ها ولی طبق صورت پروژه باید 2 تا کم کنیم)
                          SUB  currentRadius, 5
    
                          POP  CX                       ; شمارنده رو برمیگردونیم
                          LOOP DRAW_LOOP                ; برو بالا برای دایره بعدی

    ; صبر میکنیم کاربر یه کلید بزنه که برنامه بسته نشه
                          MOV  AH, 00h
                          INT  16h

    ; برمیگردیم به حالت متنی معمولی
                          MOV  AX, 0003h
                          INT  10h

    EXIT_APP:             
    ; خروج از برنامه و برگشت به داس
                          MOV  AH, 4Ch
                          INT  21h
MAIN ENDP

    ; =====================================================
    ; اینجا توابع کمکی رو نوشتم که کدم شلوغ نشه
    ; =====================================================

    ; -----------------------------------------------------
    ; تابع مقایسه دو تا رشته
    ; ورودی: آدرس دو تا رشته و طولشون رو میدیم
    ; خروجی: اگه برابر بودن AL=1 میشه، اگه نه AL=0
    ; -----------------------------------------------------
STR_COMPARE PROC
                          PUSH SI
                          PUSH DI
                          PUSH CX
                          PUSH BX

    COMPARE_LOOP:         
                          MOV  AL, [SI]                 ; حرف اول رو برمیداریم
                          MOV  BL, [DI]                 ; حرف دوم رو برمیداریم
                          CMP  AL, BL                   ; مقایسه میکنیم
                          JNE  STR_NOT_EQUAL            ; اگه یکی نبودن بپر بیرون
    
                          INC  SI                       ; برو حرف بعدی
                          INC  DI                       ; برو حرف بعدی
                          LOOP COMPARE_LOOP             ; تکرار کن تا تموم بشه

    STR_EQUAL:            
                          MOV  AL, 1                    ; برابر بودن
                          JMP  STR_DONE

    STR_NOT_EQUAL:        
                          MOV  AL, 0                    ; برابر نبودن

    STR_DONE:             
                          POP  BX
                          POP  CX
                          POP  DI
                          POP  SI
                          RET
STR_COMPARE ENDP

    ; -----------------------------------------------------
    ; تابع خوندن عدد از ورودی
    ; چون ورودی رشته است، باید تبدیلش کنیم به عدد واقعی
    ; (فرمول ساخت عدد: عدد قبلی * 10 + رقم جدید)
    ; -----------------------------------------------------
READ_DECIMAL PROC
                          PUSH BX
                          PUSH CX
                          PUSH DX

                          MOV  BX, 0                    ; اینجا عدد نهایی رو میسازیم
    
    READ_CHAR:            
                          MOV  AH, 01h                  ; گرفتن کاراکتر
                          INT  21h
    
                          CMP  AL, 13                   ; اگه اینتر زد یعنی تموم شد
                          JE   READ_DONE
    
                          SUB  AL, '0'                  ; تبدیل کد اسکی به عدد واقعی
                          MOV  AH, 0
                          MOV  CX, AX                   ; رقم رو نگه میداریم
    
                          MOV  AX, BX                   ; عدد قبلی رو میاریم
                          MUL  ten                      ; ضرب در 10 میکنیم (یکان میشه دهگان و ...)
                          ADD  AX, CX                   ; رقم جدید رو اضافه میکنیم
                          MOV  BX, AX                   ; ذخیره میکنیم
    
                          JMP  READ_CHAR                ; برو بعدی

    READ_DONE:            
                          MOV  AX, BX                   ; نتیجه رو میذاریم تو AX
    
                          POP  DX
                          POP  CX
                          POP  BX
                          RET
READ_DECIMAL ENDP

    ; -----------------------------------------------------
    ; بخش گرافیک
    ; -----------------------------------------------------

    ; -----------------------------------------------------
    ; رسم دایره با الگوریتم برزنهام
    ; این الگوریتم ریاضیه و پیکسل ها رو حساب میکنه
    ; -----------------------------------------------------
DRAW_CIRCLE_BRESENHAM PROC
                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI
                          PUSH DI

    ; نقطه شروع: x=0, y=شعاع
                          MOV  BX, 0                    ; X
                          MOV  DX, currentRadius        ; Y
    
    ; محاسبه پارامتر تصمیم (فرمول برزنهام)
                          MOV  SI, 3
                          MOV  AX, currentRadius
                          SHL  AX, 1                    ; ضرب در 2
                          SUB  SI, AX                   ; d = 3 - 2*r

    CIRCLE_LOOP:          
                          CMP  BX, DX                   ; تا وقتی x از y کمتره ادامه بده
                          JG   CIRCLE_DONE

    ; 8 تا نقطه قرینه رو میکشیم
                          CALL PLOT_OCTANTS

    ; x رو زیاد میکنیم
                          INC  BX

    ; پارامتر تصمیم رو چک میکنیم
                          CMP  SI, 0
                          JL   D_LESS_0

    ; اگه مثبت بود
                          DEC  DX
    
                          MOV  AX, BX
                          SUB  AX, DX
                          SHL  AX, 1
                          SHL  AX, 1
                          ADD  SI, AX
                          ADD  SI, 10
                          JMP  CIRCLE_LOOP

    D_LESS_0:             
    ; اگه منفی بود
                          MOV  AX, BX
                          SHL  AX, 1
                          SHL  AX, 1
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
    ; رسم 8 نقطه قرینه
    ; چون دایره متقارنه، با داشتن یک نقطه میشه 7 تای دیگه رو پیدا کرد
    ; -----------------------------------------------------
PLOT_OCTANTS PROC
    ; نقطه اول
                          MOV  CX, centerX
                          ADD  CX, BX
                          MOV  DI, centerY
                          ADD  DI, DX
                          CALL PUT_PIXEL

    ; نقطه دوم
                          MOV  CX, centerX
                          SUB  CX, BX
                          MOV  DI, centerY
                          ADD  DI, DX
                          CALL PUT_PIXEL

    ; نقطه سوم
                          MOV  CX, centerX
                          ADD  CX, BX
                          MOV  DI, centerY
                          SUB  DI, DX
                          CALL PUT_PIXEL

    ; نقطه چهارم
                          MOV  CX, centerX
                          SUB  CX, BX
                          MOV  DI, centerY
                          SUB  DI, DX
                          CALL PUT_PIXEL

    ; نقطه پنجم
                          MOV  CX, centerX
                          ADD  CX, DX
                          MOV  DI, centerY
                          ADD  DI, BX
                          CALL PUT_PIXEL

    ; نقطه ششم
                          MOV  CX, centerX
                          SUB  CX, DX
                          MOV  DI, centerY
                          ADD  DI, BX
                          CALL PUT_PIXEL

    ; نقطه هفتم
                          MOV  CX, centerX
                          ADD  CX, DX
                          MOV  DI, centerY
                          SUB  DI, BX
                          CALL PUT_PIXEL

    ; نقطه هشتم
                          MOV  CX, centerX
                          SUB  CX, DX
                          MOV  DI, centerY
                          SUB  DI, BX
                          CALL PUT_PIXEL

                          RET
PLOT_OCTANTS ENDP

    ; -----------------------------------------------------
    ; رسم دایره توپر
    ; ترفند: هی شعاع رو کم میکنیم و دایره میکشیم تا پر بشه
    ; -----------------------------------------------------
DRAW_FILLED_CIRCLE PROC
                          PUSH AX
                          PUSH currentRadius            ; شعاع اصلی رو نگه میداریم

    FILL_LOOP:            
                          MOV  AX, currentRadius
                          CMP  AX, 0                    ; اگه شعاع صفر شد تمومه
                          JL   FILL_DONE
    
                          CALL DRAW_CIRCLE_BRESENHAM    ; دایره بکش
    
                          DEC  currentRadius            ; شعاع رو یکی کم کن
                          JMP  FILL_LOOP                ; دوباره

    FILL_DONE:            
                          POP  currentRadius            ; شعاع اصلی رو برگردون
                          POP  AX
                          RET
DRAW_FILLED_CIRCLE ENDP

    ; -----------------------------------------------------
    ; روشن کردن یک پیکسل روی صفحه
    ; باید آدرس حافظه ویدئویی رو حساب کنیم
    ; فرمول: (y * 320) + x
    ; -----------------------------------------------------
PUT_PIXEL PROC
                          PUSH AX
                          PUSH BX
                          PUSH DX
                          PUSH ES
                          PUSH DI

    ; چک میکنیم که نقطه بیرون صفحه نباشه
                          CMP  CX, 0
                          JL   SKIP_PIXEL
                          CMP  CX, 319
                          JG   SKIP_PIXEL
                          CMP  DI, 0
                          JL   SKIP_PIXEL
                          CMP  DI, 199
                          JG   SKIP_PIXEL

                          MOV  AX, 0A000h               ; آدرس شروع حافظه گرافیکی
                          MOV  ES, AX
    
    ; محاسبه آدرس پیکسل
                          MOV  AX, DI
                          SHL  AX, 8                    ; ضرب در 256
                          MOV  BX, DI
                          SHL  BX, 6                    ; ضرب در 64
                          ADD  AX, BX                   ; جمعشون میشه ضرب در 320
                          ADD  AX, CX                   ; به علاوه x
    
                          MOV  DI, AX
                          MOV  AL, color                ; رنگ رو میذاریم
                          MOV  ES:[DI], AL              ; مینویسیم تو حافظه

    SKIP_PIXEL:           
                          POP  DI
                          POP  ES
                          POP  DX
                          POP  BX
                          POP  AX
                          RET
PUT_PIXEL ENDP

END MAIN
