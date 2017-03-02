
public PVector vecLerp(PVector _a, PVector _b, float _f){
    return new PVector(lerp(_a.x, _b.x, _f), lerp(_a.y, _b.y, _f));
}

public void vecVert(PGraphics _pg, PVector _pv){
    _pg.vertex(_pv.x+2, _pv.y);
}

void vecLine(PGraphics _pg, PVector a, PVector b) {
    _pg.line(a.x,a.y,b.x,b.y);
}
