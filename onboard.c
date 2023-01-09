// I2C3_Write_Multiple() retrieved from https://microcontrollerslab.com/i2c-communication-tm4c123g-tiva-c-launchpad/
// I2C3_read_Multiple() retrieved from https://microcontrollerslab.com/i2c-communication-tm4c123g-tiva-c-launchpad/
// I2C_wait_till_done() retrieved from https://microcontrollerslab.com/i2c-communication-tm4c123g-tiva-c-launchpad/
// I2C3_Init() retrieved from https://microcontrollerslab.com/i2c-communication-tm4c123g-tiva-c-launchpad/ 
// Above 4 functions are modified and configured according to TSL2561 temperature sensor. We have obtained default functions must to be used at the I2C.

#include "TM4C1231H6PM.h"
#include "stdio.h"
#include "CalculateLux.h"

extern updateLCD(void);
extern SPI0_init(void);
extern void OutStr(char *);

void initializeGPIOB(void);
void initializeGPIOF(void);
void initializeADC0(void);
void I2C3_Init(void); // I2C3 Initialization
void delayInMiliSeconds(int time_msec);
void pulse_init(void);

uint32_t readADCPin(void);
int getPotResistance();

static int I2C_wait_till_done(void);  // I2C Wait Bus Function

char I2C3_Write_Multiple(int slave_address, char slave_memory_address, int bytes_count, char* data); // Function to Write with I2C3 SDA
char I2C3_read_Multiple(int slave_address, char slave_memory_address, int bytes_count, char* data); // Function to Read fron I2C3 SDA

extern unsigned int CalculateLux(unsigned int iGain, unsigned int tInt, unsigned intch0, unsigned int ch1, int iType); // Calculate LUX Function from Data Sheet

char error = 0;

int *ptrLUM=0x20000500;
int *ptrLT=0x20000400;
int *ptrHT=0x20000420;

static int LOW=50; // Initial default values for duty cycle LOW
static int HIGH=50; // Initial default values for duty cycle HIGH

static int lowTH=300; // Low threshold value Set at here
static int	highTH=1000; // High threshold value Set at here
	
unsigned int* ptr; // Keeps current luminosity value
volatile int* temp = (volatile int*) 0x20000550; // 
volatile int* MemoryPtrADC0 = (volatile int*) 0x20000700; // Keep input value inside pre-declared address to check it from memory location directly.


