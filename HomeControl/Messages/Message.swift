//
//  Message.swift
//  HomeControl
//
//  Created by Andreas Fertl on 25.02.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation


struct Msg: Codable {
    let destId: Destination?
    let srcId: Destination?
    let remoteHandle: Int?
    let command: Command?
    let commandType: CommandType?
    let value: Any?
    let type: String = "Messanger.Msg, Messanger"
    let objectType: String = "Messanger.CommandType, Messanger, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null"
    
    enum CodingKeys: String, CodingKey {
        case Destination
        case Source
        case RemoteHandle
        case Command
        case CommandType
        case Value
        case type = "$type"
        case ObjectType
    }
}

//functions
extension Msg {
    
    static func genSubscribeTo(commandType: CommandType) -> Msg {
        return Msg(destId: Destination.Server, srcId: Destination.NotSet, remoteHandle: 0, command: Command.set, commandType: CommandType.Subscribe, value: commandType)
    }
    
    static func genSubscribeToJsonMsg(commandType: CommandType) -> String? {
        let msg = genSubscribeTo(commandType: commandType)
        
        do {
            let jsonSubscribeMsg = try JSONEncoder().encode(msg)
            return String(data: jsonSubscribeMsg, encoding: .utf8)
        }
        catch let error
        {
            print(error)
        }
        return nil
    }

}


//Decode / Encode Json
extension Msg {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        destId = try values.decodeIfPresent(Destination.self, forKey: .Destination)
        srcId  = try values.decodeIfPresent(Destination.self, forKey: .Source)
        remoteHandle = try values.decodeIfPresent(Int.self, forKey: .RemoteHandle)
        command = try values.decodeIfPresent(Command.self, forKey: .Command)
        commandType = try values.decodeIfPresent(CommandType.self, forKey: .CommandType)

        do {
            if commandType == .LightControl {
                let nestedValues = try values.nestedContainer(keyedBy: LightMessage.CodingKeys.self, forKey: .Value)
                let Id = try nestedValues.decode(Int.self, forKey: LightMessage.CodingKeys.Id)
                let lightState = try nestedValues.decode(LightState.self, forKey: LightMessage.CodingKeys.lightState)
                value = LightMessage(Id: Id, lightState: lightState)
            } else if commandType == CommandType.MandolynSensor {
                let nestedValues = try values.nestedContainer(keyedBy: MandolynSensor.CodingKeys.self, forKey: .Value)
                let Humidity = try nestedValues.decode(Int.self, forKey: MandolynSensor.CodingKeys.Humidity)
                let Id = try nestedValues.decode(Int.self, forKey: MandolynSensor.CodingKeys.Id)
                let Temp = try nestedValues.decode(Float.self, forKey: MandolynSensor.CodingKeys.Temp)
                value = MandolynSensor(Id: Id, Temp: Temp, Humidity: Humidity)
            } else if commandType == CommandType.TempMessage {
                let nestedValues = try values.nestedContainer(keyedBy: TempMessage.CodingKeys.self, forKey: .Value)
                let Humidity = try nestedValues.decode(Int.self, forKey: TempMessage.CodingKeys.Humidity)
                let Id = try nestedValues.decode(Int.self, forKey: TempMessage.CodingKeys.InternalId)
                let Temp = try nestedValues.decode(Float.self, forKey: TempMessage.CodingKeys.Temp)
                let Name = try nestedValues.decode(String.self, forKey: TempMessage.CodingKeys.Name)
                value = TempMessage(InternalId: Id, Temp: Temp, Humidity: Humidity, Name: Name)
            } else if commandType == CommandType.ConfigurationMessage {
                let configData = try values.decode(ConfiguredMessageBasic.self, forKey: .Value)
                if configData.type == "Messanger.ConfiguredMessageSensors, Messanger" {
                    value = try values.decode(ConfiguredMessageSensors.self, forKey: .Value)
                } else if configData.type == "Messanger.ConfiguredLights, Messanger" {
                    value = try values.decode(ConfiguredLights.self, forKey: .Value)
                }
                else {
                    value = nil
                }
            } else {
                value = nil
            }
        }
        catch {
            value = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(destId, forKey: .Destination)
            try container.encode(srcId, forKey: .Source)
            try container.encode(remoteHandle, forKey: .RemoteHandle)
            try container.encode(command, forKey: .Command)
            try container.encode(commandType, forKey: .CommandType)
            
            if commandType == CommandType.Subscribe {
                if let subscribeToCommandType = value as? CommandType {
                    try container.encode("Messanger.SubscribeToMsg, Messanger", forKey: .type)
                    try container.encode(objectType, forKey: .ObjectType)
                    try container.encode(subscribeToCommandType, forKey: .Value)
                }
            } else if commandType == .LightControl {
                if let lightMessage = value as? LightMessage {
                    var nestedValues = container.nestedContainer(keyedBy: LightMessage.CodingKeys.self, forKey: .Value)
                    try nestedValues.encode(lightMessage.type, forKey: LightMessage.CodingKeys.type)
                    try nestedValues.encode(lightMessage.Id, forKey: LightMessage.CodingKeys.Id)
                    try nestedValues.encode(lightMessage.lightState, forKey: LightMessage.CodingKeys.lightState)
                }
            } else if commandType == .ConfigurationMessage {
                if let configuredMessageSensors = value as? ConfiguredMessageSensors {
                    var nestedValues = container.nestedContainer(keyedBy: ConfiguredMessageSensors.CodingKeys.self, forKey: .Value)
                    try nestedValues.encode(configuredMessageSensors.type, forKey: ConfiguredMessageSensors.CodingKeys.type)
                    try nestedValues.encode(configuredMessageSensors.tempHumiditySensors, forKey: ConfiguredMessageSensors.CodingKeys.tempHumiditySensors)
                }
                if let configuredLights = value as? ConfiguredLights {
                    var nestedValues = container.nestedContainer(keyedBy: ConfiguredLights.CodingKeys.self, forKey: .Value)
                    try nestedValues.encode(configuredLights.type, forKey: ConfiguredLights.CodingKeys.type)
                    try nestedValues.encode(configuredLights.lights, forKey: ConfiguredLights.CodingKeys.lights)
                }
            }
        }
        catch
        {
            
        }
    }
}
