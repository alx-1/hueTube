// standalone teensy code for HueTube project
// Copyright Maxime Damecour 05/2017 maxd@nnvtn.ca

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
int sum = 0;
int previousSum = 0;
int piezoIndex = 0;
#define WINDOW_SIZE 4

typedef struct {
	int input;
	int average;
	int past[WINDOW_SIZE];
	int delta;
} Piezo;

Piezo piezos[PIEZO_COUNT];

/////////////////////////////// pulses //////////////////////////////
#define POOL_SIZE 100

typedef struct {
	float life;
	float power;
	float start;
	float position;
	bool bounced;
	int colorIndex;
} Pulse;

Pulse pulses[POOL_SIZE];
#define DEBOUNCE 300
#define TIMEOUT 10000
uint16_t lastTrigger = 0;
/////////////////////////////// RenderOptions //////////////////////////////
#define FADE_VALUE 10
#define COLOR_COUNT 4
CRGB pallette[COLOR_COUNT] = {CRGB(255,30,30), CRGB(0,255,0), CRGB(10,10,255), CRGB(100,0,100)};
int colorIndex = 0;


/////////////////////////////// setup //////////////////////////////

void setup(){
	Serial.begin(115200);
	Serial1.begin(115200);
	// init LEDs
	FastLED.addLeds<WS2812, DATA_PIN1, RGB>(leds[0], NUM_LEDS_PER_STRIP);
	FastLED.addLeds<WS2812, DATA_PIN2, RGB>(leds[1], NUM_LEDS_PER_STRIP);
	for(int i = 0; i < NUM_LEDS_PER_STRIP; i++){
		leds[0][i] = CRGB(30,30,30);
		leds[1][i] = CRGB(30,30,30);
	}
	FastLED.show();
	delay(300);
	// init pulses
	for(int i = 0; i < POOL_SIZE; i++){
		pulses[i].life = -1.0;
	}
	// init piezos
	for(int i =0; i < PIEZO_COUNT; i++){
		initPiezo(&piezos[i]);
	}
}

/////////////////////////////// loop //////////////////////////////

void loop(){
	poll();
	// fade effect
	for(int i = 0; i < NUM_LEDS; i++){
		buffer[i] -= CRGB(FADE_VALUE, FADE_VALUE, FADE_VALUE);
	}
	// debug
	printPulses();
	// do pulses
	for(int i = 0; i < POOL_SIZE; i++){
		updatePulse(&pulses[i]);
		renderPulse(&pulses[i]);
	}
	// push LEDs
	if(millis() - lastTrigger > TIMEOUT) {
		standby();
	}
	show();
	delay(4);
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
		buffer[_index-1] += pallette[_pulse->colorIndex%COLOR_COUNT]/3.0;
		buffer[_index] +=  pallette[_pulse->colorIndex%COLOR_COUNT];
		buffer[_index+1] += pallette[_pulse->colorIndex%COLOR_COUNT]/3.0;
	}
}

void standby(){
	for(int i = 0; i < NUM_LEDS; i++){
		buffer[i] = CHSV(int(i*2+millis()/10.0)%255,255,255);
	}
}

/////////////////////////////// input //////////////////////////////

void poll(){
	int _sum = 0;
	// buffer into the piezo structs and make average
	for(int i = 0; i < PIEZO_COUNT; i++){
		 piezos[i].input = Serial1.read();
		_sum += piezos[i].input;
	}
	_sum /= PIEZO_COUNT;
	// check for event
	if(_sum > previousSum && millis()-lastTrigger > DEBOUNCE){
		lastTrigger = millis();
		for(int i = 0; i < PIEZO_COUNT; i++){
			updatePiezo(&piezos[i]);
		}
		piezoIndex++;
		piezoIndex %= WINDOW_SIZE;
		int _index = 0;
		int _high = 0;
		for(int i =0 ; i < PIEZO_COUNT; i++){
			if(piezos[i].delta > _high){
				_high = piezos[i].delta;
				_index = i;
			}
		}

		float _pos = _index/float(PIEZO_COUNT);
		float _pow = 0.2+_high/20.0;
		startPulse(_pos, _pos < 0.5 ? _pow : -_pow);
	}
	previousSum = _sum;

	// light map piezos
	// for(int i = 0; i < NUM_LEDS; i++){
	// 	buffer[i] += CRGB(average[i/6]*5);
	// }
	// show();
	Serial1.write('*');
}

void updatePiezo(Piezo* _piezo){
	_piezo->delta = _piezo->input - _piezo->average;
	_piezo->past[piezoIndex] = _piezo->input;
	_piezo->average = 0;
	for(int i = 0; i < WINDOW_SIZE; i++){
		_piezo->average += _piezo->past[i];
	}
}

void initPiezo(Piezo* _piezo){
	_piezo->input = 0;
	_piezo->average = 0;
	memset(_piezo->past, 0, sizeof(_piezo));
	_piezo->delta = 0;
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
	_pulse->colorIndex = colorIndex;//random(COLOR_COUNT);
	colorIndex++;
	// colorIndex %= COLOR_COUNT;
}



void updatePulse(Pulse* _pulse){
	if(_pulse->life >= 0){
		_pulse->position += _pulse->power/13.0;
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
