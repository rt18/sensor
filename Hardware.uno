#include "edp.c"
#include <Servo.h>
#define KEY  "XpAhYrqhsZbk9eVqESnMJznDb3A="    //APIkey 
#define ID   "4051313"                          //设备ID
//#define PUSH_ID "680788"
#define PUSH_ID NULL
 
// 串口
#define _baudrate   115200
#define _rxpin      3
#define _txpin      2
#define WIFI_UART   Serial
#define DBG_UART    dbgSerial   //调试打印串口
 
SoftwareSerial dbgSerial( _rxpin, _txpin ); // 软串口，调试打印
edp_pkt *pkt;
 
/*
* doCmdOk
* 发送命令至模块，从回复中获取期待的关键字
* keyword: 所期待的关键字
* 成功找到关键字返回true，否则返回false
*/
bool doCmdOk(String data, char *keyword)
{
bool result = false;
if (data != "")   //对于tcp连接命令，直接等待第二次回复
{
WIFI_UART.println(data);  //发送AT指令
DBG_UART.print("SEND: ");
DBG_UART.println(data);
}
if (data == "AT")   //检查模块存在
delay(2000);
else
while (!WIFI_UART.available());  // 等待模块回复
 
delay(200);
if (WIFI_UART.find(keyword))   //返回值判断
{
DBG_UART.println("do cmd OK");
result = true;
}
else
{
DBG_UART.println("do cmd ERROR");
result = false;
}
while (WIFI_UART.available()) WIFI_UART.read();   //清空串口接收缓存
delay(500); //指令时间间隔
return result;
}
 
 
void setup()
{
char buf[100] = {0};
int tmp;
 
pinMode(13, OUTPUT);   //WIFI模块指示灯
pinMode(8, OUTPUT);    //用于连接EDP控制的舵机
 
WIFI_UART.begin( _baudrate );
DBG_UART.begin( _baudrate );
WIFI_UART.setTimeout(3000);    //设置find超时时间
delay(3000);
DBG_UART.println("hello world!");
 
#include <Servo.h>    // 声明调用Servo.h库
Servo myservo;        // 创建一个舵机对象
int pos = 0;          // 变量pos用来存储舵机位置
void setup() { 
    myservo.attach(9);  // 将引脚9上的舵机与声明的舵机对象连接起来
} 

void loop() { 
   for(pos = 0; pos < 180; pos += 1){    // 舵机从0°转到180°，每次增加1°          
      myservo.write(pos);           // 给舵机写入角度   
      delay(15);                    // 延时15ms让舵机转到指定位置
   }
    for(pos = 180; pos>=1; pos-=1) {    // 舵机从180°转回到0°，每次减小1°                               
       myservo.write(pos);        // 写角度到舵机     
       delay(15);                 // 延时15ms让舵机转到指定位置
    } 
} 
while (!doCmdOk("AT+CWMODE=3", "OK"));            //工作模式
while (!doCmdOk("AT+CWJAP=\"PDCN\",\"1234567890\"", "OK"));
while (!doCmdOk("AT+CIPST