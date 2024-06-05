# PathFinder: Real-Time Object Recognition and Navigation Assistance for the Blind

## Introduction

This project proposes the development of a mobile application designed to leverage computer vision and object recognition technology. The app aims to provide blind users with real-time information about their surroundings, enhancing their ability to navigate safely and independently.

## Project Goal

The primary goal is to develop a user-friendly and accessible mobile application that empowers visually impaired individuals by providing real-time object recognition and navigation assistance. The app will offer audio descriptions of objects in the user's environment, aiding in safe and independent navigation.

![](https://github.com/NadeeTharuka/pathfinder/blob/main/Blind%20app.drawio%20Light.png)

## Object Recognition Technologies

Object recognition is a critical component of navigation assistance systems for the blind. Several studies have explored the use of various AI techniques, such as deep learning and computer vision, to identify and classify objects in real-time. Convolutional Neural Networks (CNNs) have been particularly successful in image recognition tasks due to their ability to learn hierarchical features from raw images. For instance, the YOLO (You Only Look Once) algorithm, a state-of-the-art CNN model, has been widely adopted for its efficiency and accuracy in real-time object detection (Redmon et al., 2016).

Mobile devices, equipped with powerful processors and cameras, provide an accessible platform for implementing these AI models. Researchers have developed mobile applications that leverage pre-trained models to recognize objects in the user's environment and provide auditory feedback. For example, the Seeing AI app by Microsoft uses AI to describe people, text, and objects to visually impaired users in real-time (Microsoft, 2020).

## Methodology

The methodology involves using the smartphone camera to capture live video, which is then streamed to a server. The server analyzes the image frames to detect objects and sends the results back to the mobile application. A text-to-speech module generates audio descriptions for the user.

The entire process operates seamlessly on the user's mobile device. When the app is launched, the smartphone camera is activated, allowing the user to position the phone for optimal camera view, such as in a front pocket. The real-time video is streamed to the server for object recognition and analysis. The server's results are transmitted back to the application, where text-to-speech functionality conveys the information to the user through earphones.

## Navigation Assistance Systems

Navigation assistance systems aim to provide directional guidance and obstacle avoidance to ensure safe movement for blind users. These systems typically integrate GPS for outdoor navigation and computer vision for indoor navigation. The combination of these technologies allows for comprehensive navigation support in various environments.

Several studies have proposed the use of smartphone-based systems that utilize the device's camera and sensors to detect obstacles and guide users. For instance, the NAVI (Navigation Assistance for Visually Impaired Individuals) system employs image processing techniques to detect obstacles and uses audio cues to direct users around them (Mughal et al., 2018). Additionally, researchers have explored the use of augmented reality (AR) to enhance navigation assistance by overlaying virtual guides onto the real-world environment viewed through the smartphone camera (Guerreiro et al., 2017).

## Key Functionalities

- Real-time Video Processing: The app captures and processes live video for object recognition.

- Object Recognition: Utilizing deep learning models, the app identifies objects within the video frames.

- Audio Description Generation: The app generates concise audio descriptions of identified objects using text-to-speech technology.

- Navigation Assistance: Future functionalities may include obstacle detection and path guidance to further aid in navigation.


## Usage

- Launch the application on your mobile device.

- Ensure the smartphone camera is activated and positioned for an optimal view.

- The app will begin capturing and processing live video.

- Detected objects will be identified, and audio descriptions will be generated and played through the earphones.

## Conclusion

The development of real-time object recognition and navigation assistance systems using mobile applications holds significant promise for improving the quality of life for visually impaired individuals. Advances in AI and mobile technology have enabled the creation of innovative solutions that offer real-time feedback and guidance. However, ongoing research and development are necessary to address the challenges and enhance the effectiveness and usability of these systems. By leveraging emerging technologies and user-centered design principles, future systems can provide more reliable and intuitive assistance to the blind community.


![]()


## Contributing
Contributions are welcome! Please read the contribution guidelines for more information.

## References

- Guerreiro, T., Eloy, S., Fernandes, H., Gonçalves, D., & Jorge, J. (2017). NAVI: An indoor navigation application for visually impaired people. ACM Transactions on Accessible Computing (TACCESS), 10(3), 1-25.
- Microsoft. (2020). Seeing AI. Retrieved from https://www.microsoft.com/en-us/ai/seeing-ai
- Mughal, M. A., Ali, S. A., & Mirza, H. T. (2018). NAVI: An intelligent indoor navigation system for elderly and visually impaired persons. Proceedings of the 2018 International Conference on Artificial Intelligence and Data Processing (IDAP), 1-5.
- Redmon, J., Divvala, S., Girshick, R., & Farhadi, A. (2016). You Only Look Once: Unified, real-time object detection. Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 779-788.