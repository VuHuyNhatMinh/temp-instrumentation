;MAIN
;=========================DEFINE=======================================
num equ p0
nghin bit p1.1
tram bit p1.2
chuc bit p1.3
donvi bit p1.4

	
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
	
gia_tri_don_vi equ 51h
gia_tri_chuc equ 52h
gia_tri_tram equ 53h
gia_tri_nghin equ 54h
chu_so equ 55h
	
wr_ bit p3.6	;allow converting 
intr_ bit p1.7	;converting succeed
rd_ bit p3.7	;allow communicating	
	
spk bit p1.0
led_orange bit p3.1			//test led
led_white bit p3.2			//test led
led_interrupt bit p3.0
;=================================================================	
	
	
org 00h
ljmp START_X				//jump to main l
	

org 000Bh	//nhay den vung nho cua ham intterupt cho timer 0
ljmp 030h

org 030h
;=========================TIMER_0_INTERRUPT========================
MOV a, delay_count
cjne a, #250, TIMER0_NEXT
MOV delay_count, #0
mov a, p1 		//		, lay gia tri bit p2.7 roi luu vao a
anl a, #01h		// a = a & 0000 0001  //lay gia tri cua cai speaker
cjne a,#01h, TURN_ON		//neu bam nut button_ok thi thoat khoi cai SETUP
clr spk
lcall OFF_WARNING
lcall TIMER0_SETUP_FOR_WARNING
reti
TIMER0_NEXT:
INC delay_count
lcall TIMER0_SETUP_FOR_WARNING
reti
TURN_ON:
setb spk
lcall SHOW_WARNING
lcall TIMER0_SETUP_FOR_WARNING
reti
;============================================================================



org 001Bh
ljmp 0080h

org 0080h
;=============================TIMER_1_INTERRUPT===============================
setb led_interrupt
;lcall DELAY_2
;clr led_interrupt
;lcall DELAY_2
mov a, delay_count
cjne a, #40, TIMER1_NEXT			//a=250 cho 10s
mov delay_count, #0
lcall CONVERT
lcall TIMER1_SETUP_FOR_MAIN
reti
TIMER1_NEXT:
inc delay_count
lcall TIMER1_SETUP_FOR_MAIN
reti
;==================================end===========================================





;=======================set up parameters=========================================
START_X:			//set up parameter
mov inc_set, #80h		//nut set so cai dat
mov ok_set, #40h		//nut ok 
mov num_set, #00h		//luu so duoc cai dat// cho so ban dau bay gio là 87
mov p2, #0ffh		//port2 là internal pull up, keo internal pullup len
mov p1,#0ffh		//port1 cung là internal pull up, keo internal pullup len
mov a, #00h    
mov p3, #0ffh		//kéo internal pull_up cua port 3 len de cho port 3 la input
mov sum_of_sample, #00h
mov delay_count, #00h
mov chu_so, #00h
mov gia_tri_don_vi, #00h
mov gia_tri_chuc, #00h
mov gia_tri_tram, #00h
mov gia_tri_nghin, #00h

clr p3.0
clr p3.1
clr p3.2
clr spk
;==================================================================================



;=========================================set up upper limit======================
SETUP:				
clr c
setb led_orange
mov button_inc, p1  		//		, lay gia tri bit p1 roi luu vao button_inc
anl button_inc, #40h		// button_inc = button_inc & 0100 0000
mov a, button_inc
mov b, inc_set
cjne a,b, NOT_EQ_INC_SET		//neu nut bam button_inc co gia tri khac voi inc_set thi nhay
;mov a, num_set
;lcall HEX_BCD
;lcall BCD_7SEG
;lcall SHOW
lcall SHOW_SETUP

mov button_ok, p1 		//		, lay gia tri bit p2.6 roi luu vao button_ok
anl button_ok, #20h		// button_inc = button_ok & 0010 0000
mov a, button_ok
mov b, ok_set
cjne a,b, NOT_EQ_OK_SET
;cjne a,#40h, MAIN		//neu bam nut button_ok thi thoat khoi cai SETUP
sjmp SETUP

NOT_EQ_INC_SET:
mov a, button_inc
cjne a, #40h, INC_
NEXT_1:
mov inc_set, button_inc
lcall SHOW_SETUP
JMP SETUP

INC_:
mov a, chu_so
cjne a, #00h, NOT_DON_VI
mov a, gia_tri_don_vi
inc a
mov gia_tri_don_vi, a
cjne a, #10, DON_VI_10
mov gia_tri_don_vi, #0h
jmp NEXT_1

DON_VI_10:
jmp NEXT_1

NOT_DON_VI:
mov a, chu_so
cjne a, #01h, NOT_CHUC
mov a, gia_tri_chuc
inc a
mov gia_tri_chuc, a
cjne a, #10, CHUC_10
mov gia_tri_chuc, #0h
jmp NEXT_1

CHUC_10:
jmp NEXT_1

NOT_CHUC:
mov a, chu_so
cjne a, #02h, NOT_TRAM
mov a, gia_tri_tram
cjne a,#1, CHUYEN_TRAM_THANH_1
mov gia_tri_tram, #0
jmp NEXT_1
CHUYEN_TRAM_THANH_1:
mov gia_tri_tram, #1
jmp NEXT_1


NOT_TRAM:
mov a, gia_tri_nghin
cjne a, #01h, CHUYEN_NGHIN_THANH_1
mov gia_tri_nghin, #00h
jmp NEXT_1
CHUYEN_NGHIN_THANH_1:
mov gia_tri_nghin, #01h
jmp NEXT_1


NOT_EQ_OK_SET:
mov a, button_ok
cjne a, #20h, BAM_NUT_OK				//xem co dang bam hay khong
NEXT_2:
mov ok_set, button_ok
lcall SHOW_SETUP
jmp SETUP

