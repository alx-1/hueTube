
// 1D pulse system

class PulseSystem {
	ArrayList<Pulse> pulseArray;
	PVector pointA;
	PVector pointB;
	int incrementer = 0;

	public PulseSystem(PVector _pointA , PVector _pointB){
		pulseArray = new ArrayList<Pulse>();
		pointA = _pointA;
		pointB = _pointB;
	}

	public void makePulse(float _pos, float _power){
		println("adding pulse at "+_pos+" "+_power);
		addPulse(_pos, _power);
		addPulse(_pos, -_power);
		incrementer++;
	}

	public void addPulse(float _pos, float _power){
		Pulse _newPulse = new Pulse(_pos, _power);
		switch(incrementer % 3){
			case 0:
				_newPulse.setColor(color(255,0,0));
				break;
			case 1:
				_newPulse.setColor(color(0,255,0));
				break;
			case 2:
				_newPulse.setColor(color(0,0,255));
				break;
		}
		pulseArray.add(_newPulse);
	}

	public void draw(PGraphics _pg){
		_pg.strokeWeight(3);
		if(pulseArray.size() > 0){
			for(Pulse _pulse : pulseArray){
				_pg.pushMatrix();
				_pg.translate(lerp(pointA.x, pointB.x, _pulse.getPositon()), pointA.y);
				_pulse.draw(_pg);
				_pg.popMatrix();
			}
		}
	}

	public void update(){
		ArrayList<Pulse> _removeList = new ArrayList<Pulse>();
		if(pulseArray.size() > 0){
			for(Pulse _pulse : pulseArray){
				if(_pulse.update()) _removeList.add(_pulse);
			}
		}
		if(_removeList.size() > 0){
			for(Pulse _pulse : _removeList){
				pulseArray.remove(_pulse);
			}
		}
	}

}



class Pulse {
	float position;
	float power;
	float life;
	color pulseColor;
	/**
	 *
	 *  @param float position, 0-1
	 *	@param float power, positive, or negative inertia
	 */
	public Pulse(float _pos, float _power){
		position = _pos;
		power = _power;
		life = 1.0;
	}
	public void setColor(color _c){
		pulseColor = _c;
	}

	public boolean update(){
		position += power;
		if(position < 0.0){
			position = 0.0;
			power *= -1;
		}
		else if(position > 1.0){
			position = 1.0;
			power *= -1;
		}
		life -= 0.01;
		power -= power / 100.0;

		// if life is at zero reutrn true to remove
		return life < 0.0;
	}

	public void draw(PGraphics _pg){
		float _width = 10.0;
		_pg.beginShape();
		_pg.stroke(0);
		_pg.vertex(-10.0, 0);
		_pg.stroke(lerpColor(color(0), pulseColor, life));
		_pg.vertex(0, 0);
		_pg.stroke(0);
		_pg.vertex(10.0, 0);
		_pg.endShape();
	}

	public float getPositon(){
		return position;
	}
}
