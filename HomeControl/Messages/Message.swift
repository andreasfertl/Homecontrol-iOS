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
    
    enum CodingKeys: String, CodingKey {
        case Destination
        case Source
        case RemoteHandle
        case Command
        case CommandType
        case Value
    }
}

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
                    try container.encode(subscribeToCommandType, forKey: .Value)
                }
            }
        }
        catch
        {
            
        }

//        var additionalInfo = container.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
//        try additionalInfo.encode(elevation, forKey: .elevation)
    }
    
}
