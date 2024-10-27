import cv
import cv2
import numpy as np
from ultralytics import YOLO
import supervision as sv

from static.distances import KNOWN_WIDTHS, FOCAL_LENGTH

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


def calculate_distance(actual_width, object_width_in_image, focal_length):
    # Estimate the distance
    distance = (actual_width * focal_length) / object_width_in_image
    return distance


def start_stream_capture1(frame_data):
    model = YOLO("assets/yolov8n.pt")

    # Decode the frame data
    frame = cv2.imdecode(np.frombuffer(frame_data, np.uint8), cv2.IMREAD_COLOR)

    # Ensure the frame is correctly passed to the model
    results = model(frame)

    object_names = []
    print(object_names)

    pred = model(frame, augment=False)[0]
    print(pred)

    # Loop through the results
    for r in results:
        boxes = r.boxes  # Identifying boxes

        for box in boxes:
            # Bounding box
            x1, y1, x2, y2 = box.xyxy[0]
            x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)  # Convert to int values

            # Width of object in the image (in pixels)
            object_width_in_image = x2 - x1

            cls = int(box.cls[0])  # Identifying class name

            # Get the known width of the object class
            known_width = KNOWN_WIDTHS.get(classNames[cls], None)

            if known_width is not None:
                # Estimate the distance
                distance = calculate_distance(known_width, object_width_in_image, FOCAL_LENGTH)
                object_names.append(f"{classNames[cls]}: {distance} inches away")
            else:
                object_names.append(classNames[cls])

    return ', '.join(object_names)