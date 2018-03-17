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
        
        //Destination.Server, srcId, Command.Set, CommandType.Subscribe, type
        
        
        
        
        //tcpSocket.write(stringToSend: "This is a test")
        //tcpSocket.write(stringToSend: "{\"$type\":\"Messanger.SubscribeToMsg, Messanger\",\"Value\":17,\"Destination\":1,\"Source\":17,\"RemoteHandle\":0,\"Command\":0,\"CommandType\":0,\"ObjectType\":\"Messanger.CommandType, Messanger, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null\"}")
        
        //HomeControlTableViewController.AddCellString("Testme")
        
        //let lightmsg = LightMessage(Id: 127, lightState: LightState.On, Value: "LightMessage")
//        {"$type":"Messanger.SubscriberMsg, Messanger","Value":{"$type":"Messanger.LightMessage, Messanger","ID":17,"LightState":1},"Destination":4294967294,"Source":0,"RemoteHandle":0,"Command":0,"CommandType":5,"ObjectType":"Messanger.LightMessage, Messanger, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null"}

        
//        do
//        {
//            let jsonLightMsg = try JSONEncoder().encode(lightmsg)
//            let jsonString = String(data: jsonLightMsg, encoding: .ascii)
//            if  jsonString != nil
//            {
//                print(jsonString!)
//            }
//            else
//            {
//                print("error")
//            }
//        }
//        catch let error
//        {
//            print(error)
//        }
        
        
        let stringme = "{\"$type\":\"Messanger.SubscriberMsg, Messanger\",\"Value\":{\"$type\":\"Messanger.MandolynSensor, Messanger\",\"Temp\":22.14,\"Humidity\":75,\"Id\":21},\"Destination\":4294967294,\"Source\":17,\"RemoteHandle\":0,\"Command\":0,\"CommandType\":17,\"ObjectType\":\"Messanger.MandolynSensor, Messanger, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null\"}"
        
    
        do {
            let jsonConverted = try JSONDecoder().decode(Msg.self, from: stringme.data(using: .ascii)!)
            let sensor = jsonConverted.value as? MandolynSensor
            if sensor?.Humidity == 75
            {
                print("75")
            }
            else
            {
                print("?")
            }
        }
        catch let error
        {
            print(error)
        }
        
        
        
        
    }
}

