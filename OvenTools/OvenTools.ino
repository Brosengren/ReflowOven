#include <Adafruit_MAX31856.h>
#include <LiquidCrystal.h>
const int rs = 7, en = 6, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);


// All variables (minus iterators) get delcared here
int ovenTemp = 0;
int templateTemp2 = 0;
unsigned long sTime = 0;
int runTime = 0;
char str1[20] = {0};
char str2[10] = {0};
int OvenPin = 13;
int cnt = 0;
Adafruit_MAX31856 amax = Adafruit_MAX31856(9, 10, 11, 14);

//void(* resetFunc) (void) = 0; //declare reset function @ address 0

void setup() {
    lcd.begin(16, 2);

	Serial.begin(115200);
	amax.begin();
  amax.setThermocoupleType(MAX31856_TCTYPE_K);
	pinMode(OvenPin, OUTPUT);
//	delay(250);
}

void loop() {
//	ovenTemp = millis()/1000;
	getTemp();
//	getTime();
	sendSerial();
	setRelays();
	//delay(250);
}

void sendSerial(){
	sprintf(str1, "%d", ovenTemp);

	runTime = (millis()-sTime)/1000;
	sprintf(str2, "%d", runTime);

	strcat(str1, ","); 
	strcat(str2, ",");
	strcat(str1, str2);
	Serial.println(str1);
}

void getTemp(){
	ovenTemp = amax.readThermocoupleTemperature();
}

void setRelays(){
  if(Serial.available() > 0){
    cnt = 0;
  	Serial.readBytesUntil('x', str1, 20);
    strcat(str1, 0);
    if(!strcmp(str1, "rst")){
    	sTime=millis();
    	str1[1]=0;
    }
  	templateTemp2 = atoi(str1);
  	if(ovenTemp >= templateTemp2 + 2){
  		digitalWrite(OvenPin, LOW);
  	}
  	else if(ovenTemp <= templateTemp2 - 1){
  		digitalWrite(OvenPin, HIGH);
  	}
   
    lcd.clear();
    lcd.setCursor(0,0);
    lcd.print(ovenTemp);
    lcd.print(" , ");
    lcd.print(runTime);
    lcd.setCursor(0,1);
    lcd.print(templateTemp2);
    lcd.print(" , ");
    lcd.print(str1);
    
    while(Serial.available() > 0){
      Serial.read();
    }
  }
    else{
      if(cnt > 5){  
        if(digitalRead(OvenPin)){
          digitalWrite(OvenPin, LOW);
        }
      }
      cnt++;
  }
//	Serial.println(ovenTemp);
//	Serial.println(templateTemp2);
}
