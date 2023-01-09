# Light-Based-LED-Driver

Our system consists of several parts which include **LCD screen display(SPI)**, **Sensor (I2C)** data reading, **setting threshold values using potentiometer**, 
**driving LED using PWM (duty cycle)**, and **setting onboard RGB** according to **luminosity value** read from the sensor.

### LCD Screen Display
In order to write SPI configurations and print values on the screen Assembly language is used. SSI0 module and A port is used for setting LCD. 

● CLK is PA2  
● Din is PA5  
● DC is PA7  
● CE is PA3  
● RESET is PA6   

SPI0_init subroutine is responsible for setting appropriate settings for SPI 0 module. In the Figure 1 given on the left an example configuration for the SSI is provided. 
There are two subroutines called SPI1_Write_cmd and SPI1_Write_data. These subroutines are intended to achieve LCD configuration and data transfer for LCD.

![image](https://user-images.githubusercontent.com/88316097/211329025-b13987e7-d802-4477-b1d7-0cc7b28aac25.png)


In order to send commands for LCD screen DC and CE is set to low and waits until Tx FIFO is not full. By the same logic in order to send data DC is set to high.
The main function for the LCD is LCDupdate. LCD update uses AutoText subroutine which enables us to write predefined letters. LUM is luminosity value, LT is low threshold and HT is high threshold. 
For the data, horizontal addressing is used. 

![image](https://user-images.githubusercontent.com/88316097/211329295-7e3ade7b-733e-4a99-8f63-6d6bdca182ca.png)

For example, in order to write L ;0x7f, 0x40, 0x40, 0x40, 0x40 hex values are sent by SPI1_Write_data subroutine. 
The orientation for the writings is done by SPI1_Write_cmd subroutine and 0x80 sets X address to beginning and 0x40 sets Y address to 0. segment (there are 6 segments). 
By changing these hex values we are able to arrange the letters as in Figure 2. 


In order to write numbers we use a subroutine called CNVRT which is used to obtain the digits of the hex number provided by the C code (data obtained from the sensor) and sending the digits 
correspondent place on the LCD. In C code we defined pointers to specific locations of the memory and read the memory data in the assembly code. The numbers are predefined in writeDigit.s subroutine. 
By comparing values we decide which number is provided and print the data. An example LCD screen display can be illustrated in Figure 3.

![image](https://user-images.githubusercontent.com/88316097/211329484-03da1bc7-7247-4866-b041-97465268ef20.png)

LUM, LT, HT values are updated synchronously with the changing values of luminosity and threshold values read from POT.


### Setting On-Board RGB

The luminosity value is first calculated by calling the function CalculateLux with the arguments 1u, 2u, CH0, CH1, 1. 
The resulting luminosity value is then stored in the variable luminosity and a pointer to this variable is created.
Next, we compare the luminosity value to two threshold values: lowTH and highTH . If the luminosity value is less than lowTH, 
the red LED is turned on and the green and blue LEDs are turned off. If the luminosity value is greater than highTH, the blue LED is 
turned on and the red and green LEDs are turned off. If the luminosity value is within the range between lowTH  and highTH, the green
 LED is turned on and the red and blue LEDs are turned off.

![image](https://user-images.githubusercontent.com/88316097/211330067-648b12b8-51d2-4be0-ae88-07afa7064026.png)

An example illustration is shown in the upper Figure 4. Luminosity is higher than high threshold so blue led is turned on.

![image](https://user-images.githubusercontent.com/88316097/211330135-618dbae2-b127-4c63-9e04-8634adf1db70.png)

As can be seen in Figure 5 if the luminosity is between low and high thresholds green onboard led is turned on.
Overall, luminosity value is used as a way to control the color of the RGB LED based on  threshold values set by Potentiometer. 


### LED Driving Using PWM

For LED brightness change according to luminosity value read by the sensor we utilized a timer module to create PWM signal. 
We changed the duty cycle by changing the TAMR register in the timer handler. This enabled us to create a PWM signal. 
PB3 pin used in order to create a signal for turning on and off of the transistor which drives the LED.
We set HIGH and LOW time values in the handler when the counter counts down to zero. This means we change the duration of logic high and low case.
This duty cycle change varies according to the luminosity value as can be seen in Figure 6.

![image](https://user-images.githubusercontent.com/88316097/211330500-ce8351f3-ac37-45ad-86a8-e91a79add569.png)

In order to achieve such an operation we set the timer configurations in pulse init function which is provided to us in the Lab Manual.
Periodic countdown functionality is utilized so that continuous operation is achieved.  

![image](https://user-images.githubusercontent.com/88316097/211330707-a144af4a-b456-41d0-a79f-29f2b0354ad6.png)

In Figures 7 and 8 the brightness change of the LED according to luminosity can be illustrated.

### Threshold Setting from POT

![image](https://user-images.githubusercontent.com/88316097/211331184-1b38df33-ec94-45ec-bf34-6af0c1e03003.png)

Setting the threshold value part of the project, the ADC0 module of the Tiva TM4C123 microcontroller is initialized and 
configured to read the resistance of a potentiometer connected to the ADC0 pin. The ‘getPotResistance’ function is used to read 
the potentiometer resistance and convert it to a voltage, which is then converted to the resistance value using Ohm's law and the voltage divider equation.
The main function then calculates the mid, low, and high threshold values by multiplying the potentiometer resistance value by 0.034 
and adding or subtracting 500, respectively. These threshold values are then stored in memory locations pointed to by ptrLT and ptrHT. 
Additionally, the multiplication coefficient is 0.034 because we have found max luminosity that we have obtained around 1700 from memory. 
Hence, multiplication is done with that coefficient to proportion it.

**initializeADC0:** This function is responsible for configuring the ADC0 module of the Tiva TM4C123 microcontroller 
and setting up the ADC0 pin (PE3) as an analog input. It does this by first enabling the clock for Port E and setting the direction, 
analog mode, alternate function, and digital enable bits for PE3. It then enables the clock for the ADC0 module and waits for it to become ready. 
Next, it disables the SS3 sample sequencer for configuration and sets the trigger adjustment, input channel selection, and interrupt and end-of-sequence bits for SS3. 
It also enables the SS3 interrupt and sets the sample rate and resolution bits for the ADC0 module.Finally, it enables the SS3 sample sequencer.

**getPotResistance:** This function reads the value of the potentiometer resistance by first calling the **’readADCPin’** function to obtain a 12-bit ADC conversion result. 
It then converts this result to a float and applies a scaling factor to it to obtain the voltage at the ADC0 pin. This voltage is then converted to the resistance 
of the potentiometer using Ohm's law and the voltage divider equation, and the resulting value is returned.

**readADCPin:** This function reads the value of the ADC0 pin by initiating a conversion on SS3 and waiting for the conversion to complete. 
It then reads the 12-bit result from the SSFIFO3 register and clears the interrupt flag by writing to the ISC register. 
It stores the result in a global memory location and returns it.

