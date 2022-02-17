//
//  ViewController.swift
//  Rover-ESP32
//
//  Created by Alessandro D'Apice on 26/04/2020.
//  Copyright © 2020 Alessandro D'Apice. All rights reserved.
//

import UIKit
import CoreMotion



class ViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
//    label
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var frontLabel: UILabel!
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var deviceStatusLabel: UILabel!
    
//    Buttons
    @IBOutlet weak var onButtonOutlet: UIButton!
    @IBOutlet weak var stopButtonOutlet: UIButton!
    @IBOutlet weak var offButtonOutlet: UIButton!
    @IBOutlet weak var connectButtonOutlet: UIButton!
    @IBOutlet weak var upArrowOutlet: UIButton!
    @IBOutlet weak var downArrowOutlet: UIButton!
    @IBOutlet weak var leftArrowOutlet: UIButton!
    @IBOutlet weak var rightArrowOutlet: UIButton!
    

    @IBOutlet weak var pickerView: UIPickerView!
    private var pickerData: [String] = [String]()
    private var mqttManager:MQTTManager!
    private var broker = "broker.emqx.io" //"test.mosquitto.org"
    private var topics = ["dapis/rover/status/","dapis/rover/commands","dapis/rover/distance/sens1","dapis/rover/distance/sens2","dapis/rover/infrared/left","dapis/rover/infrared/right","dapis/rover/connectivity","dapis/rover/esp32","dapis/rover/esp32/mode","dapis/rover/esp32/toggle"]
    private var motion = CMMotionManager()
    
    
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           // Dispose of any resources that can be recreated.
       }

