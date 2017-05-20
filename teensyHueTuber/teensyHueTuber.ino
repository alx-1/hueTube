// standalone teensy code for HueTube project
// Copyright Maxime Damecour 16/05/2017 maxd@nnvtn.ca

#include "FastLED.h"

/////////////////////////////// LEDs //////////////////////////////
#define NUM_LEDS_PER_STRIP 60
#define NUM_STRIPS 2
#define NUM_LEDS NUM_LEDS_PER_STRIP * NUM_STRIPS
#define DATA_PIN1 11
#define DATA_PIN2 13
CRGB leds[NUM_STRIPS][NUM_LEDS];
CRGB buffer[NUM_LEDS];

/////////////////////////////// input //////////////////////////////
#define PIEZO_COUNT 20
int piezos[PIEZO_COUNT];
int sum = 0;
int previousSum = 0;
#define OFFSET_WINDOW 4
int offset[OFFSET_WINDOW][PIEZO_COUNT];
int average[PIEZO_COUNT];
int offsetIndex = 0;
//
// typedef struct {
//
// } Piezo;


/////////////////////////////// pulses //////////////////////////////

typedef struct {
	float life;
	float power;
	float start;
	float position;
	bool bounced;
	// bool dir;
	// bool alive;
	CRGB color;
} Pulse;
#define POOL_SIZE  100
Pulse pulses[POOL_SIZE];


/////////////////////////////// RenderOptions //////////////////////////////
#define FADE_VALUE 10
#define COLOR_COUNT 4
CRGB pallette[COLOR_COUNT] = {CRGB(255,30,30), CRGB(0,255,0), CRGB(10,10,255), CRGB(100,0,100)};
int colorIndex = 0;


/////////////////////////////// setup //////////////////////////////

void setup(){
	Serial.begin(115200);
	Serial1.begin(115200);
	// FastLED.addLeds<WS2812, DATA_PIN, CLOCK_PIN>(leds, NUM_LEDS);
	FastLED.addLeds<WS2812, DATA_PIN1, GRB>(leds[0], NUM_LEDS_PER_STRIP);
	FastLED.addLeds<WS2812, DATA_PIN2, GRB>(leds[1], NUM_LEDS_PER_STRIP);

	for(int i = 0; i < NUM_LEDS_PER_STRIP; i++){
		leds[0][i] = CRGB(30,0,0);
		leds[1][i] = CRGB(30,0,0);
	}
	FastLED.show();
	for(int i = 0; i < POOL_SIZE; i++){
		pulses[i].life = -1.0;
	}
	memset(piezos, 0, sizeof(piezos));
	memset(offset, 0, sizeof(offset));
	memset(average, 0, sizeof(average));

}

/////////////////////////////// loop //////////////////////////////

void loop(){
	poll();
	// fade effect
	for(int i = 0; i < NUM_LEDS; i++){
		buffer[i] -= CRGB(FADE_VALUE, FADE_VALUE, FADE_VALUE);
	}
	// manual trigger
	// if(Serial.available()){
	// 	Serial.read();Serial.read();Serial.read();
	// 	float pos = 0.5 + ((random(4)-2.0)/10.0);
	// 	float power = 0.3;
	// 	startPulse(pos, pos < 0.5 ? power : -power);
	// 	// startPulse(pos, -power);
	// }
	// debug
	printPulses();
	// do pulses
	for(int i = 0; i < POOL_SIZE; i++){
		updatePulse(&pulses[i]);
		renderPulse(&pulses[i]);
	}
	// push LEDs
	show();
	delay(15);
}

/////////////////////////////// LED stuff //////////////////////////////

void show(){
	for(int i = 0; i < NUM_LEDS_PER_STRIP; i++){
		leds[0][i] = buffer[NUM_LEDS_PER_STRIP - i];
		leds[1][i] = buffer[NUM_LEDS_PER_STRIP+i];
	}
	FastLED.show();
}

void renderPulse(Pulse* _pulse){
	if(_pulse->life >= 0){
		int _index = 1+_pulse->position*(NUM_LEDS-2);
		buffer[_index-1] += _pulse->color/3.0;
		buffer[_index] += _pulse->color;
		buffer[_index+1] += _pulse->color/3.0;
	}
}

/////////////////////////////// input //////////////////////////////

void poll(){
	sum = 0;
	for(int i = 0; i < PIEZO_COUNT; i++){
		piezos[i] = Serial1.read();
		sum += piezos[i];
		// Serial.println(piezos[i]);
	}
	sum /= PIEZO_COUNT;
	if(sum > previousSum){
		// Serial.println(sum - previousSum);
		for(int i = 0; i < PIEZO_COUNT; i++){
			offset[offsetIndex][i] = piezos[i];
			offsetIndex++;
			offsetIndex %= OFFSET_WINDOW;
		}
		for(int j = 0; j < PIEZO_COUNT; j++){
			average[j] = 0;
			for(int i = 0; i < OFFSET_WINDOW; i++){
				average[j] += offset[i][j];
			}
			average[j] /= OFFSET_WINDOW;

			Serial.print(average[j]);
			Serial.print(" ");
		}
		Serial.println();
		// launch
		for(int i = 0; i < PIEZO_COUNT; i++){
			if(piezos[i] > average[i]+1 ){
				float _pos = i/float(PIEZO_COUNT);
				float _pow = 0.3;
				startPulse(_pos, _pos < 0.5 ? _pow : -_pow);
			}
		}

	}
	previousSum = sum;

	// light map piezos
	// for(int i = 0; i < NUM_LEDS; i++){
	// 	buffer[i] += CRGB(average[i/6]*5);
	// }
	// show();
	Serial1.write('*');
}


/////////////////////////////// Pulses //////////////////////////////

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
	_pulse->position = _pos;
	_pulse->start = _pos;
	_pulse->power = _power;
	_pulse->life = 1.0;
	_pulse->bounced = false;
	_pulse-> color = pallette[colorIndex];
	colorIndex++;
	colorIndex %= COLOR_COUNT;
}



void updatePulse(Pulse* _pulse){
	if(_pulse->life >= 0){
		_pulse->position += _pulse->power/10.0;
		if(_pulse->position < 0.0){
			_pulse->position = 0.0;
			_pulse->power *= -1;
			_pulse->bounced = true;
		}
		else if(_pulse->position > 1.0){
			_pulse->position = 1.0;
			_pulse->power *= -1;
			_pulse->bounced = true;
		}
		_pulse->life -= 0.001;
		if( _pulse->bounced){
			if(abs(_pulse->position - _pulse->start) < 0.01){
				_pulse->life = -0.1;
			}
		}
		_pulse->power -= _pulse->power / 80.0;
		float _minSpeed = 0.02;
		if(_pulse->power < 0) _pulse->power = constrain(_pulse->power,-1.0, -_minSpeed);
		else _pulse->power = constrain(_pulse->power, _minSpeed, 1.0);

		// if(_pulse->life <= 0) _pulse->alive = false;
		// if(_pulse->dir) _pulse->alive = _pulse->position > _pulse->start;
		// else _pulse->alive = _pulse->position < _pulse->start;
	}
}

void printPulses(){
	for(int i = 0; i < POOL_SIZE; i++){
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
	// Serial.print(" dir ");
	// Serial.print(_pulse->dir);
	Serial.println();
}
