from ultralytics import YOLO  #import the model

import cv2
import math 

cap = cv2.VideoCapture(0) # start webcam
cap.set(3, 640) # set the size
cap.set(4, 480) # set the size

model = YOLO("yolo-Weights/yolov8n.pt") # load model

# define object classes
classNames = ["person", "bicycle", "car", "motorbike", "aeroplane", "bus", "train", "truck", "boat",
              "traffic light", "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat",
              "dog", "horse", "sheep", "cow", "elephant", "bear", "zebra", "giraffe", "backpack", "umbrella",
              "handbag", "tie", "suitcase", "frisbee", "skis", "snowboard", "sports ball", "kite", "baseball bat",
              "baseball glove", "skateboard", "surfboard", "tennis racket", "bottle", "wine glass", "cup",
              "fork", "knife", "spoon", "bowl", "banana", "apple", "sandwich", "orange", "broccoli",
              "carrot", "hot dog", "pizza", "donut", "cake", "chair", "sofa", "pottedplant", "bed",
              "diningtable", "toilet", "tvmonitor", "laptop", "mouse", "remote", "keyboard", "cell phone",
              "microwave", "oven", "toaster", "sink", "refrigerator", "book", "clock", "vase", "scissors",
              "teddy bear", "hair drier", "toothbrush"]

while True:
    success, img = cap.read() # read image data
    results = model(img, stream=True)  # pass the image frame to the model

    # looping through coordinates
    for r in results:
        boxes = r.boxes # identifying boxes

        for box in boxes:
            # bounding box
            x1, y1, x2, y2 = box.xyxy[0]
            x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2) # convert to int values

            cv2.rectangle(img, (x1, y1), (x2, y2), (255, 0, 255), 3) # put box in cam

            confidence = math.ceil((box.conf[0]*100))/100 # calculating confidence score
            print("Confidence --->",confidence)

            cls = int(box.cls[0]) # identifying class name
            print("Class name -->", classNames[cls])

            # object details
            org = [x1, y1]
            font = cv2.FONT_HERSHEY_SIMPLEX
            fontScale = 1
            color = (255, 0, 0)
            thickness = 2

            cv2.putText(img, classNames[cls], org, font, fontScale, color, thickness) # printing label over the bounding box

    cv2.imshow('Webcam', img) # display the image
    if cv2.waitKey(1) == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
