#include <WiFi.h>
#include <HTTPClient.h>
#include <ESP32Servo.h>
#include <ArduinoJson.h>
#include <WebServer.h>
#include <ESPmDNS.h>

const char* ssid = "aruuu";
const char* password = "alva123asd";
const String url = "http://192.168.137.1:8000/api/pineapple/latest";

Servo myservo;
int servoPin = 27;
int lastDataId = 0;

WebServer server(80);

void moveServo(String statusNanas) {
  Serial.println("[Servo] Moving for status: " + statusNanas);
  myservo.attach(servoPin, 500, 2400);

  if (statusNanas == "RIPE" || statusNanas == "1") {
    myservo.write(180);
    delay(450);
    myservo.write(90);
    delay(400);
  } else {
    myservo.write(0);
    delay(450);
    myservo.write(90);
    delay(400);
  }
  myservo.detach();
}

void handleMove() {
  if (server.hasArg("status")) {
    String status = server.arg("status");
    server.send(200, "text/plain", "OK");
    moveServo(status);
  } else {
    server.send(400, "text/plain", "Missing Status");
  }
}

void setup() {
  Serial.begin(115200);
  ESP32PWM::allocateTimer(1);
  myservo.setPeriodHertz(50);

  myservo.attach(servoPin, 500, 2400);
  myservo.write(90);
  delay(500);
  myservo.detach();

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(200);
    Serial.print(".");
  }
  Serial.println("\n[WiFi] Connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  if (MDNS.begin("nanas-servo")) {
    Serial.println("[mDNS] nanas-servo.local started");
  }

  server.on("/move", handleMove);
  server.begin();
}

void loop() {
  server.handleClient();

  // Polling tetap ada sebagai backup atau sinkronisasi awal
  static unsigned long lastPoll = 0;
  if (millis() - lastPoll > 2000) {  // Kurangi frekuensi polling ke 2 detik agar tidak berat
    lastPoll = millis();
    if (WiFi.status() == WL_CONNECTED) {
      HTTPClient http;
      http.setTimeout(500);
      http.begin(url);
      int httpCode = http.GET();
      if (httpCode == 200) {
        StaticJsonDocument<256> doc;
        deserializeJson(doc, http.getStream());
        int currentId = doc["id"];
        if (currentId > lastDataId) {
          lastDataId = currentId;
          moveServo(doc["status"]);
        }
      }
      http.end();
    }
  }
}