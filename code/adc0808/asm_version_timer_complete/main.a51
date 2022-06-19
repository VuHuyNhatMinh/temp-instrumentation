; hien hai so57
; start
;===========================
num equ p0
;nghin bit p1.3
tram bit p1.2
chuc bit p1.1
donvi bit p1.0	
	
inc_set equ 40h
ok_set equ 41h
button_inc equ 42h
button_ok equ 43h
num_set equ 44h
test equ 45h
delay_count equ 46h
sum_of_sample equ 47h
average_of_sample equ 48h
sample_count equ 49h
sample equ 50h
	
start bit p1.6	;allow converting 
eoc bit p1.4	;converting succeed
ale bit p1.5	;allow communicating
	
led bit p3.0
led_orange bit p3.7			//test led
led_white bit p1.7			//test led
led_interrupt bit p3.6
org 00h
ljmp START_X
	

org 000Bh	//nhay den vung nho cua ham intterupt cho timer 0
ljmp 030h

org 030h
TIMER_0_INTERRUPT:
setb led_white
MOV a, delay_count
cjne a, #250, TIMER0_NEXT
MOV delay_count, #0
mov a, p3  		//		, lay gia tri bit p3 roi luu vao a
anl a, #01		// a = a & 00000001  //lay gia tri cua cai led warning
cjne a,#1, TURN_ON		//neu bam nut button_ok thi thoat khoi cai SETUP
clr led
lcall OFF_WARNING
lcall TIMER0_SETUP_FOR_WARNING
reti
TIMER0_NEXT:
INC delay_count
lcall TIMER0_SETUP_FOR_WARNING
reti
TURN_ON:
setb led
lcall SHOW_WARNING
/////<<<<<<<----------------tat overflow flag for timer0 TAI DAY
lcall TIMER0_SETUP_FOR_WARNING
reti

org 001Bh
ljmp 0080h

org 0080h
TIMER_1_INTERRUPT:
setb led_interrupt
mov a, delay_count
cjne a, #250, TIMER1_NEXT
mov delay_count, #0
lcall CONVERT
lcall TIMER1_SETUP_FOR_MAIN
reti
TIMER1_NEXT:
inc delay_count
lcall TIMER1_SETUP_FOR_MAIN
reti
	

START_X:			//set up parameter
mov inc_set, #0h		//nut set so cai dat
mov ok_set, #0h		//nut ok 
mov num_set, #80		//luu so duoc cai dat// cho so ban dau bay gio là 87
mov p2, #0ffh		//port2 là internal pull up, keo internal pullup len
mov p1,#0ffh		//port1 cung là internal pull up, keo internal pullup len
mov a, #0h    
mov p3, #0ffh		//kéo internal pull_up cua port 3 len de cho port 3 la input
mov sum_of_sample, #00h
mov average_of_sample, #00h
mov sample_count, #00h
mov delay_count, #00h

clr p3.7
clr p3.0
clr p1.7
clr p3.6

SETUP:				
clr c
setb led_orange
clr led_white
mov button_inc, p3  		//		, lay gia tri bit p2.1 roi luu vao button_inc
anl button_inc, #02h		// button_inc = button_inc & 00000010
mov a, button_inc
mov b, inc_set
cjne a,b, NOT_EQ_INC_SET		//neu nut bam button_inc co gia tri khac voi inc_set thi nhay
;cjne a,b, MAIN		//neu nut bam button_inc co gia tri khac voi inc_set thi nhay
mov a, num_set
lcall HEX_BCD
lcall BCD_7SEG
lcall SHOW

mov button_ok, p3 		//		, lay gia tri bit p2.2 roi luu vao button_ok
anl button_ok, #08h		// button_inc = button_inc & 00001000
mov a, button_ok
;mov b, ok_set
cjne a,#8, MAIN		//neu bam nut button_ok thi thoat khoi cai SETUP
sjmp SETUP

NOT_EQ_INC_SET:
mov a, button_inc
cjne a, #2, INC_
NEXT_1:
mov inc_set, button_inc
JMP SETUP

INC_:
mov a, num_set
inc a
mov num_set, a
cjne a, #100, NUM_SET_NOT_EQU
NEXT_2:
clr c
mov a, num_set
lcall HEX_BCD
lcall BCD_7SEG
lcall SHOW
jmp NEXT_1

NUM_SET_NOT_EQU:
jc NEXT_2
jmp WARNING



;org 70h	
MAIN:	
mov delay_count, #0
clr TR0
lcall CONVERT
lcall TIMER1_SETUP_FOR_MAIN		//de cai timer setup o ben ngoai ham main chinh, vi ben trong chuong trinh con cua interrupt 
								//minh da cho no tu dong setup lai cai timer roi
MAIN_NEXT:
clr c

		
mov b, num_set			//lay gia tri limit luu vao b
//to-do: process sampling datas
mov a, p2
cjne a,b,NOT_EQUAL

NEXT:
clr c
lcall HEX_BCD
lcall BCD_7SEG
lcall SHOW
sjmp MAIN_NEXT

CONVERT:
setb ale
clr ale
setb start
jb eoc,$	   //$ chính là dia chi hien tai, cu nhay lai dong nay den khi eoc = 1 thi moi sang cau lenh tiep theo
clr start
;mov r7,#150
;de: lcall hienthi
;djnz r7,de
mov sample, p2
;mov b, num_set
;cjne a,b,NOT_EQUAL
ret

NOT_EQUAL:
jc NEXT
;jc MAIN
jmp WARNING


HEX_BCD:			
mov b,#100
div ab			  
;mov 12h,a
mov 32h,a
mov a,b
mov b,#10
div ab
;mov 11h,a
mov 31h,a
;mov 10h,b
mov 30h,b
ret

