#include <MuxShield.h>

//Initialize the Mux Shield
MuxShield muxShield;
int nums[] = {666,42,17,27};
//Arrays to store analog values after recieving them
int IO1AnalogVals[16];
int IO2AnalogVals[5];

void setup() {
    muxShield.setMode(1,ANALOG_IN);
    muxShield.setMode(2,ANALOG_IN);
    Serial.begin(115200);
}

void loop(){

if(Serial.available()){
        char _h = Serial.read();
        if(_h == '?'){
            Serial.print("spinWheeler");
        }
        else if(_h == '*'){
         readThemPiezos();
        }
    }

}

void readThemPiezos(){
for (int i=0; i<16; i++) // à ajuster au nombre de capteurs
  {
    //Analog read on all 16 inputs on IO1, IO2, and IO3
    IO1AnalogVals[i] = int(muxShield.analogReadMS(1,i));
    if(IO1AnalogVals[i]<4){ // preprocessing anti-bruit
    IO1AnalogVals[i] = 0;
    }
  }

  for (int i=0; i<4; i++)
  {
     IO2AnalogVals[i] = muxShield.analogReadMS(2,i);
     if(IO2AnalogVals[i]<4){ // preprocessing anti-bruit
    IO2AnalogVals[i] = 0;
    }
  } 



for (int i=0; i<16; i++)
  {
    Serial.print(IO1AnalogVals[i]);
    Serial.print(' ');
  }

    for (int i=0; i<4; i++)
  {
    Serial.print(IO2AnalogVals[i]);
    Serial.print(' ');
  }

  } /// fin de readThemPiezos()
