import cv2
import numpy as np
from fastapi import FastAPI, WebSocket, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from ultralytics import YOLO

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

model = YOLO("assets/yolov8n.pt")

classNames = ['person', 'bicycle', 'car', 'motorbike', 'aeroplane', 'bus', 'train', 'truck', 'boat', 'traffic light',
              'fire hydrant', 'stop sign', 'parking meter', 'bench', 'bird', 'cat', 'dog', 'horse', 'sheep', 'cow',
              'elephant', 'bear', 'zebra', 'giraffe', 'backpack', 'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee',
              'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat', 'baseball glove', 'skateboard', 'surfboard',
              'tennis racket', 'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple',
              'sandwich', 'orange', 'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake', 'chair', 'sofa',
              'pottedplant', 'bed', 'diningtable', 'toilet', 'tvmonitor', 'laptop', 'mouse', 'remote', 'keyboard',
              'cell phone', 'microwave', 'oven', 'toaster', 'sink', 'refrigerator', 'book', 'clock', 'vase', 'scissors',
              'teddy bear', 'hair drier', 'toothbrush']


@app.post("/predict")
async def predict_image(file: UploadFile = File(...)):
    contents = await file.read()
    np_arr = np.frombuffer(contents, np.uint8)
    frame = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

    cv2.imwrite("assets/image1.jpg", frame)

    if frame is None:
        raise ValueError("Failed to decode frame data")

    try:
        detection_output = model.predict(source=frame, conf=0.25)
        object_names = [classNames[int(detection[5])] for detection in detection_output]
        return {"objects": object_names}
    except Exception as e:
        return {"error": str(e)}


def start_stream_capture(frame_data):
    np_arr = np.frombuffer(frame_data, np.uint8)
    frame = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

    if frame is None:
        raise ValueError("Failed to decode frame data")

    try:
        detection_output = model.predict(source=frame, conf=0.25)
        object_names = [classNames[int(detection[5])] for detection in detection_output]
        return ', '.join(object_names)
    except Exception as e:
        return "No object detected"


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="localhost", port=8000)
