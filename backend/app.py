from flask import Flask, jsonify, Response
import threading
import time
import os
import cv2
from picamera2 import Picamera2

app = Flask(__name__)

# --- Kamera Ayarları ---
picam2 = Picamera2()
picam2.start()

recording = False
out = None

VIDEO_DIR = "videos"
PHOTO_DIR = "photos"
os.makedirs(VIDEO_DIR, exist_ok=True)
os.makedirs(PHOTO_DIR, exist_ok=True)

# --- Canlı yayın ---
def gen_frames():
    while True:
        frame = picam2.capture_array()
        ret, buffer = cv2.imencode('.jpg', frame)
        frame_bytes = buffer.tobytes()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

@app.route('/stream')
def stream():
    return Response(gen_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

# --- Fotoğraf çekme ---
@app.route("/capture_photo")
def capture_photo():
    frame = picam2.capture_array()
    filename = f"{PHOTO_DIR}/photo_{int(time.time())}.jpg"
    cv2.imwrite(filename, frame)
    return {"status": "ok", "file": filename}

# --- Video kaydı ---
def record_video(video_writer):
    global recording
    while recording:
        frame = picam2.capture_array()
        video_writer.write(frame)
        time.sleep(0.05)  # 20 FPS

@app.route("/start_video")
def start_video():
    global recording, out
    if not recording:
        frame_width = picam2.stream_configuration["main"]["size"][0]
        frame_height = picam2.stream_configuration["main"]["size"][1]
        filename = f"{VIDEO_DIR}/video_{int(time.time())}.mp4"
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(filename, fourcc, 20.0, (frame_width, frame_height))
        recording = True
        threading.Thread(target=record_video, args=(out,), daemon=True).start()
        return {"status": "recording", "file": filename}
    return {"status": "already recording"}

@app.route("/stop_video")
def stop_video():
    global recording, out
    if recording:
        recording = False
        out.release()
        return {"status": "stopped"}
    return {"status": "not recording"}

@app.route("/get_videos")
def get_videos():
    files = os.listdir(VIDEO_DIR)
    return jsonify(files)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