TO_MAIN:
mov delay_count, #0
jmp MAIN

BCD_7SEG:
mov dptr,#ma7seg
;mov a,10h
mov a,30h
movc a,@a + dptr
;mov 20h,a				 // 20h chua hang don vi
mov 33h,a	
;mov a,11h
mov a,31h
movc a,@a + dptr			//gia su a co gia tri 30h thi @ a có nghia la gia tri cua o nho 30h
;mov 21h,a				// 21h chua hang chuc
mov 34h,a
;mov a,12h
mov a,32h
movc a,@a + dptr
;mov 22h,a				// 22h chua hang tram
mov 35h,a
ret


SHOW:
;mov num,20h
mov num,33h
setb donvi
lcall DELAY_1
anl p1,#0f0h

;mov num,21h
mov num,34h
setb chuc
lcall DELAY_1
anl p1,#0f0h	   ; p1=----1111; hinh nhu la tat 4 bit cuoi thi moi dung

;mov num,22h
mov num,35h
setb tram
lcall DELAY_1
anl p1,#0f0h
ret

WARNING:
clr TR1				//tat timer 1
clr led_interrupt
setb led
lcall SHOW_WARNING
MOV delay_count, #0 ////////
lcall TIMER0_SETUP_FOR_WARNING
;clr TCON.2	//trigger by low level signal
;setb IE.2
;setb IE.7
WARNING_NEXT:
;setb led
;lcall SHOW_WARNING
;lcall DELAY_2
;clr led
;lcall OFF_WARNING									<<<<<<<<<<<<<--
;lcall DELAY_2
mov button_ok, p3  		//		, lay gia tri bit p2.2 roi luu vao button_ok, h nut nay la nut reset
anl button_ok, #08h		// button_ok = button_ok & 00001000
mov a, button_ok
;mov b, ok_set
cjne a,#8, RESET		//neu bam nut button_ok thi thoat khoi cai SETUP
jmp WARNING_NEXT


RESET:
setb ale
clr ale
setb start
jb eoc,$	   //$ chính là dia chi hien tai, cu nhay lai dong nay den khi eoc = 1 thi moi sang cau lenh tiep theo
clr start
;mov r7,#150
;de: lcall hienthi
;djnz r7,de
mov a,p2
mov b, num_set
cjne a,b,NOT_EQUAL_1
jmp WARNING_NEXT
NOT_EQUAL_1:
jc TO_MAIN
jmp WARNING_NEXT

SHOW_WARNING:
;mov num,20h
mov num,#0bfh
setb donvi
;mov num,21h
mov num,#0bfh
setb chuc
;mov num,22h
mov num,#0bfh
setb tram
ret

OFF_WARNING:
clr donvi
clr chuc
clr tram
ret

TIMER0_SETUP_FOR_WARNING:
setb EA		//IE.7		// enable global interrupt
setb ET0	//IE.1		//enable timer 0 overflow flag
MOV TMOD, #01h   //16bit timer-0 selected
MOV TH0, #0F0h	//delay 250 lan timer 4ms = delay 1s
MOV TL0, #060h	
setb TR0	//start timer 0
ret

TIMER1_SETUP_FOR_MAIN:
setb EA		//enable global interrupt
setb ET1	//enable timer 1 overflow flag 
mov TMOD, #10h			//16bit timer-1 selected
mov TH1, #063h			//250 lan timer 0.04s = delay 10s
mov TL1, #0C0h
;MOV TH1, #0F0h	//delay 250 lan timer 4ms = delay 1s
;MOV TL1, #060h	
setb TR1  	//start timer 1
ret 


DELAY_1:
mov r7,#250				//#250
djnz r7,$
;mov r2,#1	 ; 16 <=> 1s// con so nay sai nen khong phai la 1s	//1 chu ky may
;loop3: mov r3,#150	//r3=250 //1 chu ky may
;loop4: mov r4,#150	//r4=250	//1 chu ky may
;djnz r4,$		//giam tai cho khi nao r4=0 thi thuc hien lenh ke tiep , 2 chu ky may
;djnz r3,loop2 //r3-=1; if r3!=0 jump to loop2 else next instruction , 2 chu ky may
;djnz r2,loop1 //r2-=1; if r2!=0 jump to loop2 else next instruction , 2 chu ky may
;ret	//2 chu ky may
ret

DELAY_2: 			//tan so cua vi dieu khien = 1/12 tan so cua thach anh
mov r2,#14	 ; 16 <=> 1s// con so nay sai nen khong phai la 1s	//1 chu ky may
loop1: mov r3,#250	//r3=250 //1 chu ky may
loop2: mov r4,#250	//r4=250	//1 chu ky may
djnz r4,$		//giam tai cho khi nao r4=0 thi thuc hien lenh ke tiep , 2 chu ky may
djnz r3,loop2 //r3-=1; if r3!=0 jump to loop2 else next instruction , 2 chu ky may
djnz r2,loop1 //r2-=1; if r2!=0 jump to loop2 else next instruction , 2 chu ky may
ret	//2 chu ky may
;//3MOV + 250'djnz r4'x2 (ban_dau) + 250'r3'x(2'djnz r3'+1+250'djnz r4'x2) (ban dau) 
;//+16'r2'x(2'MOVr3,MOVr4'+2'djnz r2' + 250'djnz r4'x2 + 250'r3'x(2'djnz r3'+1+250'djnz r4'x2))  
;//hinh nhu sai cai 16 nen moi khong dung la 1s


;ma7seg:
;db 03fh,006h,05bh,04fh,066h,06dh,07dh,007h,07fh,06fh
ma7seg:
db 0c0h, 0f9h, 0a4h, 0b0h, 99h, 92h, 82h, 0f8h, 80h, 90h
end