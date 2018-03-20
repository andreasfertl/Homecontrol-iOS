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
    
    init(receiver: ReceiveMsgDelegate) {
        tcpSocket = TCPSocket(receiver: receiver)
        tcpSocket.setupNetworkCommunication(connectIp: "10.0.1.127", connectPort: 5005)
        
        
        //subscribe to data
        let msg = Msg(destId: Destination.Server, srcId: Destination.NotSet, remoteHandle: 0, command: Command.set, commandType: CommandType.Subscribe, value: CommandType.MandolynSensor)
        
        do {
            let jsonSubscribeMsg = try JSONEncoder().encode(msg)
            let jsonString = String(data: jsonSubscribeMsg, encoding: .utf8)
            if jsonString != nil{
                tcpSocket.write(stringToSend: jsonString! + "\r\n")
            }
        }
        catch let error
        {
            print(error)
        }
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
        
        do {
            let jsonSubscribeMsg = try JSONEncoder().encode(msg)
            let jsonString = String(data: jsonSubscribeMsg, encoding: .utf8)
            if jsonString != nil{
                tcpSocket.write(stringToSend: jsonString! + "\r\n")
            }
        }
        catch let error
        {
            print(error)
        }
    }
    
    func GetButtonProtocol() -> ButtonPressed {
        return self
    }
}

