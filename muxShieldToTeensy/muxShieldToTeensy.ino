#include <MuxShield.h>

//Initialize the Mux Shield
MuxShield muxShield;

#define PIEZO_COUNT 20
#define WINDOW_SIZE 16
int piezoBuffer[WINDOW_SIZE][PIEZO_COUNT];
uint8_t piezo[PIEZO_COUNT];
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
    for(int i = 0; i < PIEZO_COUNT; i++){
        Serial.write(piezo[i]);
        // Serial.print(',');
    }
    // Serial.println();
}

void readThemPiezos(){
    int _tmp = 0;
    int _sum = 0;
    readCount++;
    readCount %= WINDOW_SIZE;
    for (int i=0; i<PIEZO_COUNT; i++)
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
        piezo[i] = byte(_sum / WINDOW_SIZE);
        _sum = 0;
    }
}