//    UIPickerView functions
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    
    override func viewDidLoad() { // Do any additional setup after loading the view.
        super.viewDidLoad()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        pickerData=["manual","automatic L/R","automatic F/B","self"] // pickerview elements
        connectButtonOutlet.isEnabled = true
        onButtonOutlet.isEnabled = false
        stopButtonOutlet.isEnabled = false
        offButtonOutlet.isEnabled = false
        upArrowOutlet.isEnabled = false
        downArrowOutlet.isEnabled = false
        rightArrowOutlet.isEnabled = false
        leftArrowOutlet.isEnabled = false
//      quick tap and long press gestures
        let upTapGesture = UITapGestureRecognizer(target: self, action: #selector (upTap))  //Tap function will call when user tap on button
        let downTapGesture = UITapGestureRecognizer(target: self, action: #selector (downTap))
        let leftTapGesture = UITapGestureRecognizer(target: self, action: #selector (leftTap))
        let rightTapGesture = UITapGestureRecognizer(target: self, action: #selector (rightTap))
        let upLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(upLong))  //Long function will call when user long press on button.
        let downLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(downLong))
        let leftLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(leftLong))
        let rightLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(rightLong))
        upArrowOutlet.addGestureRecognizer(upTapGesture)
        upArrowOutlet.addGestureRecognizer(upLongGesture)
        downArrowOutlet.addGestureRecognizer(downTapGesture)
        downArrowOutlet.addGestureRecognizer(downLongGesture)
        leftArrowOutlet.addGestureRecognizer(leftTapGesture)
        leftArrowOutlet.addGestureRecognizer(leftLongGesture)
        rightArrowOutlet.addGestureRecognizer(rightTapGesture)
        rightArrowOutlet.addGestureRecognizer(rightLongGesture)
    }


    @IBAction func connectButton(_ sender: UIButton) {
        mqttManager = MQTTManager.shared(with: "iPhone_Rover_ESP32", host: broker, topics: topics)
        mqttManager.connect(controller: self)
        connectButtonOutlet.isEnabled = false
        onButtonOutlet.isEnabled = true
        stopButtonOutlet.isEnabled = true
    }
    
    
    @IBAction func onButton(_ sender: UIButton) {
        if statusLabel.text == "Connected" {
            if deviceStatusLabel.text == "Device connected" {
            mqttManager.publish(with: "on", topic: topics[0])
            onButtonOutlet.isUserInteractionEnabled = false
            onButtonOutlet.setTitleColor(.systemGreen, for: .normal)
            offButtonOutlet.isEnabled = true
            offButtonOutlet.isUserInteractionEnabled = true
            offButtonOutlet.setTitleColor(.systemBlue, for: .normal)
            stopButtonOutlet.isUserInteractionEnabled = true
            stopButtonOutlet.isEnabled = true
            stopButtonOutlet.setTitleColor(.systemBlue, for: .normal)
            let selectedValue = pickerView.selectedRow(inComponent: 0)
            if (selectedValue == 0) {
                mqttManager.publish(with: "manual", topic: topics[1])
                upArrowOutlet.isEnabled = true
                downArrowOutlet.isEnabled = true
                rightArrowOutlet.isEnabled = true
                leftArrowOutlet.isEnabled = true
            }
            if (selectedValue == 1) {
                mqttManager.publish(with: "automatic L/R", topic: topics[1])
                upArrowOutlet.isEnabled = true
                downArrowOutlet.isEnabled = true
                rightArrowOutlet.isEnabled = false
                leftArrowOutlet.isEnabled = false
                roverMotion(mqttManager: mqttManager)
            }
            if (selectedValue == 2) {
                mqttManager.publish(with: "automatic F/B", topic: topics[1])
                upArrowOutlet.isEnabled = false
                downArrowOutlet.isEnabled = false
                rightArrowOutlet.isEnabled = true
                leftArrowOutlet.isEnabled = true
                roverMotion(mqttManager: mqttManager)
            }
            if (selectedValue == 3) {
                mqttManager.publish(with: "self", topic: topics[1])
                upArrowOutlet.isEnabled = false
                downArrowOutlet.isEnabled = false
                rightArrowOutlet.isEnabled = false
                leftArrowOutlet.isEnabled = false
                }
            } else {
                let alert = UIAlertController(title: "ESP-32 ERROR", message: "ESP-32 based device not connected\n Wait or restart the app", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
                let alert = UIAlertController(title: "Connectivity issues", message: "Wait a little bit or restart the app", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        if statusLabel.text == "Connected" {
            if deviceStatusLabel.text == "Device connected" {
            mqttManager.publish(with: "stop", topic: topics[0])
            stopButtonOutlet.setTitleColor(.systemOrange, for: .normal)
            stopButtonOutlet.isUserInteractionEnabled = false
            offButtonOutlet.isEnabled = true
            offButtonOutlet.isUserInteractionEnabled = true
            offButtonOutlet.setTitleColor(.systemBlue, for: .normal)
            onButtonOutlet.isUserInteractionEnabled = true
            onButtonOutlet.setTitleColor(.systemBlue, for: .normal)
            upArrowOutlet.isEnabled = false
            downArrowOutlet.isEnabled = false
            rightArrowOutlet.isEnabled = false
            leftArrowOutlet.isEnabled = false
            } else {
                let alert = UIAlertController(title: "ESP-32 ERROR", message: "ESP-32 based device not connected\n Wait or restart the app", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Connectivity issues", message: "Wait a little bit or restart the app", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func offButton(_ sender: UIButton) {
        mqttManager.publish(with: "off", topic: topics[0])
        offButtonOutlet.isUserInteractionEnabled = false
        offButtonOutlet.setTitleColor(.systemRed, for: .normal)
        onButtonOutlet.isUserInteractionEnabled = true
        onButtonOutlet.setTitleColor(.systemBlue, for: .normal)
        stopButtonOutlet.isUserInteractionEnabled = true
        stopButtonOutlet.setTitleColor(.systemBlue, for: .normal)
        upArrowOutlet.isEnabled = false
        downArrowOutlet.isEnabled = false
        rightArrowOutlet.isEnabled = false
        leftArrowOutlet.isEnabled = false
    }
    
    
    @objc func upTap(_ sender: UIGestureRecognizer) {
        mqttManager.publish(with: "short", topic: topics[9])
        mqttManager.publish(with: "go", topic: topics[1])
    }

    @objc func upLong(_ sender: UIGestureRecognizer) {
        mqttManager.publish(with: "long", topic: topics[9])
        mqttManager.publish(with: "go", topic: topics[1])
        if sender.state == .ended || sender.state == .cancelled {
            mqttManager.publish(with: "stop", topic: topics[1])
        }
    }

    @objc func downTap(_ sender: UIGestureRecognizer) {
        mqttManager.publish(with: "short", topic: topics[9])
        mqttManager.publish(with: "back", topic: topics[1])
    }
    
    @objc func downLong(_ sender: UIGestureRecognizer) {
        mqttManager.publish(with: "long", topic: topics[9])
        mqttManager.publish(with: "back", topic: topics[1])
        if sender.state == .ended || sender.state == .cancelled {
            mqttManager.publish(with: "stop", topic: topics[1])
        }
    }
    
    @objc func leftTap(_ sender: UIGestureRecognizer) {
        mqttManager.publish(with: "short", topic: topics[9])
        mqttManager.publish(with: "left", topic: topics[1])
    }
    
    @objc func leftLong(_ sender: UIGestureRecognizer) {
        mqttManager.publish(with: "long", topic: topics[9])
        mqttManager.publish(with: "left", topic: topics[1])
        if sender.state == .ended || sender.state == .cancelled {
            mqttManager.publish(with: "stop", topic: topics[1])
        }
    }
    
    @objc func rightTap(_ sender: UIGestureRecognizer) {
        mqttManager.publish(with: "short", topic: topics[9])
        mqttManager.publish(with: "right", topic: topics[1])
    }
    
    @objc func rightLong(_ sender: UIGestureRecognizer) {
        mqttManager.publish(with: "long", topic: topics[9])
        mqttManager.publish(with: "right", topic: topics[1])
        if sender.state == .ended || sender.state == .cancelled {
            mqttManager.publish(with: "stop", topic: topics[1])
        }
    }
    

    func myDeviceLocations(){
        print("Start DeviceLocations")
        motion.gyroUpdateInterval = 0.5
        motion.startGyroUpdates(to: OperationQueue.current!) {
            (data, error) in
            print(data as Any)
            if let trueData =  data {
                print("Latitude: \(trueData.rotationRate.x)")
                print("Longitude: \(trueData.rotationRate.y)")
//                self.view.reloadInputViews()
            }
        }
        return
    }
    

    
    func roverMotion( mqttManager : MQTTManager!) {
        print("Automatic Mode")
        motion.deviceMotionUpdateInterval  = 0.5
        motion.startDeviceMotionUpdates(to: OperationQueue.current!) {
        (data, error) in
        print(data as Any)
            if let trueData =  data {
                let x = trueData.attitude.pitch // x cordinate
                let y = trueData.attitude.roll // y cordinate
                _ = trueData.attitude.yaw // z cordinate
                let selectedMode = self.pickerView.selectedRow(inComponent: 0)
                if selectedMode == 1 {
                    if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                        if x <= -0.3  {
                            mqttManager.publish(with: "left", topic: "dapis/rover/commands/automatic")
                        }
                        else if x >= 0.1 {
                            mqttManager.publish(with: "right", topic: "dapis/rover/commands/automatic")
                        }
                        else {
                            mqttManager.publish(with: "stop", topic: "dapis/rover/commands/automatic")
                        }
                    }
                    if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                        if x >= 0.2 {
                            mqttManager.publish(with: "left", topic: "dapis/rover/commands/automatic")
                        }
                        else if x <= -0.2 {
                             mqttManager.publish(with: "right", topic: "dapis/rover/commands/automatic")
                        }
                        else {
                            mqttManager.publish(with: "stop", topic: "dapis/rover/commands/automatic")
                        }
                    }
                }
                if selectedMode == 2 {
                    if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                        if y <= 0.8 {
                            mqttManager.publish(with: "forward", topic: "dapis/rover/commands/automatic")
                        }
                        else if y > 1.7 {
                            mqttManager.publish(with: "backward", topic: "dapis/rover/commands/automatic")
                        }
                        else {
                            mqttManager.publish(with: "no F/B", topic: "dapis/rover/commands/automatic")
                        }
                    }
                    if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                        if y > -0.7 {
                            mqttManager.publish(with: "forward", topic: "dapis/rover/commands/automatic")
                        }
                        else if y <= -1.4 {
                             mqttManager.publish(with: "backward", topic: "dapis/rover/commands/automatic")
                        }
                        else {
                            mqttManager.publish(with: "no F/B", topic: "dapis/rover/commands/automatic")
                        }
                    }
                }
            }
        }
        return
    }
    
    func myDeviceMotion(){
        print("Start DeviceMotion")
        motion.deviceMotionUpdateInterval  = 0.5
        motion.startDeviceMotionUpdates(to: OperationQueue.current!) {
            (data, error) in
            print(data as Any)
            if let trueData =  data {
                print("x (pitch): \(trueData.attitude.pitch)")
                print("y (roll): \(trueData.attitude.roll)")
                print("z (yaw): \(trueData.attitude.yaw)")
            }
        }
        return
    }

    
    func myGyroscope(){
        print("Start Gyroscope")
        motion.gyroUpdateInterval = 0.5
        motion.startGyroUpdates(to: OperationQueue.current!) {
            (data, error) in
            print(data as Any)
            if let trueData =  data {
                print("x: \(trueData.rotationRate.x)")
                print("y: \(trueData.rotationRate.y)")
                print("z: \(trueData.rotationRate.z)")
            }
        }
        return
    }
    
    
    func myAccelerometer() {
        print("Start Accelerometer")
        motion.accelerometerUpdateInterval = 0.5
        motion.startAccelerometerUpdates(to: OperationQueue.current!) {
            (data, error) in
            print(data as Any)
            if let trueData =  data {
                print("x: \(trueData.acceleration.x)")
                print("y: \(trueData.acceleration.y)")
                print("z: \(trueData.acceleration.z)")
            }
        }

        return
    }
    
    
}


