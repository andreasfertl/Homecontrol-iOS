//
//  ProgramManager.swift
//  HomeControl
//
//  Created by Andreas Fertl on 10.02.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation

class ProgramManager {

    var tcpSocket: TCPSocket
    
    init(receiver: ReceiveMsgDelegate) {
        tcpSocket = TCPSocket(receiver: receiver)
        tcpSocket.setupNetworkCommunication(connectIp: "10.0.0.4", connectPort: 5005)
        
        
        //subscribe to data
        let msg = Msg(destId: Destination.Server, srcId: Destination.NotSet, remoteHandle: 0, command: Command.set, commandType: CommandType.Subscribe, value: CommandType.MandolynSensor)
        
        do {
            let jsonSubscribeMsg = try JSONEncoder().encode(msg)
            let jsonString = String(data: jsonSubscribeMsg, encoding: .ascii)
            if jsonString != nil{
                tcpSocket.write(stringToSend: jsonString! + "\r\n")
            }
        }
        catch let error
        {
            print(error)
        }
    }
}

