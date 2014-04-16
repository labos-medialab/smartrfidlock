#include<SoftwareSerial.h>
#include <RCSwitch.h>
RCSwitch mySwitch = RCSwitch();

SoftwareSerial mySerial(12,12);

#define redLed 9
#define grnLed 10
#define buzzer 11
#define lock A0
#define partyPin A4
#define RCpin 13
#define temper A3
#define door A5

String keyString="";

boolean sent=1;
boolean Lsent=0,lsent=0;
boolean Csent=0,csent=0;
boolean Psent=0,psent=0;
boolean state=0,didit=0;
boolean cardReadsend=0;
boolean redytoread=1;

int currentLed=9;

int brightness = 0;
int fadeAmount = 1;
int mySerialWake=1000;
int keyStringClear=1000;
int holdDoor = 4000;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  mySerial.begin(9600);
  mySwitch.enableTransmit(A2);
  pinMode(2,INPUT_PULLUP);
  pinMode(3,INPUT_PULLUP);
  pinMode(4,INPUT_PULLUP);
  pinMode(5,INPUT_PULLUP);
  pinMode(6,OUTPUT);
  pinMode(7,OUTPUT);
  pinMode(8,OUTPUT);
  
  digitalWrite(6,1);
  digitalWrite(7,1);
  digitalWrite(8,1);
  
  pinMode(redLed,OUTPUT);
  digitalWrite(redLed,1);
  pinMode(grnLed,OUTPUT);
  digitalWrite(grnLed,1);
  pinMode(buzzer,OUTPUT);
  digitalWrite(buzzer,1);
  pinMode(door,OUTPUT);
  
  pinMode(lock, INPUT_PULLUP);
  pinMode(temper, INPUT_PULLUP);
  pinMode(partyPin, INPUT_PULLUP);
}

void loop() {
  
  //ledice
  if (state){
    currentLed=grnLed;
    digitalWrite(redLed,HIGH);
  }
  else {
    currentLed=redLed;
    digitalWrite(grnLed,HIGH);
  }
  analogWrite(currentLed, brightness);
  
  brightness = brightness + fadeAmount;
  if (brightness == 0 || brightness == 255) {
    fadeAmount = -fadeAmount ;
  }
  //ledice
  
  //temper
  if(Csent==0 && digitalRead(temper)==1){
    Serial.write("CASE\n");
    Csent=1;
    csent=0;
  }
  
  if(csent==0 && digitalRead(temper)==0){
    Serial.write("case\n");
    Csent=0;
    csent=1;
  }
  //temper
  
  //parti
  if(Psent==0 && digitalRead(partyPin)==0){
    Serial.write("PARTY\n");
    Psent=1;
    psent=0;
  }
  
  if(psent==0 && digitalRead(partyPin)==1){
    Serial.write("party\n");
    Psent=0;
    psent=1;
  }
  //parti
  
  //brava
  if(Lsent==0 && digitalRead(lock)==HIGH){
    //provala
    Serial.write("LOCK\n");
    Lsent=1;
    lsent=0;
  }
  
  if(lsent==0 && digitalRead(lock)==LOW){
    //zatvoreno
    Serial.write("lock\n");
    Lsent=0;
    lsent=1;
  }
  //brava
  
  //keypad
  if(keyStringClear<1000) keyStringClear++;
  char key=gKey();
  if(key != 'F' && sent==1){
    keyStringClear=0;
    digitalWrite(buzzer,LOW);
    if(key=='L' && keyString!=""){
      Serial.print(keyString);Serial.write("\n");
      if(keyString=="*0" && digitalRead(A0)==0){
        state=0;
      }
      keyString="";
    }
    else keyString+=key;
    delay(75);
    digitalWrite(buzzer,HIGH);
    sent=0;
  }
  
  if(keyStringClear>=1000) keyString="";
  if(key=='F') sent=1;
  //keypad
  
  //cardread
  String inputString="";
  if(mySerial.read()==2 && cardReadsend==0){
    inputString=mySerial.readStringUntil(2);
    inputString=inputString.substring(0,12);
    if (inputString.length()>10){
      Serial.print(keyString);
      Serial.print(inputString);
      Serial.write("\n");
    }
    digitalWrite(buzzer, LOW);
    delay(75);
    digitalWrite(buzzer, HIGH);
    cardReadsend=1;
  }
  
  if(holdDoor==1999) digitalWrite(door, LOW);
  
  if(holdDoor<=2000) holdDoor++;
  if(mySerialWake<200) mySerialWake++;
  if(mySerial.available()>0 && cardReadsend) mySerialWake=0;
  if(cardReadsend && mySerialWake>=200) cardReadsend=0;
  delay(3);
}

