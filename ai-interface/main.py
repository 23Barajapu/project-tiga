import os
os.environ["OPENCV_FFMPEG_LOGLEVEL"] = "-8"
import cv2
import requests
import time
import threading
from ultralytics import YOLO
from flask import Flask, Response

app = Flask(__name__)

# --- 1. SETUP MODEL YOLOv11 ---
try:
    model = YOLO("best.pt") 
    print("--------------------------------------------------")
    print("AI Model Loaded Successfully!")
except Exception as e:
    print(f"ERROR: Model gagal dimuat! ({e})")
    exit()

# --- 2. SETUP STREAM ESP32-CAM ---
ESP32_IP = "192.168.137.130"
stream_url = f"http://{ESP32_IP}/mjpeg"

class CameraStream:
    def __init__(self):
        self.stream_url = stream_url
        self.cap = cv2.VideoCapture(self.stream_url, cv2.CAP_FFMPEG)
        self.cap.set(cv2.CAP_PROP_OPEN_TIMEOUT_MSEC, 5000)
        self.cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
        self.frame = None
        self.running = True
        self.thread = threading.Thread(target=self.update, daemon=True)
        self.thread.start()

    def update(self):
        while self.running:
            try:
                success, img = self.cap.read()
                if success and img is not None:
                    self.frame = img
                else:
                    raise Exception("Frame kosong")
            except Exception as e:
                print(f"[CAMERA ERROR] Koneksi kamera bermasalah: {e}")
                try:
                    self.cap.release()
                except:
                    pass
                time.sleep(2)
                self.cap = cv2.VideoCapture(self.stream_url, cv2.CAP_FFMPEG)
                self.cap.set(cv2.CAP_PROP_OPEN_TIMEOUT_MSEC, 5000)
                self.cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
            time.sleep(0.005)

    def read(self):
        return self.frame

    def release(self):
        self.running = False
        try:
            self.cap.release()
        except:
            pass

camera_stream = CameraStream()

# --- 3. KONFIGURASI IP ---
LAPTOP_IP = "192.168.137.185"
SERVO_ESP_IP = "192.168.137.228"
LARAVEL_API_URL = f"http://{LAPTOP_IP}:8001/api/nanas/status"
LARAVEL_UPLOAD_URL = f"http://{LAPTOP_IP}:8001/api/nanas/upload-foto"

COOLDOWN_TIME = 7
pineapple_present = False
last_send_time = 0
last_seen_time = 0

def trigger_servo(status):
    """Panggil ESP32 servo langsung via IP (mDNS sering gagal di Windows)."""
    status_str = str(status)
    urls = [
        f"http://{SERVO_ESP_IP}/move?status={status_str}",
        f"http://nanas-servo.local/move?status={status_str}",
    ]
    for url in urls:
        try:
            print(f"[SERVO] Trigger {url} ...")
            res = requests.get(url, timeout=10.0)
            if res.status_code == 200:
                print(f"[SERVO] OK — servo bergerak")
                return True
            print(f"[SERVO] HTTP {res.status_code} dari {url}")
        except Exception as e:
            print(f"[SERVO] Gagal {url}: {e}")
    print("[SERVO] Semua URL gagal — cek SERVO_ESP_IP & WiFi ESP servo")
    return False


def send_trigger_with_photo(status, label, frame):
    """Mengirim status ke Servo dan upload foto ke Laravel"""
    pineapple_id = f"PINE-{int(time.time())}"
    filename = f"{pineapple_id}.jpg"
    
    cv2.imwrite(filename, frame)

    # 1. Upload dulu ke DB (backup polling ESP membaca id baru)
    try:
        with open(filename, 'rb') as f:
            files = {'image': (filename, f, 'image/jpeg')}
            data = {
                'status': status,
                'label': label,
                'pineapple_id': pineapple_id # ID unik untuk track nanas
            }
            response = requests.post(LARAVEL_UPLOAD_URL, files=files, data=data, timeout=10.0)
            if response.status_code == 200:
                print(f"[SUCCESS] {pineapple_id} uploaded to Database")
    except Exception as e:
        print(f"[DB ERROR] Gagal upload: {e}")

    # 2. Servo dikendalikan oleh Laravel (uploadFoto memanggil triggerServo).
    # Tidak perlu trigger servo di sini agar tidak bergerak dua kali.
    

    if os.path.exists(filename):
        os.remove(filename)

def generate_frames():
    global camera_stream, pineapple_present, last_send_time, last_seen_time
    
    while True:
        time.sleep(0.01)
        img = camera_stream.read()
        if img is None:
            continue

        frame = img.copy()
        results = model(frame, stream=True, conf=0.6, task='detect')
        
        detected_status = 0
        detected_label = ""

        for r in results:
            for box in r.boxes:
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                cls = int(box.cls[0])
                label = model.names[cls].lower()
                
                color = (0, 255, 0) if "matured" in label and "unmatured" not in label else (0, 0, 255)
                cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)

                if "matured" in label and "unmatured" not in label:
                    detected_status = 1 
                    detected_label = "matured"
                elif "unmatured" in label:
                    detected_status = 3 
                    detected_label = "unmatured"

        current_time = time.time()
        
        if detected_status != 0:
            last_seen_time = current_time
            if not pineapple_present and (current_time - last_send_time > COOLDOWN_TIME):
                # Gunakan snapshot frame asli (img) agar tidak ada kotak hijaunya di foto database
                import threading
                threading.Thread(target=send_trigger_with_photo, 
                                 args=(detected_status, detected_label, img), 
                                 daemon=True).start()
                
                last_send_time = current_time
                pineapple_present = True
        else:
            if pineapple_present and (current_time - last_seen_time > 1.5):
                pineapple_present = False

        # Encode untuk stream Flask
        ret, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 70])
        yield (b'--frame\r\nContent-Type: image/jpeg\r\n\r\n' + buffer.tobytes() + b'\r\n')

@app.route('/')
def index():
  return (
    '<!DOCTYPE html><html><head><meta charset="utf-8">'
    '<title>SPQC AI Stream</title></head>'
    '<body style="margin:0;background:#111;color:#0f0;text-align:center;font-family:sans-serif">'
    '<h1>SPQC AI — Live Feed</h1>'
    '<p>ESP-CAM: ' + ESP32_IP + ' | Backend: ' + LAPTOP_IP + ':8001</p>'
    '<img src="/video_feed" style="max-width:100%;border:3px solid #0f0;border-radius:8px">'
    '</body></html>'
  )


@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8888, threaded=True, debug=False)
    