int main(void)
{
	char ResistanceOfPotInDecimal[20];
	
	int POTresistance;
	int range_green;
	
	unsigned int counter = 0; // Counter to count up to 256
	
	char lowDataCH0[1]; 	// Keep Channel0's lower data register value
	char highDataCH0[1]; 	// Keep Channel0's higher data register value
	char lowDataCH1[1]; 	// Keep Channel1's lower data register value
	char highDataCH1[1]; 	// Keep Channel1's higher data register value
	
	char PowerON[1] = {0x03}; // To power ON Light Sensor I2C

	unsigned int lowCH0; 	// Channel0 low as Unsigned Int
	unsigned int highCH0;	// Channel0 high as Unsigned Int
	unsigned int lowCH1;	// Channel1 low as Unsigned Int
	unsigned int highCH1;	// Channel1 high as Unsigned Int

	unsigned int CH0, CH1;
	unsigned int luminosity;	
	
	initializeGPIOB(); // Initialize port B
	initializeGPIOF(); // Initialize port F
	initializeADC0();  // Call initialize function for ADC initialization
	I2C3_Init();   		 // I2C3 initialization
	pulse_init();
	SPI0_init();			 // SPI0 initialization
										
	GPIOB->DATA |= 0xF0;													// Close LEDs initially.

	I2C3_Write_Multiple(0x39, 0x80, 1, PowerON); 	// Power on light sensor with I2C
	
	*ptrHT=highTH;
	*ptrLT=lowTH;
	
	while (1)														 					// Read ADC input at always
	{
		
		counter = 0; // Reset counter after 256 data collected.
		CH0 = 0; 
		CH1 = 0;
		
		while(counter < 256) // Collect 256 data in 1 seconds.
		{
			counter += 1;
			
			I2C3_read_Multiple(0x39, 0x8C , 1, lowDataCH0);
			I2C3_read_Multiple(0x39, 0x8D , 1, highDataCH0);
			
			I2C3_read_Multiple(0x39, 0x8E , 1, lowDataCH1);
			I2C3_read_Multiple(0x39, 0x8F , 1, highDataCH1);
			
			lowCH0 = (unsigned int) lowDataCH0[0];
			highCH0 = (unsigned int) highDataCH0[0];	
			
			lowCH1 = (unsigned int) lowDataCH1[0];
			highCH1 = (unsigned int) highDataCH1[0];
			
			CH0 += 256*highCH0 + lowCH0;
			CH1 += 256*highCH1 + lowCH1;
		}
		
		lowTH = getPotResistance() * 0.034; // Read POT resistance
		
		range_green = 500;
	
		*ptrLT=lowTH - range_green;
		*ptrHT=lowTH + range_green;
	
		CH0 = CH0/256;
		CH1 = CH1/256;
		luminosity = CalculateLux(1u, 2u, CH0, CH1, 1); // Call luminosity calculate function to calc. from mean values.
		*ptrLUM = luminosity;
		ptr = &luminosity;
		
		if(luminosity < lowTH - range_green)
		{
			GPIOF->DATA|=0x02;
			GPIOF->DATA&=~0x04;
			GPIOF->DATA&=~0x08;
		}
		else if(luminosity > lowTH + range_green)
		{
			GPIOF->DATA|=0x04;
			GPIOF->DATA&=~0x08;
			GPIOF->DATA&=~0x02;
		}
		else
		{
			GPIOF->DATA|=0x08;
			GPIOF->DATA&=~0x02;
			GPIOF->DATA&=~0x04;
		}
			
		sprintf(ResistanceOfPotInDecimal, "%d \n%c", getPotResistance()*0.034, 0x04); // Store your decimal values from 0V to 3.3V
		OutStr(ResistanceOfPotInDecimal);
		updateLCD();
	}
	return 0;
}

void TIMER0A_Handler (void)
{
	GPIOB->DATA  ^= 8;  //toggle PB3 pin
	*temp = GPIOB->DATA;
	
	if(*ptr > *ptrHT)
	{
		HIGH = *ptrHT * 0.0588;
		LOW = 100 - HIGH;
	}
	else if(*ptr < *ptrLT)
	{
  	HIGH = *ptrLT * 0.0588;
		LOW = 100 - HIGH;
	}
	else
	{
		HIGH = (*ptr) * 0.0588;
		LOW = 100 - HIGH;
	}
	
	if ((GPIOB->DATA & 0x08) == 0x08) 
	{
		TIMER0->TAILR = HIGH; //Set interval load as LOW
	}
	else 
	{
		TIMER0->TAILR = LOW; //Set interval load as LOW
	}
	
	TIMER0->ICR |=0x01; //Clear the interrupt
	return;
}


void initializeGPIOB(void)
{
	unsigned int IOB = 0x0Fu;
	unsigned int PUB = 0xF0u;

	SYSCTL->RCGCGPIO |= 0x02; 	// Enable clock for PORT B

	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");

	GPIOB->DIR &= ~0xFF;				// Firstly, clear direction register of PORTB.
	GPIOB->DIR |= 0x0F;					// PB7-PB4 Input of MCU, PB3-PB0 Output of MCU.
	GPIOB->AFSEL &= ~0xFF;   		// Disable alternate function mode on PORTB.
	GPIOB->DEN |= 0xFF;  				// Enable digital mode on PORTB.

	GPIOB->PUR = 0xF0;					// Enable Pull UP resistor for PB7-PB4.
}


void initializeGPIOF(void)
{
	unsigned int IOB = 0x0Fu;
	unsigned int PUB = 0xF0u;

	SYSCTL->RCGCGPIO |= 0x20; 	// Enable clock for PORT F

	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");

	GPIOF->DIR			|= 0x0E; //set PF2 as output
  GPIOF->AFSEL		&= (0xFFFFFFF1);  // Regular port function
	GPIOF->PCTL			&= 0xFFFF000F;  // No alternate function
	GPIOF->AMSEL		=0; //Disable analog
	GPIOF->DEN			|=0x0E; // Enable port digital
}


