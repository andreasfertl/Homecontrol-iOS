//
//  ConfiguredMessageSensors.swift
//  HomeControl
//
//  Created by Andreas Fertl on 21.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation

struct ConfiguredTempHumiditySensors : Codable{
    let InternalId: Int
    let Name: String
    let type: String = "Messanger.ConfiguredTempHumiditySensors, Messanger"
    
    enum CodingKeys: String, CodingKey {
        case InternalId
        case Name
        case type = "$type"
    }
}

struct ConfiguredMessageSensors : Codable{
    var tempHumiditySensors : [ConfiguredTempHumiditySensors]?
    let type: String = "Messanger.ConfiguredMessageSensors, Messanger"

    enum CodingKeys: String, CodingKey {
        case tempHumiditySensors
        case type = "$type"
    }
}

