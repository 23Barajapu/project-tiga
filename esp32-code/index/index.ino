#include <WiFi.h>
#include <HTTPClient.h>
#include <ESP32Servo.h>
#include <ArduinoJson.h>
#include <WebServer.h>
#include <ESPmDNS.h>

const char* ssid = "aruuu";
const char* password = "alva123asd";
const String url = "http://192.168.137.123:8001/api/pineapple/latest";

Servo myservo;
int servoPin = 26;
int lastDataId = 0;
bool baselineSynced = false;

WebServer server(80);

bool isRipeStatus(const String& statusNanas) {
  return statusNanas == "RIPE" || statusNanas == "HALF_RIPE" ||
         statusNanas == "1" || statusNanas == "2";
}

void moveServo(String statusNanas) {
  statusNanas.trim();
  Serial.println("[Servo] Moving for status: " + statusNanas);
  myservo.attach(servoPin);

  if (isRipeStatus(statusNanas)) {
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
  Serial.println("[Servo] Done.");
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

void pollLaravelForServo() {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  http.setTimeout(5000);
  http.begin(url);
  int httpCode = http.GET();

  if (httpCode != 200) {
    Serial.printf("[Poll] HTTP error: %d\n", httpCode);
    http.end();
    return;
  }

  String payload = http.getString();
  http.end();

  StaticJsonDocument<512> doc;
  DeserializationError err = deserializeJson(doc, payload);
  if (err) {
    Serial.print("[Poll] JSON error: ");
    Serial.println(err.c_str());
    return;
  }

  int currentId = doc["id"] | 0;
  String status = doc["status"] | "UNKNOWN";

  if (currentId == 0) return;

  if (!baselineSynced) {
    lastDataId = currentId;
    baselineSynced = true;
    Serial.printf("[Poll] Baseline ID=%d (tidak gerak)\n", lastDataId);
    return;
  }

  if (currentId > lastDataId) {
    lastDataId = currentId;
    Serial.printf("[Poll] Data baru ID=%d status=%s\n", currentId, status.c_str());
    moveServo(status);
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
  Serial.print("[WiFi] IP Address: ");
  Serial.println(WiFi.localIP());
  Serial.println(">>> Salin IP ini ke SERVO_ESP_IP di main.py <<<");

  if (MDNS.begin("nanas-servo")) {
    Serial.println("[mDNS] http://nanas-servo.local/move");
  }

  server.on("/move", handleMove);
  server.begin();
  Serial.println("[HTTP] GET /move?status=1 atau 3");
}

void loop() {
  server.handleClient();

  // [DIMATIKAN] Polling otomatis dinonaktifkan.
  // ESP32 sekarang HANYA bergerak jika menerima request langsung ke /move?status=X
  // dari Laravel (via PineappleController::triggerServo()).
  // Polling dua jalur inilah yang menyebabkan servo bergerak DUA KALI.
  //
  // static unsigned long lastPoll = 0;
  // if (millis() - lastPoll > 1500) {
  //   lastPoll = millis();
  //   pollLaravelForServo();
  // }
}
