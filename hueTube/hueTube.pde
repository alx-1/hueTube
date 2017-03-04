import dmxP512.*;

// dmx addresses, 0, 145, 192
// on controller 000000000   0001
//               101011010
//               000000000
//               000000000

DmxP512 dmxOutput;
int universeSize = 512;
String DMXPRO_PORT="/dev/ttyUSB0";
int DMXPRO_BAUDRATE=115200;

// piezo sensing
Arduino piezoDuino;
String ARDUINO_PORT = "/dev/ttyACM0";
int ARDUINO_BAUDRATE = 115200;
final int PIEZO_COUNT = 20;
ValueSmoother[] smoothers;

// led mapping
LEDStrip fixture;
byte[] dmxBuffer;
PGraphics ledGraphics;

// pulse system
PulseSystem pulseSystem;
PulseRender renderer;
boolean doFlash;
int SENSITIVITY = 10;
int STANDBY_TIME = 10000;
int timeout = 0;
boolean standby = false;

void setup() {
    size(800, 600, P2D);
    ledGraphics = createGraphics(width, height, P2D);
    ledGraphics.beginDraw();
    ledGraphics.background(0);
    ledGraphics.endDraw();

    piezoDuino = new Arduino(this);
    piezoDuino.connect(ARDUINO_PORT, ARDUINO_BAUDRATE);

    dmxOutput = new DmxP512(this,universeSize,true); // dmxOutput=new DmxP512(this,universeSize,false); était false
    dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);

    fixture = new LEDStrip(20, 60);
    fixture.addLEDs(119, 59);
    fixture.addLEDs(0,59);

    dmxBuffer = new byte[512];
    blackout();

    pulseSystem = new PulseSystem();
    renderer = new PulseRender(fixture.getPointA(), fixture.getPointB());

    smoothers = new ValueSmoother[PIEZO_COUNT];
    for(int i = 0; i < PIEZO_COUNT; i++){
        smoothers[i] = new ValueSmoother();
    }
}

void draw() {
    // if(frameCount % 120 == 1) pulseSystem.makePulse(float(mouseX) / float(width), random(0.001, 0.02), renderer);
    background(170,20,20);
    textSize(20);

    pulseSystem.update();
    doLEDGraphics();
    outputDMX();

    text((int)frameRate, 20, 20);

    if(frameCount % 4 == 1){
        poll();
        checkForPulse();
    }
    drawPiezo();
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Serial Stuff
///////
////////////////////////////////////////////////////////////////////////////////////
// poll piezos
void poll(){
    String[] _buf = split(piezoDuino.poll(), ',');
    if(_buf.length >= PIEZO_COUNT){
        int _ind = 0;
        for(String _str : _buf){
            smoothers[_ind].set(float(_str));
            _ind++;
            if(_ind >= 20) break;
        }
    }
}

// draw piezo data
void drawPiezo(){
    pushMatrix();
    translate(10, height / 2);
    stroke(255);
    strokeWeight(4);
    for(ValueSmoother _v : smoothers){
        if(_v.canUse()) stroke(255);
        else stroke(0,0,255);
        line(0,0,0,_v.getValue());
        translate(10,0);
    }
    popMatrix();
}

// determin if we send a pulse from piezo data
void checkForPulse(){
    float _highest = 0;
    float _pos = 0;
    ValueSmoother _chosen = null;
    for(int i = 0; i < PIEZO_COUNT; i++){
        if(smoothers[i].getValue() > _highest){
            _highest = smoothers[i].getValue();
            _pos = i;
            _chosen = smoothers[i];
        }
    }
    if(_highest > SENSITIVITY && _chosen != null){
        if(_chosen.canUse()){
            _chosen.use();
            pulseSystem.makePulse(_pos/20.0, _highest/1000.0, renderer);
            println(_pos/20.0+" "+_highest/1000.0);
            timeout = millis();
        }
    }
    if(millis() - timeout > STANDBY_TIME) standby = true;
    else standby = false;
}

void mousePressed(){
   pulseSystem.makePulse(float(mouseX) / float(width), random(0.001, 0.02), renderer);
}

void doLEDGraphics(){
    // init the grpahics buffer
    ledGraphics.beginDraw();
    // ledGraphics.background(0,0);
    ledGraphics.fill(0, 30);
    ledGraphics.noStroke();
    // ledGraphics.rectMode()
    ledGraphics.blendMode(BLEND);
    ledGraphics.rect(0,0,width, height);

    fixture.draw(ledGraphics);
    // draw stuff
    // ledGraphics.stroke(255,0,0);
    // ledGraphics.strokeWeight(3);
    // ledGraphics.point(mouseX, 60);

    // draw the pulses
    if(standby) RGBGradient();
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
