import dmxP512.*;
import processing.serial.*;

import oscP5.*;
import netP5.*;

Serial myPort;  // Create object from Serial class
OscP5 oscP5;
NetAddress myRemoteLocation;
ArrayList<OscMessage> buffer;

// dmx addresses, 0, 145, 192
// on controller 000000000   0001
//               101011010
//               000000000
//               000000000
final int PIEZO_COUNT = 20;
ValueSmoother[] smoothers;

DmxP512 dmxOutput;
int universeSize = 512;
String DMXPRO_PORT="/dev/ttyUSB0";
int DMXPRO_BAUDRATE=115200;

LEDStrip fixture;
byte[] dmxBuffer;
PGraphics ledGraphics;

PulseSystem pulseSystem;
PulseRender renderer;
boolean doFlash;

void setup() {
    buffer = new ArrayList<OscMessage>();
  size(800, 600, P2D);
  ledGraphics = createGraphics(width, height, P2D);
  ledGraphics.beginDraw();
  ledGraphics.background(0);
  ledGraphics.endDraw();

  dmxOutput = new DmxP512(this,universeSize,true); // dmxOutput=new DmxP512(this,universeSize,false); était false
  dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);

  myPort = new Serial(this, "/dev/ttyACM0", 115200);

  fixture = new LEDStrip(20, 60);
  fixture.addLEDs(119, 59);
  fixture.addLEDs(0,59);

  dmxBuffer = new byte[512];
  blackout();

  pulseSystem = new PulseSystem();
  renderer = new LifeRender(fixture.getPointA(), fixture.getPointB());

  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("10.0.1.43",12000);
  smoothers = new ValueSmoother[PIEZO_COUNT];
  for(int i = 0; i < PIEZO_COUNT; i++){
      smoothers[i] = new ValueSmoother();
  }
}

void draw() {
    // if(frameCount % 120 == 1) pulseSystem.makePulse(float(mouseX) / float(width), random(0.001, 0.02), renderer);
    background(170,20,20);
    textSize(20);
    text((int)frameRate, 20, 20);

    pulseSystem.update();
    doLEDGraphics();
    outputDMX();
    if(buffer.size() > 0){
        parseOSC(buffer.get(0));
        buffer.remove(0);
    }
    poll();
}



void poll(){
    myPort.write('*');
    String _tmp = "";
    while ( myPort.available() > 0){
        _tmp += myPort.read();         // read it and store it in _tmp
    }
    // {  // If data is available,

    // }
    // if(_tmp!=null){ // check si _tmp est non null parce qu'on a un problème de synchro entre arduino et processing
    String[] _buf = split(_tmp, ',');
    println(_buf);
    if(_buf.length >= PIEZO_COUNT){
        int _ind = 0;
        for(String _str : _buf){
            smoothers[_ind].set(float(_str));
            _ind++;
        }
    }
    // }
    pushMatrix();
    translate(10, height / 2);
    stroke(255);
    strokeWeight(4);
    for(ValueSmoother _v : smoothers){
        line(0,0,0,_v.getValue());
        translate(10,0);
    }
    popMatrix();
}


void mousePressed(){
    oscPulse(float(mouseX) / float(width), random(0.001, 0.02));
//    pulseSystem.makePulse(float(mouseX) / float(width), random(0.001, 0.02), renderer);
}

void oscPulse(float _pos, float _power){
    OscMessage myMessage = new OscMessage("/huetube/pulse");
    myMessage.add(_pos);
    myMessage.add(_power);
    oscP5.send(myMessage, myRemoteLocation);
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
    buffer.add(theOscMessage);
}

void parseOSC(OscMessage theOscMessage){
    if(theOscMessage.checkAddrPattern("/huetube/pulse")==true) {
      if(theOscMessage.checkTypetag("ff")) {
        pulseSystem.makePulse(theOscMessage.get(0).floatValue(), theOscMessage.get(1).floatValue()/10.0, renderer);
      }
    }
    doFlash = true;
}

void doLEDGraphics(){
    // init the grpahics buffer
    ledGraphics.beginDraw();
    ledGraphics.background(0,0);
    ledGraphics.fill(0, 30);
    ledGraphics.noStroke();
    // ledGraphics.rectMode()
    ledGraphics.blendMode(BLEND);
    ledGraphics.rect(0,0,width, height);

    fixture.draw(ledGraphics);
    // draw stuff
    ledGraphics.stroke(255,0,0);
    ledGraphics.strokeWeight(3);
    ledGraphics.point(mouseX, 60);

    // draw the pulses
    // RGBGradient();
    drawPulses();
    // end the drawing process on buffer
    ledGraphics.endDraw();
    image(ledGraphics, 0,0);

    // parse graphics buffer and ouptut DMX
    ledGraphics.loadPixels();
    fixture.parseGraphics(ledGraphics);
    fixture.bufferData(dmxBuffer);
}

void drawPulses(){
    ledGraphics.strokeCap(SQUARE);
    ledGraphics.blendMode(ADD);
    // vecLine(ledGraphics, fixture.getPointA(), fixture.getPointB());
    for(Pulse _pulse : pulseSystem.getPulses()){
        _pulse.draw(ledGraphics);
    }
    ledGraphics.blendMode(BLEND);
}

void blackout(){
    dmxOutput.set(3, (int)random(255));
    for(int i = 0; i < 512; i++){
        dmxOutput.set(i, 0);
    }
}

void outputDMX(){

    for(int i = 0; i < 511; i++){
        dmxOutput.set(i+1, doFlash ? 255 : (int)dmxBuffer[i]);
    }
    doFlash = false;
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
