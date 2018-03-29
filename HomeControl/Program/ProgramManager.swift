//
//  ProgramManager.swift
//  HomeControl
//
//  Created by Andreas Fertl on 10.02.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation

protocol ButtonPressed: class {
    func buttonPress(index: Int, on: Bool)
}

class ProgramManager : ButtonPressed {

    var tcpSocket: TCPSocket
    var connected: Bool
    
    init(receiver: ReceiveMsgDelegate) {
        tcpSocket = TCPSocket(receiver: receiver)
        connected = false
    }
    
    func buttonPress(index: Int, on: Bool) {
        
        var stateToChangeTo : LightState
        if (on == true) {
            stateToChangeTo = LightState.On
        } else {
            stateToChangeTo = LightState.Off
        }
        
        let lightMessage = LightMessage(Id: index, lightState: stateToChangeTo)
        let msg = Msg(destId: Destination.Subscribers, srcId: Destination.NotSet, remoteHandle: 0, command: Command.set, commandType: CommandType.LightControl, value: lightMessage)
        tcpSocket.sendMsg(msg: msg)
        
    }
    
    func GetButtonProtocol() -> ButtonPressed {
        return self
    }
    
    func Start() {
        if !connected {
            connected = true
            tcpSocket.setupNetworkCommunication(connectIp: "10.0.1.127", connectPort: 5005)
            
            //do a async request of configuration
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                //subscribe to several messages
                self.tcpSocket.sendJsonMsg(msgToSend: Msg.genSubscribeToJsonMsg(commandType: CommandType.TempMessage))
                self.tcpSocket.sendJsonMsg(msgToSend: Msg.genSubscribeToJsonMsg(commandType: CommandType.LightControl))
                
                //request configured sensors
                self.tcpSocket.sendMsg(msg: Msg(destId: Destination.ConfigurationManager, srcId: Destination.NotSet, remoteHandle: 0, command: Command.get, commandType: CommandType.ConfigurationMessage, value: ConfiguredMessageSensors()))
                
                //request configured lights
                self.tcpSocket.sendMsg(msg: Msg(destId: Destination.ConfigurationManager, srcId: Destination.NotSet, remoteHandle: 0, command: Command.get, commandType: CommandType.ConfigurationMessage, value: ConfiguredLights()))
            }
        }
    }
    
    func Stop() {
        if connected {
            tcpSocket.Stop()
            connected = false
        }
    }
}