BAM_NUT_OK:
mov a, chu_so
cjne a, #03h, CHU_SO_KHAC_3
NEU_CHU_SO_BANG_3:
mov a, gia_tri_nghin
cjne a, #0, GIA_TRI_NGHIN_BANG_1
mov chu_so, #0h
jmp NEXT_2

GIA_TRI_NGHIN_BANG_1:
jmp MAIN_SETUP

CHU_SO_KHAC_3:
mov a, chu_so
inc a
mov chu_so, a
jmp NEXT_2
;=========================================================================================


;=======================================calculate upper limit=============================
MAIN_SETUP:
mov a, gia_tri_chuc
mov b, #10
mul ab
add a,gia_tri_don_vi
mov num_set, a
mov a, gia_tri_tram
mov b, #100
mul ab
add a, num_set
mov num_set, a
;mov a, num_set

;lcall HEX_BCD
;lcall BCD_7SEG
;lcall SHOW
;jmp MAIN_SETUP

;org 70h	
;=========================================================================================



;==============================================main loop==================================
MAIN:	
	clr spk
	mov delay_count, #0
	clr TR0
	lcall CONVERT
	lcall TIMER1_SETUP_FOR_MAIN		//de cai timer setup o ben ngoai ham main chinh, vi ben trong chuong trinh con cua interrupt 
									//minh da cho no tu dong setup lai cai timer roi
	MAIN_NEXT:
	//10s moi doc gia tri mot lan
	clr c

			
	mov b, num_set			//lay gia tri limit luu vao b
	mov a, sample
	cjne a,b,NOT_EQUAL

	NEXT:
	clr c
	lcall HEX_BCD
	lcall BCD_7SEG
	lcall SHOW
	sjmp MAIN_NEXT
	
	NOT_EQUAL:
	jc NEXT
	;jc MAIN
	jmp WARNING

;=========================================================================================



CONVERT:
	;setb ale
	;clr ale
	;setb start
	;jb eoc,$	   //$ chính là dia chi hien tai, cu nhay lai dong nay den khi eoc = 1 thi moi sang cau lenh tiep theo
	;clr start
	;;mov r7,#150
	;;de: lcall hienthi
	;;djnz r7,de
	;mov sample, p2
	;;mov b, num_set
	;;cjne a,b,NOT_EQUAL
	;ret

	clr wr_
	lcall DELAY_1
	setb wr_
	jb intr_ ,$

	clr rd_
	lcall DELAY_1
	mov sample, p2
	setb rd_
	ret



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

SHOW_SETUP:
	mov dptr, #ma7seg
	mov a, gia_tri_don_vi
	movc a, @a + dptr
	mov num, a
	setb donvi
	lcall DELAY_1
	anl p1, #0e1h			//p1 &= 11100001
	mov dptr, #ma7seg
	mov a, gia_tri_chuc
	movc a, @a + dptr
	mov num, a
	setb chuc
	lcall DELAY_1
	anl p1, #0e1h
	mov dptr, #ma7seg
	mov a, gia_tri_tram
	movc a, @a + dptr
	mov num, a
	setb tram
	lcall DELAY_1
	anl p1, #0e1h
	mov dptr, #ma7seg
	mov a, gia_tri_nghin
	movc a, @a + dptr
	mov num, a
	setb nghin
	lcall DELAY_1
	anl p1, #0e1h
	ret


TO_MAIN:
mov delay_count, #0
jmp MAIN

SHOW:
	;mov num,20h
	mov num,33h
	setb donvi
	lcall DELAY_1
	anl p1, #0e1h			//p1 &= 11100001

	;mov num,21h
	mov num,34h
	setb chuc
	lcall DELAY_1
	anl p1, #0e1h	   

	;mov num,22h
	mov num,35h
	setb tram
	lcall DELAY_1
	anl p1, #0e1h
	ret


WARNING:
	clr TR1				//tat timer 1
	clr led_interrupt
	setb spk
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
	mov button_ok, p1  		//		, lay gia tri bit p1.5 roi luu vao button_ok, h nut nay la nut reset
	anl button_ok, #20h		// button_ok = button_ok & 0010 0000
	mov a, button_ok
	;mov b, ok_set
	cjne a,#20h, RESET		//neu bam nut button_ok thi thoat khoi cai SETUP
	jmp WARNING_NEXT


RESET:	
;	clr TR0				//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	;setb ale
	;clr ale
	;setb start
	;jb eoc,$	   //$ chính là dia chi hien tai, cu nhay lai dong nay den khi eoc = 1 thi moi sang cau lenh tiep theo
	;clr start
	;;mov r7,#150
	;;de: lcall hienthi
	;;djnz r7,de
	;mov a,p2
	clr wr_
	lcall DELAY_1
	setb wr_
	jb intr_ ,$
		
	clr rd_
	lcall DELAY_1
	mov a, p2
	setb rd_

	mov b, num_set
	setb led_white
	cjne a,b,NOT_EQUAL_1
;	setb TR0
	jmp WARNING_NEXT
	NOT_EQUAL_1:
;	setb TR0				//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
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
	MOV TH0, #0F0h	//delay 250 lan timer 0.004s = delay 1s
	MOV TL0, #060h	
	setb TR0	//start timer 0
	ret

TIMER1_SETUP_FOR_MAIN:
	setb EA		//enable global interrupt
	setb ET1	//enable timer 1 overflow flag 
	mov TMOD, #10h			//16bit timer-1 selected
	mov TH1, #063h			//250 lan timer 0.04s = delay 10s
	mov TL1, #0C0h
	setb TR1  	//start timer 1
	ret 


DELAY_1:
	mov r7,#10				//#250
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