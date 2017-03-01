

class LEDFixture {
    final int PIXEL_SPACING = 3;
    int posX;
    int posY;

    ArrayList<LEDPixel> ledPixels;
    color fixtureColor;
    float unitInterval;

    public LEDFixture(int _x, int _y){
        posX = _x;
        posY = _y;
        ledPixels = new ArrayList<LEDPixel>();
    }
    public void draw(PGraphics _pg){

    }
    public void addLEDs(int _start, int _end){

    }

    public void bufferData(byte[] _buf){
        for(LEDPixel _p : ledPixels){
            _p.bufferData(_buf);
        }
    }

    public void parseGraphics(PGraphics _pg){
        for(LEDPixel _p : ledPixels){
            _p.parseGraphics(_pg);
        }
    }

    public ArrayList<LEDPixel> getPixels(){
        return ledPixels;
    }
    public void setColor(color _c){
        fixtureColor = _c;
    }
    public void setUnit(float _f){
        unitInterval = _f;
    }
}

class LEDStrip extends LEDFixture {
    PVector pointA;
    PVector pointB;
    boolean direction;
    public LEDStrip(int _x, int _y){
        super(_x, _y);
        pointA = new PVector(0,0);
        pointB = new PVector(0,0);
    }

    public void addLEDs(int _start, int _end){
        int _xStart = posX;
        int _yStart = posY;
        if(ledPixels.size() != 0){
            _xStart = ledPixels.get(ledPixels.size() - 1).xPos;
            _yStart = ledPixels.get(ledPixels.size() - 1).yPos;
        }
        if(_end > _start){
            direction = true;
            for(int i = 0; i <= _end - _start; i++){
                ledPixels.add(new LEDPixel(_start + i, _xStart + i * PIXEL_SPACING, _yStart));
            }
        }
        else {
            direction = false;
            for(int i = _start - _end; i >= 0; i--){
                ledPixels.add(new LEDPixel(_end + i, _xStart + i * PIXEL_SPACING, _yStart));
            }
        }
        pointA.set(ledPixels.get(0).xPos, ledPixels.get(0).yPos);
        pointB.set(ledPixels.get(ledPixels.size()-1).xPos, ledPixels.get(ledPixels.size()-1).yPos);
        // pointA.y -= 10;
        // pointB.y += 10;
    }

    public void draw(PGraphics _pg){
        _pg.rectMode(CORNER);
        _pg.stroke(255);
        _pg.strokeWeight(1);
        _pg.noFill();
        _pg.rect(pointA.x-4, pointA.y-4, pointB.x - pointA.x + 8,  pointB.y - pointA.y + 8);
        // draw a point on one led at a time for testing
        // int ha = 0;
        // for(LEDPixel _p : ledPixels){
        //     if(ha == (millis()/100)%(48*3)) _pg.point(_p.xPos, _p.yPos);
        //     ha++;
        // }
    }
    public PVector getPointA(){
        return pointA;
    }
    public PVector getPointB(){
        return pointB;
    }
}


/**
 * A RGB pixel to be mapped
 *
 */
class LEDPixel {
    // its address
    int address;
    // x-y coordinates
    int xPos;
    int yPos;
    // color
    int red;
    int green;
    int blue;
    color col;

    public LEDPixel(int _adr, int _x, int _y){
        address = _adr;
        xPos = _x;
        yPos = _y;
        // println("LED "+_adr+" "+_x+" "+_y);
    }
    public void parseGraphics(PGraphics _pg){
        int adr = yPos * width + xPos;
        if(adr < width * height) setColor(_pg.pixels[adr]);
    }

    // RGBFixture specific
    public void setColor(color _c){
      col = _c;
      red = (col >> 16) & 0xFF;
      green = (col >> 8) & 0xFF;
      blue = col & 0xFF;
    }
    public color getColor(){
        return col;
    }
    // buffer the data into a byte buffer
    public void bufferData(byte[] _buffer){
        int _adr = address*3;
        if(_adr < _buffer.length-2){
            _buffer[_adr] = byte(red);
            _buffer[_adr+1] = byte(green);
            _buffer[_adr+2] = byte(blue);
        }
    }
}
