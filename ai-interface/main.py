import cv2
import requests
import time
import os
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
ESP32_IP = "192.168.137.182" 
stream_url = f"http://{ESP32_IP}/mjpeg" 

def koneksi_kamera():
    c = cv2.VideoCapture(stream_url, cv2.CAP_FFMPEG)
    c.set(cv2.CAP_PROP_OPEN_TIMEOUT_MSEC, 5000)
    c.set(cv2.CAP_PROP_BUFFERSIZE, 1)
    return c

cap = koneksi_kamera()

# --- 3. KONFIGURASI IP ---
LAPTOP_IP = "10.188.27.109"
LARAVEL_API_URL = f"http://{LAPTOP_IP}:8001/api/nanas/status"
# Endpoint baru di Laravel untuk upload foto
LARAVEL_UPLOAD_URL = f"http://{LAPTOP_IP}:8001/api/nanas/upload-foto" 
SERVO_URL = "http://nanas-servo.local/move"

COOLDOWN_TIME = 7       
pineapple_present = False 
last_send_time = 0      
last_seen_time = 0      

def send_trigger_with_photo(status, label, frame):
    """Mengirim status ke Servo dan upload foto ke Laravel"""
    # 1. Buat ID Unik berbasis waktu (Labeling)
    pineapple_id = f"PINE-{int(time.time())}"
    filename = f"{pineapple_id}.jpg"
    
    # Simpan sementara di lokal laptop (opsional)
    cv2.imwrite(filename, frame)

    # 2. Trigger Servo (Real-time)
    try:
        print(f"[SERVO] Triggering for {pineapple_id} ({label})...")
        requests.get(f"{SERVO_URL}?status={status}", timeout=1.5)
    except:
        print("[SERVO] Timeout - Fallback to DB")

    # 3. Upload Foto & Data ke Laravel
    try:
        with open(filename, 'rb') as f:
            files = {'image': (filename, f, 'image/jpeg')}
            data = {
                'status': status,
                'label': label,
                'pineapple_id': pineapple_id # ID unik untuk track nanas
            }
            response = requests.post(LARAVEL_UPLOAD_URL, files=files, data=data, timeout=3.0)
            if response.status_code == 200:
                print(f"[SUCCESS] {pineapple_id} uploaded to Database")
    except Exception as e:
        print(f"[DB ERROR] Gagal upload: {e}")
    
    # Hapus file lokal setelah diupload agar tidak penuh
    if os.path.exists(filename):
        os.remove(filename)

def generate_frames():
    global cap, pineapple_present, last_send_time, last_seen_time
    
    while True:
        time.sleep(0.01)
        success, img = cap.read()
        
        if not success:
            cap.release()
            time.sleep(2)
            cap = koneksi_kamera()
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

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8888, threaded=True, debug=False)