void initializeADC0(void)
{
  // Configurations of the PE3 as analog input
	SYSCTL->RCGCGPIO |= 0x10; 			// Enable clock for Port E
	
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	
	GPIOE->DIR &= ~0x08u;
	GPIOE->AMSEL |= 0x08u;   				// Enable analog on PE3
	GPIOE->AFSEL |= 0x08u;   				// Enable alternate function on PE3
  GPIOE->DEN &= ~0x08u;    				// Disable digital on PE3
		
	SYSCTL->RCGCADC |= 0x0001;			// Enable clock to ADC0 // Configure ADC0
	
	while((SYSCTL->PRADC & 0x0001)==0x0){}
		
  ADC0->ACTSS &= ~0x0008u;      	// Disable SS3 for configuration
  ADC0->EMUX &= ~0xF000u;       	// Processor trigger adjustment
  ADC0->SSMUX3 &= ~0x000Fu;     	// clear bits 3:0 to select AIN0
  ADC0->SSCTL3 |= 0x0006u;      	// set bits 2:1 (IE0, END0) IE0 is set since we want RIS to be set
  ADC0->IM |= 0x0008u;          	// Enable SS3 interrupt
	ADC0->PC = 0x1u; 						  	// Set bits 0:3 to 0x1 for 125k sps
  ADC0->ACTSS |= 0x0008u;       	// Enable ADC0 SS3
}


void I2C3_Init (void) // Initializations of GPIO AFSEL and I2C3 configurations.
{
	SYSCTL->RCGCGPIO |= 0x8; // Activate clock port D
		while (!SYSCTL->PRGPIO) {} // Wait for GPIO clock to be ready
	SYSCTL->RCGCI2C |= 0x8; // Activate I2C3's clock 
		while (!SYSCTL->PRI2C) {} // Wait for GPIO clock to be ready
			
	GPIOD->DEN |= 0x03; // Digital enable for PD0 and PD1

	GPIOD->AFSEL |= 0x3 ; // Activate AFSEL for PORTD
	GPIOD->PCTL |= 0x00000033 ; // Configure PCTL register for I2C3
	GPIOD->ODR |= 0x00000002 ; // SDA (PD1) pin as open drain
	I2C3->MCR  = 0x0010 ; // Enable I2C 3 master function
	I2C3->MTPR  = 0x07 ;
}


// Subroutine for delay in seconds
void delayInMiliSeconds(int time_msec)
{
    int i, j;
    for(i = 0 ; i < time_msec; i++)
        for(j = 0; j < 3180; j++)
            {}  // excute NOP for 1ms
}


void pulse_init(void){
	volatile int *NVIC_EN0 = (volatile int*) 0xE000E100;
	volatile int *NVIC_PRI4 = (volatile int*) 0xE000E410;

	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	
	
	SYSCTL->RCGCTIMER	|=0x01; // Start timer0
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	TIMER0->CTL			&=0xFFFFFFFE; //Disable timer during setup
	TIMER0->CFG			=0x04;  //Set 16 bit mode
	TIMER0->TAMR		=0x02; // set to periodic, count down
	TIMER0->TAILR		=LOW; //Set interval load as LOW
	TIMER0->TAPR		=15; // Divide the clock by 16 to get 1us
	TIMER0->IMR			=0x01; //Enable timeout intrrupt	
	
	//Timer0A is interrupt 19
	//Interrupt 16-19 are handled by NVIC register PRI4
	//Interrupt 19 is controlled by bits 31:29 of PRI4
	*NVIC_PRI4 &=0x00FFFFFF; //Clear interrupt 19 priority
	*NVIC_PRI4 |=0x40000000; //Set interrupt 19 priority to 2
	
	//NVIC has to be neabled
	//Interrupts 0-31 are handled by NVIC register EN0
	//Interrupt 19 is controlled by bit 19
	*NVIC_EN0 |=0x00080000;
	
	//Enable timer
	TIMER0->CTL			 |=0x03; // bit0 to enable and bit 1 to stall on debug
	return;
}


