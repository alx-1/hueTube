// standalone teensy code for HueTube project
// Copyright Maxime Damecour 16/05/2017 maxd@nnvtn.ca

#include "FastLED.h"

#define NUM_LEDS 120
#define DATA_PIN 11
#define CLOCK_PIN 13
CRGB leds[NUM_LEDS];
#define COLOR_COUNT 4
CRGB pallette[COLOR_COUNT] = {CRGB(255,10,60), CRGB(0,100,4), CRGB(0,10,60), CRGB(10,10,10)};
int colorIndex = 0;
typedef struct {
	float life;
	float power;
	float start;
	float position;
	bool dir;
	// bool alive;
	CRGB color;
} Pulse;
#define POOL_SIZE  100
Pulse pulses[POOL_SIZE];


void setup(){
	Serial.begin(115200);
	// Serial1.begin(115200);
	// FastLED.addLeds<WS2812, DATA_PIN, CLOCK_PIN>(leds, NUM_LEDS);
	FastLED.addLeds<WS2812, DATA_PIN, GRB>(leds, NUM_LEDS);
	for(int i = 0; i < NUM_LEDS; i++){
		leds[i] = CRGB(30,0,0);
	}
	FastLED.show();
	for(int i = 0; i < POOL_SIZE; i++){
		pulses[i].life = -1.0;
	}
}

void loop(){
	for(int i = 0; i < NUM_LEDS; i++){
		leds[i] = CRGB(0,0,0);
	}
	FastLED.show();

	if(Serial.available()){
		Serial.read();Serial.read();Serial.read();
		startPulse(random(20)/20.0, 0.3);
	}

	printPulses();

	for(int i = 0; i < POOL_SIZE; i++){
		updatePulse(&pulses[i]);
		renderPulse(&pulses[i]);
	}
	FastLED.show();
	delay(10);

}

void renderPulse(Pulse* _pulse){
	if(_pulse->life >= 0){
		int _index = 1+_pulse->position*(NUM_LEDS-2);
		leds[_index-1] += _pulse->color/3.0;
		leds[_index] += _pulse->color;
		leds[_index+1] += _pulse->color/3.0;
	}
}

void startPulse(float _pos, float _power){
	int _lowIndex = 0;
	float _lowVal = 1.0;
	for(int i = 0; i < POOL_SIZE; i++){
		if(pulses[i].life < 0){
			setPulse(&pulses[i], _pos, _power);
			return;
		}
		else {
			if(pulses[i].life < _lowVal){
				_lowIndex = i;
				_lowVal = pulses[i].life;
			}
		}
	}
	setPulse(&pulses[_lowIndex], _pos, _power);
}

void setPulse(Pulse* _pulse, float _pos, float _power){
	// pulses[i].position = _pos;
	// pulsesp[i].power = _power;
	colorIndex++;
	colorIndex %= COLOR_COUNT;

	_pulse->position = _pos;
	_pulse->power = _power;
	_pulse->life = 1.0;
	_pulse-> color = pallette[colorIndex];
	Serial.print("new pulse ");
	Serial.print(_pulse->position);
	Serial.print(" ");
	Serial.println(_pulse->life);
}

void printPulses(){
	for(int i = 0; i < POOL_SIZE; i++){
		// Serial.println(pulses[i].life);
		if(pulses[i].life >= 0.0){
			printPulse(&pulses[i], i);
		}
	}
}

void printPulse(Pulse* _pulse, int _index){
	Serial.print("ind ");
	Serial.print(_index);
	Serial.print(" lif ");
	Serial.print(_pulse->life);
	Serial.print(" pow ");
	Serial.print(_pulse->power);
	Serial.print(" str ");
	Serial.print(_pulse->start);
	Serial.print(" pos ");
	Serial.print(_pulse->position);
	Serial.print(" dir ");
	Serial.print(_pulse->dir);
	Serial.println();
}

void updatePulse(Pulse* _pulse){
	if(_pulse->life >= 0){
		_pulse->position += _pulse->power/10.0;
		if(_pulse->position < 0.0){
			_pulse->position = 0.0;
			_pulse->power *= -1;
		}
		else if(_pulse->position > 1.0){
			_pulse->position = 1.0;
			_pulse->power *= -1;
		}
		_pulse->life -= 0.001;
		_pulse->power -= _pulse->power / 40.0;
		float _minSpeed = 0.02;
		if(_pulse->power < 0) _pulse->power = constrain(_pulse->power,-1.0, -_minSpeed);
		else _pulse->power = constrain(_pulse->power, _minSpeed, 1.0);

		// if(_pulse->life <= 0) _pulse->alive = false;
		// if(_pulse->dir) _pulse->alive = _pulse->position > _pulse->start;
		// else _pulse->alive = _pulse->position < _pulse->start;
	}
}
