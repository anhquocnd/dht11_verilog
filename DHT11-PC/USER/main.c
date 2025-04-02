#include "stm32f10x.h"
#include "LED.h"
#include "delay.h"
#include "sys.h"
#include "usart.h"

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>


#include "dht11.h"
 
 int main(void)
 {	
	 u8 temp=0,humi=0;
	 char buffer[100];
	 delay_init();
	 pinMode(PB5,OUTPUT);
	 pinMode(PB6,INPUT);
	 
	 USARTx_Init(USART2, Pins_PA2PA3, 115200);
	 DHT11_Init();
  while(1)
	{
	
		DHT11_Read_Data(&temp,&humi);
		printf("%d--%d\r\n",temp,humi);
		delay_ms(300);
		

	}
 }