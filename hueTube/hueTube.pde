import dmxP512.*;
import processing.serial.*;

// dmx addresses, 0, 145, 192
// on controller 000000000   0001
//               101011010
//               000000000
//               000000000

DmxP512 dmxOutput;
int universeSize = 512;
String DMXPRO_PORT="/dev/ttyUSB0";
int DMXPRO_BAUDRATE=115200;

Serial myPort;  // Create object from Serial class

int chanDMX =  245; // pour le contrôleur maison de seb qui reçoit les valeurs de 256 à 400
int valCouleur = 0;

String val; // data du port série
int[] piezos; // données une fois converties

LEDStrip fixture;
byte[] dmxBuffer;
PGraphics ledGraphics;

PulseSystem pulseSystem;
PulseRender renderer;

void setup() {

  size(800, 600, P2D);
  ledGraphics = createGraphics(width, height, P2D);

  dmxOutput = new DmxP512(this,universeSize,true); // dmxOutput=new DmxP512(this,universeSize,false); était false
  dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);

  fixture = new LEDStrip(20, 60);
  fixture.addLEDs(119, 59);
  fixture.addLEDs(0,59);

  dmxBuffer = new byte[512];
  blackout();

  pulseSystem = new PulseSystem();
  renderer = new LifeRender(fixture.getPointA(), fixture.getPointB());
  //
  // String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
  // myPort = new Serial(this, portName, 115200);
}

void draw() {

  background(170,20,20);
  textSize(20);
  text((int)frameRate, 20, 20);

  pulseSystem.update();
  doLEDGraphics();
  outputDMX();
  //
  // if ( myPort.available() > 0)
  // {  // If data is available,
  // val = myPort.readStringUntil('\n');         // read it and store it in val
  // }
  // println(val); //print it out in the console
  //   if(val!=null){ // check si val est non null parce qu'on a un problème de synchro entre arduino et processing
  //   piezos = int(split(val, ' '));
  //
  //  for(int i = 0;i<piezos.length-1;i++){
  //
  //    fill(204, 100, 50);
  //    rect(width/10+i*60, height/4, 60, piezos[i]*4); // dessine un rectangle
  //    text(i, width/10+i*60+30, height/4);
  //
  //    }
  // }
}

void mousePressed(){
    pulseSystem.makePulse(float(mouseX) / float(width), random(0.001, 0.02), renderer);
}

void doLEDGraphics(){
    // init the grpahics buffer
    ledGraphics.beginDraw();
    ledGraphics.background(0,0);
    fixture.draw(ledGraphics);
    // draw stuff
    // RGBGradient();
    ledGraphics.stroke(255,0,0);
    ledGraphics.strokeWeight(3);
    ledGraphics.point(mouseX, 60);

    ledGraphics.strokeCap(SQUARE);
    ledGraphics.blendMode(ADD);
    // vecLine(ledGraphics, fixture.getPointA(), fixture.getPointB());
    for(Pulse _pulse : pulseSystem.getPulses()){
        _pulse.draw(ledGraphics);
    }
    // end the drawing process on buffer
    ledGraphics.endDraw();
    image(ledGraphics, 0,0);

    // parse graphics buffer and ouptut DMX
    ledGraphics.loadPixels();
    fixture.parseGraphics(ledGraphics);
    fixture.bufferData(dmxBuffer);
}

void drawPulses(){

}

void blackout(){
    dmxOutput.set(3, (int)random(255));
    for(int i = 0; i < 512; i++){
        dmxOutput.set(i, 0);
    }
}

void outputDMX(){
    for(int i = 0; i < 511; i++){
        dmxOutput.set(i+1, (int)dmxBuffer[i]);
    }
}

void RGBGradient(){
    // ledGraphics.blendMode(ADD);
    ledGraphics.ellipse(mouseX, mouseY, 20,20);
    ledGraphics.strokeWeight(7);
    ledGraphics.beginShape(LINES);

    ledGraphics.stroke(255,0,0);
    vecVert(ledGraphics, fixture.getPointA());

    ledGraphics.stroke(0,255,0);
    vecVert(ledGraphics, vecLerp(fixture.getPointA() , fixture.getPointB(), 0.5));
    vecVert(ledGraphics, vecLerp(fixture.getPointA() , fixture.getPointB(), 0.5));

    ledGraphics.stroke(0,0,255);
    vecVert(ledGraphics, fixture.getPointB());
    ledGraphics.endShape();
}

void bounce(){
    PVector _pos = vecLerp(fixture.getPointA(), fixture.getPointB(), pow(sin((millis()/1000.0)), 2) );
    ledGraphics.noStroke();
    ledGraphics.fill(0);
    ledGraphics.rect(_pos.x-5, _pos.y-5, 10,10);
}
