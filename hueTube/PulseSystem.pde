
// 1D pulse system
class PulseSystem {
	ArrayList<Pulse> pulseArray;
	int incrementer = 0;

	public PulseSystem(){
		pulseArray = new ArrayList<Pulse>();
	}

	public void makePulse(float _pos, float _power, PulseRender _renderer){
		println("adding pulse at "+_pos+" "+_power);
		addPulse(_pos, _power, _renderer);
		addPulse(_pos, -_power, _renderer);
		incrementer++;
	}

	public void addPulse(float _pos, float _power, PulseRender _renderer){
		Pulse _newPulse = new Pulse(_pos, _power, _renderer);
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

	public ArrayList<Pulse> getPulses(){
		return pulseArray;
	}

}



class Pulse {
	float position;
	float power;
	float life;
	color pulseColor;
	PulseRender renderer;

	/**
	 *  @param float position, 0-1
	 *	@param float power, positive, or negative inertia
	 */
	public Pulse(float _pos, float _power, PulseRender _renderer){
		position = _pos;
		power = _power;
		life = 1.0;
		renderer = _renderer;
	}

	public void setColor(color _c){
		pulseColor = _c;
	}

	public void draw(PGraphics _pg){
		renderer.draw(_pg, this);
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

	public float getPositon(){
		return position;
	}
	public float getLife(){
		return life;
	}
	public float getPower(){
		return power;
	}
	public color getColor(){
		return pulseColor;
	}
}

class ReturnPulse extends Pulse {
	float startingPosition;
	boolean dir;
	public ReturnPulse(float _pos, float _power, PulseRender _renderer){
		super(_pos, _power, _renderer);
		startingPosition = _pos;
		dir = _power > 0.0;
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
		if(dir) return position < startingPosition;
		else return position > startingPosition;

		// if life is at zero reutrn true to remove
		// return life < 0.0;
	}
}
