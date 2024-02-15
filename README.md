# iOS 4WD Rover ESP-32

<p align="center">
 <img alt="Languages" src="https://img.shields.io/badge/language-Python-yellow">
 <img alt="Languages" src="https://img.shields.io/badge/language-Swift-orange">
 <img alt="Version" src="https://img.shields.io/badge/Python->=3.6-yellow"/>
 <img alt="Version" src="https://img.shields.io/badge/Swift->=5.0-orange"/>
 <img alt="Version" src="https://img.shields.io/badge/version-2.0-blue"/>
  <img alt="Development" src="https://img.shields.io/badge/development-terminated-brightgreen"/>   
</p>

 iOS application for controlling a 4WD Rover powered by an ESP-32  microcontroller.
 Goal: The aim of this project was the remote control of a rover device powered by an ESP-32 microcontroller with a dedicated iOS application.
 The rover was equipped with 2 HCSR04 ultrasonic sensors, 2 infrared sensors, a battery slot and of course 4 dc motors and can be piloted in two different ways: 
 1) Manually
 The user via the iOS application can control the device by tapping on the screen or by using the iPhone built-in accelerometer and gyroscope (imagine playing Mario kart with a         Nintendo Wii and a Wii mote).
 2) "Automatically"
 The rover will move forwards until an obstacle is detected and then it will decide the best route to avoid the obstacle. An obstacle is detected with a combo of HCSR04 sensors and   infrared sensors.
 Of course the device can be stopped at any time with the iPhone application. 
 All data obtained from the sensors (presence of an obstacle and its distance) will be shown in the iOS app in real time.
 Both the ESP-32 microcontroller and the iOS device must be connected on the same wifi network in order to control the rover.
 Also a desktop python gui was built in order to control the device prior to the development of the iOS application (4WD Rover ESP32 Desktop client).
 
# Technical Information
- The python code for the microcontroller was developed under Zerynth studio, consequently it will not run properly under any other environment, you will have to register your microcontroller under zerynth studio and then run the code.
- Due to zerynth studio limitations a c library was included.
- The iOS application was specifically developed for an iPhone XR withouth using constraints in the GUI, therefore it may look a bit messy on other devices.
- A device running XCode is required in order to sideload the iOS application into a compatible iOS device.