uint32_t readADCPin(void) 								// Read 12-bit value from ADC0
{
	uint32_t resultADCread;
  ADC0->PSSI |= 0x0008;            				// Initiate SS3
  while((ADC0->RIS & 0x08) == 0) {}    	  // Wait for conversion to complete
		
  resultADCread = ADC0->SSFIFO3 & 0xFFF;  // Read 12-bit result
  ADC0->ISC |= 0x0008;            				// Clear interrupt
		
	*MemoryPtrADC0 = (int) resultADCread;
	return resultADCread;
}


int getPotResistance()
{
	int Result;
	int POTresistance;
	double floatResult;
	
	Result = (int)readADCPin();    			// Read 12-bit input value and store it inside result variable at location  
	floatResult = (double)	Result;		
	floatResult = (floatResult * 1.65) / 2048.0;
	POTresistance = (floatResult / 3.3) * 50000;
	
	return POTresistance;
}


static int I2C_wait_till_done(void) 
{
    while(I2C3->MCS & 1);   /* wait until I2C master is not busy */
    return I2C3->MCS & 0xE; /* return I2C error code, 0 if no error*/
}


// Receive one byte of data from I2C slave device
char I2C3_Write_Multiple(int slave_address, char slave_memory_address, int bytes_count, char* data)
{   
    if (bytes_count <= 0)
        return -1;                  /* no write was performed */
    /* send slave address and starting address */
    I2C3->MSA = slave_address << 1;
    I2C3->MDR = slave_memory_address;
    I2C3->MCS = 3;                  /* S-(saddr+w)-ACK-maddr-ACK */

    error = I2C_wait_till_done();   /* wait until write is complete */
    if (error) return error;

    /* send data one byte at a time */
    while (bytes_count > 1)
    {
        I2C3->MDR = *data++;             /* write the next byte */
        I2C3->MCS = 1;                   /* -data-ACK- */
        error = I2C_wait_till_done();
        if (error) return error;
        bytes_count--;
    }
    
    /* send last byte and a STOP */
    I2C3->MDR = *data++;                 /* write the last byte */ 
    I2C3->MCS = 5;                       /* -data-ACK-P */
    error = I2C_wait_till_done();
    while(I2C3->MCS & 0x40);             /* wait until bus is not busy */
    if (error) return error;
    return 0;       /* no error */
}


/* This function reds from slave memory location of slave address */
/* read address should be specified in the second argument */
/* read: S-(saddr+w)-ACK-maddr-ACK-R-(saddr+r)-ACK-data-ACK-data-ACK-...-data-NACK-P */
char I2C3_read_Multiple(int slave_address, char slave_memory_address, int bytes_count, char* data)
{
    if (bytes_count <= 0)
        return -1;         /* no read was performed */

    /* send slave address and starting address */
    I2C3->MSA = slave_address << 1;
    I2C3->MDR = slave_memory_address;
    I2C3->MCS = 3;       /* S-(saddr+w)-ACK-maddr-ACK */
    error = I2C_wait_till_done();
    if (error)
        return error;

    /* to change bus from write to read, send restart with slave addr */
    I2C3->MSA = (slave_address << 1) + 1;   /* restart: -R-(saddr+r)-ACK */

    if (bytes_count == 1)             /* if last byte, don't ack */
        I2C3->MCS = 7;              /* -data-NACK-P */
    else                            /* else ack */
        I2C3->MCS = 0xB;            /* -data-ACK- */
    error = I2C_wait_till_done();
    if (error) return error;

    *data++ = I2C3->MDR;            /* store the data received */

    if (--bytes_count == 0)           /* if single byte read, done */
    {
        while(I2C3->MCS & 0x40);    /* wait until bus is not busy */
        return 0;       /* no error */
    }
 
    /* read the rest of the bytes */
    while (bytes_count > 1)
    {
        I2C3->MCS = 9;              /* -data-ACK- */
        error = I2C_wait_till_done();
        if (error) return error;
        bytes_count--;
        *data++ = I2C3->MDR;        /* store data received */
    }

    I2C3->MCS = 5;                  /* -data-NACK-P */
    error = I2C_wait_till_done();
    *data = I2C3->MDR;              /* store data received */
    while(I2C3->MCS & 0x40);        /* wait until bus is not busy */
    
    return 0;       /* no error */
}




