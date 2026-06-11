import os
import sys
import re


def update_file(filepath, pattern, replacement):
    if not os.path.exists(filepath):
        print(f"File {filepath} tidak ditemukan.")
        return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    new_content = re.sub(pattern, replacement, content)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Update: {filepath}")


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Penggunaan: python update_ip.py <LAPTOP_IP> <ESP_CAM_IP> <ESP_SERVO_IP>")
        print("Contoh: python update_ip.py 192.168.137.185 192.168.137.130 192.168.137.228")
        sys.exit(1)

    laptop_ip = sys.argv[1]
    esp_cam_ip = sys.argv[2]
    esp_servo_ip = sys.argv[3]

    print("Mengupdate IP address...")

    # 1. Update Flutter
    flutter_file = "mobile_flutter/lib/config/app_config.dart"
    update_file(
        flutter_file, r"static const String laptopIp = '[^']+';", f"static const String laptopIp = '{laptop_ip}';")
    update_file(
        flutter_file, r"static const String espCamIp = '[^']+';", f"static const String espCamIp = '{esp_cam_ip}';")
    update_file(
        flutter_file, r"static const String espServoIp = '[^']+';", f"static const String espServoIp = '{esp_servo_ip}';")

    # 2. Update Python AI
    ai_file = "ai-interface/main.py"
    update_file(
        ai_file, r'ESP32_IP\s*=\s*"[^"]+"', f'ESP32_IP = "{esp_cam_ip}"')
    update_file(
        ai_file, r'LAPTOP_IP\s*=\s*"[^"]+"', f'LAPTOP_IP = "{laptop_ip}"')
    update_file(
        ai_file, r'SERVO_ESP_IP\s*=\s*"[^"]+"', f'SERVO_ESP_IP = "{esp_servo_ip}"')

    # 3. Update ESP32 Servo
    servo_file = "esp32-code/index/index.ino"
    update_file(
        servo_file, r'const String url = "http://[^:]+:8000', f'const String url = "http://{laptop_ip}:8000')

    # 4. Update Laravel
    env_file = "backend-laravel/.env"
    with open(env_file, 'r', encoding='utf-8') as f:
        env_content = f.read()
    if 'SERVO_ESP_URL' in env_content:
        update_file(env_file, r'SERVO_ESP_URL=http://[^\s]+', f'SERVO_ESP_URL=http://{esp_servo_ip}')
    else:
        with open(env_file, 'a', encoding='utf-8') as f:
            f.write(f'\nSERVO_ESP_URL=http://{esp_servo_ip}\n')
        print(f"Update: {env_file}")

    print("\nSelesai! Semua IP berhasil diupdate.")
