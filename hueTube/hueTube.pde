import dmxP512.*;
import processing.serial.*;

DmxP512 dmxOutput;
int universeSize=512;
String DMXPRO_PORT="/dev/tty.usbserial-EN168786";
int DMXPRO_BAUDRATE=115200;

Serial myPort;  // Create object from Serial class

int chanDMX =  245; // pour le contrôleur maison de seb qui reçoit les valeurs de 256 à 400 
int valCouleur = 0;

String val; // data du port série
int[] piezos; // données une fois converties

void setup() {
   
  size(800, 600, JAVA2D);  
  
  dmxOutput=new DmxP512(this,universeSize,true); // dmxOutput=new DmxP512(this,universeSize,false); était false
  dmxOutput.setupDmxPro(DMXPRO_PORT,DMXPRO_BAUDRATE);
  
  String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 115200);
  
}

void draw() {    
 
  background(70,20,20);
  textSize(20); 
  doIt();

  if ( myPort.available() > 0) 
  {  // If data is available,
  val = myPort.readStringUntil('\n');         // read it and store it in val
  } 
  println(val); //print it out in the console
    if(val!=null){ // check si val est non null parce qu'on a un problème de synchro entre arduino et processing
    piezos = int(split(val, ' '));
 
   for(int i = 0;i<piezos.length-1;i++){
    
     fill(204, 100, 50);
     rect(width/10+i*60, height/4, 60, piezos[i]*4); // dessine un rectangle
     text(i, width/10+i*60+30, height/4);
     
     }
  }
}

void doIt(){
  
    chanDMX = chanDMX+3;
    valCouleur = valCouleur+10;
      for(int i = 256;i<404;i++){
        dmxOutput.set(i,0);}
        dmxOutput.set(chanDMX,valCouleur); // R
        dmxOutput.set(chanDMX+1,valCouleur-50); // V
        dmxOutput.set(chanDMX+2,valCouleur+50); // B
          if(chanDMX > 410){
          chanDMX = 250;
          valCouleur = 0;
          } 
    }