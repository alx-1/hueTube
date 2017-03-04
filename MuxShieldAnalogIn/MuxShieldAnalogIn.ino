#include <MuxShield.h>

//Initialize the Mux Shield
MuxShield muxShield;

#define WINDOW_SIZE 16
int piezoBuffer[WINDOW_SIZE][20];
int piezo[20];
int readCount;

void setup() {
    muxShield.setMode(1,ANALOG_IN);
    muxShield.setMode(2,ANALOG_IN);
    Serial.begin(115200);
    readCount = 0;
}

void loop(){
    readThemPiezos();
    delay(1);
    if(Serial.available()){
        char _h = Serial.read();
        if(_h == '?'){
            Serial.print("piezo");
        }
        else if(_h == '*'){
            sendData();
        }
    }
}

void sendData(){
    for(int i = 0; i < 20; i++){
        Serial.print(piezo[i]);
        Serial.print(',');
    }
    // Serial.println();
}

void readThemPiezos(){
    int _tmp = 0;
    int _sum = 0;
    readCount++;
    readCount %= WINDOW_SIZE;
    for (int i=0; i<20; i++)
    {
        if(i < 16){
            _tmp = int(muxShield.analogReadMS(1,i));
        }
        else{
            _tmp = int(muxShield.analogReadMS(2,i));
        }

        piezoBuffer[readCount][i] = _tmp;

        for(int j = 0; j < WINDOW_SIZE; j++){
            _sum += piezoBuffer[j][i];
        }
        piezo[i] = _sum / WINDOW_SIZE;
        _sum = 0;
    }
}













// #include <MuxShield.h>
//
// //Initialize the Mux Shield
// MuxShield muxShield;
//
// double compteur = 0;
//
// void setup()
// {
//     //Set I/O 1, I/O 2, and I/O 3 as analog inputs
//     muxShield.setMode(1,ANALOG_IN);
//     muxShield.setMode(2,ANALOG_IN);
//     muxShield.setMode(3,ANALOG_IN);
//
//     Serial.begin(115200);
// }
//
// //Arrays to store analog values after recieving them
// int IO1AnalogVals[16];
// int IO2AnalogVals[16];
// int IO3AnalogVals[16];
//
// void loop()
// {
//   delay(50); // pourrait être diminué, question de timing avec Processing
//   for (int i=0; i<4; i++) // à ajuster au nombre de capteurs
//   {
//     //Analog read on all 16 inputs on IO1, IO2, and IO3
//     IO1AnalogVals[i] = int(muxShield.analogReadMS(1,i)/10);
//   //  IO2AnalogVals[i] = muxShield.analogReadMS(2,i);
//   //  IO3AnalogVals[i] = muxShield.analogReadMS(3,i);
//   }
//
//   //Print IO1 values for inspection
//   //Serial.print("IO1 analog values: ");
//   for (int i=0; i<4; i++)
//   {
//     Serial.print(IO1AnalogVals[i]);
//     Serial.print(' ');
//     //Serial.print('\t');
//    // Serial.print(IO2AnalogVals[i]);
//    // Serial.print('\t');
//    // Serial.print(IO3AnalogVals[i]);
//    // Serial.print('\t');
//   }
//  /* Serial.println();
//  Serial.print("compteur : ");
//  Serial.print(compteur);
//   Serial.print('\t');
//   Serial.println();
//   compteur = compteur+1; */
// }
