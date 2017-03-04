

class PulseRender{
	PVector pointA;
	PVector pointB;

	public PulseRender(PVector _pointA, PVector _pointB){
		pointA = _pointA;
		pointB = _pointB;
	}

	public void draw(PGraphics _pg, Pulse _pulse){
		_pg.pushMatrix();
		_pg.translate(lerp(pointA.x, pointB.x, _pulse.getPositon()), pointA.y);
		render(_pg, _pulse);
		_pg.popMatrix();
	}

	public void render(PGraphics _pg, Pulse _pulse){
		_pg.strokeWeight(3);
		float _width = 10.0;
		_pg.beginShape();
		_pg.stroke(0);
		_pg.vertex(-10.0, 0);
		_pg.stroke( _pulse.getColor() );
		// _pg.stroke(lerpColor(color(0), _pulse.getColor(), _pulse.getLife()));
		_pg.vertex(0, 0);
		_pg.stroke(0);
		_pg.vertex(10.0, 0);
		_pg.endShape();
	}
}

class LifeRender extends PulseRender{

	public LifeRender(PVector _pointA, PVector _pointB){
		super(_pointA, _pointB);
	}

	public void render(PGraphics _pg, Pulse _pulse){
		color _col = HSBtoRGB(1.0-_pulse.getLife(), 1.0, 1.0);
		float _life = _pulse.getLife();
		float _boost = lim((_life-0.8)*5.0);
		_col = lerpColor(_col, color(255), _boost);
		_pg.strokeWeight(3);
		float _width = 10.0+_boost*10.0;
		_pg.beginShape();
		_pg.stroke(0, _life * 255);
		_pg.vertex(-10.0, 0);
		_pg.stroke(lerpColor(color(0,0), _col, _life));
		_pg.vertex(0, 0);
		_pg.stroke(0, _life * 255);
		_pg.vertex(10.0, 0);
		_pg.endShape();
	}
}
