// Output
byte b_output;

// Joystick
int VRx = A0;
int VRy = A1;
int x_pos;
int y_pos;

// Ultrasonic
int trigPin = 12;
int echoPin = 11;
long duration;

void setup(){
	Serial.begin(115200);
	
	// Joystick
	pinMode(VRx,INPUT);
	pinMode(VRy,INPUT);
	
	// Ultrasonic
	pinMode(trigPin, OUTPUT);
	pinMode(echoPin, INPUT);
}
void loop(){
	b_output = 0x00;
	
	// Joystick
	x_pos = analogRead(VRx);
	y_pos = analogRead(VRy);
	if (x_pos > 900){ // stick up
		b_output |= 0x01;
	}
	if (x_pos < 100){ // stick down
		b_output |= 0x02;
	}
	if (y_pos > 900){ // stick right
		b_output |= 0x04;
	}
	if (y_pos < 100){ // stick left
		b_output |= 0x08;
	}

	// Ultrasonic
	digitalWrite(trigPin, LOW);
	delayMicroseconds(5);
	digitalWrite(trigPin, HIGH);
	delayMicroseconds(10);
	digitalWrite(trigPin, LOW);
	pinMode(echoPin, INPUT);
	duration = pulseIn(echoPin, HIGH);
	// mapto 0~15 and shift left 4
	if (duration < 3500) b_output |= (duration / 219) << 4;

	// Write to serial port
	Serial.write(b_output);
	
	delay(15);
}