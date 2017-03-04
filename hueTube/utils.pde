
public PVector vecLerp(PVector _a, PVector _b, float _f){
    return new PVector(lerp(_a.x, _b.x, _f), lerp(_a.y, _b.y, _f));
}

public void vecVert(PGraphics _pg, PVector _pv){
    _pg.vertex(_pv.x+2, _pv.y);
}

void vecLine(PGraphics _pg, PVector a, PVector b) {
    _pg.line(a.x,a.y,b.x,b.y);
}

color alphaMod(color  _c, int _alpha){
  	return color(red(_c), green(_c), blue(_c), _alpha);
}

color HSBtoRGB(float _h, float _s, float _b){
  	return java.awt.Color.HSBtoRGB(_h, _s, _b);
}

float lim(float _f){
    return constrain(_f, 0.0, 1.0);
}
