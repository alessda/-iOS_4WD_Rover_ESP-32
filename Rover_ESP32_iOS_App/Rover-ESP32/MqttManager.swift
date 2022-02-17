//
//  MqttManager.swift
//  Rover-ESP32
//
//  Created by Alessandro D'Apice on 26/06/2020.
//  Copyright © 2020 Alessandro D'Apice. All rights reserved.
//

import Foundation
import CocoaMQTT


class MQTTManager {
    private var mqtt:CocoaMQTT?
    private var identifier:String!
    private var host:String!
    private var topics:[String]!
    private var controller:ViewController!
    private init() {}
    
    
    
    func setUpMQTT() {
        let clientID = "CocoaMQTT-\(identifier ?? "default")-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: host, port: 1883)
        mqtt!.username = nil
        mqtt!.password = nil
        mqtt!.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt!.keepAlive = 60
        mqtt!.delegate = self
    }
    
    // MARK: Shared Instance
    
    private static let _shared = MQTTManager()
    
    // MARK: - Accessors
    class func shared(with identifier:String, host:String, topics: [String]) -> MQTTManager {
        _shared.identifier = identifier
        _shared.host = host
        _shared.topics = topics
        _shared.setUpMQTT()
        return _shared
    }
    
    
    func connect( controller : ViewController){
        self.controller = controller
        mqtt?.connect()
     }
    func subscribe(){
        for index in 0...topics.count-1 {
            mqtt?.subscribe(topics[index], qos: .qos1)
        }
        print("4")
     }
    func publish(with message:String, topic:String){
         mqtt?.publish(topic, withString: message, qos: .qos1)
     }
}

extension MQTTManager: CocoaMQTTDelegate{
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) { //issue here
        for index in 0...topics.count-1 {
        TRACE("topic: \(topics[index])")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck){
        TRACE("ack: \(ack)")
        if ack == .accept {
            for index in 0...topics.count-1 {
                mqtt.subscribe(topics[index], qos: .qos1)
            }
            controller.statusLabel.text = "Connected"
        }
    }
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16){
        TRACE("message: \(message.string.description), id: \(id)")
    }
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16){
        TRACE("id: \(id)")
    }
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ){
        TRACE("message: \(message.string.description), id: \(id)")
        if message.topic == "dapis/rover/connectivity" {
            controller.deviceStatusLabel.text = message.string.description
        }
        if message.topic == "dapis/rover/distance/sens1" {
            controller.frontLabel.text = message.string.description
        }
        if message.topic == "dapis/rover/distance/sens2" {
            controller.backLabel.text = message.string.description
        }
        if message.topic == "dapis/rover/infrared/left" {
            controller.leftLabel.text =  message.string.description
        }
        if message.topic == "dapis/rover/infrared/right" {
            controller.rightLabel.text =  message.string.description
        }
        if message.topic == "dapis/rover/esp32" {
            if message.string.description == "on" {
                controller.onButtonOutlet.isUserInteractionEnabled = false
                controller.onButtonOutlet.setTitleColor(.systemGreen, for: .normal)
                controller.offButtonOutlet.isEnabled = true
                controller.offButtonOutlet.isUserInteractionEnabled = true
                controller.offButtonOutlet.setTitleColor(.systemBlue, for: .normal)
                controller.stopButtonOutlet.isUserInteractionEnabled = true
                controller.stopButtonOutlet.isEnabled = true
                controller.stopButtonOutlet.setTitleColor(.systemBlue, for: .normal)
                if controller.pickerView.selectedRow(inComponent: 0) == 0 {
                    controller.upArrowOutlet.isEnabled = true
                    controller.downArrowOutlet.isEnabled = true
                    controller.rightArrowOutlet.isEnabled = true
                    controller.leftArrowOutlet.isEnabled = true
                }
                if controller.pickerView.selectedRow(inComponent: 0) == 1 {
                    controller.upArrowOutlet.isEnabled = true
                    controller.downArrowOutlet.isEnabled = true
                    controller.rightArrowOutlet.isEnabled = false
                    controller.leftArrowOutlet.isEnabled = false
                }
                if controller.pickerView.selectedRow(inComponent: 0) == 2 {
                    controller.upArrowOutlet.isEnabled = false
                    controller.downArrowOutlet.isEnabled = false
                    controller.rightArrowOutlet.isEnabled = true
                    controller.leftArrowOutlet.isEnabled = true
                }
                if controller.pickerView.selectedRow(inComponent: 0) == 3 {
                    controller.upArrowOutlet.isEnabled = false
                    controller.downArrowOutlet.isEnabled = false
                    controller.rightArrowOutlet.isEnabled = false
                    controller.leftArrowOutlet.isEnabled = false
                }
            }
            if message.string.description == "stop" {
                controller.stopButtonOutlet.setTitleColor(.systemOrange, for: .normal)
                controller.stopButtonOutlet.isUserInteractionEnabled = false
                controller.offButtonOutlet.isEnabled = true
                controller.offButtonOutlet.isUserInteractionEnabled = true
                controller.offButtonOutlet.setTitleColor(.systemBlue, for: .normal)
                controller.onButtonOutlet.isUserInteractionEnabled = true
                controller.onButtonOutlet.setTitleColor(.systemBlue, for: .normal)
                controller.upArrowOutlet.isEnabled = false
                controller.downArrowOutlet.isEnabled = false
                controller.rightArrowOutlet.isEnabled = false
                controller.leftArrowOutlet.isEnabled = false
            }
            if message.string.description == "off" {
                controller.offButtonOutlet.isUserInteractionEnabled = false
                controller.offButtonOutlet.setTitleColor(.systemRed, for: .normal)
                controller.onButtonOutlet.isUserInteractionEnabled = true
                controller.onButtonOutlet.setTitleColor(.systemBlue, for: .normal)
                controller.stopButtonOutlet.isUserInteractionEnabled = true
                controller.stopButtonOutlet.setTitleColor(.systemBlue, for: .normal)
                controller.upArrowOutlet.isEnabled = false
                controller.downArrowOutlet.isEnabled = false
                controller.rightArrowOutlet.isEnabled = false
                controller.leftArrowOutlet.isEnabled = false
            }
        }
        
    }
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String){
        TRACE("topic: \(topic)")
    }
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String){
        TRACE("topic: \(topic)")
    }
    func mqttDidPing(_ mqtt: CocoaMQTT){
        TRACE()
    }
    func mqttDidReceivePong(_ mqtt: CocoaMQTT){
        TRACE()
    }
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?){
        TRACE("\(err.description)")
        controller.statusLabel.text = "Disconnected [\(err.description)]"
        controller.connectButtonOutlet.isEnabled = true
        controller.connectButtonOutlet.isUserInteractionEnabled = true
    }
    
}

extension MQTTManager{
    func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        if names.count == 1 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }
        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconect"
        }
        print("[TRACE] [\(prettyName)]: \(message)")
    }
}

extension Optional {
    // Unwarp optional value for printing log only
    var description: String {
        if let warped = self {
            return "\(warped)"
        }
        return ""
    }
}