void serialEvent() {
  String dataString="";
  while(Serial.available() > 0){
    mySerialWake=0;
    dataString=Serial.readStringUntil(';');
    if(dataString.startsWith("open")) state=1;
    else if(dataString.startsWith("close")) state=0;
    else if(dataString.startsWith("state")) state=!state;
    else if(dataString.startsWith("unlock")) {
      digitalWrite(door, HIGH);
      holdDoor=0;
    }
    else if(dataString.startsWith("ok")) {
      digitalWrite(buzzer,LOW);
    delay(100);
      digitalWrite(buzzer,HIGH);
      delay(30);
      digitalWrite(buzzer,LOW);
      delay(200);
      digitalWrite(buzzer,HIGH);
    }
    else if(dataString.startsWith("nok")) {
      analogWrite(buzzer,100);
      delay(150);
      digitalWrite(buzzer,HIGH);
      delay(10);
      analogWrite(buzzer,100);
      delay(150);
      digitalWrite(buzzer,HIGH);
      delay(10);
      analogWrite(buzzer,100);
      delay(120);
      digitalWrite(buzzer,HIGH);
    }
    else if(dataString.startsWith("kk")) {
      digitalWrite(buzzer,LOW);
      delay(200);
      digitalWrite(buzzer,HIGH);
      delay(30);
      analogWrite(buzzer,100);
      delay(200);
      digitalWrite(buzzer,HIGH);
    }
    else if(dataString.startsWith("ON")) ON();
    else if(dataString.startsWith("OFF")) OFF();
    else if(dataString.startsWith("A"))mySwitch.send(5588305,24);
    else if(dataString.startsWith("a"))mySwitch.send(5588308,24);
    else if(dataString.startsWith("B"))mySwitch.send(5591377,24);
    else if(dataString.startsWith("b"))mySwitch.send(5591380,24);
    else if(dataString.startsWith("C"))mySwitch.send(5592145,24);
    else if(dataString.startsWith("c"))mySwitch.send(5592148,24);
    else if(dataString.startsWith("D"))mySwitch.send(5592337,24);
    else if(dataString.startsWith("d"))mySwitch.send(5592340,24);
    else if(dataString.startsWith("E"))mySwitch.send(1394001,24);
    else if(dataString.startsWith("e"))mySwitch.send(1394004,24);
  }
}

char gKey(){
  digitalWrite(6,0);
  digitalWrite(7,1);
  digitalWrite(8,1);
  if(digitalRead(2)==0)return '1';
  if(digitalRead(3)==0)return '4';
  if(digitalRead(4)==0)return '7';
  if(digitalRead(5)==0)return '*';
  digitalWrite(6,1);
  digitalWrite(7,0);
  digitalWrite(8,1);
  if(digitalRead(2)==0)return '2';
  if(digitalRead(3)==0)return '5';
  if(digitalRead(4)==0)return '8';
  if(digitalRead(5)==0)return '0';
  digitalWrite(6,1);
  digitalWrite(7,1);
  digitalWrite(8,0);
  if(digitalRead(2)==0)return '3';
  if(digitalRead(3)==0)return '6';
  if(digitalRead(4)==0)return '9';
  if(digitalRead(5)==0)return 'L';
  return 'F';
}

void ON(){
  mySwitch.send(5588305,24);
  mySwitch.send(5591377,24);
  mySwitch.send(5592145,24);
  mySwitch.send(5592337,24);
  mySwitch.send(1394001,24);
}
void OFF(){
  mySwitch.send(5588308,24);
  mySwitch.send(5591380,24);
  mySwitch.send(5592148,24);
  mySwitch.send(5592340,24);
  mySwitch.send(1394004,24);
}
