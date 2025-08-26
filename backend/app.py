from flask import Flask, jsonify, Response
import threading
import time
import os
import cv2
from picamera2 import Picamera2
import atexit

app = Flask(__name__)

# --- Kamera ve Klasör Ayarları ---
VIDEO_DIR = "videos"
PHOTO_DIR = "photos"
os.makedirs(VIDEO_DIR, exist_ok=True)
os.makedirs(PHOTO_DIR, exist_ok=True)

picam2 = Picamera2()
config = picam2.create_preview_configuration(main={"size": (1280, 720)}, lores={"size": (640, 480)}, display="lores")
picam2.configure(config)
picam2.start()
time.sleep(2)

# --- Global Değişkenler ---
recording = False
video_writer = None
lock = threading.Lock()

# --- Canlı Yayın ---
def gen_frames():
    while True:
        frame = picam2.capture_array("lores")
        ret, buffer = cv2.imencode('.jpg', frame)
        if not ret:
            continue
        frame_bytes = buffer.tobytes()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

@app.route('/stream')
def stream():
    return Response(gen_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

# --- Fotoğraf Çekme ---
@app.route("/capture_photo")
def capture_photo():
    try:
        frame = picam2.capture_array("main")
        timestamp = int(time.time())
        filename = f"{PHOTO_DIR}/photo_{timestamp}.jpg"
        # OpenCV BGR formatında kaydeder, bu genellikle sorun olmaz.
        # Renklerin doğru olması isteniyorsa: frame = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
        cv2.imwrite(filename, frame)
        print(f"Fotoğraf kaydedildi: {filename}")
        return jsonify({"status": "ok", "file": filename, "timestamp": timestamp})
    except Exception as e:
        print(f"Fotoğraf çekilirken hata: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

# --- Video Kaydı ---
def record_video_thread():
    global video_writer
    while recording:
        frame = picam2.capture_array("main")
        video_writer.write(frame)

@app.route("/start_video")
def start_video():
    global recording, video_writer
    with lock:
        if recording:
            return jsonify({"status": "already recording"})
        timestamp = int(time.time())
        filename = f"{VIDEO_DIR}/video_{timestamp}.mp4"
        width, height = picam2.stream_configuration("main")["size"]
        fps = 20.0
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        video_writer = cv2.VideoWriter(filename, fourcc, fps, (width, height))
        recording = True
        thread = threading.Thread(target=record_video_thread, daemon=True)
        thread.start()
        print(f"Video kaydı başladı: {filename}")
        return jsonify({"status": "recording_started", "file": filename})

@app.route("/stop_video")
def stop_video():
    global recording, video_writer
    with lock:
        if not recording:
            return jsonify({"status": "not_recording"})
        recording = False
        if video_writer:
            video_writer.release()
            video_writer = None
        print("Video kaydı durduruldu.")
        return jsonify({"status": "recording_stopped"})

# --- Dosya Listeleme ---
@app.route("/get_media")
def get_media():
    try:
        videos = sorted(os.listdir(VIDEO_DIR), reverse=True)
        photos = sorted(os.listdir(PHOTO_DIR), reverse=True)
        return jsonify({"videos": videos, "photos": photos})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# --- Sunucuyu ve Kamerayı Düzgün Kapatma ---
def cleanup():
    print("Sunucu kapatılıyor, kamera durduruluyor...")
    if recording:
        video_writer.release()
    picam2.stop()
    print("Kamera durduruldu.")

atexit.register(cleanup)

if __name__ == "__main__":
    print("Sunucu http://0.0.0.0:5000 adresinde başlatılıyor..." )
    app.run(host="0.0.0.0", port=5000)
