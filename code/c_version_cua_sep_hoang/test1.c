#include <REGX52.h>

// Khai bao ket noi voi ADC
sbit ADC_RD    = P3^7;
sbit ADC_WR    = P3^6;
sbit ADC_INTR  = P1^7;

// Khai bao ket noi voi LED7SEG
sbit LED_TRAM  = P1^2;
sbit LED_CHUC  = P1^3;
sbit LED_DONVI = P1^4;

// Khai bao ket noi nut bam va loa
sbit SET_BUTTON = P1^5;
sbit INC_BUTTON = P1^6;
sbit SPEAKER_PIN = P1^0;

unsigned char count = 0;
unsigned char temp;

// Delay Function
void Delay_us(unsigned int t);

// ADC Read Function
unsigned char ADC_Read();

// Display 7seg Function
void Display(unsigned char temp);

// Blink function - Nhap nhay LED khi nhiet do vuot nguong
void Blink();
 
// Ngat Timer
void TimerOverflow(void) interrupt 1 
{
	// Nap lai gia tri cho TH0 và TL0
	TH0 = 0x00;
	TL0 = 0x00;
  count ++; // bien dem so chu ki ngat
	if(count == 140) // 1 chu ki ngat ~ 0.065s => 150 chu ki ~ 10s thi doc ADC
		{
			count = 0; // Reset lai bien dem	
			temp = ADC_Read();
		}
}

// Main
void main()
{
	unsigned char count_inc = 0; // bien dem so lan an nut INC
	unsigned char count_button = 0; // bien dem so lan an nut SET
	unsigned char Tref = 80;	
	temp = ADC_Read();
	// Cau hinh timer0 16bit
	TMOD &= 0xF0;
	TMOD |= 0x01;
	TH0 = 0x00;
	TL0 = 0x00;
	ET0 = 1;
  EA = 1;
	TR0 = 1;
	
	while(1)
	{ 
		// Nut an tang nhiet do nguong
		if(INC_BUTTON == 0)
				{
					while(INC_BUTTON == 0);
					Tref = Tref + 1;
        }
		Display(Tref);
		if(SET_BUTTON == 0) {break;} // An nut SET thoat vong lap va chuyen sang phan hien thi nhiet do
	}	
  while(1)
		{
			TR0 = 1;
		  if(temp<Tref)  
						{          
						 Display(temp);
						 SPEAKER_PIN = 0;
	          }
       if(temp>=Tref)
						{ 
							while(1)
								{
									TR0 = 0; // Tat Timer
							    Blink();
                  Delay_us(10000);
                  SPEAKER_PIN = 1; // Batloa
                  if(SET_BUTTON == 0)
										{
											while(SET_BUTTON == 0);
										  count_button++; 
										}
                  if(count_button>0) // Khi bam nut SET,doc gia tri nhiet do ngay lap tuc va thoat vong lap
										{
											temp=ADC_Read();
										  count_button = 0;
										  break;
										}							
						     }
              }
     }
}


void Blink()
{
	P1_1 = 0;
    
	LED_TRAM = 1;
	P0 = 0xBF;
	Delay_us(250);
  LED_TRAM = 0;
  
	LED_CHUC = 1;
  P0 = 0xBF;
  Delay_us(250);
  LED_CHUC = 0;	
	
  LED_DONVI = 1;
	P0 = 0xBF;
	Delay_us(250);
  LED_DONVI = 0;
}	

void Display(unsigned char temp)
{
	unsigned char LED7SEG[10] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90};
	unsigned char tram,chuc,dv;
	P1_1 = 0; // Ko hien thi chu so hang nghin
	tram = temp/100;
	chuc = (temp%100)/10;
	dv = temp%10;
  
  // Hien thi chu so hang tram  
	LED_TRAM = 1;
	P0 = LED7SEG[tram];
	Delay_us(250);
  LED_TRAM = 0;
  
	// Hien thi chu so hang chuc
	LED_CHUC = 1;
  P0 = LED7SEG[chuc];
  Delay_us(250);
  LED_CHUC = 0;	
	
	// Hien thi chu so hang don vi
  LED_DONVI = 1;
	P0 = LED7SEG[dv];
	Delay_us(250);
  LED_DONVI = 0;
}	

unsigned char ADC_Read() 
{
	unsigned char result;
	
	// Tao xung bat dau chuyen doi 
	ADC_WR = 0;
	ADC_WR = 1;
	
	// Doi cho den khi chuyen doi xong
	while(ADC_INTR);
	
	// Doc gia tri sau khi chuyen doi
	ADC_RD = 0;
	Delay_us(250);
	result = P2;
	ADC_RD = 1;
	
	return result;
}

void Delay_us(unsigned int t)
{
	unsigned int x,y;
	for(x=0;x<t;x++)
	{
		for(y=0;y<2;y++);
	}
}	


	
	

