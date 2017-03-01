
#include <MuxShield.h>

//Initialize the Mux Shield
MuxShield muxShield;

double compteur = 0;

void setup()
{
    //Set I/O 1, I/O 2, and I/O 3 as analog inputs
    muxShield.setMode(1,ANALOG_IN);
    muxShield.setMode(2,ANALOG_IN);
    muxShield.setMode(3,ANALOG_IN);
    
    Serial.begin(115200);
}

//Arrays to store analog values after recieving them
int IO1AnalogVals[16];
int IO2AnalogVals[16];
int IO3AnalogVals[16];

void loop()
{
  delay(50); // pourrait être diminué, question de timing avec Processing
  for (int i=0; i<4; i++) // à ajuster au nombre de capteurs
  {
    //Analog read on all 16 inputs on IO1, IO2, and IO3
    IO1AnalogVals[i] = int(muxShield.analogReadMS(1,i)/10);
  //  IO2AnalogVals[i] = muxShield.analogReadMS(2,i);
  //  IO3AnalogVals[i] = muxShield.analogReadMS(3,i);
  }
  
  //Print IO1 values for inspection
  //Serial.print("IO1 analog values: ");
  for (int i=0; i<4; i++)
  {
    Serial.print(IO1AnalogVals[i]);
    Serial.print(' ');
    //Serial.print('\t');
   // Serial.print(IO2AnalogVals[i]);
   // Serial.print('\t');
   // Serial.print(IO3AnalogVals[i]);
   // Serial.print('\t');
  }
 /* Serial.println();
 Serial.print("compteur : ");
 Serial.print(compteur);
  Serial.print('\t');
  Serial.println();
  compteur = compteur+1; */
}
