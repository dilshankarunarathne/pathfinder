# PathFinder: Navigation Assistance with Real-Time Object Detection for Visually Impaired

## Introduction

This project proposes the development of a mobile application designed to provide navigation assistance to visually impaired individuals through real-time object detection. Leveraging computer vision and object recognition technology, the app aims to offer directional guidance and obstacle avoidance, helping users navigate their surroundings safely and independently.

## Project Goal

The primary goal is to develop a user-friendly and accessible mobile application that empowers visually impaired individuals by providing real-time object detection and navigation assistance. The app will offer audio descriptions of nearby objects and give directional guidance, enhancing safe and independent mobility.

## System Architecture
The system architecture for the Navigation Assistance with Real-Time Object Detection consists of a mobile application integrated with computer vision, GPS, and object detection technologies. The user's smartphone captures live video using the camera and processes it to detect objects in real-time. Simultaneously, GPS data can be used for outdoor navigation, and the app provides obstacle detection and navigation guidance using a combination of visual and spatial data. Recognized objects and directional cues are transmitted back to the mobile application, where text-to-speech functionality provides audio feedback to the user. This architecture ensures efficient real-time processing and delivers immediate and accurate navigation assistance.

  
![System Architecture](https://github.com/NadeeTharuka/pathfinder/blob/main/Blind%20app.drawio%20Light.png)

## Object Recognition Technologies

Real-time object detection is a critical component of navigation assistance systems for the visually impaired. Various AI techniques, such as deep learning and computer vision, are used to identify and classify objects in real-time. Convolutional Neural Networks (CNNs) are particularly effective in image recognition due to their ability to learn hierarchical features from images. For instance, the YOLO (You Only Look Once) algorithm has been widely adopted for its efficiency and accuracy in real-time object detection.

Mobile devices equipped with powerful processors, GPS, and cameras provide an accessible platform for these AI models. For example, the Seeing AI app by Microsoft uses AI to describe surroundings to visually impaired users (Microsoft, 2020). Additionally, systems like NAVI combine image processing with audio guidance to provide real-time obstacle detection and path guidance.

## Methodology

The methodology involves using the smartphone camera to capture live video, which is processed locally or on a server for object detection. The system uses deep learning models to detect and identify objects in the video stream. At the same time, GPS data is used to offer real-time navigation cues. A text-to-speech module generates audio descriptions for the user, along with verbal guidance to avoid obstacles or follow a path.

When the app is launched, the smartphone camera is activated to capture the user's surroundings. Real-time object detection is performed on the video frames, while GPS data enables the system to provide guidance in both indoor and outdoor environments. Text-to-speech functionality conveys this information to the user through earphones, providing them with a detailed awareness of their environment.

## Navigation Assistance Systems

Navigation assistance systems provide both obstacle detection and directional guidance to visually impaired users. These systems often integrate GPS for outdoor navigation and object detection for obstacle avoidance, ensuring comprehensive navigation support.

Smartphone-based systems use the device’s camera and sensors to detect obstacles and provide directional guidance through audio cues. The NAVI system, for example, employs image processing techniques to detect obstacles and uses audio cues to guide users around them. Combining object detection with GPS makes it possible to offer both indoor and outdoor navigation assistance.

## Key Functionalities

- Real-time Video Processing: The app captures and processes live video for real-time object detection and navigation assistance.

- Object Detection: Deep learning models are used to identify and classify objects in the environment.

- Audio Description Generation: The app provides audio feedback to the user, describing objects in the surroundings.

- Navigation Assistance: The app offers obstacle detection and path guidance, using GPS for outdoor navigation and computer vision for indoor     navigation.

## Usage

- Launch the application on your mobile device.

- Ensure the smartphone camera is activated and positioned for an optimal view of the environment.

- The app will begin capturing and processing live video for real-time object detection.

- Detected objects and navigation cues will be provided as audio descriptions through earphones.

- GPS will assist in providing directional guidance during outdoor navigation.

## Conclusion

The development of real-time object detection and navigation assistance systems using mobile applications holds great potential for improving the quality of life for visually impaired individuals. Advances in AI, computer vision, and mobile technology have made it possible to create solutions that offer real-time feedback and navigation guidance. Ongoing research and development will further improve the effectiveness and usability of these systems, ultimately providing more reliable and intuitive assistance to visually impaired users.


## Contributing
Contributions are welcome! Please read the contribution guidelines for more information.

## References

- Guerreiro, T., Eloy, S., Fernandes, H., Gonçalves, D., & Jorge, J. (2017). NAVI: An indoor navigation application for visually impaired people. ACM Transactions on Accessible Computing (TACCESS), 10(3), 1-25.
- Microsoft. (2020). Seeing AI. Retrieved from https://www.microsoft.com/en-us/ai/seeing-ai
- Mughal, M. A., Ali, S. A., & Mirza, H. T. (2018). NAVI: An intelligent indoor navigation system for elderly and visually impaired persons. Proceedings of the 2018 International Conference on Artificial Intelligence and Data Processing (IDAP), 1-5.
- Redmon, J., Divvala, S., Girshick, R., & Farhadi, A. (2016). You Only Look Once: Unified, real-time object detection. Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 779-788.