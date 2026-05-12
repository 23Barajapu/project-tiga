import cv2
import requests
import time
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
ESP32_IP = "192.168.137.202" 
stream_url = f"http://{ESP32_IP}/mjpeg" 

def koneksi_kamera():
    """Fungsi untuk inisialisasi ulang kamera dengan timeout FFMPEG"""
    c = cv2.VideoCapture(stream_url, cv2.CAP_FFMPEG)
    # Paksa timeout FFMPEG ke 5 detik (5000ms) agar tidak stuck selamanya
    c.set(cv2.CAP_PROP_OPEN_TIMEOUT_MSEC, 5000)
    c.set(cv2.CAP_PROP_BUFFERSIZE, 1)
    return c

cap = koneksi_kamera()

# --- 3. KONFIGURASI IP GATEWAY HOTSPOT ---
LAPTOP_IP = "192.168.137.1"
LARAVEL_URL = f"http://{LAPTOP_IP}:8000/api/nanas/status"
SERVO_URL = "http://nanas-servo.local/move" # Endpoint langsung ke ESP32 Servo

last_sent_status = None 
last_send_time = 0      
COOLDOWN_TIME = 7       # Durasi minimum antar trigger servo
pineapple_present = False # Status apakah nanas sedang berada di depan kamera
last_seen_time = 0      # Waktu terakhir nanas terdeteksi

def send_trigger(status, label):
    """Fungsi untuk mengirim trigger ke Servo dan Laravel secara cepat"""
    try:
        # 1. Trigger Servo (Prioritas Utama - Real-time)
        # Tingkatkan timeout ke 1.5s karena mDNS (.local) seringkali butuh waktu lebih lama
        print(f"[SERVO] Sending trigger to ESP32 ({label})...")
        requests.get(f"{SERVO_URL}?status={status}", timeout=1.5)
        print(f"[SERVO] Trigger Success")
    except Exception as e:
        print(f"[SERVO] Direct link timeout/error, fallback to DB polling...")

    try:
        # 2. Update Database (Untuk History di Flutter)
        requests.get(f"{LARAVEL_URL}?status={status}", timeout=1.0)
        print(f"[DB UPDATE] {label.upper()} Success")
    except Exception:
        print("[DB UPDATE] Laravel API Error")

def generate_frames():
    global last_sent_status, last_send_time, cap, pineapple_present, last_seen_time
    
    while True:
        # Kurangi jeda agar deteksi lebih responsif (10ms)
        time.sleep(0.01)
        
        success, img = cap.read()
        
        if not success:
            print("Kamera Terputus! Reconnecting...")
            cap.release() 
            time.sleep(2) 
            cap = koneksi_kamera() 
            continue

        frame = img.copy()

        # --- 5. DETEKSI AI ---
        results = model(frame, stream=True, conf=0.6, task='detect')
        detected_status = 0
        detected_label = ""

        for r in results:
            for box in r.boxes:
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                cls = int(box.cls[0])
                label = model.names[cls].lower()
                conf = round(float(box.conf[0]) * 100, 1)

                color = (0, 255, 0) if "matured" in label and "unmatured" not in label else (0, 0, 255)
                
                cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
                cv2.putText(frame, f"{label.upper()} {conf}%", (x1, y1 - 10), 
                            cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)

                if "matured" in label and "unmatured" not in label:
                    detected_status = 1 
                    detected_label = "matured"
                elif "unmatured" in label:
                    detected_status = 3 
                    detected_label = "unmatured"

        # --- 6. LOGIKA PENGIRIMAN (ANTI-REDUNDANT & FAST TRIGGER) ---
        current_time = time.time()
        
        if detected_status != 0:
            last_seen_time = current_time # Update waktu terakhir nanas terlihat
            
            # Jika ini nanas baru (belum ditandai present) dan sudah lewat cooldown
            if not pineapple_present and (current_time - last_send_time > COOLDOWN_TIME):
                import threading
                threading.Thread(target=send_trigger, args=(detected_status, detected_label), daemon=True).start()
                
                last_send_time = current_time
                pineapple_present = True # Tandai bahwa nanas ini sudah diproses
                print(f"--- NEW DETECTION: {detected_label.upper()} ---")
        else:
            # Jika tidak ada nanas yang terdeteksi
            # Berikan toleransi 1.5 detik "kosong" sebelum menganggap nanas sudah benar-benar lewat
            if pineapple_present and (current_time - last_seen_time > 1.5):
                pineapple_present = False
                print("--- SYSTEM READY FOR NEXT PINEAPPLE ---")

        # Visual Status
        is_paused = current_time - last_send_time < COOLDOWN_TIME
        if is_paused or pineapple_present:
            status_text = "SERVO BUSY" if is_paused else "OBJECT PRESENT"
            cv2.rectangle(frame, (15, 15), (200, 45), (0, 165, 255), -1)
            cv2.putText(frame, status_text, (25, 35), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)


        # --- 7. ENCODE FRAME (STABILIZER) ---
        # Kompresi ke 70% JPEG untuk meringankan beban transmisi ke Flutter
        ret, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 70])
        if not ret: 
            continue
            
        frame_bytes = buffer.tobytes()
        
        try:
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')
        except Exception:
            # Jika user tutup aplikasi Flutter, biarkan loop tetap jalan untuk scan selanjutnya
            continue

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == "__main__":
    print("--------------------------------------------------")
    print(f"Server AI: http://{LAPTOP_IP}:8888/video_feed")
    print("Sistem QC Nanas Running...")
    print("--------------------------------------------------")
    app.run(host='0.0.0.0', port=8888, threaded=True, debug=False)