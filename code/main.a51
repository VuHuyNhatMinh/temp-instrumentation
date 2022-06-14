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
	
start bit p1.6	;allow converting 
eoc bit p1.4	;converting succeed
ale bit p1.5	;allow communicating
	
led bit p2.0
led_orange bit p2.7			//test led
led_white bit p1.7			//test led
org 00h
	
mov inc_set, #0h		//nut set so cai dat
mov ok_set, #0h		//nut ok 
mov num_set, #80		//luu so duoc cai dat// cho so ban dau bay gio là 87
mov p2, #0ffh		//port2 là internal pull up, keo internal pullup len
mov p1,#0ffh		//port1 cung là internal pull up, keo internal pullup len
mov a, #0h    
mov p3, #0ffh		//kéo internal pull_up cua port 3 len de cho port 3 la input
clr p2.7
clr p2.0
clr p1.7

SETUP:
clr psw.7
setb led_orange
clr led_white
mov button_inc, p2  		//		, lay gia tri bit p2.1 roi luu vao button_inc
anl button_inc, #02h		// button_inc = button_inc & 00000010
mov a, button_inc
mov b, inc_set
cjne a,b, NOT_EQ_INC_SET		//neu nut bam button_inc co gia tri khac voi inc_set thi nhay
;cjne a,b, MAIN		//neu nut bam button_inc co gia tri khac voi inc_set thi nhay
mov a, num_set
lcall HEX_BCD
lcall BCD_7SEG
lcall SHOW

mov button_ok, p2  		//		, lay gia tri bit p2.2 roi luu vao button_ok
anl button_ok, #04h		// button_inc = button_inc & 00000100
mov a, button_ok
;mov b, ok_set
cjne a,#4, MAIN		//neu bam nut button_ok thi thoat khoi cai SETUP
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
jmp LED_WARNING



MAIN:
clr led_orange
setb led_white
lcall CONVERT
cjne a,b,NOT_EQUAL
NEXT:
clr c
lcall HEX_BCD
lcall BCD_7SEG
lcall SHOW
sjmp MAIN




CONVERT:
setb ale
clr ale
setb start
jb eoc,$	   //$ chính là dia chi hien tai, cu nhay lai dong nay den khi eoc = 1 thi moi sang cau lenh tiep theo
clr start
;mov r7,#150
;de: lcall hienthi
;djnz r7,de
mov a,p3
mov b, num_set
;cjne a,b,NOT_EQUAL
ret

NOT_EQUAL:
jc NEXT
;jc MAIN
jmp LED_WARNING


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

LED_WARNING:
setb led
lcall DELAY_2
clr led
lcall DELAY_2
mov button_ok, p2  		//		, lay gia tri bit p2.2 roi luu vao button_ok, h nut nay la nut reset
anl button_ok, #04h		// button_ok = button_ok & 00000100
mov a, button_ok
;mov b, ok_set
cjne a,#4, RESET		//neu bam nut button_ok thi thoat khoi cai SETUP
jmp LED_WARNING


RESET:
setb ale
clr ale
setb start
jb eoc,$	   //$ chính là dia chi hien tai, cu nhay lai dong nay den khi eoc = 1 thi moi sang cau lenh tiep theo
clr start
;mov r7,#150
;de: lcall hienthi
;djnz r7,de
mov a,p3
mov b, num_set
cjne a,b,NOT_EQUAL_1
jmp LED_WARNING
NOT_EQUAL_1:
jc MAIN

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