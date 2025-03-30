/*
 ============================================================================
 Name        : main.c
 Author      : 
 Version     :
 Copyright   : Your copyright notice
 Description : Hello RISC-V World in C
 ============================================================================
 */

#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <platform.h>
#include "init.h"

#define STRBUF_SIZE			256	// String bufferS size

#define ISP_BUS_EN  0x0000000F;


#define ISP_CTRL_ADDR     _AC(0x10014000,UL)  
#define ISP_STATE_REG(offset) _REG32(ISP_CTRL_ADDR, offset)

#define ISP_CFA_STATE_REG     	0x00
#define ISP_AWB_STATE_REG     	0x04
#define ISP_CCM_STATE_REG     	0x08
#define ISP_GAMMA_STATE_REG     0x0C
#define ISP_AI_STATE_REG     	0x10

int get(){
	char str=12;
	for(int i=1;i<=20;i++){
		scanf("%c", &str);
	}
	return (int)str+80;
}

int main(void)
{
	_init();
	

	GPIO_REG(GPIO_OUTPUT_EN)|=ISP_BUS_EN;
	GPIO_REG(GPIO_OUTPUT_VAL)=0x00000001;
	while(1)
	{	
		
		// scanf("%c", &str);
		// printf("str_addr:%x\n",(int)(&str));
		int a=get();
		// printf("Hi computer:I have received:%d\n",a);
		if(a==1){//CFA type 
			int rb=ISP_STATE_REG(ISP_CFA_STATE_REG);
			int b=get();
			ISP_STATE_REG(ISP_CFA_STATE_REG)= b;
			GPIO_REG(GPIO_OUTPUT_EN)|=ISP_BUS_EN;
			GPIO_REG(GPIO_OUTPUT_VAL)=0x00000001;
			printf("Have Changed CFA type from %d to %d!",rb,b);
		}
		if(a==2){//GAMMA type
			int rb=ISP_STATE_REG(ISP_GAMMA_STATE_REG);
			int b=get();
			ISP_STATE_REG(ISP_GAMMA_STATE_REG)= b;
			GPIO_REG(GPIO_OUTPUT_EN)|=ISP_BUS_EN;
			GPIO_REG(GPIO_OUTPUT_VAL)=0x00000002;
			printf("Have Changed GAMMA type from %d to %d!",rb,b);
		}
		//Waiting for your coding 
	}
	return 0;
}
