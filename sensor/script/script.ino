#include "Ultrasonic.h";

int pinoTrigger = 13;
int pinoEcho = 12;

HC_SR04 sensor(pinoTrigger, pinoEcho);

void setup() {
  Serial.begin(9600);
}

void loop() {
  float distancia = sensor.distance();

  if (distancia >= 15 && distancia <= 100) {
    Serial.println("1");
  } else {
    Serial.println("0");
  }

  delay(5000);
}